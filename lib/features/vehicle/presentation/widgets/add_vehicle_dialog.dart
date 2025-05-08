import 'package:flutter/material.dart';
import '../../domain/entities/vehicle.dart';

class AddVehicleDialog extends StatefulWidget {
  const AddVehicleDialog({super.key});

  @override
  State<AddVehicleDialog> createState() => _AddVehicleDialogState();
}

class _AddVehicleDialogState extends State<AddVehicleDialog> {
  final _formKey = GlobalKey<FormState>();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _engineSizeController = TextEditingController();
  final _cityConsumptionController = TextEditingController();
  final _highwayConsumptionController = TextEditingController();
  final _mixedConsumptionController = TextEditingController();
  String _selectedFuelType = 'Gasolina';
  String _selectedTransmission = 'Manual';
  bool _isDefault = false;

  final List<String> _fuelTypes = [
    'Gasolina',
    'Diesel',
    'Eléctrico',
    'Híbrido',
  ];
  final List<String> _transmissionTypes = ['Manual', 'Automático'];

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _engineSizeController.dispose();
    _cityConsumptionController.dispose();
    _highwayConsumptionController.dispose();
    _mixedConsumptionController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        final vehicle = Vehicle(
          id: '', // Will be set by the server
          userId: '', // Will be set by the server
          brand: _brandController.text,
          model: _modelController.text,
          year: int.parse(_yearController.text),
          engineSize: double.parse(_engineSizeController.text),
          fuelType: _selectedFuelType,
          transmission: _selectedTransmission,
          consumption: Consumption(
            city: double.parse(_cityConsumptionController.text),
            highway: double.parse(_highwayConsumptionController.text),
            mixed: double.parse(_mixedConsumptionController.text),
          ),
          isDefault: _isDefault,
          createdAt: DateTime.now(),
        );

        if (mounted) {
          Navigator.pop(context, vehicle);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al crear vehículo: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF2563EB);
    const orange = Color(0xFFFFA726);
    const green = Color(0xFF2ECC40);
    const chipBg = Color(0xFFF1F5FF);
    const chipOrangeBg = Color(0xFFFFF3E0);
    const chipGreyBg = Color(0xFFF5F5F5);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 16,
          left: 8,
          right: 8,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(32)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 24,
                offset: Offset(0, -8),
              ),
            ],
          ),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.92,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: chipBg,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.directions_car_rounded,
                        color: blue,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'Agregar Vehículo',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                      color: Colors.grey[600],
                    ),
                  ],
                ),
              ),
              // Form
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Información básica
                        const Text(
                          'Información Básica',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _brandController,
                          label: 'Marca',
                          icon: Icons.business_rounded,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingrese la marca';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: _modelController,
                          label: 'Modelo',
                          icon: Icons.directions_car_rounded,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingrese el modelo';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: _yearController,
                                label: 'Año',
                                icon: Icons.calendar_today_rounded,
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Por favor ingrese el año';
                                  }
                                  if (int.tryParse(value) == null) {
                                    return 'Por favor ingrese un año válido';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildTextField(
                                controller: _engineSizeController,
                                label: 'Motor (L)',
                                icon: Icons.speed_rounded,
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Por favor ingrese el tamaño del motor';
                                  }
                                  if (double.tryParse(value) == null) {
                                    return 'Por favor ingrese un valor válido';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Tipo de vehículo
                        const Text(
                          'Tipo de Vehículo',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Column(
                          children: [
                            _buildDropdown(
                              value: _selectedFuelType,
                              items: _fuelTypes,
                              label: 'Combustible',
                              icon: Icons.local_gas_station_rounded,
                              onChanged: (value) {
                                setState(() {
                                  _selectedFuelType = value!;
                                });
                              },
                            ),
                            const SizedBox(height: 12),
                            _buildDropdown(
                              value: _selectedTransmission,
                              items: _transmissionTypes,
                              label: 'Transmisión',
                              icon: Icons.settings_rounded,
                              onChanged: (value) {
                                setState(() {
                                  _selectedTransmission = value!;
                                });
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Consumo
                        const Text(
                          'Consumo de Combustible',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildConsumptionField(
                                controller: _cityConsumptionController,
                                label: 'Ciudad',
                                icon: Icons.location_city_rounded,
                                color: blue,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildConsumptionField(
                                controller: _highwayConsumptionController,
                                label: 'Carretera',
                                icon: Icons.route_rounded,
                                color: green,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildConsumptionField(
                                controller: _mixedConsumptionController,
                                label: 'Mixto',
                                icon: Icons.sync_alt_rounded,
                                color: orange,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Vehículo por defecto
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: chipGreyBg,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.star_rounded,
                                color: Colors.amber[700],
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'Establecer como vehículo por defecto',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Switch(
                                value: _isDefault,
                                onChanged: (value) {
                                  setState(() {
                                    _isDefault = value;
                                  });
                                },
                                activeColor: blue,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Footer
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          side: BorderSide(color: Colors.grey[300]!),
                          foregroundColor: Colors.grey[700],
                          backgroundColor: Colors.white,
                          elevation: 0,
                        ),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: const Text('Guardar'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey[600]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF2563EB)),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required String label,
    required IconData icon,
    required void Function(String?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.grey[600]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF2563EB)),
          ),
        ),
        items:
            items.map((type) {
              return DropdownMenuItem(value: type, child: Text(type));
            }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildConsumptionField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'L/100km',
            hintStyle: TextStyle(color: Colors.grey[400]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: color.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: color.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: color),
            ),
            filled: true,
            fillColor: color.withOpacity(0.05),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Requerido';
            }
            if (double.tryParse(value) == null) {
              return 'Inválido';
            }
            return null;
          },
        ),
      ],
    );
  }
}
