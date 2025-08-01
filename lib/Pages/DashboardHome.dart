import 'package:dirgebeya/Pages/HomePage.dart';
import 'package:dirgebeya/Pages/Delivery_Screen.dart';
import 'package:dirgebeya/Pages/Widgets/BottomSheetDashBoard.dart';
import 'package:dirgebeya/Pages/order_list_page.dart';
import 'package:dirgebeya/Pages/MenuDemoScreen.dart'; // needed for showAppMenuBottomSheet()
import 'package:dirgebeya/Provider/profile_provider.dart';
import 'package:dirgebeya/config/color.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  @override
void initState() {
  super.initState();
  _initStatusUpdate();
}

  void _initStatusUpdate() async {
  final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
  await profileProvider.updateUserStatusInfo();
  
}

  final List<Widget> _screens = const [
    HomePage(),
    MyOrderScreen(),
    RefundScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 8.0,
        onTap: (index) {
          if (index == 3) {
            // Show bottom sheet instead of switching screen
            showAppMenuBottomSheet(context);
          } else {
            setState(() {
              _selectedIndex = index;
            });
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('assets/image/home.png')),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('assets/image/orders.png')),
            label: 'My Order',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.delivery_dining),
            label: 'Delivery',
          ),

          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('assets/image/menu.png')),
            label: 'Menu',
          ),
        ],
      ),
    );
  }
}
