import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rendiven/features/fuel/data/services/fuel_service.dart';
import 'package:rendiven/features/fuel/domain/models/fuel_model.dart';

// Events
abstract class FuelEvent {}

class LoadFuels extends FuelEvent {}

class AddFuel extends FuelEvent {
  final FuelModel fuel;
  AddFuel(this.fuel);
}

class DeleteFuel extends FuelEvent {
  final String id;
  DeleteFuel(this.id);
}

class UpdateFuel extends FuelEvent {
  final String id;
  final FuelModel fuel;
  UpdateFuel(this.id, this.fuel);
}

// States
abstract class FuelState {}

class FuelInitial extends FuelState {}

class FuelLoading extends FuelState {}

class FuelLoaded extends FuelState {
  final List<FuelModel> fuels;
  FuelLoaded(this.fuels);
}

class FuelError extends FuelState {
  final String message;
  FuelError(this.message);
}

class FuelBloc extends Bloc<FuelEvent, FuelState> {
  final FuelService fuelService;
  FuelBloc({required this.fuelService}) : super(FuelInitial()) {
    on<LoadFuels>(_onLoadFuels);
    on<AddFuel>(_onAddFuel);
    on<DeleteFuel>(_onDeleteFuel);
    on<UpdateFuel>(_onUpdateFuel);
  }

  Future<void> _onLoadFuels(LoadFuels event, Emitter<FuelState> emit) async {
    emit(FuelLoading());
    try {
      final fuels = await fuelService.getFuels();
      emit(FuelLoaded(fuels));
    } catch (e) {
      emit(FuelError(e.toString()));
    }
  }

  Future<void> _onAddFuel(AddFuel event, Emitter<FuelState> emit) async {
    try {
      await fuelService.createFuel(event.fuel);
      add(LoadFuels());
    } catch (e) {
      emit(FuelError(e.toString()));
    }
  }

  Future<void> _onDeleteFuel(DeleteFuel event, Emitter<FuelState> emit) async {
    try {
      await fuelService.deleteFuel(event.id);
      add(LoadFuels());
    } catch (e) {
      emit(FuelError(e.toString()));
    }
  }

  Future<void> _onUpdateFuel(UpdateFuel event, Emitter<FuelState> emit) async {
    try {
      await fuelService.updateFuel(event.id, event.fuel);
      add(LoadFuels());
    } catch (e) {
      emit(FuelError(e.toString()));
    }
  }
}
