import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rendiven/features/fuel/presentation/bloc/fuel_bloc.dart';
import 'package:rendiven/features/fuel/domain/models/fuel_model.dart';

class NewFuelModal extends StatefulWidget {
  const NewFuelModal({super.key});

  @override
  State<NewFuelModal> createState() => _NewFuelModalState();
}

class _NewFuelModalState extends State<NewFuelModal> {
  final _formKey = GlobalKey<FormState>();
  final _gasStationController = TextEditingController();
  final _locationController = TextEditingController();
  final _totalCostController = TextEditingController();
  final _pricePerLiterController = TextEditingController();
  double _liters = 0.0;
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _gasStationController.dispose();
    _locationController.dispose();
    _totalCostController.dispose();
    _pricePerLiterController.dispose();
    super.dispose();
  }

  void _calculateLiters() {
    final total = double.tryParse(_totalCostController.text);
    final price = int.tryParse(_pricePerLiterController.text);
    if (total != null && price != null && price > 0) {
      setState(() {
        _liters = total / price;
      });
    } else {
      setState(() {
        _liters = 0.0;
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final totalCost = double.parse(_totalCostController.text);
      final pricePerLiter = int.parse(_pricePerLiterController.text);
      final liters = _liters;

      // Redondear los valores antes de crear el modelo
      final roundedLiters = double.parse(liters.toStringAsFixed(1));
      final roundedTotalCost = double.parse(totalCost.toStringAsFixed(2));

      final newFuel = FuelModel(
        id: '', // El ID será generado por el backend
        date: _selectedDate,
        liters: roundedLiters,
        pricePerLiter: pricePerLiter,
        totalCost: roundedTotalCost,
        gasStation: _gasStationController.text,
        location: _locationController.text,
      );

      context.read<FuelBloc>().add(AddFuel(newFuel));
      Navigator.pop(context);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Nueva recarga combustible',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF3B2FE3),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _gasStationController,
                decoration: InputDecoration(
                  labelText: 'Estación de Servicio',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.local_gas_station),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese la estación de servicio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'Ubicación',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.location_on),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese la ubicación';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _totalCostController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Monto Total',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.attach_money),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingrese el monto total';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Ingrese un número válido';
                        }
                        return null;
                      },
                      onChanged: (_) => _calculateLiters(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _pricePerLiterController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Precio/Litro',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.local_drink),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingrese el precio por litro';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Ingrese un número entero válido';
                        }
                        return null;
                      },
                      onChanged: (_) => _calculateLiters(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                enabled: false,
                decoration: InputDecoration(
                  labelText: 'Litros (calculado)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.local_gas_station),
                ),
                controller: TextEditingController(
                  text: _liters > 0 ? _liters.toStringAsFixed(1) : '',
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Fecha',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}',
                    style: GoogleFonts.poppins(),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B2FE3),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Guardar Recarga',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
