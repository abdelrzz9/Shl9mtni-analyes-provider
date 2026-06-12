import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/history_entry.dart';
import '../../domain/repositories/history_repository.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  static const _key = 'math_app_history';

  @override
  Future<List<HistoryEntry>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list.map((e) => HistoryEntry(
      id: e['id'],
      feature: e['feature'],
      input: e['input'],
      result: e['result'],
      timestamp: DateTime.parse(e['timestamp']),
      isFavorite: e['isFavorite'] ?? false,
    )).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  @override
  Future<void> addEntry(HistoryEntry entry) async {
    final entries = await getHistory();
    entries.insert(0, entry);
    await _save(entries);
  }

  @override
  Future<void> deleteEntry(String id) async {
    final entries = await getHistory();
    entries.removeWhere((e) => e.id == id);
    await _save(entries);
  }

  @override
  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  @override
  Future<void> toggleFavorite(String id) async {
    final entries = await getHistory();
    final index = entries.indexWhere((e) => e.id == id);
    if (index != -1) {
      entries[index] = entries[index].copyWith(isFavorite: !entries[index].isFavorite);
      await _save(entries);
    }
  }

  Future<void> _save(List<HistoryEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(entries.map((e) => {
      'id': e.id,
      'feature': e.feature,
      'input': e.input,
      'result': e.result,
      'timestamp': e.timestamp.toIso8601String(),
      'isFavorite': e.isFavorite,
    }).toList());
    await prefs.setString(_key, data);
  }
}
