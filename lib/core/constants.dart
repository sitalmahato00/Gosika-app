import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Colors
const Color kPrimary = Color(0xFFFF5500); // Gosika orange-red
const Color kPrimaryDark = Color(0xFFE04B00);
const Color kNavy = Color(0xFF161D2B);
const Color kInk = Color(0xFF1E293B);
const Color kMuted = Color(0xFF64748B);
const Color kBorder = Color(0xFFE2E8F0);
const Color kBg = Color(0xFFF4F6F9);
const Color kSurface = Color(0xFFFFFFFF);
const Color kSuccess = Color(0xFF10B981);
const Color kWarning = Color(0xFFF59E0B);
const Color kDanger = Color(0xFFEF4444);

// Spacing & Radius
const double kRadius = 10.0;
const double kRadiusLg = 14.0;
const double kRadiusXl = 20.0;
const double kPad = 16.0;

// API Constants
const String kBaseUrl = 'https://gosika.sital.info.np/api/v1';
const String kTokenKey = 'gosika_token';

// Currency Formatter
String formatNPR(dynamic amount) {
  final d = double.tryParse(amount?.toString() ?? '0') ?? 0.0;
  final format = NumberFormat.currency(
    locale: 'en_NP',
    symbol: 'रु',
    decimalDigits: 2,
  );
  return format.format(d);
}
