class ProductModel {
  final int productId;
  final String productName;
  final int viewStatistics;
  final String productSlug;
  final String productFeaturedImage;
  final int totalOrders;
  final String shareLink;
  final String message;


  ProductModel({
    required this.productId,
    required this.productName,
    required this.viewStatistics,
    required this.productSlug,
    required this.productFeaturedImage,
    this.totalOrders = 0,
    this.shareLink = '',
    required this.message,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      productId: json['product_id'] ?? 0,
      productName: json['product_name'] ?? '',
      viewStatistics: json['view_statistics'] ?? 0,
      productSlug: json['product_slug'] ?? '',
      productFeaturedImage: json['product_featured_image'] ?? '',
      totalOrders: json['total_orders'] ?? 0,
      shareLink: json['share_link'] ?? '',
      message: json['message']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'product_name': productName,
      'view_statistics': viewStatistics,
      'product_slug': productSlug,
      'product_featured_image': productFeaturedImage,
      'total_orders': totalOrders,
      'share_link': shareLink,
      'message':message
    };
  }

  /// Convert to simplified UI Map
  Map<String, String> toMapForUI() {
    return {
      'title': productName,
      'image':
          'https://direthiopia.com/assets/images/product/upload/thumb/$productFeaturedImage',
      'sold': totalOrders.toString(),
      'view': viewStatistics.toString(),
      'share': shareLink,
    };
  }
}
