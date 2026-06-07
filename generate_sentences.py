import os
import json
import time
import sys
from google import genai
from google.genai import types
from pydantic import BaseModel
from typing import List

# Setup client
api_key = os.environ.get('GOOGLE_API_KEY')
if not api_key:
    print("Error: GOOGLE_API_KEY environment variable not found.")
    sys.exit(1)

client = genai.Client(api_key=api_key)

# Pydantic models for structured output
class WordItem(BaseModel):
    id: int
    ipa: str
    pos: str
    ex1: str
    ex1_tr: str
    ex2: str
    ex2_tr: str

class WordsResponse(BaseModel):
    words: List[WordItem]

def load_data(file_path):
    if os.path.exists(file_path):
        with open(file_path, 'r', encoding='utf-8') as f:
            return json.load(f)
    return {"words": []}

def save_data(file_path, data):
    with open(file_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

def process_batch(batch_idx, batch):
    print(f"Starting batch {batch_idx} (Size: {len(batch)})...", flush=True)
    prompt_words = [{'id': w['id'], 'ENG': w['ENG'], 'TR': w['TR']} for w in batch]
    
    prompt = f"""
You are a lexicographer helping to compile the Oxford 3000 vocabulary list.
For each of the following words (with English word/phrase and Turkish translation), generate:
1. An accurate IPA pronunciation.
2. The correct Part of Speech (noun, verb, adjective, adverb, preposition, conjunction, pronoun, determiner, etc.).
3. A natural, common English example sentence using the word.
4. The accurate Turkish translation of that example sentence.
5. A second natural, common English example sentence using the word.
6. The accurate Turkish translation of that second example sentence.

Format your output EXACTLY as a JSON array matching the response schema.

List of words to process:
{json.dumps(prompt_words, ensure_ascii=False)}
"""
    
    retries = 5
    backoff = 4.0
    
    while retries > 0:
        try:
            response = client.models.generate_content(
                model='gemini-2.5-flash',
                contents=prompt,
                config=types.GenerateContentConfig(
                    response_mime_type='application/json',
                    response_schema=WordsResponse
                )
            )
            
            res_data = json.loads(response.text)
            generated_words = res_data.get('words', [])
            
            if not generated_words:
                raise ValueError("Received empty list of words from API")
                
            print(f"Batch {batch_idx} completed successfully ({len(generated_words)} items).", flush=True)
            return generated_words
            
        except Exception as e:
            retries -= 1
            sleep_time = backoff
            if "RESOURCE_EXHAUSTED" in str(e) or "429" in str(e):
                print(f"Rate limit hit in batch {batch_idx}. Sleeping for 60 seconds...", flush=True)
                sleep_time = 60.0
            else:
                print(f"Error in batch {batch_idx}: {e}. Retrying in {sleep_time:.1f}s... (Retries left: {retries})", flush=True)
            time.sleep(sleep_time)
            backoff *= 2.0
            
    print(f"FAILED to process batch {batch_idx} after multiple retries.", flush=True)
    return []

def main():
    json_path = 'oxford_3000.json'
    data = load_data(json_path)
    words_list = data.get('words', [])
    total_words = len(words_list)
    print(f"Loaded {total_words} words from {json_path}", flush=True)
    
    # Filter words that need generation
    words_to_process = []
    for w in words_list:
        if 'ex1' not in w or not w['ex1']:
            words_to_process.append(w)
            
    print(f"Words remaining to process: {len(words_to_process)}", flush=True)
    if not words_to_process:
        print("All words are already processed!", flush=True)
        return

    # Chunk into batches of 40 words
    batch_size = 40
    batches = [words_to_process[i:i+batch_size] for i in range(0, len(words_to_process), batch_size)]
    
    word_map = {w['id']: w for w in words_list}
    
    print("Starting sequential execution...", flush=True)
    for i, batch in enumerate(batches):
        batch_idx = i + 1
        results = process_batch(batch_idx, batch)
        if results:
            for res_word in results:
                wid = res_word['id']
                if wid in word_map:
                    word_map[wid]['ipa'] = res_word['ipa']
                    word_map[wid]['pos'] = res_word['pos']
                    word_map[wid]['ex1'] = res_word['ex1']
                    word_map[wid]['ex1_tr'] = res_word['ex1_tr']
                    word_map[wid]['ex2'] = res_word['ex2']
                    word_map[wid]['ex2_tr'] = res_word['ex2_tr']
            
            save_data(json_path, data)
            print(f"Saved progress after batch {batch_idx}.", flush=True)
        
        # Sleep 13 seconds between batches to strictly stay under 5 RPM limit
        if batch_idx < len(batches):
            print("Sleeping 13 seconds to respect rate limits...", flush=True)
            time.sleep(13)

    print("\nGeneration run completed! Checking results...", flush=True)
    data = load_data(json_path)
    missing = sum(1 for w in data.get('words', []) if 'ex1' not in w or not w['ex1'])
    print(f"Finished. Words remaining without sentences: {missing}/{total_words}", flush=True)

if __name__ == '__main__':
    main()
