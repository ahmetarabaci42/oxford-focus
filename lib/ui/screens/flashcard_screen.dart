import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:oxford_focus/data/local/database_helper.dart';
import 'package:oxford_focus/data/models/word.dart';
import 'package:oxford_focus/providers/auth_provider.dart';
import 'package:oxford_focus/providers/word_providers.dart';
import 'package:oxford_focus/providers/stats_provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shared_preferences/shared_preferences.dart';

final ttsProvider = Provider<FlutterTts>((ref) {
  final tts = FlutterTts();
  tts.setLanguage('en-US');
  tts.setSpeechRate(0.48);
  tts.setVolume(1.0);
  tts.setPitch(1.0);
  return tts;
});

// ─── Oxford level helper ──────────────────────────────────────────────────────

String _oxfordLevel(int categoryId) {
  if (categoryId <= 1) return 'A1';
  if (categoryId <= 2) return 'A2';
  if (categoryId <= 3) return 'B1';
  return 'B2';
}

Color _levelColor(String level) {
  switch (level) {
    case 'A1':
      return const Color(0xFF69FF47);
    case 'A2':
      return const Color(0xFF00E5FF);
    case 'B1':
      return const Color(0xFFFFD740);
    case 'B2':
      return const Color(0xFFFF4081);
    default:
      return Colors.grey;
  }
}

// Part-of-speech badge color
Color _posColor(String pos) {
  switch (pos.toLowerCase()) {
    case 'noun':
      return const Color(0xFF00E5FF);
    case 'verb':
      return const Color(0xFFFF4081);
    case 'adjective':
    case 'adj':
      return const Color(0xFFFFD740);
    case 'adverb':
    case 'adv':
      return const Color(0xFF69FF47);
    default:
      return Colors.grey;
  }
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class FlashcardScreen extends ConsumerStatefulWidget {
  const FlashcardScreen({super.key});

  @override
  ConsumerState<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends ConsumerState<FlashcardScreen> {
  int _currentIndex = 0;
  bool _isFlipped = false;
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  double _dragStartX = 0;
  bool _hasLoadedSavedIndex = false;
  List<String>? _loadedWordsIds;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  Future<void> _loadSavedIndex(String userId, List<String> currentIds) async {
    final prefs = await SharedPreferences.getInstance();
    final savedHash = prefs.getString('flashcard_words_hash_$userId') ?? '';
    final currentHash = currentIds.join(',');
    
    if (savedHash == currentHash) {
      final savedIndex = prefs.getInt('flashcard_index_$userId') ?? 0;
      if (savedIndex < currentIds.length) {
        if (mounted) {
          setState(() {
            _currentIndex = savedIndex;
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
          _currentIndex = 0;
        });
      }
      await prefs.setString('flashcard_words_hash_$userId', currentHash);
      await prefs.setInt('flashcard_index_$userId', 0);
    }
  }

  Future<void> _saveIndex(String userId, int index, List<String> currentIds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('flashcard_words_hash_$userId', currentIds.join(','));
    await prefs.setInt('flashcard_index_$userId', index);
  }

  void _handleResult(String result, List<Word> words, String userId) async {
    // Record to DB
    await DatabaseHelper().recordStudySession(
      userId: userId,
      wordId: words[_currentIndex].id,
      result: result,
    );

    // Show label snack
    final label = result == 'know'
        ? '✅ Got It!'
        : result == 'hard'
            ? '🟡 Keep Trying'
            : '🔴 Added to Review';
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          duration: const Duration(milliseconds: 800),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
        ),
      );
    }

    // Move to next
    if (_currentIndex < words.length - 1) {
      setState(() {
        _currentIndex++;
        _isFlipped = false;
      });
      _saveIndex(userId, _currentIndex, words.map((w) => w.id).toList());
      // Invalidate stats
      ref.invalidate(statsProvider);
    } else {
      // Session complete
      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: const Color(0xFF1E1E1E),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('🎉 Session Complete!',
                style: TextStyle(color: Colors.white)),
            content: Text(
              'You studied ${words.length} words. Keep it up!',
              style: TextStyle(color: Colors.grey[400]),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _currentIndex = 0;
                    _isFlipped = false;
                  });
                  _saveIndex(userId, 0, words.map((w) => w.id).toList());
                },
                child: const Text('Study Again'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Done'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final wordsAsync = ref.watch(currentWeekWordsProvider);
    final userIdAsync = ref.watch(currentUserIdProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Study'),
        automaticallyImplyLeading: false,
      ),
      body: wordsAsync.when(
        loading: () => _buildShimmer(),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $e', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(currentWeekWordsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (words) {
          if (words.isEmpty) {
            return _buildEmptyState();
          }
          final userId =
              userIdAsync.when(data: (id) => id, loading: () => 'local_user', error: (_, __) => 'local_user');

          if (!_hasLoadedSavedIndex) {
            _hasLoadedSavedIndex = true;
            _loadedWordsIds = words.map((w) => w.id).toList();
            _loadSavedIndex(userId, _loadedWordsIds!);
          } else {
            final currentIds = words.map((w) => w.id).toList();
            if (_loadedWordsIds == null || !_listEquals(_loadedWordsIds!, currentIds)) {
              _loadedWordsIds = currentIds;
              _currentIndex = 0;
              _saveIndex(userId, 0, currentIds);
            }
          }

          if (_currentIndex >= words.length) {
            _currentIndex = 0;
          }

          return _buildStudyView(words, userId);
        },
      ),
    );
  }

  Widget _buildStudyView(List<Word> words, String userId) {
    final progress = (_currentIndex + 1) / words.length;

    return SafeArea(
      child: Column(
        children: [
          // Progress bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_currentIndex + 1} / ${words.length}',
                      style: TextStyle(color: Colors.grey[500], fontSize: 13),
                    ),
                    Text(
                      '${(progress * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(
                          color: Color(0xFF00E5FF),
                          fontSize: 13,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 5,
                    backgroundColor: Colors.grey[800],
                    valueColor: const AlwaysStoppedAnimation(Color(0xFF00E5FF)),
                  ),
                ),
              ],
            ),
          ),

          // Card area (gesture detector for swipe)
          Expanded(
            child: GestureDetector(
              onHorizontalDragStart: (d) => _dragStartX = d.globalPosition.dx,
              onHorizontalDragEnd: (d) {
                final dx = d.globalPosition.dx - _dragStartX;
                if (dx < -60) {
                  // Swipe left = don't know
                  if (!_isFlipped) return;
                  _handleResult('dont_know', words, userId);
                } else if (dx > 60) {
                  // Swipe right = got it
                  if (!_isFlipped) return;
                  _handleResult('know', words, userId);
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: _FlipCard(
                  word: words[_currentIndex],
                  isFlipped: _isFlipped,
                  onTap: () => setState(() => _isFlipped = !_isFlipped),
                ),
              ),
            ),
          ),

          // Swipe hint
          if (!_isFlipped)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'Tap card to reveal answer',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'Swipe ← Don\'t Know  •  Swipe → Got It',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ),

          // Action buttons (only shown after flip)
          AnimatedOpacity(
            opacity: _isFlipped ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 250),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      label: "Don't Know",
                      emoji: '🔴',
                      color: const Color(0xFFFF4081),
                      onTap: _isFlipped
                          ? () => _handleResult('dont_know', words, userId)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ActionButton(
                      label: 'Hard',
                      emoji: '🟡',
                      color: const Color(0xFFFFD740),
                      onTap: _isFlipped
                          ? () => _handleResult('hard', words, userId)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ActionButton(
                      label: 'Got It',
                      emoji: '🟢',
                      color: const Color(0xFF69FF47),
                      onTap: _isFlipped
                          ? () => _handleResult('know', words, userId)
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.style_outlined, size: 80, color: Colors.grey[700]),
          const SizedBox(height: 24),
          Text(
            'No words loaded yet',
            style: TextStyle(
                color: Colors.grey[400],
                fontSize: 20,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Text(
            'Go to Home and tap the upload button\nto seed the Oxford 3000 words.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600], fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Shimmer.fromColors(
        baseColor: const Color(0xFF2A2A2A),
        highlightColor: const Color(0xFF3A3A3A),
        child: Column(
          children: [
            Container(
                height: 8,
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4))),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Flip Card Widget ─────────────────────────────────────────────────────────

class _FlipCard extends StatefulWidget {
  final Word word;
  final bool isFlipped;
  final VoidCallback onTap;

  const _FlipCard({
    required this.word,
    required this.isFlipped,
    required this.onTap,
  });

  @override
  State<_FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<_FlipCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _anim = Tween<double>(begin: 0, end: math.pi).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(_FlipCard old) {
    super.didUpdateWidget(old);
    if (widget.isFlipped != old.isFlipped) {
      if (widget.isFlipped) {
        _ctrl.forward();
      } else {
        _ctrl.reverse();
      }
    }
    // Word changed (new card) — reset
    if (widget.word.id != old.word.id) {
      _ctrl.reset();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _anim,
        builder: (context, child) {
          final angle = _anim.value;
          final isFrontSide = angle < math.pi / 2;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            child: isFrontSide
                ? _buildFront()
                : Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(math.pi),
                    child: _buildBack(),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildFront() {
    final pos = widget.word.partOfSpeech.isNotEmpty ? widget.word.partOfSpeech : _inferPOS(widget.word.english);
    return _CardShell(
      gradient: const LinearGradient(
        colors: [Color(0xFF1E1E2E), Color(0xFF252535)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderColor: const Color(0xFF00E5FF).withOpacity(0.3),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // POS badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _posColor(pos).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _posColor(pos).withOpacity(0.5)),
                  ),
                  child: Text(
                    pos.toUpperCase(),
                    style: TextStyle(
                        color: _posColor(pos),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5),
                  ),
                ),
                const SizedBox(height: 24),
                // English word
                Text(
                  widget.word.english,
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.1,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                // IPA (real or simulated)
                Text(
                  widget.word.ipa.isNotEmpty ? widget.word.ipa : _simulateIPA(widget.word.english),
                  style: TextStyle(
                      color: Colors.grey[500], fontSize: 18, fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.touch_app_rounded, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 6),
                    Text('Tap to flip',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: _SpeakerButton(text: widget.word.english),
          ),
        ],
      ),
    );
  }

  Widget _buildBack() {
    final level = _oxfordLevel(int.tryParse(widget.word.difficulty.length <= 2 ? widget.word.difficulty : '1') ?? 1);
    final examples = widget.word.example1.isNotEmpty
        ? [
            {'english': widget.word.example1, 'turkish': widget.word.example1Tr},
            if (widget.word.example2.isNotEmpty)
              {'english': widget.word.example2, 'turkish': widget.word.example2Tr},
          ]
        : _generateExamples(widget.word.english, widget.word.turkish);

    return _CardShell(
      gradient: const LinearGradient(
        colors: [Color(0xFF1A2035), Color(0xFF1E2840)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderColor: const Color(0xFFFF4081).withOpacity(0.3),
      child: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Oxford level badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _levelColor(level).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: _levelColor(level).withOpacity(0.5)),
                  ),
                  child: Text(
                    'Oxford $level',
                    style: TextStyle(
                        color: _levelColor(level),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5),
                  ),
                ),
                const SizedBox(height: 20),
                // Turkish meaning
                Text(
                  widget.word.turkish,
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00E5FF),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                // Divider
                Divider(color: Colors.grey[800], thickness: 1),
                const SizedBox(height: 16),
                // Example sentences
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Examples',
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5),
                  ),
                ),
                const SizedBox(height: 10),
                ...examples.map((ex) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('›',
                              style: TextStyle(
                                  color: Color(0xFFFF4081),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ex['english']!,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 14, height: 1.4, fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  ex['turkish']!,
                                  style: TextStyle(
                                      color: const Color(0xFF00E5FF).withOpacity(0.85),
                                      fontSize: 12.5,
                                      fontStyle: FontStyle.italic,
                                      height: 1.3),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: _SpeakerButton(text: widget.word.english),
          ),
        ],
      ),
    );
  }

  // Very lightweight helpers – IPA and example generation without API calls
  String _simulateIPA(String word) {
    // Returns a plausible IPA-looking transcription
    return '/${word.toLowerCase()}/';
  }

  String _inferPOS(String word) {
    if (word.endsWith('ly')) return 'adverb';
    if (word.endsWith('tion') ||
        word.endsWith('ness') ||
        word.endsWith('ment') ||
        word.endsWith('ity')) return 'noun';
    if (word.endsWith('ful') ||
        word.endsWith('ive') ||
        word.endsWith('able') ||
        word.endsWith('ous')) return 'adjective';
    if (word.endsWith('ize') ||
        word.endsWith('ise') ||
        word.endsWith('ate') ||
        word.endsWith('ify')) return 'verb';
    return 'noun';
  }

  List<Map<String, String>> _generateExamples(String eng, String tr) {
    final pos = _inferPOS(eng);
    switch (pos.toLowerCase()) {
      case 'verb':
        return [
          {
            'english': 'We should $eng this problem immediately.',
            'turkish': 'Bu sorunu hemen $tr gerekiyor.'
          },
          {
            'english': 'She made an effort to $eng the new method.',
            'turkish': 'Yeni yöntemi $tr için çaba gösterdi.'
          },
        ];
      case 'adjective':
      case 'adj':
        return [
          {
            'english': 'It was a $eng day for everyone.',
            'turkish': 'Herkes için $tr bir gündü.'
          },
          {
            'english': 'He wants to buy a $eng car next year.',
            'turkish': 'Gelecek yıl $tr bir araba satın almak istiyor.'
          },
        ];
      case 'adverb':
      case 'adv':
        return [
          {
            'english': 'She managed to complete the task $eng.',
            'turkish': 'Görevi $tr tamamlamayı başardı.'
          },
          {
            'english': 'Please follow these steps $eng.',
            'turkish': 'Lütfen bu adımları $tr takip edin.'
          },
        ];
      case 'noun':
      default:
        return [
          {
            'english': 'This is a very important $eng for our team.',
            'turkish': 'Bu ekibimiz için çok önemli bir $tr.'
          },
          {
            'english': 'The final success depends on this $eng.',
            'turkish': 'Nihai başarı bu $tr konusuna bağlıdır.'
          },
        ];
    }
  }
}

// ─── Card shell ───────────────────────────────────────────────────────────────

class _CardShell extends StatelessWidget {
  final Widget child;
  final LinearGradient gradient;
  final Color borderColor;

  const _CardShell({
    required this.child,
    required this.gradient,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: borderColor.withOpacity(0.2),
            blurRadius: 30,
            spreadRadius: 2,
          ),
        ],
      ),
      padding: const EdgeInsets.all(28),
      child: child,
    );
  }
}

// ─── Action button ────────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final String label;
  final String emoji;
  final Color color;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.label,
    required this.emoji,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.4)),
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Speaker Button ──────────────────────────────────────────────────────────

class _SpeakerButton extends ConsumerWidget {
  final String text;

  const _SpeakerButton({required this.text});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {}, // Prevent card flip propagation
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: const Icon(Icons.volume_up_rounded, color: Color(0xFF00E5FF), size: 26),
          onPressed: () async {
            final tts = ref.read(ttsProvider);
            await tts.stop();
            await tts.speak(text);
          },
        ),
      ),
    );
  }
}
