import 'package:dio/dio.dart';
import '../../domain/entities/vehicle.dart';

abstract class VehicleRemoteDataSource {
  Future<List<Vehicle>> getVehicles();
  Future<Vehicle> getVehicle(String id);
  Future<Vehicle> createVehicle(Vehicle vehicle);
  Future<Vehicle> updateVehicle(String id, Vehicle vehicle);
  Future<void> deleteVehicle(String id);
}

class VehicleRemoteDataSourceImpl implements VehicleRemoteDataSource {
  final Dio dio;

  VehicleRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<Vehicle>> getVehicles() async {
    final response = await dio.get('/api/vehicles');
    return (response.data['data'] as List)
        .map((json) => Vehicle.fromJson(json))
        .toList();
  }

  @override
  Future<Vehicle> getVehicle(String id) async {
    final response = await dio.get('/api/vehicles/$id');
    return Vehicle.fromJson(response.data['data']);
  }

  @override
  Future<Vehicle> createVehicle(Vehicle vehicle) async {
    final response = await dio.post('/api/vehicles', data: vehicle.toJson());
    return Vehicle.fromJson(response.data['data']);
  }

  @override
  Future<Vehicle> updateVehicle(String id, Vehicle vehicle) async {
    final response = await dio.put('/api/vehicles/$id', data: vehicle.toJson());
    return Vehicle.fromJson(response.data['data']);
  }

  @override
  Future<void> deleteVehicle(String id) async {
    await dio.delete('/api/vehicles/$id');
  }
}
