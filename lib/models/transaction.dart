import 'package:hive/hive.dart';

part 'transaction.g.dart';

@HiveType(typeId: 1)
class Transaction extends HiveObject {
  @HiveField(0)
  late String category;

  @HiveField(1)
  late double amount;

  @HiveField(2)
  late DateTime date;

  Transaction({
    required this.category,
    required this.amount,
    required this.date,
  });
}
