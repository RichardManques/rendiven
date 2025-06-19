import 'package:flutter/material.dart';
import '../../domain/models/efficiency_model.dart';

class EfficiencyCard extends StatelessWidget {
  final EfficiencyModel efficiency;
  final VoidCallback? onTap;
  final bool isDetail;
  final double? fuelPrice;

  const EfficiencyCard({
    Key? key,
    required this.efficiency,
    this.onTap,
    this.isDetail = false,
    this.fuelPrice,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF2563EB);
    const orange = Color(0xFFFFA726);
    const green = Color(0xFF2ECC40);
    const chipBg = Color(0xFFF1F5FF);
    const chipOrangeBg = Color(0xFFFFF3E0);
    const chipGreyBg = Color(0xFFF5F5F5);

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: Icon, tipo de ruta y estilo
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: chipBg,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      padding: const EdgeInsets.all(14),
                      child: const Icon(
                        Icons.speed_rounded,
                        color: blue,
                        size: 34,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.directions_car,
                                size: 16,
                                color: blue,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _capitalize(efficiency.routeType),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Icon(
                                Icons.emoji_people,
                                size: 16,
                                color: blue,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                _capitalize(efficiency.drivingStyle),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Fecha: 	${efficiency.date.day.toString().padLeft(2, '0')}/${efficiency.date.month.toString().padLeft(2, '0')}/${efficiency.date.year}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Chips: Ajustada, Costo/km, Recorrido, Total
                Row(
                  children: [
                    _chip(
                      icon: Icons.local_gas_station,
                      label:
                          'Ajustada: ${efficiency.efficiency.adjusted.toStringAsFixed(1)} km/L',
                      color: green,
                      bgColor: chipBg,
                    ),
                    const SizedBox(width: 8),
                    _chip(
                      icon: Icons.attach_money,
                      label:
                          'Costo/km: ${efficiency.cost.perKm.toStringAsFixed(0)}',
                      color: orange,
                      bgColor: chipOrangeBg,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _chip(
                      icon: Icons.timeline,
                      label:
                          'Recorrido: ${efficiency.kmConsumed.toStringAsFixed(0)} km',
                      color: blue,
                      bgColor: chipBg,
                    ),
                    const SizedBox(width: 8),
                    _chip(
                      icon: Icons.payments,
                      label:
                          'Total: ${efficiency.cost.total.toStringAsFixed(0)}',
                      color: green,
                      bgColor: chipBg,
                    ),
                  ],
                ),
                if (isDetail) ...[
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      _chip(
                        icon: Icons.ac_unit_rounded,
                        label: efficiency.useAC ? 'Con A/C' : 'Sin A/C',
                        color: blue,
                        bgColor: chipGreyBg,
                      ),
                      if (fuelPrice != null) ...[
                        const SizedBox(width: 8),
                        _chip(
                          icon: Icons.local_gas_station_rounded,
                          label: 'Precio/L: ${fuelPrice!.toStringAsFixed(0)}',
                          color: orange,
                          bgColor: chipOrangeBg,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'ID: ${efficiency.id}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ],
            ),
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

  static String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}
