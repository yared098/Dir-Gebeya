class Product {
  final int? productId;
  final String name;
  final double price;
  final String imageUrl;
  final String? type;
  final bool? hasLimitedStock;
  final String message;

  Product({
    this.productId,
    required this.name,
    required this.price,
    required this.imageUrl,
    this.type,
    this.hasLimitedStock = false,
    required this.message
    
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productId: json['product_id'] is int
          ? json['product_id']
          : int.tryParse(json['product_id'].toString()),
      name: json['product_name'] ?? json['name'] ?? '',
      price: (json['product_price'] ?? json['price'] as num).toDouble(),
      imageUrl: json['product_featured_image'] ?? json['imageUrl'] ?? '',
      type: json['type'],
      message:json['message'],
      hasLimitedStock: json['hasLimitedStock'] == true ||
          json['hasLimitedStock'] == 'true' ||
          json['hasLimitedStock'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'product_name': name,
      'product_price': price,
      'product_featured_image': imageUrl,
      'type': type,
      'hasLimitedStock': hasLimitedStock,
      'message':message,
    };
  }
}