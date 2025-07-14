import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

class EarningsHeader extends StatelessWidget {
  final String? dropdownValue;
  final Function(String?) onChanged;

  const EarningsHeader({
    super.key,
    required this.dropdownValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isSmallScreen = constraints.maxWidth < 400;

        return Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 12,
          children: [
            const SectionTitle(
              icon: Icons.monetization_on,
              iconColor: Colors.green,
              title: 'Earning Statistics',
            ),
            Container(
              width: isSmallScreen ? double.infinity : 180,
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.grey.shade300, width: 1.5),
                color: Colors.white,
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: dropdownValue,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
                  onChanged: onChanged,
                  items: const ['This Year', 'This Month', 'Overall']
                      .map((value) => DropdownMenuItem<String>(
                            value: value,
                            child: Text(value, style: TextStyle(color: Colors.black54)),
                          ))
                      .toList(),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class EarningsLegend extends StatelessWidget {
  const EarningsLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        LegendItem(color: Color(0xFF1E3A8A), label: 'Your Earnings'),
        SizedBox(width: 24),
        LegendItem(color: Color(0xFFFBBF24), label: 'Commission Given'),
      ],
    );
  }
}

class LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const LegendItem({super.key, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: Colors.black54, fontSize: 14)),
      ],
    );
  }
}

class SectionTitle extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;

  const SectionTitle({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 28),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
      ],
    );
  }
}

class NoStatsCard extends StatelessWidget {
  const NoStatsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Column(
        children: [
          Icon(Icons.insert_chart_outlined, color: Colors.grey[300], size: 60),
          const SizedBox(height: 16),
          Text(
            'No statistics generated yet',
            style: TextStyle(color: Colors.grey[500], fontSize: 16),
          ),
        ],
      ),
    );
  }
}
class TopProductsGrid extends StatelessWidget {
  final List<Map<String, String>> topProducts;
  final String fallbackImage =
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRdP4BEslWaCgOcdLfQUfoDugdR84xlJUypUQ&s'; // Default image

  const TopProductsGrid({super.key, required this.topProducts});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: topProducts.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemBuilder: (context, index) {
        final product = topProducts[index];
        final imageUrl = (product['image'] == null || product['image']!.isEmpty)
            ? fallbackImage
            : product['image']!;
        // return ProductCard(
        //   image: imageUrl,
        //   // image: fallbackImage,
        //   title: product['title'] ?? 'No Title',
        //   soldCount: product['sold'] ?? '0',
        // );
      },
    );
  }
}
class ProductCard extends StatelessWidget {
  final String image;
  final String title;
  final String soldCount;

  const ProductCard({
    super.key,
    required this.image,
    required this.title,
    required this.soldCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 6,
            spreadRadius: 1,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Full-fit image
          AspectRatio(
            aspectRatio: 1.2,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                image,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Center(child: Icon(Icons.image_not_supported)),
              ),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6),
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),

          // Sold count badge
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Align(
              alignment: Alignment.center,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$soldCount Sold',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}
