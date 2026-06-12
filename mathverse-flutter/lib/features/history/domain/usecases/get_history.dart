import '../entities/history_entry.dart';
import '../repositories/history_repository.dart';

class GetHistory {
  final HistoryRepository repository;

  GetHistory(this.repository);

  Future<List<HistoryEntry>> call() => repository.getHistory();
}

class AddHistoryEntry {
  final HistoryRepository repository;

  AddHistoryEntry(this.repository);

  Future<void> call(HistoryEntry entry) => repository.addEntry(entry);
}

class DeleteHistoryEntry {
  final HistoryRepository repository;

  DeleteHistoryEntry(this.repository);

  Future<void> call(String id) => repository.deleteEntry(id);
}

class ClearHistory {
  final HistoryRepository repository;

  ClearHistory(this.repository);

  Future<void> call() => repository.clearHistory();
}

class ToggleFavorite {
  final HistoryRepository repository;

  ToggleFavorite(this.repository);

  Future<void> call(String id) => repository.toggleFavorite(id);
}
