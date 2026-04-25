import 'package:hive_flutter/hive_flutter.dart';
import '../models/allocation.dart';
import '../models/transaction.dart';

class DatabaseService {
  static Future<void> init() async {
    await Hive.initFlutter();

    // Register your generated adapters
    Hive.registerAdapter(AllocationAdapter());
    Hive.registerAdapter(TransactionAdapter());

    // Open both boxes used in the dashboard
    await Hive.openBox<Allocation>('allocations');
    await Hive.openBox<Transaction>('transactions');
  }
}
