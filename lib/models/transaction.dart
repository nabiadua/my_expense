import 'package:hive/hive.dart';

part 'transaction.g.dart';

@HiveType(typeId: 0) // typeId 0 is unique for this class
class Transaction extends HiveObject {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final String category;

  @HiveField(2)
  final DateTime date;

  @HiveField(3)
  final double amount; // Positive for Income, Negative for Expense

  Transaction({
    required this.title,
    required this.category,
    required this.date,
    required this.amount,
  });
}
