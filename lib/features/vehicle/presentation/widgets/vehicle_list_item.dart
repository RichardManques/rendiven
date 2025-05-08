import 'package:flutter/material.dart';
import '../../domain/entities/vehicle.dart';

class VehicleListItem extends StatelessWidget {
  final Vehicle vehicle;
  final VoidCallback onDelete;
  final VoidCallback? onEdit;

  const VehicleListItem({
    Key? key,
    required this.vehicle,
    required this.onDelete,
    this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF2563EB);
    const orange = Color(0xFFFFA726);
    const green = Color(0xFF2ECC40);
    const chipBg = Color(0xFFF1F5FF);
    const chipOrangeBg = Color(0xFFFFF3E0);
    const chipGreyBg = Color(0xFFF5F5F5);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 24,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: Icon, title, actions
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: chipBg,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    padding: const EdgeInsets.all(14),
                    child: Icon(
                      Icons.directions_car_rounded,
                      color: blue,
                      size: 34,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      '${vehicle.brand} ${vehicle.model}',
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        letterSpacing: 0.1,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.grey[400],
                      size: 26,
                    ),
                    onPressed: onDelete,
                    splashRadius: 22,
                    tooltip: 'Eliminar',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Chips: Año y motor
              Row(
                children: [
                  _chip(
                    icon: Icons.calendar_today_rounded,
                    label: '${vehicle.year}',
                    color: blue,
                    bgColor: chipBg,
                  ),
                  const SizedBox(width: 8),
                  _chip(
                    icon: Icons.speed_rounded,
                    label: '${vehicle.engineSize} L',
                    color: Colors.white,
                    bgColor: blue,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Chips: Transmisión y combustible
              Row(
                children: [
                  _chip(
                    icon: Icons.settings,
                    label: _capitalize(vehicle.transmission),
                    color: blue,
                    bgColor: chipGreyBg,
                  ),
                  const SizedBox(width: 8),
                  _chip(
                    icon: Icons.local_gas_station_rounded,
                    label: _capitalize(vehicle.fuelType),
                    color: orange,
                    bgColor: chipOrangeBg,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              // Consumo Promedio: tres columnas
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _consumoColumn(
                    'Ciudad',
                    vehicle.consumption.city,
                    blue,
                    Icons.location_city,
                  ),
                  _consumoColumn(
                    'Carretera',
                    vehicle.consumption.highway,
                    green,
                    Icons.route,
                  ),
                  _consumoColumn(
                    'Mixto',
                    vehicle.consumption.mixed,
                    orange,
                    Icons.sync_alt_rounded,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip({
    required IconData icon,
    required String label,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 15),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _consumoColumn(
    String label,
    double value,
    Color color,
    IconData icon,
  ) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${value.toStringAsFixed(1)}L/100km',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }
}
