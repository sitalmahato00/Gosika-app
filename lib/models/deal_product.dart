class DealProduct {
  final String id;
  final String name;
  final String slug;
  final double price;
  final double? compareAtPrice;
  final String? imageUrl;
  final String? brandName;
  final double ratingAvg;
  final int ratingCount;
  final String stockStatus;

  DealProduct({
    required this.id,
    required this.name,
    required this.slug,
    required this.price,
    this.compareAtPrice,
    this.imageUrl,
    this.brandName,
    required this.ratingAvg,
    required this.ratingCount,
    required this.stockStatus,
  });

  factory DealProduct.fromJson(Map<String, dynamic> json) {
    return DealProduct(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      compareAtPrice: json['compare_at_price'] != null
          ? double.tryParse(json['compare_at_price'].toString())
          : null,
      imageUrl: json['primary_image']?['url'] ?? json['image'],
      brandName: json['brand']?['name'],
      ratingAvg: double.tryParse(json['rating_avg']?.toString() ?? '0') ?? 0.0,
      ratingCount: json['rating_count'] ?? 0,
      stockStatus: json['stock_status'] ?? 'in_stock',
    );
  }

  int get discountPercentage {
    if (compareAtPrice == null || compareAtPrice! <= price) return 0;
    return (((compareAtPrice! - price) / compareAtPrice!) * 100).round();
  }
}
