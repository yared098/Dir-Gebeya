import 'package:dirgebeya/Pages/Widgets/statistics_widgets.dart';
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
    Future.microtask(() {
      Provider.of<ProductsProvider>(context, listen: false).fetchProducts();
    });
  }

  Future<void> _refreshProducts() async {
    await Provider.of<ProductsProvider>(context, listen: false).fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductsProvider>(context);
    final isLoading = productProvider.isLoading;
    final error = productProvider.error;
    final products = productProvider.products;

    final topProducts = products.map((product) {
      return {
        'image': product.imageUrl,
        'title': product.name,
        'sold': product.price?.toString() ?? '1',
      };
    }).toList();

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshProducts,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(), // Required for RefreshIndicator
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                const SectionTitle(
                  icon: Icons.star,
                  iconColor: Colors.amber,
                  title: 'Top Selling Products',
                ),
                const SizedBox(height: 16),
                if (isLoading)
                  const Center(child: CircularProgressIndicator())
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
