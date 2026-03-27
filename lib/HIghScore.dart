// ═══════════════════════════════════════════════════════════════════════════
//  5.  HIGHSCORE SCREEN
// ═══════════════════════════════════════════════════════════════════════════

import 'package:chromadasher/theme.dart';
import 'package:flutter/material.dart';

class ScoreEntry {
  final int score;
  final String mode;
  final String date;
  ScoreEntry(this.score, this.mode, this.date);
}

class HighscoreScreen extends StatefulWidget {
  const HighscoreScreen({super.key});

  @override
  State<HighscoreScreen> createState() => _HighscoreScreenState();
}

class _HighscoreScreenState extends State<HighscoreScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entryCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 700))
    ..forward();

  // ── Replace with SharedPreferences load ──────────────────────────────
  // No dummy data — wire up SharedPreferences to populate this list.
  final List<ScoreEntry> _scores = [];
  // ─────────────────────────────────────────────────────────────────────

  Color _rankColor(int rank) {
    if (rank == 0) return CD.amber;
    if (rank == 1) return const Color(0xFFC0C0C0);
    if (rank == 2) return const Color(0xFFCD7F32);
    return CD.cyan.withOpacity(0.7);
  }

  void _confirmClear(BuildContext ctx) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: CD.bgMid,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title:
        Text('Clear All Scores?', style: CD.label(16, CD.red, ls: 1)),
        content: Text('This cannot be undone.',
            style: CD.body(13, Colors.white54)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('CANCEL',
                  style: CD.label(13, Colors.white54))),
          TextButton(
              onPressed: () {
                // TODO: SharedPreferences clear here
                setState(() => _scores.clear());
                Navigator.pop(ctx);
              },
              child: Text('CLEAR', style: CD.label(13, CD.red))),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CD.bg,
      body: NeonBg(
        child: SafeArea(
          child: Column(
            children: [
              // ── App bar ──
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: CD.neonBox(CD.cyan, r: 12),
                        child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: CD.cyan,
                            size: 18),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text('HIGHSCORES',
                          style: CD.glow(22, CD.violet, ls: 4)),
                    ),
                    if (_scores.isNotEmpty)
                      GestureDetector(
                        onTap: () => _confirmClear(context),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: CD.neonBox(CD.red, r: 12),
                          child: const Icon(
                              Icons.delete_outline_rounded,
                              color: CD.red,
                              size: 18),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Best score banner ──
              if (_scores.isNotEmpty)
                FadeTransition(
                  opacity: _entryCtrl,
                  child: Container(
                    margin:
                    const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    decoration: CD.neonBox(CD.amber, r: 18),
                    child: Row(
                      children: [
                        const Icon(Icons.emoji_events_rounded,
                            color: CD.amber, size: 36),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text('PERSONAL BEST',
                                style: CD.label(10,
                                    CD.amber.withOpacity(0.7),
                                    ls: 3)),
                            Text(
                              _scores.first.score
                                  .toString()
                                  .padLeft(6, '0'),
                              style: CD.glow(30, CD.amber, ls: 3),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: CD.neonBox(CD.amber, r: 8),
                          child: Text(_scores.first.mode,
                              style:
                              CD.label(11, CD.amber, ls: 1)),
                        ),
                      ],
                    ),
                  ),
                ),

              if (_scores.isNotEmpty) const SizedBox(height: 16),

              // ── Score list ──
              Expanded(
                child: _scores.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment:
                    MainAxisAlignment.center,
                    children: [
                      Icon(Icons.sports_esports_rounded,
                          color:
                          CD.cyan.withOpacity(0.3),
                          size: 72),
                      const SizedBox(height: 20),
                      Text('No scores yet',
                          style: CD.label(
                              16,
                              Colors.white
                                  .withOpacity(0.35))),
                      const SizedBox(height: 8),
                      Text(
                          'Play a game to see your best!',
                          style: CD.body(
                              13,
                              Colors.white
                                  .withOpacity(0.22))),
                    ],
                  ),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(
                      20, 4, 20, 24),
                  itemCount: _scores.length,
                  itemBuilder: (_, i) {
                    final entry = _scores[i];
                    final rc = _rankColor(i);

                    return FadeTransition(
                      opacity: CurvedAnimation(
                        parent: _entryCtrl,
                        curve: Interval(
                            (i * 0.08).clamp(0.0, 0.8),
                            1.0,
                            curve: Curves.easeOut),
                      ),
                      child: Container(
                        margin: const EdgeInsets.only(
                            bottom: 10),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 14),
                        decoration:
                        CD.neonBox(rc, r: 14),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 34,
                              child: Text(
                                '#${i + 1}',
                                style: CD.label(
                                    16, rc, ls: 1),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                entry.score
                                    .toString()
                                    .padLeft(6, '0'),
                                style: CD.label(17,
                                    Colors.white,
                                    ls: 1),
                              ),
                            ),
                            Container(
                              padding:
                              const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4),
                              decoration: BoxDecoration(
                                color: rc.withOpacity(0.12),
                                borderRadius:
                                BorderRadius.circular(
                                    6),
                                border: Border.all(
                                    color:
                                    rc.withOpacity(0.4),
                                    width: 1),
                              ),
                              child: Text(entry.mode,
                                  style: CD.label(
                                      9, rc, ls: 1)),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              entry.date,
                              style: CD.body(
                                  10,
                                  Colors.white
                                      .withOpacity(0.3)),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}