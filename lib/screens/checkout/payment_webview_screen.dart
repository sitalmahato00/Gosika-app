import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../providers/auth_provider.dart';
import '../../services/checkout_service.dart';
import '../../core/api_client.dart';

class PaymentWebViewScreen extends ConsumerStatefulWidget {
  final String orderId;
  final String method;
  const PaymentWebViewScreen({super.key, required this.orderId, required this.method});

  @override
  ConsumerState<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends ConsumerState<PaymentWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(GestureDetector().behavior == HitTestBehavior.opaque ? JavaScriptMode.unrestricted : JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) => setState(() => _isLoading = false),
          onNavigationRequest: (request) {
            if (request.url.contains('payments/callback/success')) {
              final uri = Uri.parse(request.url);
              final data = uri.queryParameters['data'];
              if (data != null) {
                _verifyAndFinish(data);
              } else {
                context.go('/checkout/success', extra: 'payment_confirmed');
              }
              return NavigationDecision.prevent;
            }
            if (request.url.contains('payments/callback/failure')) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Payment failed or cancelled'), backgroundColor: kDanger),
              );
              context.pop();
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      );

    _loadPayment();
  }

  Future<void> _loadPayment() async {
    try {
      final apiClient = ref.read(apiClientProvider);
      final service = CheckoutService(apiClient);
      final paymentData = await service.initiatePayment(
        orderId: widget.orderId,
        paymentMethod: widget.method,
      );

      if (widget.method == 'esewa') {
        final form = paymentData['payment_form'];
        final action = form['action'];
        final fields = form['fields'] as Map<String, dynamic>;

        String html = '<html><body onload="document.forms[0].submit()"><form method="POST" action="$action">';
        fields.forEach((key, value) {
          html += '<input type="hidden" name="$key" value="$value">';
        });
        html += '</form></body></html>';

        _controller.loadHtmlString(html);
      } else if (widget.method == 'khalti') {
        final url = paymentData['payment_url'];
        _controller.loadRequest(Uri.parse(url));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Initialization error: $e')));
        context.pop();
      }
    }
  }

  Future<void> _verifyAndFinish(String data) async {
    setState(() => _isLoading = true);
    try {
      final apiClient = ref.read(apiClientProvider);
      await CheckoutService(apiClient).verifyEsewa(data);
      if (mounted) context.go('/checkout/success', extra: 'payment_verified');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Verification failed, but payment might have gone through.')));
        context.go('/orders');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.method.toUpperCase()} Payment')),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
