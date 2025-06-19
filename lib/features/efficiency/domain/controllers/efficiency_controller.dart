import 'package:dio/dio.dart';
import 'package:rendiven/features/efficiency/domain/models/efficiency_model.dart';
import 'package:rendiven/services/storage/storage_service.dart';

class EfficiencyController {
  final Dio _dio;
  final StorageService storageService;

  EfficiencyController({required String baseUrl, required this.storageService})
    : _dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          headers: {'Content-Type': 'application/json'},
        ),
      );

  Future<void> _setAuthHeader() async {
    final token = await storageService.getToken();
    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }

  // Crear nuevo registro de eficiencia
  Future<EfficiencyModel> createEfficiency(EfficiencyModel efficiency) async {
    await _setAuthHeader();
    final response = await _dio.post('/efficiency', data: efficiency.toJson());
    if (response.statusCode == 201) {
      return EfficiencyModel.fromJson(response.data['data']);
    } else {
      throw Exception(
        'Error al crear el registro de eficiencia: ${response.data}',
      );
    }
  }

  // Obtener todos los registros de eficiencia
  Future<List<EfficiencyModel>> getEfficiencies() async {
    await _setAuthHeader();
    final response = await _dio.get('/efficiency');
    if (response.statusCode == 200) {
      final List<dynamic> efficiencies = response.data['data'];
      return efficiencies.map((e) => EfficiencyModel.fromJson(e)).toList();
    } else {
      throw Exception(
        'Error al obtener los registros de eficiencia: ${response.data}',
      );
    }
  }

  // Obtener registros de eficiencia por vehículo
  Future<List<EfficiencyModel>> getEfficienciesByVehicle(
    String vehicleId,
  ) async {
    await _setAuthHeader();
    final response = await _dio.get('/efficiency/vehicle/$vehicleId');
    if (response.statusCode == 200) {
      final List<dynamic> efficiencies = response.data['data'];
      return efficiencies.map((e) => EfficiencyModel.fromJson(e)).toList();
    } else {
      throw Exception(
        'Error al obtener los registros de eficiencia del vehículo: ${response.data}',
      );
    }
  }

  // Obtener un registro de eficiencia específico
  Future<EfficiencyModel> getEfficiency(String id) async {
    await _setAuthHeader();
    final response = await _dio.get('/efficiency/$id');
    if (response.statusCode == 200) {
      return EfficiencyModel.fromJson(response.data['data']);
    } else {
      throw Exception(
        'Error al obtener el registro de eficiencia: ${response.data}',
      );
    }
  }

  // Actualizar un registro de eficiencia
  Future<EfficiencyModel> updateEfficiency(
    String id,
    EfficiencyModel efficiency,
  ) async {
    await _setAuthHeader();
    final response = await _dio.put(
      '/efficiency/$id',
      data: efficiency.toJson(),
    );
    if (response.statusCode == 200) {
      return EfficiencyModel.fromJson(response.data['data']);
    } else {
      throw Exception(
        'Error al actualizar el registro de eficiencia: ${response.data}',
      );
    }
  }

  // Eliminar un registro de eficiencia
  Future<void> deleteEfficiency(String id) async {
    await _setAuthHeader();
    final response = await _dio.delete('/efficiency/$id');
    if (response.statusCode != 200) {
      throw Exception(
        'Error al eliminar el registro de eficiencia: ${response.data}',
      );
    }
  }

  // Obtener estadísticas de eficiencia por vehículo
  Future<Map<String, dynamic>> getEfficiencyStats(String vehicleId) async {
    await _setAuthHeader();
    final response = await _dio.get('/efficiency/stats/$vehicleId');
    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw Exception(
        'Error al obtener las estadísticas de eficiencia: ${response.data}',
      );
    }
  }
}
