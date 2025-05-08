import 'package:dio/dio.dart';
import '../../domain/entities/vehicle.dart';
import '../../domain/repositories/vehicle_repository.dart';
import '../datasources/vehicle_remote_data_source.dart';

class VehicleRepositoryImpl implements VehicleRepository {
  final VehicleRemoteDataSource remoteDataSource;

  VehicleRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Vehicle>> getVehicles() async {
    try {
      final vehicles = await remoteDataSource.getVehicles();
      return vehicles;
    } on DioException catch (e) {
      throw Exception('Error al obtener vehículos: ${e.message}');
    }
  }

  @override
  Future<Vehicle> getVehicle(String id) async {
    try {
      final vehicle = await remoteDataSource.getVehicle(id);
      return vehicle;
    } on DioException catch (e) {
      throw Exception('Error al obtener vehículo: ${e.message}');
    }
  }

  @override
  Future<Vehicle> createVehicle(Vehicle vehicle) async {
    try {
      final createdVehicle = await remoteDataSource.createVehicle(vehicle);
      return createdVehicle;
    } on DioException catch (e) {
      throw Exception('Error al crear vehículo: ${e.message}');
    }
  }

  @override
  Future<Vehicle> updateVehicle(String id, Vehicle vehicle) async {
    try {
      final updatedVehicle = await remoteDataSource.updateVehicle(id, vehicle);
      return updatedVehicle;
    } on DioException catch (e) {
      throw Exception('Error al actualizar vehículo: ${e.message}');
    }
  }

  @override
  Future<void> deleteVehicle(String id) async {
    try {
      await remoteDataSource.deleteVehicle(id);
    } on DioException catch (e) {
      throw Exception('Error al eliminar vehículo: ${e.message}');
    }
  }
}
