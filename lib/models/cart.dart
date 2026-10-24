class Cart {
  final String id;
  final List<CartItem> items;
  final double subtotal;
  final int itemCount;

  Cart({
    required this.id,
    required this.items,
    required this.subtotal,
    required this.itemCount,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      id: json['id'],
      items: (json['items'] as List?)?.map((e) => CartItem.fromJson(e)).toList() ?? [],
      subtotal: double.tryParse(json['subtotal']?.toString() ?? '0') ?? 0.0,
      itemCount: json['item_count'] ?? 0,
    );
  }

  static Cart empty() => Cart(id: '', items: [], subtotal: 0, itemCount: 0);
}

class CartItem {
  final String id;
  final String productId;
  final String? variantId;
  final String productName;
  final String? image;
  final int quantity;
  final double unitPrice;
  final double lineTotal;

  CartItem({
    required this.id,
    required this.productId,
    this.variantId,
    required this.productName,
    this.image,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      productId: json['product_id'],
      variantId: json['variant_id'],
      productName: json['product_name'],
      image: json['image'],
      quantity: json['quantity'] ?? 1,
      unitPrice: double.tryParse(json['unit_price']?.toString() ?? '0') ?? 0.0,
      lineTotal: double.tryParse(json['line_total']?.toString() ?? '0') ?? 0.0,
    );
  }
}
