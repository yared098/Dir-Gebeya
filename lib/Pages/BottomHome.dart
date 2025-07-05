import 'package:dirgebeya/Pages/MenuPage.dart' show MenuPage;
import 'package:dirgebeya/Pages/RefundPage.dart';
import 'package:flutter/material.dart';


// Dummy tab screens
import 'dashboard_page.dart'; // Replace with actual DashboardPage
import 'order_list_page.dart'; // Replace with actual OrderListPage


class BottomHomePage extends StatefulWidget {
  const BottomHomePage({super.key});

  @override
  State<BottomHomePage> createState() => _HomePageState();
}

class _HomePageState extends State<BottomHomePage> {
  int _currentIndex = 0;

  // Dummy counts
  int notificationCount = 3;
  int messageCount = 5;

  final List<Widget> _pages = const [
    DashboardPage(),
    OrderListPage(),
    RefundPage(),
    MenuPage(),
  ];

  final List<String> _titles = [
    'Home',
    'My Orders',
    'Refund',
    'Menu',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'DirGebeya Vendor',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          _buildBadgeIcon(Icons.notifications_none, notificationCount),
          const SizedBox(width: 12),
          _buildBadgeIcon(Icons.message_outlined, messageCount),
          const SizedBox(width: 16),
        ],
      ),

      body: _pages[_currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.black,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Homer'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'My Orders'),
          BottomNavigationBarItem(icon: Icon(Icons.refresh), label: 'Refund'),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Menu'),
        ],
      ),
    );
  }

  /// Badge icon builder for notification & message
  Widget _buildBadgeIcon(IconData icon, int count) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        IconButton(
          icon: Icon(icon, color: Colors.black),
          onPressed: () {}, // Add your logic
        ),
        if (count > 0)
          Positioned(
            top: 6,
            right: 6,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
              child: Center(
                child: Text(
                  '$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
