import '../entities/history_entry.dart';

abstract class HistoryRepository {
  Future<List<HistoryEntry>> getHistory();
  Future<void> addEntry(HistoryEntry entry);
  Future<void> deleteEntry(String id);
  Future<void> clearHistory();
  Future<void> toggleFavorite(String id);
}
