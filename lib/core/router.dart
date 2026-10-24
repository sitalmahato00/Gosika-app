import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/welcome_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/verify_email_screen.dart';
import '../screens/location/location_permission_screen.dart';
import '../screens/catalog/product_detail_screen.dart';
import '../screens/catalog/product_list_screen.dart';
import '../screens/cart/cart_screen.dart';
import '../screens/checkout/checkout_screen.dart';
import '../screens/checkout/address_form_screen.dart';
import '../screens/checkout/order_success_screen.dart';
import '../screens/orders/order_list_screen.dart';
import '../screens/orders/order_detail_screen.dart';
import '../screens/account/account_screen.dart';
import '../screens/account/profile_screen.dart';
import '../screens/account/address_list_screen.dart';
import '../screens/account/wishlist_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/main_navigation_screen.dart';
import '../screens/checkout/payment_webview_screen.dart';
import '../screens/auth/verify_phone_screen.dart';

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen<AuthState>(
      authProvider,
      (previous, next) {
        if (previous?.isAuthenticated != next.isAuthenticated) {
          notifyListeners();
        }
      },
    );
  }
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

final routerProvider = Provider<GoRouter>((ref) {
  final routerNotifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: routerNotifier,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final isAuthenticated = authState.isAuthenticated;
      final isSplash = state.matchedLocation == '/splash';
      final isLoggingIn = state.matchedLocation == '/login';
      final isRegistering = state.matchedLocation == '/register';
      final isWelcome = state.matchedLocation == '/welcome';

      if (isSplash) return null;

      if (isAuthenticated && (isLoggingIn || isRegistering || isWelcome)) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/location-permission',
        builder: (context, state) => const LocationPermissionScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const MainNavigationScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/verify-email',
        builder: (context, state) {
          final email = state.extra as String? ?? '';
          return VerifyEmailScreen(email: email);
        },
      ),
      GoRoute(
        path: '/verify-phone',
        builder: (context, state) {
          final phone = state.extra as String? ?? '';
          return VerifyPhoneScreen(phone: phone);
        },
      ),
      GoRoute(
        path: '/shop',
        builder: (context, state) => const ProductListScreen(title: 'Shop'),
      ),
      GoRoute(
        path: '/categories/:uuid',
        builder: (context, state) {
          final uuid = state.pathParameters['uuid']!;
          final title = state.uri.queryParameters['name'];
          return ProductListScreen(title: title ?? 'Category', categoryId: uuid);
        },
      ),
      GoRoute(
        path: '/brands/:uuid',
        builder: (context, state) {
          final uuid = state.pathParameters['uuid']!;
          final title = state.uri.queryParameters['name'];
          return ProductListScreen(title: title ?? 'Brand', brandId: uuid);
        },
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) {
          final query = state.uri.queryParameters['q'];
          return ProductListScreen(title: 'Search: $query', search: query);
        },
      ),
      GoRoute(
        path: '/products/:uuid',
        builder: (context, state) {
          final uuid = state.pathParameters['uuid']!;
          return ProductDetailScreen(productId: uuid);
        },
      ),
      GoRoute(
        path: '/cart',
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        path: '/checkout',
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: '/checkout/address/new',
        builder: (context, state) => const AddressFormScreen(),
      ),
      GoRoute(
        path: '/checkout/payment',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return PaymentWebViewScreen(orderId: extra['orderId'], method: extra['method']);
        },
      ),
      GoRoute(
        path: '/checkout/success',
        builder: (context, state) {
          final orderNo = state.extra as String? ?? '';
          return OrderSuccessScreen(orderNumber: orderNo);
        },
      ),
      GoRoute(
        path: '/orders',
        builder: (context, state) => const OrderListScreen(),
      ),
      GoRoute(
        path: '/orders/:uuid',
        builder: (context, state) {
          final uuid = state.pathParameters['uuid']!;
          return OrderDetailScreen(orderId: uuid);
        },
      ),
      GoRoute(
        path: '/account',
        builder: (context, state) => const AccountScreen(),
      ),
      GoRoute(
        path: '/account/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/account/addresses',
        builder: (context, state) => const AddressListScreen(),
      ),
      GoRoute(
        path: '/wishlist',
        builder: (context, state) => const WishlistScreen(),
      ),
    ],
  );
});
