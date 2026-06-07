import json
import urllib.request
import urllib.parse
import urllib.error
import time
import sys

TEMPLATES = {
    'verb': [
        "You should {word} the instructions carefully.",
        "They decided to {word} the new proposal."
    ],
    'noun': [
        "This is an interesting {word} to study.",
        "We need to find a better {word} for this."
    ],
    'adjective': [
        "It was a {word} moment for all of us.",
        "The results of the test were {word}."
    ],
    'adverb': [
        "She performed her duties {word}.",
        "He walked {word} to the classroom."
    ],
    'default': [
        "Can you explain the meaning of {word}?",
        "This {word} is very common in English."
    ]
}

def translate(text):
    if not text:
        return ""
    try:
        url = 'https://translate.googleapis.com/translate_a/single?client=gtx&sl=en&tl=tr&dt=t&q=' + urllib.parse.quote(text)
        req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
        with urllib.request.urlopen(req, timeout=10) as r:
            res = json.loads(r.read().decode('utf-8'))
            return ''.join([item[0] for item in res[0] if item[0]])
    except Exception as e:
        print(f"Translation error: {e}", flush=True)
        return ""

def fetch_dictionary_data(word):
    url = f'https://api.dictionaryapi.dev/api/v2/entries/en/{urllib.parse.quote(word)}'
    req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
    try:
        with urllib.request.urlopen(req, timeout=10) as r:
            entries = json.loads(r.read().decode('utf-8'))
            if not entries:
                return None
            entry = entries[0]
            
            # Extract IPA
            ipa = entry.get('phonetic', '')
            if not ipa and entry.get('phonetics'):
                for p in entry['phonetics']:
                    if p.get('text'):
                        ipa = p['text']
                        break
                        
            # Extract POS and Examples
            pos = ''
            examples = []
            for m in entry.get('meanings', []):
                if not pos:
                    pos = m.get('partOfSpeech', '')
                for d in m.get('definitions', []):
                    if d.get('example') and d['example'] not in examples:
                        examples.append(d['example'])
                        
            return {
                'ipa': ipa,
                'pos': pos,
                'examples': examples
            }
    except Exception as e:
        return None

def main():
    json_path = 'oxford_3000.json'
    
    # Load JSON
    try:
        with open(json_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
    except Exception as e:
        print(f"Error loading {json_path}: {e}", flush=True)
        sys.exit(1)
        
    words_list = data.get('words', [])
    total_words = len(words_list)
    
    # Find missing words
    missing_words = [w for w in words_list if 'ex1' not in w or not w['ex1']]
    print(f"Loaded {total_words} words. Missing sentences: {len(missing_words)}", flush=True)
    
    if not missing_words:
        print("No missing words to process!", flush=True)
        return
        
    word_map = {w['id']: w for w in words_list}
    save_interval = 5
    processed_count = 0
    
    print("Starting generation using Free Dictionary API and Google Translate...", flush=True)
    
    for i, word_item in enumerate(missing_words):
        eng = word_item['ENG']
        tr_meaning = word_item['TR']
        
        print(f"[{i+1}/{len(missing_words)}] Processing: '{eng}'", flush=True)
        
        # 1. Fetch info
        dict_data = fetch_dictionary_data(eng)
        
        ipa = ""
        pos = word_item.get('pos', '')
        examples = []
        
        if dict_data:
            ipa = dict_data['ipa']
            if dict_data['pos']:
                pos = dict_data['pos']
            examples = dict_data['examples']
            
        # 2. Fallbacks if missing info
        if not pos:
            pos = 'noun'
            
        if len(examples) < 2:
            # Generate template sentences
            templates = TEMPLATES.get(pos, TEMPLATES['default'])
            needed = 2 - len(examples)
            for t_idx in range(needed):
                sentence = templates[t_idx % len(templates)].format(word=eng)
                if sentence not in examples:
                    examples.append(sentence)
                    
        # 3. Translate examples
        ex1 = examples[0] if len(examples) > 0 else f"This is the word {eng}."
        ex2 = examples[1] if len(examples) > 1 else f"We use {eng} in a sentence."
        
        ex1_tr = translate(ex1)
        ex2_tr = translate(ex2)
        
        # 4. Update word object
        wid = word_item['id']
        if wid in word_map:
            if ipa:
                word_map[wid]['ipa'] = ipa
            if pos:
                word_map[wid]['pos'] = pos
            word_map[wid]['ex1'] = ex1
            word_map[wid]['ex1_tr'] = ex1_tr
            word_map[wid]['ex2'] = ex2
            word_map[wid]['ex2_tr'] = ex2_tr
            
        processed_count += 1
        
        # Save progress at intervals
        if processed_count % save_interval == 0:
            with open(json_path, 'w', encoding='utf-8') as f:
                json.dump(data, f, indent=2, ensure_ascii=False)
            print(f"Saved progress after {processed_count} words.", flush=True)
            
        # Respect rate limits for public API
        time.sleep(0.9)
        
    # Final save
    with open(json_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
    print("\nGeneration completed and all progress saved successfully!", flush=True)

if __name__ == '__main__':
    main()
