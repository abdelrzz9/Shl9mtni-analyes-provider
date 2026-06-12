import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/history_entry.dart';
import '../../domain/usecases/get_history.dart';

sealed class HistoryEvent extends Equatable {
  const HistoryEvent();

  @override
  List<Object?> get props => [];
}

final class LoadHistory extends HistoryEvent {
  const LoadHistory();
}

final class AddHistory extends HistoryEvent {
  final HistoryEntry entry;

  const AddHistory(this.entry);

  @override
  List<Object?> get props => [entry];
}

final class DeleteHistory extends HistoryEvent {
  final String id;

  const DeleteHistory(this.id);

  @override
  List<Object?> get props => [id];
}

final class ClearAllHistory extends HistoryEvent {
  const ClearAllHistory();
}

final class ToggleHistoryFavorite extends HistoryEvent {
  final String id;

  const ToggleHistoryFavorite(this.id);

  @override
  List<Object?> get props => [id];
}

sealed class HistoryState extends Equatable {
  const HistoryState();

  @override
  List<Object?> get props => [];
}

final class HistoryLoading extends HistoryState {
  const HistoryLoading();
}

final class HistoryLoaded extends HistoryState {
  final List<HistoryEntry> entries;

  const HistoryLoaded(this.entries);

  @override
  List<Object?> get props => [entries];
}

final class HistoryError extends HistoryState {
  final String message;

  const HistoryError(this.message);

  @override
  List<Object?> get props => [message];
}

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final GetHistory _getHistory;
  final AddHistoryEntry _addHistoryEntry;
  final DeleteHistoryEntry _deleteHistoryEntry;
  final ClearHistory _clearHistory;
  final ToggleFavorite _toggleFavorite;

  HistoryBloc({
    required GetHistory getHistory,
    required AddHistoryEntry addHistoryEntry,
    required DeleteHistoryEntry deleteHistoryEntry,
    required ClearHistory clearHistory,
    required ToggleFavorite toggleFavorite,
  }) : _getHistory = getHistory,
       _addHistoryEntry = addHistoryEntry,
       _deleteHistoryEntry = deleteHistoryEntry,
       _clearHistory = clearHistory,
       _toggleFavorite = toggleFavorite,
       super(const HistoryLoading()) {
    on<LoadHistory>(_onLoad);
    on<AddHistory>(_onAdd);
    on<DeleteHistory>(_onDelete);
    on<ClearAllHistory>(_onClear);
    on<ToggleHistoryFavorite>(_onToggle);
  }

  Future<void> _onLoad(LoadHistory event, Emitter<HistoryState> emit) async {
    emit(const HistoryLoading());
    try {
      final entries = await _getHistory();
      emit(HistoryLoaded(entries));
    } catch (e) {
      emit(HistoryError(e.toString()));
    }
  }

  Future<void> _onAdd(AddHistory event, Emitter<HistoryState> emit) async {
    try {
      await _addHistoryEntry(event.entry);
      add(const LoadHistory());
    } catch (e) {
      emit(HistoryError(e.toString()));
    }
  }

  Future<void> _onDelete(DeleteHistory event, Emitter<HistoryState> emit) async {
    try {
      await _deleteHistoryEntry(event.id);
      add(const LoadHistory());
    } catch (e) {
      emit(HistoryError(e.toString()));
    }
  }

  Future<void> _onClear(ClearAllHistory event, Emitter<HistoryState> emit) async {
    try {
      await _clearHistory();
      add(const LoadHistory());
    } catch (e) {
      emit(HistoryError(e.toString()));
    }
  }

  Future<void> _onToggle(ToggleHistoryFavorite event, Emitter<HistoryState> emit) async {
    try {
      await _toggleFavorite(event.id);
      add(const LoadHistory());
    } catch (e) {
      emit(HistoryError(e.toString()));
    }
  }
}
