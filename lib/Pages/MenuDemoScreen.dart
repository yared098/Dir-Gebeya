// Create a RouteObserver that you provide to MaterialApp
import 'package:flutter/material.dart';

final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

class MenuDemoScreen extends StatefulWidget {
  const MenuDemoScreen({super.key});

  @override
  State<MenuDemoScreen> createState() => _MenuDemoScreenState();
}

class _MenuDemoScreenState extends State<MenuDemoScreen> with RouteAware {
  @override
  void initState() {
    super.initState();
    // Show bottom sheet when first built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showAppMenuBottomSheet(context);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Subscribe to the route observer
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    // Unsubscribe when disposed
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  // Called when this route has been pushed.
  @override
  void didPush() {
    // You could also show here but it's handled in initState.
  }

  // Called when coming back to this route (e.g., after pop)
  @override
  void didPopNext() {
    // Show bottom sheet again when user returns to this page
    showAppMenuBottomSheet(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
    );
  }
}

// This function can be called from anywhere to show the menu
void showAppMenuBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        builder: (_, controller) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
            ),
            child: AppMenuGrid(parentContext: context), // ✅ Pass context
          );
        },
      );
    },
  );
}


class AppMenuGrid extends StatelessWidget {
  const AppMenuGrid({super.key, required BuildContext parentContext});

  // Data for the menu grid items.
  static final List<Map<String, dynamic>> _menuItems = [
   
    {
      'icon': "assets/image/profile.png",
      'label': 'Profile',
      // 'color': Color(0xff4a90e2),
      'route': '/profile',
    },
    {
      'icon': "assets/image/my-shop.png",
      'label': 'My Shop',
      'color': Color(0xff50e3c2),
      'route': '/my-shop',
    },
    {
      'icon': "assets/image/product.png",
      'label': 'Products',
      // 'color': Color(0xfff5a623),
      'route': '/products',
    },
    {
      'icon': "assets/image/settings.png",
      'label': 'Settings',
      'color': Color(0xff9b9b9b),
      'route': '/settings',
    },
    {
      'icon': "assets/image/wallet.png",
      'label': 'Wallet',
      // 'color': Color(0xff2ecc71),
      'route': '/wallet',
    },
    {
      'icon': "assets/image/message.png",
      'label': 'Message',
      'color': Color(0xff3498db),
      'route': '/messages',
    },
    {
      'icon': "assets/image/bank-info.png",
      'label': 'Bank Info',
      'color': Color(0xff8e44ad),
      'route': '/bank-info',
    },
    {
      'icon': "assets/image/terms-and-conditions.png",
      'label': 'Terms & C...',
      // 'color': Color(0xfff39c12),
      'route': '/terms',
    },

    {
      'icon': "assets/image/transactions.png",
      'label': 'Transaction',
      // 'color': Color(0xff16a085),
      'route': '/transaction',
    },
    {
      'icon': "assets/image/refunds.png",
      'label': 'Loan',
      'color': Color(0xff16a085),
      'route': '/loan',
    },
    {
      'icon': "assets/image/about-us.png",
      'label': 'About Us',
      'color': Color(0xff16a085),
      'route': '/about',
    },
    {
      'icon': "assets/image/refund_policy.png",
      'label': 'Loan policy...',
      // 'color': Color(0xffd35400),
      'route': '/loan-policy',
    },
    {
      'icon': "assets/image/logout.png",
      'label': 'Logout',
      // 'color': Color(0xff34495e),
      'route': '/logout',
    },
    {
      'icon': "assets/image/logout.png",
      'label': 'Request',
      // 'color': Color(0xff34495e),
      'route': '/request',
    },
    {
      'icon': "assets/image/app-info.png",
      'label': 'v - 15.2',
      // 'color': Colors.blueGrey,
      'route': null, // No route
    },

    // RequestPage
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // The small grey handle at the top of the sheet
        const SizedBox(height: 12),
        const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
        const SizedBox(height: 12),
        // The grid of menu items
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio:
                  0.9, // Adjust this ratio to get the desired item height
            ),
            itemCount: _menuItems.length,
            itemBuilder: (context, index) {
              final item = _menuItems[index];
              return _buildMenuItem(
                iconPath: item['icon'],
                color: item['color'],
                label: item['label'],
                onTap: () {
                  Navigator.pop(context); // Close the bottom sheet
                  final route = item['route'];
                  if (route != null) {
                    Navigator.pushNamed(context, route);
                  } else {
                    // Optional: handle items like version info with no route
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${item['label']} has no page')),
                    );
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }
Widget _buildMenuItem({
    required String iconPath,
    required String label,
    required Color? color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              iconPath,
              width: 32,
              height: 32,
              color: color, // optional tint color
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

}
