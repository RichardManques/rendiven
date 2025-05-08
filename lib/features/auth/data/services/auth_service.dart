import 'package:dio/dio.dart';
import 'package:rendiven/core/constants/api_constants.dart';
import 'package:rendiven/features/auth/domain/models/user_model.dart';
import 'package:rendiven/services/api/jwt_interceptor.dart';
import 'package:rendiven/services/storage/storage_service.dart';

class AuthResponse {
  final UserModel user;
  final String token;

  AuthResponse({required this.user, required this.token});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    if (data == null || data['token'] == null) {
      throw Exception('Respuesta inválida del servidor: falta data o token');
    }
    return AuthResponse(user: UserModel.fromJson(data), token: data['token']);
  }
}

class AuthService {
  final Dio _dio;
  final StorageService _storageService;

  AuthService({required String baseUrl, required StorageService storageService})
    : _storageService = storageService,
      _dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 3),
        ),
      )..interceptors.add(JwtInterceptor(storageService));

  Future<UserModel> login(String email, String password) async {
    try {
      final response = await _dio.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );
      print('Respuesta login:');
      print(response.data);
      final authResponse = AuthResponse.fromJson(response.data);
      await _storageService.saveToken(authResponse.token);
      return authResponse.user;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<UserModel> register(String name, String email, String password) async {
    try {
      final response = await _dio.post(
        ApiConstants.register,
        data: {'name': name, 'email': email, 'password': password},
      );
      print('Respuesta register:');
      print(response.data);
      final authResponse = AuthResponse.fromJson(response.data);
      await _storageService.saveToken(authResponse.token);
      return authResponse.user;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<UserModel> getMe() async {
    try {
      final response = await _dio.get(ApiConstants.getMe);
      print('Respuesta getMe:');
      print(response.data);
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> logout() async {
    try {
      await _storageService.deleteToken();
    } catch (e) {
      throw 'Error al cerrar sesión: ${e.toString()}';
    }
  }

  String _handleError(DioException error) {
    if (error.response?.statusCode == 401) {
      return 'Credenciales inválidas';
    } else if (error.response?.statusCode == 400) {
      final message = error.response?.data['message'];
      if (message != null) {
        return message;
      }
      return 'Datos inválidos';
    } else if (error.response?.statusCode == 409) {
      return 'El correo electrónico ya está registrado';
    } else if (error.type == DioExceptionType.connectionTimeout) {
      return 'Tiempo de conexión agotado';
    } else {
      return 'Error desconocido: ${error.message}';
    }
  }
}
