import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rendiven/features/fuel/domain/models/fuel_model.dart';
import 'package:rendiven/features/fuel/presentation/bloc/fuel_bloc.dart';

class FuelEditModal extends StatefulWidget {
  final FuelModel fuel;
  const FuelEditModal({required this.fuel, super.key});

  @override
  State<FuelEditModal> createState() => _FuelEditModalState();
}

class _FuelEditModalState extends State<FuelEditModal> {
  late TextEditingController _gasStationController;
  late TextEditingController _locationController;
  late TextEditingController _litersController;
  late TextEditingController _pricePerLiterController;
  late TextEditingController _totalCostController;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _gasStationController = TextEditingController(text: widget.fuel.gasStation);
    _locationController = TextEditingController(text: widget.fuel.location);
    _litersController = TextEditingController(
      text: widget.fuel.liters.toStringAsFixed(1),
    );
    _pricePerLiterController = TextEditingController(
      text: widget.fuel.pricePerLiter.toString(),
    );
    _totalCostController = TextEditingController(
      text: widget.fuel.totalCost.toStringAsFixed(2),
    );
    _selectedDate = widget.fuel.date;
  }

  @override
  void dispose() {
    _gasStationController.dispose();
    _locationController.dispose();
    _litersController.dispose();
    _pricePerLiterController.dispose();
    _totalCostController.dispose();
    super.dispose();
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

  void _updateFuel() {
    final totalCost = double.parse(_totalCostController.text);
    final pricePerLiter = int.parse(_pricePerLiterController.text);
    final liters = double.parse(_litersController.text);

    final updatedFuel = FuelModel(
      id: widget.fuel.id,
      date: _selectedDate,
      liters: liters,
      pricePerLiter: pricePerLiter,
      totalCost: totalCost,
      gasStation: _gasStationController.text,
      location: _locationController.text,
    );

    context.read<FuelBloc>().add(UpdateFuel(widget.fuel.id, updatedFuel));
    Navigator.pop(context);
  }

  Future<void> _deleteFuel() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            backgroundColor: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F6FA),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(16),
                    child: const Icon(
                      Icons.delete_outline,
                      color: Color(0xFFEB5757),
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Eliminar recarga',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '¿Estás seguro de que deseas eliminar esta recarga?',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context, false),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            side: BorderSide(color: Colors.grey[300]!),
                            foregroundColor: Colors.grey[700],
                            backgroundColor: Colors.white,
                          ),
                          child: Text(
                            'Cancelar',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEB5757),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            'Eliminar',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );

    if (confirmed == true) {
      context.read<FuelBloc>().add(DeleteFuel(widget.fuel.id));
      Navigator.pop(context);
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Editar recarga',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF3B2FE3),
                  ),
                ),
                IconButton(
                  onPressed: _deleteFuel,
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Color(0xFFEB5757),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _gasStationController,
              decoration: InputDecoration(
                labelText: 'Gasolinera',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                prefixIcon: const Icon(Icons.local_gas_station),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: 'Ubicación',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                prefixIcon: const Icon(Icons.location_on),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _litersController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Litros',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      prefixIcon: const Icon(Icons.local_drink),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: TextField(
                    controller: _pricePerLiterController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Precio por litro',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      prefixIcon: const Icon(Icons.attach_money),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _totalCostController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Costo total',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                prefixIcon: const Icon(Icons.payments),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
            const SizedBox(height: 18),
            InkWell(
              onTap: () => _selectDate(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.grey[50],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Color(0xFF3B2FE3)),
                    const SizedBox(width: 12),
                    Text(
                      '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _updateFuel,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B2FE3),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'Guardar cambios',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
