class Product {
  final String id;
  final String name;
  final String slug;
  final String? description;
  final String? shortDescription;
  final String? sku;
  final double price;
  final double? compareAtPrice;
  final String? image;
  final List<String> images;
  final List<ProductVariant> variants;
  final double ratingAvg;
  final int ratingCount;
  final bool isFeatured;
  final String status;
  final String stockStatus;

  Product({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.shortDescription,
    this.sku,
    required this.price,
    this.compareAtPrice,
    this.image,
    required this.images,
    required this.variants,
    required this.ratingAvg,
    required this.ratingCount,
    required this.isFeatured,
    required this.status,
    required this.stockStatus,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
      description: json['description'],
      shortDescription: json['short_description'],
      sku: json['sku'],
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      compareAtPrice: json['compare_at_price'] != null
          ? double.tryParse(json['compare_at_price'].toString())
          : null,
      image: json['image'] ?? json['primary_image']?['url'],
      images: (json['images'] as List?)?.map((e) => e['url'] as String).toList() ?? [],
      variants: (json['variants'] as List?)
              ?.map((e) => ProductVariant.fromJson(e))
              .toList() ??
          [],
      ratingAvg: double.tryParse(json['rating_avg']?.toString() ?? '0') ?? 0.0,
      ratingCount: json['rating_count'] ?? 0,
      isFeatured: json['is_featured'] == 1 || json['is_featured'] == true,
      status: json['status'] ?? 'active',
      stockStatus: json['stock_status'] ?? 'in_stock',
    );
  }
}

class ProductVariant {
  final String id;
  final String? name;
  final double price;
  final String? sku;
  final Map<String, String> attributes;

  ProductVariant({
    required this.id,
    this.name,
    required this.price,
    this.sku,
    required this.attributes,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      id: json['id'],
      name: json['name'],
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      sku: json['sku'],
      attributes: Map<String, String>.from(json['attributes'] ?? {}),
    );
  }
}

class Category {
  final String id;
  final String name;
  final String slug;
  final String? icon;
  final String? image;

  Category({
    required this.id,
    required this.name,
    required this.slug,
    this.icon,
    this.image,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
      icon: json['icon'] ?? json['icon_url'],
      image: json['image_url'],
    );
  }
}

class Banner {
  final String id;
  final String? title;
  final String imageUrl;
  final String? linkType;
  final String? linkId;

  Banner({
    required this.id,
    this.title,
    required this.imageUrl,
    this.linkType,
    this.linkId,
  });

  factory Banner.fromJson(Map<String, dynamic> json) {
    return Banner(
      id: json['id'],
      title: json['title'],
      imageUrl: json['image_url'],
      linkType: json['link_type'],
      linkId: json['link_id'],
    );
  }
}

class PaginatedResponse<T> {
  final List<T> data;
  final PaginationMeta meta;

  PaginatedResponse({required this.data, required this.meta});
}

class PaginationMeta {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  PaginationMeta({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    final pagination = json['pagination'] ?? json;
    return PaginationMeta(
      currentPage: pagination['current_page'] ?? 1,
      lastPage: pagination['last_page'] ?? 1,
      perPage: pagination['per_page'] ?? 20,
      total: pagination['total'] ?? 0,
    );
  }
}
