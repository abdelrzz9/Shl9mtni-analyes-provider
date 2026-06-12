import 'package:equatable/equatable.dart';

class HistoryEntry extends Equatable {
  final String id;
  final String feature;
  final String input;
  final String result;
  final DateTime timestamp;
  final bool isFavorite;

  const HistoryEntry({
    required this.id,
    required this.feature,
    required this.input,
    required this.result,
    required this.timestamp,
    this.isFavorite = false,
  });

  @override
  List<Object?> get props => [id, feature, input, result, timestamp, isFavorite];

  HistoryEntry copyWith({
    String? id,
    String? feature,
    String? input,
    String? result,
    DateTime? timestamp,
    bool? isFavorite,
  }) {
    return HistoryEntry(
      id: id ?? this.id,
      feature: feature ?? this.feature,
      input: input ?? this.input,
      result: result ?? this.result,
      timestamp: timestamp ?? this.timestamp,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
