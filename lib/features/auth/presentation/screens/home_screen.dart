import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rendiven/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:rendiven/features/auth/presentation/screens/login_screen.dart';
import 'package:rendiven/features/auth/presentation/screens/register_screen.dart';
import 'package:rendiven/features/fuel/presentation/bloc/fuel_bloc.dart';
import 'package:rendiven/features/fuel/presentation/widgets/new_fuel_modal.dart';
import 'package:rendiven/features/fuel/presentation/widgets/fuel_card.dart';
import 'package:rendiven/features/fuel/presentation/widgets/fuel_edit_modal.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<FuelBloc>().add(LoadFuels());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthInitial || state is AuthError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Rendiven')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    child: const Text('Iniciar Sesión'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterScreen(),
                        ),
                      );
                    },
                    child: const Text('Registrarse'),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is AuthLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is AuthSuccess) {
          final user = state.user;
          return Scaffold(
            backgroundColor: const Color(0xFFF5F6FA),
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Text(
                'Dashboard',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF3B2FE3),
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(
                    Icons.account_circle,
                    color: Color(0xFF3B2FE3),
                  ),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                      ),
                      builder: (context) {
                        return Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Center(
                                child: Column(
                                  children: [
                                    CircleAvatar(
                                      radius: 36,
                                      backgroundColor: const Color(0xFF3B2FE3),
                                      child: Text(
                                        user.name.isNotEmpty
                                            ? user.name[0].toUpperCase()
                                            : '',
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      user.name,
                                      style: GoogleFonts.poppins(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF3B2FE3),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      user.email,
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFF3B2FE3,
                                        ).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Text(
                                        user.role.toUpperCase(),
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: const Color(0xFF3B2FE3),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              ListTile(
                                leading: const Icon(
                                  Icons.settings,
                                  color: Color(0xFF3B2FE3),
                                ),
                                title: Text(
                                  'Configuración',
                                  style: GoogleFonts.poppins(),
                                ),
                                onTap: () {
                                  // TODO: Navegar a pantalla de configuración
                                  Navigator.pop(context);
                                },
                              ),
                              ListTile(
                                leading: const Icon(
                                  Icons.logout,
                                  color: Colors.red,
                                ),
                                title: Text(
                                  'Cerrar sesión',
                                  style: GoogleFonts.poppins(color: Colors.red),
                                ),
                                onTap: () {
                                  Navigator.pop(context);
                                  context.read<AuthBloc>().add(
                                    LogoutRequested(),
                                  );
                                  Navigator.pushNamedAndRemoveUntil(
                                    context,
                                    '/login',
                                    (route) => false,
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  tooltip: 'Perfil',
                ),
              ],
            ),
            body: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              children: [
                // Justo después del AppBar/título y antes de la sección de últimas recargas
                const SizedBox(height: 16),
                BlocBuilder<FuelBloc, FuelState>(
                  builder: (context, fuelState) {
                    if (fuelState is FuelLoaded) {
                      final fuels = List.of(fuelState.fuels)
                        ..sort((a, b) => b.date.compareTo(a.date));
                      final now = DateTime.now();
                      final fuelsThisMonth =
                          fuels
                              .where(
                                (f) =>
                                    f.date.year == now.year &&
                                    f.date.month == now.month,
                              )
                              .toList();
                      final totalMonth = fuelsThisMonth.fold<double>(
                        0,
                        (sum, f) => sum + f.totalCost,
                      );
                      String comparativa = 'No hay datos suficientes';
                      if (fuels.length >= 2) {
                        final last = fuels[0].pricePerLiter;
                        final prev = fuels[1].pricePerLiter;
                        final diff = last - prev;
                        if (diff > 0) {
                          comparativa =
                              'Pagaste ${diff.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} más que la recarga anterior';
                        } else if (diff < 0) {
                          comparativa =
                              'Pagaste ${(-diff).toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} menos que la recarga anterior';
                        } else {
                          comparativa =
                              'Pagaste lo mismo que la recarga anterior';
                        }
                      }
                      String tendencia = 'Sin datos';
                      if (fuels.length >= 3) {
                        final last = fuels[0].pricePerLiter;
                        final prev = fuels[1].pricePerLiter;
                        final prev2 = fuels[2].pricePerLiter;
                        if (last > prev && prev > prev2) {
                          tendencia = 'Subiendo';
                        } else if (last < prev && prev < prev2) {
                          tendencia = 'Bajando';
                        } else {
                          tendencia = 'Estable';
                        }
                      } else if (fuels.length >= 2) {
                        final last = fuels[0].pricePerLiter;
                        final prev = fuels[1].pricePerLiter;
                        if (last > prev) {
                          tendencia = 'Subiendo';
                        } else if (last < prev) {
                          tendencia = 'Bajando';
                        } else {
                          tendencia = 'Estable';
                        }
                      }
                      return SizedBox(
                        height: 140,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            _InfoCard(
                              icon: Icons.attach_money,
                              title: 'Gasto mes',
                              value:
                                  '\$${totalMonth.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                              color: const Color(0xFF3B2FE3),
                            ),
                            const SizedBox(width: 12),
                            _InfoCard(
                              icon: Icons.compare_arrows,
                              title: 'Comparativa',
                              value: comparativa,
                              color: const Color(0xFF6A5AE0),
                            ),
                            const SizedBox(width: 12),
                            _InfoCard(
                              icon: Icons.trending_up,
                              title: 'Tendencia',
                              value: tendencia,
                              color: const Color(0xFF00B894),
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox(height: 140);
                  },
                ),
                const SizedBox(height: 24),
                // Sección de últimas recargas
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Últimas 4 recargas',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF3B2FE3),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => const NewFuelModal(),
                          );
                        },
                        icon: const Icon(
                          Icons.add_circle_outline,
                          color: Color(0xFF3B2FE3),
                          size: 24,
                        ),
                        tooltip: 'Nueva recarga combustible',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Lista de recargas
                BlocBuilder<FuelBloc, FuelState>(
                  builder: (context, fuelState) {
                    if (fuelState is FuelLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF3B2FE3),
                          ),
                        ),
                      );
                    }
                    if (fuelState is FuelLoaded) {
                      final fuels = List.of(fuelState.fuels)
                        ..sort((a, b) => b.date.compareTo(a.date));
                      final latestFuels = fuels.take(4).toList();
                      if (latestFuels.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.local_gas_station,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No hay recargas recientes',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return Column(
                        children:
                            latestFuels.map((fuel) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: FuelCard(
                                  fuel: fuel,
                                  onTap: () {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(24),
                                        ),
                                      ),
                                      builder:
                                          (context) =>
                                              FuelEditModal(fuel: fuel),
                                    );
                                  },
                                ),
                              );
                            }).toList(),
                      );
                    }
                    if (fuelState is FuelError) {
                      return Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 48,
                              color: Colors.red[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              fuelState.message,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          );
        }

        return const Scaffold(body: Center(child: Text('Error desconocido')));
      },
    );
  }
}

// Widget para los cards informativos
class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 190,
      height: 170,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.10),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.15),
                child: Icon(icon, color: color, size: 28),
                radius: 24,
              ),
            ],
          ),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 15,
              color: Colors.grey[700],
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Expanded(
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  color: color,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.1,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
