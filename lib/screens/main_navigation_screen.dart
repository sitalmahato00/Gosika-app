import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import 'account/account_screen.dart';
import 'account/wishlist_screen.dart';
import 'catalog/category_screen.dart';
import 'home/home_screen.dart';
import 'home/widgets/floating_bottom_nav.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    CategoryScreen(),
    WishlistScreen(),
    AccountScreen(),
    AccountScreen(),
  ];

  void _onItemTapped(int index) {
    final requiresAuth = [2, 3, 4].contains(index); // Wishlist, Account
    final isAuthenticated = ref.read(authProvider).isAuthenticated;

    if (requiresAuth && !isAuthenticated) {
      context.push('/login');
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Active Screen
          IndexedStack(
            index: _selectedIndex,
            children: _screens,
          ),

          // Floating Bottom Navigation Bar Overlay
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: FloatingBottomNav(
                selectedIndex: _selectedIndex,
                onItemTapped: _onItemTapped,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
