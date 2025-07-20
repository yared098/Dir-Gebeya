import 'package:dirgebeya/Pages/ProductDetailPage.dart' show ProductDetailPage;
import 'package:dirgebeya/Pages/Widgets/RecentCallsPage.dart';
import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  final String image;
  final String title;
  final String soldCount;
  final String viewCount;
  final String shareLink;
  final String message;
  final int id;

  const ProductCard({
    super.key,
    required this.image,
    required this.title,
    required this.soldCount,
    required this.viewCount,
    required this.shareLink,
    required this.message,
    required this.id,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? Colors.grey[900] : Colors.white;
    final textColor = isDark ? Colors.white70 : Colors.black87;
    final subtitleColor = isDark ? Colors.grey[400] : Colors.black54;

    return Material(
      elevation: 3,
      borderRadius: BorderRadius.circular(12),
      color: cardColor,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          print("url: $image");
        },
        child: Container(
          height: 280,
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Product Image
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductDetailPage(
                        title: title,
                        image: image,
                        price: '',
                        productId: id,
                      ),
                    ),
                  );
                },
                child: AspectRatio(
                  aspectRatio: 1.2,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      image,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Center(
                        child: Icon(Icons.image_not_supported, size: 40),
                      ),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(child: CircularProgressIndicator());
                      },
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Title
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),

              const SizedBox(height: 6),

              // Stats Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _statChip(
                    Icons.shopping_cart,
                    '$soldCount sold',
                    subtitleColor!,
                  ),
                  _statChip(
                    Icons.remove_red_eye,
                    '$viewCount views',
                    subtitleColor,
                  ),
                ],
              ),

              const Spacer(),

              // Share Button
              SizedBox(
                height: 36,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  icon: const Icon(Icons.share, size: 16),
                  label: Text(
                    "Share",
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      builder: (context) {
                        return RecentCallsContent(
                          message: message,
                          shareLink: shareLink,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statChip(IconData icon, String text, Color textColor) {
    return Row(
      children: [
        Icon(icon, size: 14, color: textColor),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 12, color: textColor)),
      ],
    );
  }
}
