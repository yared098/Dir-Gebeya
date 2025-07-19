import 'package:dirgebeya/Model/ProductModel.dart';
import 'package:dirgebeya/Pages/Widgets/ProductCard.dart';
import 'package:dirgebeya/config/api_config.dart';
import 'package:flutter/material.dart';

class TopProductsGrid extends StatelessWidget {
  final List<ProductModel> topProducts;

  const TopProductsGrid({super.key, required this.topProducts});

  final String fallbackImage =
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRdP4BEslWaCgOcdLfQUfoDugdR84xlJUypUQ&s';

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: topProducts.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.68,
      ),
      itemBuilder: (context, index) {
        final product = topProducts[index];
        final hasImage = product.productFeaturedImage != null && product.productFeaturedImage!.isNotEmpty;
        final baseImageUrl = ApiConfig.productimage.endsWith('/')
            ? ApiConfig.productimage
            : '${ApiConfig.productimage}/';

        final imageUrl = hasImage
            ? '$baseImageUrl${product.productFeaturedImage}'
            : fallbackImage;

        return ProductCard(
          image: imageUrl,
          title: product.productName ?? 'No Title',
          soldCount: product.totalOrders?.toString() ?? '0',
          viewCount: product.viewStatistics?.toString() ?? '0',
          shareLink: product.shareLink ?? '',
          message:product.message,
        );
      },
    );
  }
}
