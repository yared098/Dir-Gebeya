import 'dart:typed_data';

import 'package:dirgebeya/Model/Product.dart';
import 'package:dirgebeya/Pages/SheetPages/ProductDetailsScreen.dart';
import 'package:dirgebeya/Provider/products_provider.dart';
import 'package:dirgebeya/utils/token_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'All';
   String? _token;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductsProvider>(context, listen: false).fetchProducts();
    });
     _loadToken();

     
  }




  Future<void> _loadToken() async {
    final token = await TokenStorage.getToken();
    if (token == null) {
      debugPrint("❌ Missing token");
    }
    setState(() {
      _token = token;
    });
  }
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductsProvider>(context);
    final allProducts = provider.products;

    // ✅ Apply search and filter logic
    final filteredProducts = allProducts.where((product) {
      final matchesSearch = product.name.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );

      final matchesFilter =
          _selectedFilter == 'All' ||
          (product.type?.toLowerCase() == _selectedFilter.toLowerCase());

      return matchesSearch && matchesFilter;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black54),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Product List',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.error != null
          ? Center(child: Text(provider.error!))
          : Column(
              children: [
                _buildSearchBar(context),
                Expanded(
                  child: filteredProducts.isEmpty
                      ? const Center(child: Text("No products found"))
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          itemCount: filteredProducts.length,
                          separatorBuilder: (context, index) => const Divider(
                            height: 1,
                            indent: 16,
                            endIndent: 16,
                          ),
                          itemBuilder: (context, index) {
                            return ProductListItem(
                              product: filteredProducts[index],
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          // 🔍 Search Field
          Expanded(
            child: TextField(
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
              decoration: InputDecoration(
                hintText: 'Search by product name',
                hintStyle: TextStyle(color: Colors.grey.shade500),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFFF3F4F6),
                contentPadding: const EdgeInsets.symmetric(vertical: 15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // 🎛 Filter Button with fixed options
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.filter_list, color: Colors.white),
              onSelected: (value) {
                setState(() => _selectedFilter = value);
              },
              itemBuilder: (BuildContext context) {
                const statusOptions = [
                  'All',
                  'Pending',
                  'Approved',
                  'Rejected',
                ];
                return statusOptions
                    .map(
                      (status) =>
                          PopupMenuItem(value: status, child: Text(status)),
                    )
                    .toList();
              },
            ),
          ),
        ],
      ),
    );
  }
}

// --- REUSABLE PRODUCT LIST ITEM WIDGET ---


class ProductListItem extends StatefulWidget {
  final Product product;
  final String? token;

  const ProductListItem({super.key, required this.product, this.token});

  @override
  State<ProductListItem> createState() => _ProductListItemState();
}

class _ProductListItemState extends State<ProductListItem> {
  Uint8List? _imageBytes;
  bool _loadingImage = false;
  bool _imageLoadError = false;

  @override
  void initState() {
    super.initState();
    _fetchImage();
  }

  Future<void> _fetchImage() async {
    if (widget.token == null || widget.product.imageUrl.isEmpty) {
      // No token or no image, skip fetch
      return;
    }

    setState(() {
      _loadingImage = true;
      _imageLoadError = false;
    });

    final url = "https://direthiopia.com/assets/images/product/upload/thumb/${widget.product.imageUrl}";

    try {
      final response = await http.get(Uri.parse(url), headers: {
        'Authorization': 'Bearer ${widget.token}',
      });
      print("response"+widget.token.toString());

      if (response.statusCode == 200) {
        setState(() {
          _imageBytes = response.bodyBytes;
        });
      } else {
        setState(() {
          _imageLoadError = true;
        });
      }
    } catch (e) {
      setState(() {
        _imageLoadError = true;
      });
    } finally {
      setState(() {
        _loadingImage = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Side: Image and Type
          Column(
            children: [
              Container(
                width: 80,
                height: 80,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: _loadingImage
                    ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                    : (_imageBytes != null
                        ? Image.memory(_imageBytes!, fit: BoxFit.cover)
                        : Image.asset('assets/image/logo.png', fit: BoxFit.cover)),
              ),
              const SizedBox(height: 8),
              Text(
                widget.product.type ?? '',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          // Middle: Product Info (same as your original code)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.product.hasLimitedStock ?? false)
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Limited Stocks', style: TextStyle(fontSize: 13)),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.inventory_2_outlined, color: Colors.white, size: 14),
                        ),
                      ],
                    ),
                  ),
                Text(
                  widget.product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1FAE5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Approved',
                    style: TextStyle(color: Color(0xFF065F46), fontWeight: FontWeight.w600, fontSize: 12),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${widget.product.price.toStringAsFixed(2)} ETB',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ],
            ),
          ),
          // Right Side: Options Menu (keep your original)
          const SizedBox(width: 8),
          Builder(
            builder: (context) {
              return InkWell(
                onTap: () {
                  // Your existing _showActionMenu logic or replace here
                },
                customBorder: const CircleBorder(),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 5,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.more_horiz, color: Colors.grey, size: 20),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}