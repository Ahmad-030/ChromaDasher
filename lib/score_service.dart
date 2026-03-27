import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ScoreEntry {
  final int score;
  final String mode;
  final String date;

  ScoreEntry(this.score, this.mode, this.date);

  Map<String, dynamic> toJson() => {
    'score': score,
    'mode': mode,
    'date': date,
  };

  factory ScoreEntry.fromJson(Map<String, dynamic> json) =>
      ScoreEntry(json['score'], json['mode'], json['date']);
}

class ScoreService {
  static const _key = 'chroma_scores';
  static const _maxEntries = 20;

  /// Load all scores, sorted descending.
  static Future<List<ScoreEntry>> loadScores() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    return raw
        .map((s) => ScoreEntry.fromJson(jsonDecode(s)))
        .toList()
      ..sort((a, b) => b.score.compareTo(a.score));
  }

  /// Save a new score. Keeps only the top [_maxEntries].
  static Future<void> saveScore(int score, String mode) async {
    final prefs = await SharedPreferences.getInstance();
    final scores = await loadScores();

    final now = DateTime.now();
    final dateStr =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';

    scores.add(ScoreEntry(score, mode.toUpperCase(), dateStr));
    scores.sort((a, b) => b.score.compareTo(a.score));

    final trimmed = scores.take(_maxEntries).toList();
    final encoded = trimmed.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_key, encoded);
  }

  /// Get the all-time best score (0 if none).
  static Future<int> getBestScore() async {
    final scores = await loadScores();
    return scores.isEmpty ? 0 : scores.first.score;
  }

  /// Wipe everything.
  static Future<void> clearScores() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}