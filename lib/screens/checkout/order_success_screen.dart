import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';

class OrderSuccessScreen extends StatelessWidget {
  final String orderNumber;
  const OrderSuccessScreen({super.key, required this.orderNumber});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(kPad * 2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle_outline, color: kSuccess, size: 100),
              const SizedBox(height: 32),
              const Text('Order Placed Successfully!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: kNavy)),
              const SizedBox(height: 16),
              Text('Your order #$orderNumber has been received and is being processed.', textAlign: TextAlign.center, style: const TextStyle(color: kMuted, fontSize: 16)),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: () => context.go('/orders'),
                child: const Text('View My Orders'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.go('/'),
                child: const Text('Continue Shopping', style: TextStyle(color: kPrimary, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
