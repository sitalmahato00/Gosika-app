import 'product.dart';

class Order {
  final String id;
  final String orderNumber;
  final String status;
  final String paymentMethod;
  final String paymentStatus;
  final double subtotal;
  final double discount;
  final double deliveryCharge;
  final double tax;
  final double grandTotal;
  final DateTime placedAt;
  final List<VendorOrder> vendorOrders;
  final Map<String, dynamic>? shippingAddressSnapshot;

  Order({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.subtotal,
    required this.discount,
    required this.deliveryCharge,
    required this.tax,
    required this.grandTotal,
    required this.placedAt,
    required this.vendorOrders,
    this.shippingAddressSnapshot,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      orderNumber: json['order_number'],
      status: json['status'],
      paymentMethod: json['payment_method'],
      paymentStatus: json['payment_status'],
      subtotal: double.tryParse(json['subtotal']?.toString() ?? '0') ?? 0.0,
      discount: double.tryParse(json['discount']?.toString() ?? '0') ?? 0.0,
      deliveryCharge: double.tryParse(json['delivery_charge']?.toString() ?? '0') ?? 0.0,
      tax: double.tryParse(json['tax']?.toString() ?? '0') ?? 0.0,
      grandTotal: double.tryParse(json['grand_total']?.toString() ?? '0') ?? 0.0,
      placedAt: DateTime.parse(json['placed_at'] ?? json['created_at']),
      vendorOrders: (json['vendor_orders'] as List?)
              ?.map((e) => VendorOrder.fromJson(e))
              .toList() ??
          [],
      shippingAddressSnapshot: json['shipping_address_snapshot'],
    );
  }
}

class VendorOrder {
  final String id;
  final String vendorOrderNumber;
  final String status;
  final String deliveryStatus;
  final double grandTotal;
  final List<OrderItem> items;

  VendorOrder({
    required this.id,
    required this.vendorOrderNumber,
    required this.status,
    required this.deliveryStatus,
    required this.grandTotal,
    required this.items,
  });

  factory VendorOrder.fromJson(Map<String, dynamic> json) {
    return VendorOrder(
      id: json['id'],
      vendorOrderNumber: json['vendor_order_number'],
      status: json['status'],
      deliveryStatus: json['delivery_status'],
      grandTotal: double.tryParse(json['grand_total']?.toString() ?? '0') ?? 0.0,
      items: (json['items'] as List?)
              ?.map((e) => OrderItem.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class OrderItem {
  final String id;
  final String productName;
  final String? variantName;
  final String? image;
  final int quantity;
  final double unitPrice;
  final double lineTotal;
  final String deliveryStatus;

  OrderItem({
    required this.id,
    required this.productName,
    this.variantName,
    this.image,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
    required this.deliveryStatus,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      productName: json['product_name'],
      variantName: json['variant_name'],
      image: json['image'],
      quantity: json['quantity'] ?? 0,
      unitPrice: double.tryParse(json['unit_price']?.toString() ?? '0') ?? 0.0,
      lineTotal: double.tryParse(json['line_total']?.toString() ?? '0') ?? 0.0,
      deliveryStatus: json['delivery_status'] ?? 'pending',
    );
  }
}

class OrderTracking {
  final String status;
  final String note;
  final double? latitude;
  final double? longitude;
  final DateTime trackedAt;

  OrderTracking({
    required this.status,
    required this.note,
    this.latitude,
    this.longitude,
    required this.trackedAt,
  });

  factory OrderTracking.fromJson(Map<String, dynamic> json) {
    return OrderTracking(
      status: json['status'],
      note: json['note'] ?? '',
      latitude: double.tryParse(json['latitude']?.toString() ?? ''),
      longitude: double.tryParse(json['longitude']?.toString() ?? ''),
      trackedAt: DateTime.parse(json['tracked_at']),
    );
  }
}

class CheckoutSummary {
  final double subtotal;
  final double discount;
  final double deliveryCharge;
  final double tax;
  final double grandTotal;
  final List<String> availablePaymentMethods;

  CheckoutSummary({
    required this.subtotal,
    required this.discount,
    required this.deliveryCharge,
    required this.tax,
    required this.grandTotal,
    required this.availablePaymentMethods,
  });

  factory CheckoutSummary.fromJson(Map<String, dynamic> json) {
    return CheckoutSummary(
      subtotal: double.tryParse(json['subtotal']?.toString() ?? '0') ?? 0.0,
      discount: double.tryParse(json['discount']?.toString() ?? '0') ?? 0.0,
      deliveryCharge: double.tryParse(json['delivery_charge']?.toString() ?? '0') ?? 0.0,
      tax: double.tryParse(json['tax']?.toString() ?? '0') ?? 0.0,
      grandTotal: double.tryParse(json['grand_total']?.toString() ?? '0') ?? 0.0,
      availablePaymentMethods: List<String>.from(json['available_payment_methods'] ?? []),
    );
  }
}
