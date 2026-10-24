import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../providers/cart_provider.dart';
import '../../providers/address_provider.dart';
import '../../providers/platform_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/address.dart';
import '../../services/checkout_service.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  CustomerAddress? _selectedAddress;
  String _selectedPayment = 'cod';
  bool _isPlacingOrder = false;
  final TextEditingController _couponController = TextEditingController();

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartAsync = ref.watch(cartProvider);
    final addressesAsync = ref.watch(addressListProvider);
    final platformConfig = ref.watch(platformConfigProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Checkout',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: kNavy),
        ),
      ),
      body: cartAsync.when(
        data: (cart) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Delivery Address Section
                _buildSectionTitle('Delivery Address', onActionTap: () {
                  context.push('/checkout/address/new');
                }, actionText: 'Change'),
                const SizedBox(height: 8),
                addressesAsync.when(
                  data: (list) {
                    if (list.isEmpty) return _buildAddAddressCta();
                    _selectedAddress ??= list.firstWhere((e) => e.isDefault, orElse: () => list.first);
                    return _buildAddressCard(_selectedAddress!);
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Color(0xFFFF5722))),
                  ),
                  error: (e, s) => Text('Error loading addresses: $e'),
                ),
                const SizedBox(height: 24),

                // Payment Method Section
                _buildSectionTitle('Payment Method'),
                const SizedBox(height: 8),
                platformConfig.when(
                  data: (config) => Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        if (config.checkout.codEnabled)
                          _buildPaymentOption('cod', 'Cash on Delivery', Icons.payments_outlined),
                        if (config.checkout.esewaEnabled)
                          _buildPaymentOption('esewa', 'eSewa Mobile Wallet', Icons.account_balance_wallet_outlined),
                        if (config.checkout.khaltiEnabled)
                          _buildPaymentOption('khalti', 'Khalti Digital Wallet', Icons.account_balance_wallet),
                      ],
                    ),
                  ),
                  loading: () => const LinearProgressIndicator(),
                  error: (e, s) => const Text('Error loading payment methods'),
                ),
                const SizedBox(height: 24),

                // Apply Coupon Section
                _buildSectionTitle('Apply Coupon'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _couponController,
                        decoration: InputDecoration(
                          hintText: 'Enter coupon code',
                          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          filled: true,
                          fillColor: Colors.grey[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFFFF5722)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        if (_couponController.text.isNotEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Coupon applied successfully!'),
                              backgroundColor: Color(0xFFFF5722),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF5722),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(80, 48),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      child: const Text('Apply', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Order Summary Section
                _buildSectionTitle('Order Summary'),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      _buildSummaryRow('Items (${cart.items.length})', formatNPR(cart.subtotal)),
                      const SizedBox(height: 6),
                      _buildSummaryRow('Delivery Fee', 'रु 0.00'),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Divider(height: 1),
                      ),
                      _buildSummaryRow('Grand Total', formatNPR(cart.subtotal), isBold: true),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Place Order Button
                ElevatedButton(
                  onPressed: (_selectedAddress == null || _isPlacingOrder) ? null : _handlePlaceOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF5722),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  child: _isPlacingOrder
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Place Order', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Color(0xFFFF5722))),
        ),
        error: (e, s) => Center(child: Text('Error loading checkout: $e')),
      ),
    );
  }

  Widget _buildSectionTitle(String title, {VoidCallback? onActionTap, String actionText = '+ Add New'}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: kNavy)),
        if (onActionTap != null)
          GestureDetector(
            onTap: onActionTap,
            child: Text(
              actionText,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFFF5722)),
            ),
          ),
      ],
    );
  }

  Widget _buildAddAddressCta() {
    return InkWell(
      onTap: () => context.push('/checkout/address/new'),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.05),
          border: Border.all(color: const Color(0xFFFF5722).withOpacity(0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Column(
          children: [
            Icon(Icons.add_location_alt_outlined, color: Color(0xFFFF5722), size: 32),
            SizedBox(height: 8),
            Text(
              'No saved addresses. Tap to add one.',
              style: TextStyle(color: Color(0xFFFF5722), fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressCard(CustomerAddress addr) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.location_on_outlined, color: Color(0xFFFF5722), size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(addr.label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: kNavy)),
                const SizedBox(height: 2),
                Text(addr.fullName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                Text(addr.addressLine1, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                Text(addr.phone, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(String val, String title, IconData icon) {
    final isSelected = _selectedPayment == val;
    return InkWell(
      onTap: () => setState(() => _selectedPayment = val),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Radio<String>(
              value: val,
              groupValue: _selectedPayment,
              onChanged: (v) => setState(() => _selectedPayment = v!),
              activeColor: const Color(0xFFFF5722),
            ),
            Icon(icon, color: isSelected ? const Color(0xFFFF5722) : Colors.grey[600], size: 20),
            const SizedBox(width: 10),
            Text(
              title,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
                color: kNavy,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 15 : 13,
            color: isBold ? kNavy : Colors.grey[600],
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 17 : 13,
            color: isBold ? const Color(0xFFFF5722) : kNavy,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Future<void> _handlePlaceOrder() async {
    setState(() => _isPlacingOrder = true);
    try {
      final cart = ref.read(cartProvider).value!;
      final itemIds = cart.items.map((e) => e.id).toList();
      final checkoutService = CheckoutService(await ref.read(apiClientProvider));

      final sessionId = await checkoutService.createSession(addressId: _selectedAddress!.id, itemIds: itemIds);
      final result = await checkoutService.placeOrder(checkoutSessionId: sessionId, paymentMethod: _selectedPayment);

      if (mounted) {
        ref.invalidate(cartProvider);

        if (_selectedPayment == 'cod') {
          context.go('/checkout/success', extra: result.orderNumber);
        } else {
          context.push('/checkout/payment', extra: {'orderId': result.id, 'method': _selectedPayment});
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Checkout failed: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isPlacingOrder = false);
    }
  }
}
