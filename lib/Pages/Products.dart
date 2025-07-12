import 'package:dirgebeya/Pages/Widgets/statistics_widgets.dart';
import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dirgebeya/Provider/products_provider.dart'; // update path accordingly

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}
class _StatisticsScreenState extends State<StatisticsScreen> {
  String? _dropdownValue = 'This Year';

  @override
  void initState() {
    super.initState();

    // Call fetchProducts after the widget is built
    Future.microtask(() {
      Provider.of<ProductsProvider>(context, listen: false).fetchProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductsProvider>(context);
    
    final isLoading = productProvider.isLoading;
    final error = productProvider.error;
    final products = productProvider.products;

    // Convert product data to expected map format
    final topProducts = products.map((product) {
      return {
        'image': product.imageUrl,
        'title': product.name,
        'sold': product.price?.toString() ?? '1',
      };
    }).toList();

    print("products"+topProducts.toList().toString());

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(1),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SectionTitle(
                  icon: Icons.star,
                  iconColor: Colors.amber,
                  title: 'Top Selling Products',
                ),
                const SizedBox(height: 16),

                if (isLoading)
                  const CircularProgressIndicator()
                else if (error != null)
                  Text(error, style: const TextStyle(color: Colors.red))
                else if (topProducts.isEmpty)
                  const Text('No products found.')
                else
                  TopProductsGrid(topProducts: topProducts),
              ],
            ),
          ),
        ),
      ),
    );
  }
}