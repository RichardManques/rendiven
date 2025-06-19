import 'package:flutter/material.dart';
import 'package:rendiven/features/efficiency/domain/controllers/efficiency_controller.dart';
import 'package:rendiven/features/efficiency/domain/models/efficiency_model.dart';
import 'package:rendiven/features/vehicle/data/services/vehicle_service.dart';
import 'package:rendiven/features/vehicle/domain/entities/vehicle.dart';
import 'package:rendiven/services/storage/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rendiven/features/fuel/data/services/fuel_service.dart';
import 'package:rendiven/features/fuel/domain/models/fuel_model.dart';

class EfficiencyFormScreen extends StatefulWidget {
  final EfficiencyModel? efficiency;

  const EfficiencyFormScreen({super.key, this.efficiency});

  @override
  State<EfficiencyFormScreen> createState() => _EfficiencyFormScreenState();
}

class _EfficiencyFormScreenState extends State<EfficiencyFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late EfficiencyController _controller;

  late TextEditingController _startKmController;
  late TextEditingController _endKmController;
  late String _drivingStyle;
  late String _routeType;
  late bool _useAC;
  late double _baseEfficiency;
  late double _adjustedEfficiency;
  late double _costPerKm;
  late double _totalCost;

  List<Vehicle> _vehicles = [];
  String? _selectedVehicleId;
  bool _loadingVehicles = true;
  List<FuelModel> _fuels = [];
  double? _lastFuelPrice;

  @override
  void initState() {
    super.initState();
    _startKmController = TextEditingController(
      text: widget.efficiency?.startKm.toString() ?? '',
    );
    _endKmController = TextEditingController(
      text: widget.efficiency?.endKm.toString() ?? '',
    );
    _drivingStyle = widget.efficiency?.drivingStyle ?? 'normal';
    _routeType = widget.efficiency?.routeType ?? 'mixta';
    _useAC = widget.efficiency?.useAC ?? false;
    _baseEfficiency = widget.efficiency?.efficiency.base ?? 0.0;
    _adjustedEfficiency = widget.efficiency?.efficiency.adjusted ?? 0.0;
    _costPerKm = widget.efficiency?.cost.perKm ?? 0.0;
    _totalCost = widget.efficiency?.cost.total ?? 0.0;
    _initControllerAndLoadVehicles();
  }

  Future<void> _initControllerAndLoadVehicles() async {
    final prefs = await SharedPreferences.getInstance();
    final storageService = StorageService(prefs);
    _controller = EfficiencyController(
      baseUrl: 'http://10.0.2.2:5000/api',
      storageService: storageService,
    );
    await _loadVehicles(storageService);
    await _loadLastFuelPrice(storageService);
  }

  Future<void> _loadVehicles(StorageService storageService) async {
    setState(() => _loadingVehicles = true);
    final vehicleService = VehicleService(
      baseUrl: 'http://10.0.2.2:5000/api',
      storageService: storageService,
    );
    try {
      final vehicles = await vehicleService.getVehicles();
      setState(() {
        _vehicles = vehicles;
        _loadingVehicles = false;
        if (widget.efficiency != null) {
          _selectedVehicleId = widget.efficiency!.vehicleId;
        } else if (vehicles.isNotEmpty) {
          _selectedVehicleId = vehicles.first.id;
        }
      });
    } catch (e) {
      setState(() => _loadingVehicles = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar vehículos: $e')),
        );
      }
    }
  }

  Future<void> _loadLastFuelPrice(StorageService storageService) async {
    final fuelService = FuelService(
      baseUrl: 'http://10.0.2.2:5000/api',
      storageService: storageService,
    );
    try {
      final fuels = await fuelService.getFuels();
      fuels.sort((a, b) => b.date.compareTo(a.date));
      setState(() {
        _fuels = fuels;
        _lastFuelPrice =
            fuels.isNotEmpty ? fuels.first.pricePerLiter.toDouble() : null;
      });
    } catch (e) {
      setState(() {
        _lastFuelPrice = null;
      });
    }
  }

  @override
  void dispose() {
    _startKmController.dispose();
    _endKmController.dispose();
    super.dispose();
  }

  void _calculateEfficiency() {
    if (_startKmController.text.isNotEmpty &&
        _endKmController.text.isNotEmpty &&
        _selectedVehicleId != null) {
      final startKm = double.parse(_startKmController.text);
      final endKm = double.parse(_endKmController.text);
      final kmConsumed = startKm - endKm;
      final vehicle = _vehicles.firstWhere((v) => v.id == _selectedVehicleId);
      // Usar directamente el valor de km/L según tipo de ruta
      switch (_routeType) {
        case 'ciudad':
          _baseEfficiency = vehicle.consumption.city;
          break;
        case 'carretera':
          _baseEfficiency = vehicle.consumption.highway;
          break;
        default:
          _baseEfficiency = vehicle.consumption.mixed;
      }
      // Ajustes según el estilo de conducción
      switch (_drivingStyle) {
        case 'suave':
          _adjustedEfficiency = _baseEfficiency * 1.2;
          break;
        case 'agresivo':
          _adjustedEfficiency = _baseEfficiency * 0.8;
          break;
        default:
          _adjustedEfficiency = _baseEfficiency;
      }
      // Ajuste por uso de AC
      if (_useAC) {
        _adjustedEfficiency *= 0.9;
      }
      // Cálculo de costos usando el precio de la última recarga
      final fuelPrice = _lastFuelPrice ?? 1.0;
      _costPerKm = fuelPrice / _adjustedEfficiency;
      _totalCost = _costPerKm * kmConsumed;
      setState(() {});
    }
  }

  Future<void> _saveEfficiency() async {
    if (_formKey.currentState!.validate()) {
      try {
        final efficiency = EfficiencyModel(
          id: widget.efficiency?.id ?? '',
          userId:
              'current_user_id', // Esto debería venir del estado de autenticación
          vehicleId: _selectedVehicleId!,
          startKm: double.parse(_startKmController.text),
          endKm: double.parse(_endKmController.text),
          kmConsumed:
              double.parse(_startKmController.text) -
              double.parse(_endKmController.text),
          drivingStyle: _drivingStyle,
          routeType: _routeType,
          useAC: _useAC,
          efficiency: EfficiencyData(
            base: _baseEfficiency,
            adjusted: _adjustedEfficiency,
          ),
          cost: CostData(perKm: _costPerKm, total: _totalCost),
          date: DateTime.now(),
        );

        print('JSON enviado al backend:');
        print(efficiency.toJson());

        if (widget.efficiency == null) {
          await _controller.createEfficiency(efficiency);
        } else {
          await _controller.updateEfficiency(efficiency.id, efficiency);
        }

        if (mounted) {
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al guardar la eficiencia: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF2563EB);
    const chipBg = Color(0xFFF1F5FF);
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
                      child: Icon(Icons.speed_rounded, color: blue, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        widget.efficiency == null
                            ? 'Agregar Eficiencia'
                            : 'Editar Eficiencia',
                        style: const TextStyle(
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
              // Formulario
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Sección: Kilometraje
                        const Text(
                          'Kilometraje del Viaje',
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
                              child: _roundedInput(
                                controller: _startKmController,
                                label: 'Kilómetros Iniciales',
                                icon: Icons.speed,
                                suffix: 'km',
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Ingrese el km inicial';
                                  }
                                  return null;
                                },
                                onChanged: (_) => _calculateEfficiency(),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _roundedInput(
                                controller: _endKmController,
                                label: 'Kilómetros Finales',
                                icon: Icons.speed_outlined,
                                suffix: 'km',
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Ingrese el km final';
                                  }
                                  if (double.parse(value) >=
                                      double.parse(_startKmController.text)) {
                                    return 'Final debe ser menor a inicial';
                                  }
                                  return null;
                                },
                                onChanged: (_) => _calculateEfficiency(),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Sección: Vehículo
                        const Text(
                          'Vehículo',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _roundedDropdown(
                          value: _selectedVehicleId,
                          items:
                              _vehicles
                                  .map(
                                    (v) => DropdownMenuItem(
                                      value: v.id,
                                      child: Text(
                                        '${v.brand} ${v.model} (${v.year})',
                                      ),
                                    ),
                                  )
                                  .toList(),
                          label: 'Selecciona tu Vehículo',
                          icon: Icons.directions_car,
                          onChanged: (value) {
                            setState(() {
                              _selectedVehicleId = value;
                            });
                          },
                          validator:
                              (value) =>
                                  value == null
                                      ? 'Debes seleccionar un vehículo'
                                      : null,
                        ),
                        const SizedBox(height: 16),
                        if (_selectedVehicleId != null)
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _vehicleConsumptionInfo(
                                  _vehicles.firstWhere(
                                    (v) => v.id == _selectedVehicleId,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 24),
                        // Sección: Condiciones de Conducción
                        const Text(
                          'Condiciones de Conducción',
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
                              child: _roundedDropdown(
                                value: _drivingStyle,
                                items: const [
                                  DropdownMenuItem(
                                    value: 'suave',
                                    child: Text('Suave'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'normal',
                                    child: Text('Normal'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'agresivo',
                                    child: Text('Agresivo'),
                                  ),
                                ],
                                label: 'Estilo de Conducción',
                                icon: Icons.emoji_people,
                                onChanged: (value) {
                                  setState(() {
                                    _drivingStyle = value!;
                                    _calculateEfficiency();
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _roundedDropdown(
                                value: _routeType,
                                items: const [
                                  DropdownMenuItem(
                                    value: 'ciudad',
                                    child: Text('Ciudad'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'carretera',
                                    child: Text('Carretera'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'mixta',
                                    child: Text('Mixta'),
                                  ),
                                ],
                                label: 'Tipo de Ruta',
                                icon: Icons.alt_route,
                                onChanged: (value) {
                                  setState(() {
                                    _routeType = value!;
                                    _calculateEfficiency();
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Sección: Condiciones Adicionales
                        const Text(
                          'Condiciones Adicionales',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          elevation: 0,
                          color: Colors.grey[50],
                          child: SwitchListTile(
                            title: const Text('Uso de Aire Acondicionado'),
                            value: _useAC,
                            onChanged: (value) {
                              setState(() {
                                _useAC = value;
                                _calculateEfficiency();
                              });
                            },
                            secondary: const Icon(Icons.ac_unit_rounded),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        // Mostrar precio por litro usado
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.attach_money,
                                      size: 20,
                                      color: Colors.green,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Precio por litro: ',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    Text(
                                      '${_lastFuelPrice?.toStringAsFixed(0) ?? '-'}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Resultados visuales
                        SizedBox(
                          height: 240,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 170,
                                  height: 240,
                                  child: _resultCard(
                                    icon: Icons.directions_car,
                                    title: 'Rendimiento Base vs Real',
                                    value:
                                        '${_baseEfficiency.toStringAsFixed(1)} → ${_adjustedEfficiency.toStringAsFixed(1)} km/L',
                                    subtitle:
                                        'Rendimiento ajustado según tu estilo',
                                    color: Colors.blue,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                SizedBox(
                                  width: 170,
                                  height: 240,
                                  child: _resultCard(
                                    icon: Icons.attach_money,
                                    title: 'Costo por Kilómetro',
                                    value: '${_costPerKm.toStringAsFixed(0)}',
                                    subtitle: 'Basado en rendimiento real',
                                    color: Colors.green[700]!,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                SizedBox(
                                  width: 170,
                                  height: 240,
                                  child: _resultCard(
                                    icon: Icons.local_gas_station,
                                    title: 'Resumen del Viaje',
                                    value: '${_totalCost.toStringAsFixed(0)}',
                                    subtitle:
                                        '${(_startKmController.text.isNotEmpty && _endKmController.text.isNotEmpty) ? (double.parse(_startKmController.text) - double.parse(_endKmController.text)).toStringAsFixed(0) : '0'} km recorridos',
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
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
                        onPressed:
                            (_lastFuelPrice == null) ? null : _saveEfficiency,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          widget.efficiency == null ? 'Guardar' : 'Actualizar',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
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

  Widget _roundedInput({
    required TextEditingController controller,
    required String label,
    String? suffix,
    IconData? icon,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      validator: validator,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        prefixIcon: icon != null ? Icon(icon, color: Color(0xFF2563EB)) : null,
        suffixText: suffix,
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 14,
        ),
      ),
    );
  }

  Widget _roundedDropdown({
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required String label,
    required IconData icon,
    required void Function(String?) onChanged,
    String? Function(String?)? validator,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items,
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Color(0xFF2563EB)),
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 14,
        ),
      ),
    );
  }

  Widget _vehicleConsumptionInfo(Vehicle vehicle) {
    // Implementa la lógica para mostrar la información de consumo del vehículo
    // Esto puede ser una lista de chips o cualquier otra representación adecuada
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _chip(
          icon: Icons.location_city,
          label: 'Ciudad: ${vehicle.consumption.city.toStringAsFixed(1)}',
          color: Colors.blue,
          bgColor: const Color(0xFFEAF2FF),
        ),
        _chip(
          icon: Icons.alt_route,
          label: 'Carretera: ${vehicle.consumption.highway.toStringAsFixed(1)}',
          color: Colors.green,
          bgColor: const Color(0xFFE8F5E9),
        ),
        _chip(
          icon: Icons.sync_alt,
          label: 'Mixto: ${vehicle.consumption.mixed.toStringAsFixed(1)}',
          color: Colors.orange,
          bgColor: const Color(0xFFFFF3E0),
        ),
      ],
    );
  }

  Widget _chip({
    required IconData icon,
    required String label,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 15)),
        ],
      ),
    );
  }

  Widget _resultCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 0,
      color: color.withOpacity(0.07),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, color: color, size: 28),
              radius: 22,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(color: Colors.grey[700], fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
