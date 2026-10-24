import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../providers/order_provider.dart';
import '../../models/order.dart';

class OrderListScreen extends ConsumerStatefulWidget {
  const OrderListScreen({super.key});

  @override
  ConsumerState<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends ConsumerState<OrderListScreen> {
  int _selectedTabIndex = 0;
  final List<String?> _statuses = [null, 'processing', 'shipped', 'delivered'];
  final List<String> _tabLabels = ['All', 'Processing', 'Shipped', 'Delivered'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('My Orders', style: TextStyle(fontWeight: FontWeight.bold, color: kNavy, fontSize: 18)),
      ),
      body: Column(
        children: [
          // Filter Chips Row
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _tabLabels.length,
              itemBuilder: (context, index) {
                final isSelected = _selectedTabIndex == index;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(
                      _tabLabels[index],
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedTabIndex = index;
                      });
                    },
                    selectedColor: const Color(0xFFFF5722),
                    backgroundColor: Colors.grey[100],
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    showCheckmark: false,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // Order List Content
          Expanded(
            child: _OrderListContent(status: _statuses[_selectedTabIndex]),
          ),
        ],
      ),
    );
  }
}

class _OrderListContent extends ConsumerWidget {
  final String? status;
  const _OrderListContent({this.status});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(orderListProvider(status));

    if (state.isLoading && state.orders.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Color(0xFFFF5722))),
      );
    }

    if (state.orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_outlined, size: 70, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text('No orders found', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kNavy)),
            const SizedBox(height: 4),
            const Text('When you place orders, they will appear here.', style: TextStyle(color: kMuted, fontSize: 13)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.orders.length,
      itemBuilder: (context, index) => _OrderCard(order: state.orders[index]),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '#${order.orderNumber}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: kNavy),
              ),
              _StatusBadge(status: order.status),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${_formatDate(order.placedAt)} • ${order.vendorOrders.length} item(s)',
            style: TextStyle(color: Colors.grey[600], fontSize: 11),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1),
          ),

          // Bottom Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formatNPR(order.grandTotal),
                    style: const TextStyle(fontWeight: FontWeight.bold, color: kNavy, fontSize: 15),
                  ),
                ],
              ),
              InkWell(
                onTap: () => context.push('/orders/${order.id}'),
                child: const Row(
                  children: [
                    Text(
                      'View Details',
                      style: TextStyle(color: Color(0xFFFF5722), fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    SizedBox(width: 2),
                    Icon(Icons.arrow_forward, size: 14, color: Color(0xFFFF5722)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg = Colors.grey[100]!;
    Color fg = Colors.grey[800]!;

    switch (status.toLowerCase()) {
      case 'processing':
      case 'pending':
        bg = const Color(0xFFFFF3E0);
        fg = const Color(0xFFE65100);
        break;
      case 'shipped':
      case 'confirmed':
        bg = const Color(0xFFE3F2FD);
        fg = const Color(0xFF1565C0);
        break;
      case 'delivered':
      case 'completed':
        bg = const Color(0xFFE8F5E9);
        fg = const Color(0xFF2E7D32);
        break;
      case 'cancelled':
      case 'failed':
        bg = const Color(0xFFFFEBEE);
        fg = const Color(0xFFC62828);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.3),
      ),
    );
  }
}
