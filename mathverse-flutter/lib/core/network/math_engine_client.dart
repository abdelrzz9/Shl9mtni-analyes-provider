import 'package:dio/dio.dart';
import '../config/app_config.dart';

class MathEngineClient {
  late final Dio _dio;

  MathEngineClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.mathEngineUrl,
        connectTimeout: const Duration(milliseconds: AppConfig.connectTimeout),
        receiveTimeout: const Duration(milliseconds: AppConfig.receiveTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
  }

  Future<Map<String, dynamic>> evaluate(String endpoint, Map<String, dynamic> data) async {
    final response = await _dio.post('/api/v1/$endpoint', data: data);
    return response.data as Map<String, dynamic>;
  }
}
