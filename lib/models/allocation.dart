import 'package:hive/hive.dart';

part 'allocation.g.dart'; // This is the file that is currently "missing"

//update
@HiveType(typeId: 0)
class Allocation extends HiveObject {
  @HiveField(0)
  String category;

  @HiveField(1)
  double amount;

  Allocation({required this.category, required this.amount});
}
