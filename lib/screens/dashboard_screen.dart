import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction.dart';
import '../models/allocation.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      // SingleChildScrollView helps prevent overflows on smaller screens
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildBalanceCard(),
              const SizedBox(height: 30),
              const Text(
                "Transactions",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              // Use Expanded here to tell the list to take the remaining space
              // without pushing past the bottom of the screen
              Expanded(child: _buildTransactionList()),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTransaction(context),
        backgroundColor: const Color(0xFF006D77),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // Use Hive.box() WITHOUT 'await' here because we opened it in main.dart
  Widget _buildBalanceCard() {
    return ValueListenableBuilder(
      valueListenable: Hive.box<Transaction>('transactions').listenable(),
      builder: (context, Box<Transaction> txBox, _) {
        final allocBox = Hive.box<Allocation>('allocations');

        double income = allocBox.values.fold(
          0,
          (sum, item) => sum + item.amount,
        );
        double expense = txBox.values.fold(0, (sum, item) => sum + item.amount);

        return Container(
          // Card implementation...
        );
      },
    );
  }
}

Widget _buildBalanceCard() {
  return ValueListenableBuilder(
    // Listens to both boxes via combined listenable or simply the main transaction box
    valueListenable: Hive.box<Transaction>('transactions').listenable(),
    builder: (context, Box<Transaction> transactionBox, _) {
      final allocationBox = Hive.box<Allocation>('allocations');

      // Logic: Total Income - Total Expenses
      double totalIncome = allocationBox.values.fold(
        0,
        (sum, item) => sum + item.amount,
      );
      double totalExpenses = transactionBox.values.fold(
        0,
        (sum, item) => sum + item.amount,
      );
      double currentBalance = totalIncome - totalExpenses;

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF2EB5B2), // Figma Teal
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2EB5B2).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            const Text(
              "Total Balance",
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              "PKR ${currentBalance.toStringAsFixed(2)}",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatItem(
                  "Income",
                  totalIncome,
                  Icons.arrow_downward,
                  Colors.greenAccent,
                ),
                _buildStatItem(
                  "Expenses",
                  totalExpenses,
                  Icons.arrow_upward,
                  Colors.redAccent,
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}

Widget _buildStatItem(String label, double amount, IconData icon, Color color) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.white60, fontSize: 11),
            ),
            Text(
              "PKR ${amount.toStringAsFixed(0)}",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _buildTransactionList() {
  return ValueListenableBuilder(
    valueListenable: Hive.box<Transaction>('transactions').listenable(),
    builder: (context, Box<Transaction> box, _) {
      if (box.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                size: 64,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 16),
              const Text(
                "No transactions yet",
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        );
      }

      final transactions = box.values.toList().reversed.toList();

      return ListView.separated(
        itemCount: transactions.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final tx = transactions[index];
          return Dismissible(
            key: Key(tx.key.toString()),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (_) => tx.delete(),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xFFF0F9F9),
                    child: Icon(
                      _getIcon(tx.category),
                      color: const Color(0xFF006D77),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tx.category,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "${tx.date.day}/${tx.date.month}/${tx.date.year}",
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    "- PKR ${tx.amount.toStringAsFixed(0)}",
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

void _showAddTransaction(BuildContext context) {
  final cat = TextEditingController();
  final amt = TextEditingController();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Add Expense",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          TextField(
            controller: cat,
            decoration: const InputDecoration(labelText: "Category"),
          ),
          TextField(
            controller: amt,
            decoration: const InputDecoration(
              labelText: "Amount",
              prefixText: "PKR ",
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF006D77),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                final amount = double.tryParse(amt.text) ?? 0;
                if (amount > 0 && cat.text.isNotEmpty) {
                  Hive.box<Transaction>('transactions').add(
                    Transaction(
                      category: cat.text,
                      amount: amount,
                      date: DateTime.now(),
                    ),
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text(
                "Save Expense",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    ),
  );
}

void _showAddIncome(BuildContext context) {
  final amt = TextEditingController();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Add Income",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          TextField(
            controller: amt,
            decoration: const InputDecoration(
              labelText: "Amount",
              prefixText: "PKR ",
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                final amount = double.tryParse(amt.text) ?? 0;
                if (amount > 0) {
                  Hive.box<Allocation>(
                    'allocations',
                  ).add(Allocation(category: 'Income', amount: amount));
                  Navigator.pop(context);
                }
              },
              child: const Text(
                "Add Funds",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    ),
  );
}

IconData _getIcon(String category) {
  switch (category.toLowerCase()) {
    case 'food':
      return Icons.fastfood;
    case 'travel':
      return Icons.directions_bus;
    case 'shopping':
      return Icons.shopping_cart;
    default:
      return Icons.payments;
  }
}
