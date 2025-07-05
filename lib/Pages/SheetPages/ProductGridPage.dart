import 'package:flutter/material.dart';

class ProductGridPage extends StatelessWidget {
  ProductGridPage({super.key});

  final List<Map<String, dynamic>> topProducts = [
    {
      'name': 'Wireless Headphones',
      'quantitySold': 120,
      'imageUrl':
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTkB4CEjRkLRzwcydd137vmel61jC_hs3wQpA&s',
    },
    {
      'name': 'Smart Watch',
      'quantitySold': 95,
      'imageUrl':
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTkB4CEjRkLRzwcydd137vmel61jC_hs3wQpA&s',
    },
    {
      'name': 'Gaming Mouse',
      'quantitySold': 85,
      'imageUrl':
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTkB4CEjRkLRzwcydd137vmel61jC_hs3wQpA&s',
    },
    {
      'name': 'Portable Speaker',
      'quantitySold': 75,
      'imageUrl':
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTkB4CEjRkLRzwcydd137vmel61jC_hs3wQpA&s',
    },
    {
      'name': 'Backpack',
      'quantitySold': 65,
      'imageUrl':
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTkB4CEjRkLRzwcydd137vmel61jC_hs3wQpA&s',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 🔝 Title
              const Text(
                "🔥 Top Selling Products",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 16),

              /// 🔳 Product Grid
              Expanded(
                child: GridView.builder(
                  itemCount: topProducts.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.8,
                  ),
                  itemBuilder: (context, index) {
                    final product = topProducts[index];
                    return _buildProductCard(product);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    return Card(
      elevation: 3,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      shadowColor: Colors.blue.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            /// 🖼️ Product Image (Centered)
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  product['imageUrl'],
                  height: 80,
                  width: 80,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 12),

            /// 📦 Product Name
            Text(
              product['name'],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),

            /// 🛒 Quantity Sold
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.shopping_cart_outlined,
                    size: 16, color: Colors.blue),
                const SizedBox(width: 6),
                Text(
                  'Sold: ${product['quantitySold']}',
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
