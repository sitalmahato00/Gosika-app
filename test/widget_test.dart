import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gosika_ecommerce_app/shared/widgets/gosika_logo.dart';
import 'package:gosika_ecommerce_app/shared/widgets/primary_auth_button.dart';

void main() {
  testWidgets('GosikaLogo renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: GosikaLogo(logoSize: 80, showTagline: true),
        ),
      ),
    );

    expect(find.text('GOSIKA'), findsOneWidget);
    expect(find.text('Shop Smarter, Live Better'), findsOneWidget);
  });

  testWidgets('PrimaryAuthButton renders and responds to tap', (WidgetTester tester) async {
    bool tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PrimaryAuthButton(
            text: 'Create Account',
            onPressed: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.text('Create Account'), findsOneWidget);
    await tester.tap(find.text('Create Account'));
    expect(tapped, isTrue);
  });
}
