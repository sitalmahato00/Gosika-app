class PlatformConfig {
  final String name;
  final String logoUrl;
  final String currency;
  final String currencySymbol;
  final String primaryColor;
  final CheckoutConfig checkout;

  PlatformConfig({
    required this.name,
    required this.logoUrl,
    required this.currency,
    required this.currencySymbol,
    required this.primaryColor,
    required this.checkout,
  });

  factory PlatformConfig.fromJson(Map<String, dynamic> json) {
    return PlatformConfig(
      name: json['brand_name'] ?? 'GOSIKA',
      logoUrl: json['logo_light'] ?? '',
      currency: json['currency']?['code'] ?? 'NPR',
      currencySymbol: json['currency_symbol'] ?? 'रु',
      primaryColor: json['primary_color'] ?? '#ff5500',
      checkout: CheckoutConfig.fromJson(json),
    );
  }
}

class CheckoutConfig {
  final bool codEnabled;
  final bool khaltiEnabled;
  final bool esewaEnabled;

  CheckoutConfig({
    required this.codEnabled,
    required this.khaltiEnabled,
    required this.esewaEnabled,
  });

  factory CheckoutConfig.fromJson(Map<String, dynamic> json) {
    bool parseBool(dynamic value) {
      if (value == null) return false;
      if (value is bool) return value;
      if (value is String) return value == 'true' || value == '1';
      if (value is int) return value == 1;
      return false;
    }

    // The backend returns these in data.payment
    final payment = json['payment'] ?? {};
    
    return CheckoutConfig(
      codEnabled: parseBool(payment['cod_enabled'] ?? json['cod_enabled']),
      khaltiEnabled: parseBool(payment['khalti_enabled']),
      esewaEnabled: parseBool(payment['esewa_enabled']),
    );
  }
}
