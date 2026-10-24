import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../providers/catalog_provider.dart';
import '../../widgets/product_card.dart';

class ProductListScreen extends ConsumerStatefulWidget {
  final String? title;
  final String? categoryId;
  final String? brandId;
  final String? search;

  const ProductListScreen({
    super.key,
    this.title,
    this.categoryId,
    this.brandId,
    this.search,
  });

  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  final ScrollController _scrollController = ScrollController();
  late Map<String, dynamic> _filters;
  String _selectedSubCategory = 'All';

  final List<String> _subCategories = ['All', 'Men', 'Women', 'Kids', 'Accessories'];

  @override
  void initState() {
    super.initState();
    _filters = {
      'category_id': widget.categoryId,
      'brand_id': widget.brandId,
      'search': widget.search,
    };
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(productListProvider(_filters).notifier).loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productListProvider(_filters));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.title ?? 'Apparel',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: kNavy),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: kNavy),
            onPressed: () => context.push('/search'),
          ),
          IconButton(
            icon: const Icon(Icons.tune, color: kNavy),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips Row
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _subCategories.length,
              itemBuilder: (context, index) {
                final category = _subCategories[index];
                final isSelected = _selectedSubCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(
                      category,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedSubCategory = category;
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

          // Main Product Grid
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.read(productListProvider(_filters).notifier).refresh(),
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  if (state.products.isEmpty && !state.isLoading)
                    const SliverFillRemaining(
                      child: Center(
                        child: Text(
                          'No products found',
                          style: TextStyle(color: kMuted, fontSize: 16),
                        ),
                      ),
                    )
                  else ...[
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.64,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => ProductCard(product: state.products[index]),
                          childCount: state.products.length,
                        ),
                      ),
                    ),
                    if (state.isLoading)
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation(Color(0xFFFF5722)),
                            ),
                          ),
                        ),
                      ),
                    if (state.error != null)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(kPad),
                          child: Center(child: Text('Error: ${state.error}')),
                        ),
                      ),
                    const SliverToBoxAdapter(child: SizedBox(height: 40)),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
