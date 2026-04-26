import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction.dart';
import 'overview_widget.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _currentIndex = 0;
  bool _isMenuOpen = false; // Toggles the 3-option menu

  final List<Widget> _pages = [
    const OverviewWidget(), // This is the screen from image_4.png
    const Center(child: Text("Budgets")),
    const Center(child: Text("Insights")),
    const Center(child: Text("Settings")),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Light background like Figma
      body: _pages[_currentIndex],

      // The fixed Bottom Navbar
      bottomNavigationBar: _buildBottomNavbar(),

      // This stack places the floating menu OVER the body, in the bottom-right corner.
      floatingActionButton: _buildExpandableMenu(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // --- UI Component: The 3-Option Expanding Menu ---
  Widget _buildExpandableMenu() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // 1. The Options (Animated visibility)
        AnimatedVisibility(
          visible: _isMenuOpen,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildMenuIcon(
                  Icons.edit_note,
                  "Manual",
                  () => _showManualEntryForm(context),
                ),
                _buildMenuIcon(
                  Icons.qr_code_scanner_outlined,
                  "Capture",
                  () {},
                ),
                _buildMenuIcon(Icons.cloud_upload_outlined, "Upload", () {}),
              ],
            ),
          ),
        ),

        // 2. The Main Trigger Button (The Blue X or +)
        GestureDetector(
          onTap: () => setState(() => _isMenuOpen = !_isMenuOpen),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF003DA5), // Figma blue
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Icon(
              _isMenuOpen ? Icons.close : Icons.add,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
      ],
    );
  }

  // Individual Icon Component (White background with blue icon)
  Widget _buildMenuIcon(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        setState(() => _isMenuOpen = false); // Close menu on tap
        onTap();
      },
      child: Container(
        margin: const EdgeInsets.only(left: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: const Color(0xFF003DA5), size: 24),
      ),
    );
  }

  // --- DATA LOGIC: Saving to Hive Box ---
  void _saveNewTransactionToHive() {
    // Access the open database box
    final ledgerBox = Hive.box<Transaction>('ledgerBox');

    // Create the new entry (we will hardcode this for now for the demo)
    final newTx = Transaction(
      title: 'New Manual Entry',
      category: 'MISC',
      date: DateTime.now(),
      amount: -250.00, // Expense
    );

    // Add it to the box. This automatically updates any UI listening to the box.
    ledgerBox.add(newTx);
  }

  // Modal form from image_4.png (Simplified for demo)
  void _showManualEntryForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Add Transaction Manually",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const TextField(decoration: InputDecoration(labelText: 'Title')),
            const TextField(decoration: InputDecoration(labelText: 'Amount')),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(
                    0xFF003DA5,
                  ), // Blue "Save Up" button
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  // Execute saving logic
                  _saveNewTransactionToHive();
                  Navigator.pop(context); // Close the form
                },
                child: const Text(
                  "Save Up",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Standard Bottom Navbar Logic (Figma-styled)
  Widget _buildBottomNavbar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) => setState(() => _currentIndex = index),
      selectedItemColor: const Color(0xFF003DA5),
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.grid_view_rounded),
          label: 'OVERVIEW',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_balance_wallet_outlined),
          label: 'BUDGETS',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.analytics_outlined),
          label: 'INSIGHTS',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings_outlined),
          label: 'SETTINGS',
        ),
      ],
    );
  }
}

// Simple helper widget for the fade animation
class AnimatedVisibility extends StatelessWidget {
  final bool visible;
  final Widget child;
  const AnimatedVisibility({
    super.key,
    required this.visible,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: visible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: Visibility(visible: visible, child: child),
    );
  }
}
