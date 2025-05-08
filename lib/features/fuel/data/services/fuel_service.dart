import 'package:dio/dio.dart';
import 'package:rendiven/features/fuel/domain/models/fuel_model.dart';
import 'package:rendiven/services/api/jwt_interceptor.dart';
import 'package:rendiven/services/storage/storage_service.dart';

class FuelService {
  final Dio _dio;

  FuelService({required String baseUrl, required StorageService storageService})
    : _dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 3),
        ),
      )..interceptors.add(JwtInterceptor(storageService));

  Future<List<FuelModel>> getFuels() async {
    final response = await _dio.get('/fuel');
    print('Respuesta getFuels:');
    print(response.data);
    final data = response.data['data'] as List;
    return data.map((e) => FuelModel.fromJson(e)).toList();
  }

  Future<FuelModel> createFuel(FuelModel fuel) async {
    final response = await _dio.post('/fuel', data: fuel.toJson());
    return FuelModel.fromJson(response.data['data']);
  }

  Future<void> deleteFuel(String id) async {
    await _dio.delete('/fuel/$id');
  }

  Future<FuelModel> updateFuel(String id, FuelModel fuel) async {
    final response = await _dio.put('/fuel/$id', data: fuel.toJson());
    return FuelModel.fromJson(response.data['data']);
  }
}
