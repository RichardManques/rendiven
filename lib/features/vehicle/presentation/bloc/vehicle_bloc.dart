import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/vehicle.dart';
import '../../data/services/vehicle_service.dart';

// Events
abstract class VehicleEvent {}

class LoadVehicles extends VehicleEvent {}

class AddVehicle extends VehicleEvent {
  final Vehicle vehicle;
  AddVehicle(this.vehicle);
}

class UpdateVehicle extends VehicleEvent {
  final String id;
  final Vehicle vehicle;
  UpdateVehicle(this.id, this.vehicle);
}

class DeleteVehicle extends VehicleEvent {
  final String id;
  DeleteVehicle(this.id);
}

// States
abstract class VehicleState {}

class VehicleInitial extends VehicleState {}

class VehicleLoading extends VehicleState {}

class VehicleLoaded extends VehicleState {
  final List<Vehicle> vehicles;
  VehicleLoaded(this.vehicles);
}

class VehicleError extends VehicleState {
  final String message;
  VehicleError(this.message);
}

class VehicleBloc extends Bloc<VehicleEvent, VehicleState> {
  final VehicleService vehicleService;

  VehicleBloc({required this.vehicleService}) : super(VehicleInitial()) {
    on<LoadVehicles>(_onLoadVehicles);
    on<AddVehicle>(_onAddVehicle);
    on<UpdateVehicle>(_onUpdateVehicle);
    on<DeleteVehicle>(_onDeleteVehicle);
  }

  Future<void> _onLoadVehicles(
    LoadVehicles event,
    Emitter<VehicleState> emit,
  ) async {
    emit(VehicleLoading());
    try {
      final vehicles = await vehicleService.getVehicles();
      emit(VehicleLoaded(vehicles));
    } catch (e) {
      emit(VehicleError(e.toString()));
    }
  }

  Future<void> _onAddVehicle(
    AddVehicle event,
    Emitter<VehicleState> emit,
  ) async {
    try {
      await vehicleService.createVehicle(event.vehicle);
      add(LoadVehicles());
    } catch (e) {
      emit(VehicleError(e.toString()));
    }
  }

  Future<void> _onUpdateVehicle(
    UpdateVehicle event,
    Emitter<VehicleState> emit,
  ) async {
    try {
      await vehicleService.updateVehicle(event.id, event.vehicle);
      add(LoadVehicles());
    } catch (e) {
      emit(VehicleError(e.toString()));
    }
  }

  Future<void> _onDeleteVehicle(
    DeleteVehicle event,
    Emitter<VehicleState> emit,
  ) async {
    try {
      await vehicleService.deleteVehicle(event.id);
      add(LoadVehicles());
    } catch (e) {
      emit(VehicleError(e.toString()));
    }
  }
}
