class CustomerAddress {
  final String id;
  final String label;
  final String fullName;
  final String phone;
  final String addressLine1;
  final String? addressLine2;
  final int provinceId;
  final int districtId;
  final int municipalityId;
  final String? postalCode;
  final String? landmark;
  final double? latitude;
  final double? longitude;
  final bool isDefault;

  CustomerAddress({
    required this.id,
    required this.label,
    required this.fullName,
    required this.phone,
    required this.addressLine1,
    this.addressLine2,
    required this.provinceId,
    required this.districtId,
    required this.municipalityId,
    this.postalCode,
    this.landmark,
    this.latitude,
    this.longitude,
    required this.isDefault,
  });

  factory CustomerAddress.fromJson(Map<String, dynamic> json) {
    return CustomerAddress(
      id: json['id'],
      label: json['label'],
      fullName: json['full_name'],
      phone: json['phone'],
      addressLine1: json['address_line_1'],
      addressLine2: json['address_line_2'],
      provinceId: json['province_id'],
      districtId: json['district_id'],
      municipalityId: json['municipality_id'],
      postalCode: json['postal_code'],
      landmark: json['landmark'],
      latitude: double.tryParse(json['latitude']?.toString() ?? ''),
      longitude: double.tryParse(json['longitude']?.toString() ?? ''),
      isDefault: json['is_default'] == 1 || json['is_default'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'full_name': fullName,
      'phone': phone,
      'address_line_1': addressLine1,
      'address_line_2': addressLine2,
      'province_id': provinceId,
      'district_id': districtId,
      'municipality_id': municipalityId,
      'postal_code': postalCode,
      'landmark': landmark,
      'latitude': latitude,
      'longitude': longitude,
      'is_default': isDefault,
    };
  }
}
