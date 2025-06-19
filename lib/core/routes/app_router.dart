import 'package:flutter/material.dart';
import 'package:rendiven/features/efficiency/presentation/screens/efficiency_list_screen.dart';
import 'package:rendiven/features/efficiency/presentation/screens/efficiency_form_screen.dart';

class AppRouter {
  static Map<String, WidgetBuilder> get routes => {
    // ... existing routes ...
    '/efficiency': (context) => const EfficiencyListScreen(),
    '/efficiency/create': (context) => const EfficiencyFormScreen(),
    // ... existing code ...
  };
}
