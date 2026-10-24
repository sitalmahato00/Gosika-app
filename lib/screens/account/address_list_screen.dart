import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../providers/address_provider.dart';

class AddressListScreen extends ConsumerWidget {
  const AddressListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addressesAsync = ref.watch(addressListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Saved Addresses')),
      body: addressesAsync.when(
        data: (list) {
          if (list.isEmpty) {
            return _buildEmptyState(context);
          }
          return ListView.builder(
            padding: const EdgeInsets.all(kPad),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final addr = list[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(kPad),
                  title: Row(
                    children: [
                      Text(addr.label, style: const TextStyle(fontWeight: FontWeight.bold)),
                      if (addr.isDefault)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: kSuccess.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                          child: const Text('DEFAULT', style: TextStyle(color: kSuccess, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text(addr.fullName, style: const TextStyle(color: kInk)),
                      Text(addr.phone, style: const TextStyle(color: kMuted)),
                      Text(addr.addressLine1, style: const TextStyle(color: kMuted)),
                    ],
                  ),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: kDanger))),
                    ],
                    onSelected: (val) {
                      if (val == 'delete') {
                        ref.read(addressListProvider.notifier).deleteAddress(addr.id);
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/checkout/address/new'),
        label: const Text('Add New Address'),
        icon: const Icon(Icons.add),
        backgroundColor: kPrimary,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_off_outlined, size: 64, color: kMuted.withOpacity(0.3)),
          const SizedBox(height: 16),
          const Text('No saved addresses', style: TextStyle(color: kMuted)),
        ],
      ),
    );
  }
}
