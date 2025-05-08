import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rendiven/core/constants/api_constants.dart';
import 'package:rendiven/features/auth/data/services/auth_service.dart';
import 'package:rendiven/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:rendiven/features/auth/presentation/screens/login_screen.dart';
import 'package:rendiven/features/auth/presentation/screens/register_screen.dart';
import 'package:rendiven/features/splash/presentation/splash_screen.dart';
import 'package:rendiven/services/storage/storage_service.dart';
import 'package:rendiven/features/navigation/main_navigation.dart';
import 'package:rendiven/features/fuel/presentation/bloc/fuel_bloc.dart';
import 'package:rendiven/features/fuel/data/services/fuel_service.dart';
import 'package:rendiven/features/fuel/presentation/screens/fuel_history_screen.dart';
import 'package:rendiven/features/vehicle/presentation/bloc/vehicle_bloc.dart';
import 'package:rendiven/features/vehicle/data/services/vehicle_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final storageService = StorageService(prefs);

  runApp(MyApp(storageService: storageService));
}

class MyApp extends StatelessWidget {
  final StorageService storageService;

  const MyApp({super.key, required this.storageService});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create:
              (context) => AuthBloc(
                authService: AuthService(
                  baseUrl: ApiConstants.baseUrl,
                  storageService: storageService,
                ),
              ),
        ),
        BlocProvider(
          create:
              (context) => FuelBloc(
                fuelService: FuelService(
                  baseUrl: ApiConstants.baseUrl,
                  storageService: storageService,
                ),
              ),
        ),
        BlocProvider(
          create:
              (context) => VehicleBloc(
                vehicleService: VehicleService(
                  baseUrl: ApiConstants.baseUrl,
                  storageService: storageService,
                ),
              ),
        ),
      ],
      child: MaterialApp(
        title: 'Rendiven',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/home': (context) => const MainNavigation(),
          '/fuel-history': (context) => const FuelHistoryScreen(),
        },
      ),
    );
  }
}
