import 'package:dirgebeya/Pages/SheetPages/BankInfoPage.dart';
import 'package:dirgebeya/Pages/SheetPages/MyShopPage.dart';
import 'package:dirgebeya/Pages/SheetPages/ProductGridPage.dart';
import 'package:dirgebeya/Pages/SheetPages/ProductList.dart';
import 'package:dirgebeya/Pages/SheetPages/ProfilePage.dart';
import 'package:dirgebeya/Pages/SheetPages/TransactionPage.dart';
import 'package:dirgebeya/Pages/SheetPages/VendorProfilePage.dart';
import 'package:dirgebeya/Pages/SheetPages/WalletPage.dart';
import 'package:flutter/material.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  int _selectedIndex = -1;

  final List<_MenuItem> menuItems = const [
    _MenuItem(title: 'My Profile', icon: Icons.person),
    _MenuItem(title: 'Profile', icon: Icons.person),
    _MenuItem(title: 'My Shop', icon: Icons.store),
    _MenuItem(title: 'Products', icon: Icons.inventory),
    _MenuItem(title: 'Product list', icon: Icons.inventory),
    _MenuItem(title: 'Settings', icon: Icons.settings),
    _MenuItem(title: 'Wallet', icon: Icons.account_balance_wallet),
    _MenuItem(title: 'Bank Info', icon: Icons.account_balance),
      _MenuItem(title: 'Transaction Info', icon: Icons.transcribe),
    _MenuItem(title: 'Logout', icon: Icons.logout),
    _MenuItem(title: 'Refund', icon: Icons.refresh),
    _MenuItem(title: 'Share', icon: Icons.share),
    _MenuItem(title: 'Notification', icon: Icons.notifications),
  ];

  final List<Widget> _pages = [
    const ProfilePage(),
    const VendorProfilePage(), // 👤
    MyShopPage(),
    ProductGridPage(), // 📦
    ProductsListSection(),
    const Center(child: Text('⚙️ Settings Page')),
    WalletPage(), // 💰
    BankInfoPage(),
    TransactionPage(),
    const Center(child: Text('🚪 Logout Page')),
    const Center(child: Text('📤 ShRefed Page')), // 🔄
    const Center(child: Text('📤 Share Page')),
    const Center(child: Text('🔔 Notification Page')),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showGridBottomSheet();
    });
  }

  void _showGridBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          maxChildSize: 0.85,
          minChildSize: 0.4,
          builder: (_, controller) {
            return Padding(
              padding: const EdgeInsets.all(12),
              child: GridView.builder(
                controller: controller,
                itemCount: menuItems.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4, // ✅ 4 columns
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.8, // smaller card
                ),
                itemBuilder: (context, index) {
                  final item = menuItems[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(context);

                      // Fullscreen pages by index
                      final fullScreenPages = [0, 1, 3, 5, 6];

                      if (fullScreenPages.contains(index)) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => _pages[index]),
                        );
                      } else {
                        setState(() {
                          _selectedIndex = index;
                        });
                      }
                    },

                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(item.icon, size: 28, color: Colors.blue),
                            const SizedBox(height: 6),
                            Text(
                              item.title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
      body: _selectedIndex == -1
          ? const Center(child: Text("👆 Please select a service"))
          : _pages[_selectedIndex],
    );
  }
}

class _MenuItem {
  final String title;
  final IconData icon;

  const _MenuItem({required this.title, required this.icon});
}
