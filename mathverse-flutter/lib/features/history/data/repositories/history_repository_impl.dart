import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../domain/entities/history_entry.dart';
import '../../domain/repositories/history_repository.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  final ApiClient _apiClient;

  HistoryRepositoryImpl([ApiClient? apiClient])
      : _apiClient = apiClient ?? ApiClient();

  @override
  Future<List<HistoryEntry>> getHistory() async {
    try {
      final response = await _apiClient.get('/api/v1/history');
      final data = response.data['data'] as Map<String, dynamic>;
      final entries = data['entries'] as List;
      return entries
          .map((e) => HistoryEntry(
                id: e['id'] as String? ?? '',
                feature: e['type'] as String? ?? '',
                input: e['input'] as String? ?? '',
                result: e['result'] as String? ?? '',
                timestamp: DateTime.tryParse(e['createdAt'] as String? ?? '') ?? DateTime.now(),
                isFavorite: e['favorite'] as bool? ?? false,
              ))
          .toList();
    } on DioException {
      return [];
    }
  }

  @override
  Future<void> addEntry(HistoryEntry entry) async {
    try {
      await _apiClient.post('/api/v1/history', data: {
        'type': entry.feature,
        'input': entry.input,
        'result': entry.result,
      });
    } on DioException {
    }
  }

  @override
  Future<void> deleteEntry(String id) async {
    try {
      await _apiClient.delete('/api/v1/history/$id');
    } on DioException {
    }
  }

  @override
  Future<void> clearHistory() async {
    try {
      await _apiClient.delete('/api/v1/history/clear');
    } on DioException {
    }
  }

  @override
  Future<void> toggleFavorite(String id) async {
    try {
      await _apiClient.post('/api/v1/history/$id/favorite');
    } on DioException {
    }
  }
}
