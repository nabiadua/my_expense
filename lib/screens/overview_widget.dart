import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction.dart';

class OverviewWidget extends StatelessWidget {
  const OverviewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 60),
          // 1. Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundImage: NetworkImage(
                    'https://via.placeholder.com/150',
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  "Sovereign Ledger",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF003DA5),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.notifications_none_rounded),
                ),
              ],
            ),
          ),

          // 2. Portfolio Card
          _buildPortfolioCard(),

          // 3. Allocations Section
          _buildSectionHeader("Allocations"),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _buildAllocationBox(
                  "Transport",
                  "\$320",
                  0.7,
                  Icons.directions_car,
                ),
                _buildAllocationBox(
                  "Dining Out",
                  "\$485",
                  0.9,
                  Icons.restaurant,
                ),
                _buildAllocationBox(
                  "Health",
                  "\$150",
                  0.3,
                  Icons.medical_services,
                ),
              ],
            ),
          ),

          // 4. Spending Trend
          _buildSectionHeader("Spending Trend"),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            height: 180,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey[100]!),
            ),
            child: const Center(
              child: Icon(Icons.show_chart, size: 50, color: Color(0xFF003DA5)),
            ),
          ),

          // 5. Recent Ledger (DYNAMIC SECTION)
          _buildSectionHeader("Recent Ledger"),

          // ValueListenableBuilder listens to the 'ledgerBox' for any changes
          ValueListenableBuilder(
            valueListenable: Hive.box<Transaction>('ledgerBox').listenable(),
            builder: (context, Box<Transaction> box, _) {
              if (box.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Text(
                      "No transactions yet.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                );
              }

              // Get transactions and sort them so newest appears at the top
              final transactions = box.values.toList()
                ..sort((a, b) => b.date.compareTo(a.date));

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final tx = transactions[index];
                  return _buildLedgerItem(tx);
                },
              );
            },
          ),

          const SizedBox(height: 100), // Space for FAB
        ],
      ),
    );
  }

  Widget _buildPortfolioCard() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0047AB),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "LIQUID WEALTH PORTFOLIO",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                  letterSpacing: 1.2,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "+12.5%",
                  style: TextStyle(color: Colors.greenAccent, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            "\$42,950.40",
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            "Market valuation as of today",
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildCardButton("DEPOSIT")),
              const SizedBox(width: 12),
              Expanded(child: _buildCardButton("WITHDRAW")),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardButton(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildAllocationBox(
    String title,
    String amount,
    double progress,
    IconData icon,
  ) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blue[900], size: 20),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(
            amount,
            style: TextStyle(
              color: Colors.blue[900],
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[200],
            color: Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Text(
            "View All",
            style: TextStyle(color: Colors.blue, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // UPDATED: Now takes a Transaction object as an argument
  Widget _buildLedgerItem(Transaction tx) {
    final bool isExpense = tx.amount < 0;

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(_getCategoryIcon(tx.category)),
      ),
      title: Text(
        tx.title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        "${tx.category.toUpperCase()} • ${tx.date.hour}:${tx.date.minute}",
      ),
      trailing: Text(
        "${isExpense ? '-' : '+'}\$${tx.amount.abs().toStringAsFixed(2)}",
        style: TextStyle(
          color: isExpense ? Colors.red : Colors.green,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'transport':
        return Icons.directions_car_outlined;
      case 'dining out':
        return Icons.restaurant;
      case 'technology':
        return Icons.shopping_bag_outlined;
      default:
        return Icons.receipt_long;
    }
  }
}
