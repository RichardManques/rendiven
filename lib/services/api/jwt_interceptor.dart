import 'package:dio/dio.dart';
import 'package:rendiven/services/storage/storage_service.dart';

class JwtInterceptor extends Interceptor {
  final StorageService _storageService;

  JwtInterceptor(this._storageService);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _storageService.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Token expirado o inválido
      _storageService.deleteToken();
      // TODO: Navegar a la pantalla de login
    }
    handler.next(err);
  }
}
