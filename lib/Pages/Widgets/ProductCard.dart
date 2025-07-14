import 'package:dirgebeya/config/color.dart';
import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  final String image;
  final String title;
  final String soldCount;
  final String viewCount;
  final String shareLink;

  const ProductCard({
    super.key,
    required this.image,
    required this.title,
    required this.soldCount,
    required this.viewCount,
    required this.shareLink,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 3,
      borderRadius: BorderRadius.circular(12),
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          print("url"+image);
          // Optional: handle card tap
        },
        child: Container(
          height: 280, // Fix height to avoid overflow
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Product Image
              AspectRatio(
                aspectRatio: 1.2,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    image,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const Center(child: Icon(Icons.image_not_supported, size: 40)),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
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
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 6),

              // Stats Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _statChip(Icons.shopping_cart, '$soldCount sold'),
                  _statChip(Icons.remove_red_eye, '$viewCount views'),
                ],
              ),

              const Spacer(),

              // Share Button
              SizedBox(
                height: 36,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  icon: const Icon(Icons.share, size: 16),
                  label: const Text("Share", style: TextStyle(fontSize: 13,color: Colors.white)),
                  onPressed: () {
                    // Your share logic here
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Share link copied: $shareLink")),
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

  Widget _statChip(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ],
    );
  }
}
