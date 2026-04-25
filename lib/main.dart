import 'package:flutter/material.dart';
import 'services/database_service.dart';
import 'screens/liveness_screen.dart';

void main() async {
  // 1. Ensure Flutter is ready
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Wait for Hive to open 'allocations' and 'transactions'
  // This prevents the "Box not found" error
  await DatabaseService.init();

  runApp(const MyExpenseApp());
}

class MyExpenseApp extends StatelessWidget {
  const MyExpenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expense Tracker',
      theme: ThemeData(primarySwatch: Colors.teal, useMaterial3: true),
      // Start with Liveness Check for the HNG showcase
      home: const LivenessScreen(),
    );
  }
}
