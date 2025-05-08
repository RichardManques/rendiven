import 'package:dio/dio.dart';
import '../../domain/entities/vehicle.dart';
import '../../domain/repositories/vehicle_repository.dart';
import 'package:rendiven/services/storage/storage_service.dart';

class VehicleService implements VehicleRepository {
  final String baseUrl;
  final StorageService storageService;
  late final Dio _dio;

  VehicleService({required this.baseUrl, required this.storageService}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        headers: {'Content-Type': 'application/json'},
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await storageService.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );
  }

  @override
  Future<List<Vehicle>> getVehicles() async {
    try {
      final response = await _dio.get('/vehicles');
      return (response.data['data'] as List)
          .map((json) => Vehicle.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw Exception('Error al obtener vehículos: ${e.message}');
    }
  }

  @override
  Future<Vehicle> getVehicle(String id) async {
    try {
      final response = await _dio.get('/vehicles/$id');
      return Vehicle.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception('Error al obtener vehículo: ${e.message}');
    }
  }

  @override
  Future<Vehicle> createVehicle(Vehicle vehicle) async {
    try {
      final response = await _dio.post('/vehicles', data: vehicle.toJson());
      return Vehicle.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception('Error al crear vehículo: ${e.message}');
    }
  }

  @override
  Future<Vehicle> updateVehicle(String id, Vehicle vehicle) async {
    try {
      final response = await _dio.put(
        '/api/vehicles/$id',
        data: vehicle.toJson(),
      );
      return Vehicle.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception('Error al actualizar vehículo: ${e.message}');
    }
  }

  @override
  Future<void> deleteVehicle(String id) async {
    try {
      await _dio.delete('/vehicles/$id');
    } on DioException catch (e) {
      throw Exception('Error al eliminar vehículo: ${e.message}');
    }
  }
}
