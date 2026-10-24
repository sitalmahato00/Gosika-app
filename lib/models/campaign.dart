class Campaign {
  final String id;
  final String title;
  final String tagline;
  final String description;
  final String image;
  final String type;
  final String discountType;
  final String discountValue;
  final DateTime startDate;
  final DateTime endDate;

  Campaign({
    required this.id,
    required this.title,
    required this.tagline,
    required this.description,
    required this.image,
    required this.type,
    required this.discountType,
    required this.discountValue,
    required this.startDate,
    required this.endDate,
  });

  factory Campaign.fromJson(Map<String, dynamic> json) {
    return Campaign(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      tagline: json['tagline'] ?? '',
      description: json['description'] ?? '',
      image: json['image'] ?? '',
      type: json['type'] ?? 'promotion',
      discountType: json['discount_type'] ?? 'percentage',
      discountValue: json['discount_value']?.toString() ?? '0',
      startDate: DateTime.parse(json['start_date'] ?? DateTime.now().toIso8601String()),
      endDate: DateTime.parse(json['end_date'] ?? DateTime.now().toIso8601String()),
    );
  }

  String get discountText {
    if (discountType == 'percentage') {
      return 'Up to $discountValue% OFF';
    } else {
      return 'Save रु $discountValue';
    }
  }
}
