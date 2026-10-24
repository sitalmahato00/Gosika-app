import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';
import '../models/product.dart';
import '../models/deal_product.dart';
import '../models/campaign.dart';
import '../services/catalog_service.dart';

final catalogServiceProvider = Provider((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return CatalogService(apiClient);
});

final bannersProvider = FutureProvider<List<Banner>>((ref) async {
  final service = ref.watch(catalogServiceProvider);
  return service.getBanners();
});

final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final service = ref.watch(catalogServiceProvider);
  return service.getCategories();
});

final dealsProvider = FutureProvider<List<DealProduct>>((ref) async {
  final service = ref.watch(catalogServiceProvider);
  return service.getDeals();
});

final campaignsProvider = FutureProvider<List<Campaign>>((ref) async {
  final service = ref.watch(catalogServiceProvider);
  return service.getCampaigns();
});

final featuredProductsProvider = FutureProvider<List<Product>>((ref) async {
  final service = ref.watch(catalogServiceProvider);
  final response = await service.getProducts(isFeatured: true, page: 1);
  return response.data;
});

final allProductsProvider = FutureProvider<List<Product>>((ref) async {
  final service = ref.watch(catalogServiceProvider);
  final response = await service.getProducts(page: 1);
  return response.data;
});

final productDetailProvider = FutureProvider.family<Product, String>((ref, id) async {
  final service = ref.watch(catalogServiceProvider);
  return service.getProductDetail(id);
});

class ProductListState {
  final List<Product> products;
  final bool isLoading;
  final bool hasMore;
  final int currentPage;
  final String? error;

  ProductListState({
    this.products = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.currentPage = 1,
    this.error,
  });

  ProductListState copyWith({
    List<Product>? products,
    bool? isLoading,
    bool? hasMore,
    int? currentPage,
    String? error,
  }) {
    return ProductListState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      error: error ?? this.error,
    );
  }
}

class ProductListNotifier extends StateNotifier<ProductListState> {
  final CatalogService _service;
  final Map<String, dynamic> _filters;

  ProductListNotifier(this._service, this._filters) : super(ProductListState()) {
    loadNextPage();
  }

  Future<void> loadNextPage() async {
    if (state.isLoading || !state.hasMore) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _service.getProducts(
        page: state.currentPage,
        search: _filters['search'],
        categoryId: _filters['category_id'],
        brandId: _filters['brand_id'],
        isFeatured: _filters['is_featured'],
        sort: _filters['sort'],
      );

      state = state.copyWith(
        products: [...state.products, ...response.data],
        isLoading: false,
        hasMore: response.meta.currentPage < response.meta.lastPage,
        currentPage: response.meta.currentPage + 1,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() async {
    state = ProductListState();
    await loadNextPage();
  }
}

final productListProvider = StateNotifierProvider.family<ProductListNotifier, ProductListState, Map<String, dynamic>>((ref, filters) {
  final service = ref.watch(catalogServiceProvider);
  return ProductListNotifier(service, filters);
});
