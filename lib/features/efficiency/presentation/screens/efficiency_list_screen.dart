import 'package:flutter/material.dart';
import 'package:rendiven/features/efficiency/domain/controllers/efficiency_controller.dart';
import 'package:rendiven/features/efficiency/domain/models/efficiency_model.dart';
import 'package:rendiven/features/efficiency/presentation/screens/efficiency_form_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rendiven/services/storage/storage_service.dart';
import 'package:rendiven/features/efficiency/presentation/widgets/efficiency_card.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui';

class EfficiencyListScreen extends StatefulWidget {
  const EfficiencyListScreen({super.key});

  @override
  State<EfficiencyListScreen> createState() => _EfficiencyListScreenState();
}

class _EfficiencyListScreenState extends State<EfficiencyListScreen> {
  late EfficiencyController _controller;
  List<EfficiencyModel> _efficiencies = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initControllerAndLoadEfficiencies();
  }

  Future<void> _initControllerAndLoadEfficiencies() async {
    final prefs = await SharedPreferences.getInstance();
    final storageService = StorageService(prefs);
    _controller = EfficiencyController(
      baseUrl: 'http://10.0.2.2:5000/api',
      storageService: storageService,
    );
    await _loadEfficiencies();
  }

  Future<void> _loadEfficiencies() async {
    try {
      final efficiencies = await _controller.getEfficiencies();
      setState(() {
        _efficiencies = efficiencies;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar las eficiencias: $e')),
        );
      }
    }
  }

  Future<void> _deleteEfficiency(String id) async {
    try {
      await _controller.deleteEfficiency(id);
      await _loadEfficiencies();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Eficiencia eliminada correctamente')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar la eficiencia: $e')),
        );
      }
    }
  }

  void _showEfficiencyDetailModal(EfficiencyModel efficiency) {
    // Obtener el valor de la última recarga de combustible si está disponible
    double? lastFuelPrice;
    if (_efficiencies.isNotEmpty) {
      // Buscar la eficiencia más reciente (o asociada a este registro si se guarda ese dato)
      // Aquí simplemente tomamos el precio de la eficiencia seleccionada si existiera ese campo, pero como no existe, lo dejamos null
      // Si tienes una lógica para asociar fuelPrice, puedes ajustarla aquí
      lastFuelPrice = null;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.transparent,
      builder: (context) {
        return Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: const Color(0xFFF5F6FA).withOpacity(0.95),
                width: double.infinity,
                height: MediaQuery.of(context).size.height,
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(32),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 24,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Container(
                              width: 40,
                              height: 4,
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          Text(
                            'Detalle de Eficiencia',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF3B2FE3),
                            ),
                          ),
                          const SizedBox(height: 18),
                          EfficiencyCard(
                            efficiency: efficiency,
                            isDetail: true,
                            onTap: null,
                            fuelPrice: lastFuelPrice,
                          ),
                          const SizedBox(height: 18),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blueGrey,
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                  _showEfficiencyFormModal(
                                    efficiency: efficiency,
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.redAccent,
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                  showDialog(
                                    context: context,
                                    builder:
                                        (context) => AlertDialog(
                                          title: const Text(
                                            'Confirmar eliminación',
                                          ),
                                          content: const Text(
                                            '¿Estás seguro de que deseas eliminar este registro de eficiencia?',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed:
                                                  () => Navigator.pop(context),
                                              child: const Text('Cancelar'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                                _deleteEfficiency(
                                                  efficiency.id,
                                                );
                                              },
                                              child: const Text('Eliminar'),
                                            ),
                                          ],
                                        ),
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEfficiencyFormModal({EfficiencyModel? efficiency}) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: EfficiencyFormScreen(efficiency: efficiency),
              ),
            ),
          ),
        );
      },
    );
    _loadEfficiencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Eficiencia de Combustible',
          style: TextStyle(
            color: Color(0xFF3B2FE3),
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [],
      ),
      floatingActionButton: _PremiumAddButton(
        onTap: () {
          _showEfficiencyFormModal();
        },
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _efficiencies.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.speed_rounded,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No hay registros de eficiencia',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 8,
                ),
                itemCount: _efficiencies.length,
                itemBuilder: (context, index) {
                  final sortedEfficiencies = List<EfficiencyModel>.from(
                    _efficiencies,
                  )..sort((a, b) => b.date.compareTo(a.date));
                  final efficiency = sortedEfficiencies[index];
                  return EfficiencyCard(
                    efficiency: efficiency,
                    onTap: () => _showEfficiencyDetailModal(efficiency),
                  );
                },
              ),
    );
  }
}

// --- Botón premium/minimalista ---
class _PremiumAddButton extends StatefulWidget {
  final VoidCallback onTap;
  const _PremiumAddButton({required this.onTap});

  @override
  State<_PremiumAddButton> createState() => _PremiumAddButtonState();
}

class _PremiumAddButtonState extends State<_PremiumAddButton> {
  double _scale = 1.0;

  void _onTapDown(TapDownDetails details) {
    setState(() => _scale = 0.93);
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _scale = 1.0);
  }

  void _onTapCancel() {
    setState(() => _scale = 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14, right: 8),
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: AnimatedScale(
          scale: _scale,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.10),
                  blurRadius: 32,
                  spreadRadius: 0,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Center(
              child: Icon(Icons.add, color: Color(0xFF3B2FE3), size: 28),
            ),
          ),
        ),
      ),
    );
  }
}
