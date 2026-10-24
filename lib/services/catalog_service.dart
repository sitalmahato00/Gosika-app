import '../core/api_client.dart';
import '../models/product.dart';
import '../models/deal_product.dart';
import '../models/campaign.dart';

class CatalogService {
  final ApiClient _apiClient;

  CatalogService(this._apiClient);

  Future<List<Banner>> getBanners() async {
    final response = await _apiClient.dio.get('/banners');
    final List data = response.data['data'];
    return data.map((e) => Banner.fromJson(e)).toList();
  }

  Future<List<Category>> getCategories() async {
    final response = await _apiClient.dio.get('/categories');
    final List data = response.data['data'];
    return data.map((e) => Category.fromJson(e)).toList();
  }

  Future<List<DealProduct>> getDeals() async {
    final response = await _apiClient.dio.get('/deals', queryParameters: {'per_page': 12});
    final List data = response.data['data'];
    return data.map((e) => DealProduct.fromJson(e)).toList();
  }

  Future<List<Campaign>> getCampaigns() async {
    final response = await _apiClient.dio.get('/campaigns');
    final List data = response.data['data'];
    return data.map((e) => Campaign.fromJson(e)).toList();
  }

  Future<PaginatedResponse<Product>> getProducts({
    int page = 1,
    String? search,
    String? categoryId,
    String? brandId,
    bool? isFeatured,
    String? sort,
  }) async {
    final response = await _apiClient.dio.get('/products', queryParameters: {
      'page': page,
      'search': search,
      'category_id': categoryId,
      'brand_id': brandId,
      if (isFeatured != null) 'is_featured': isFeatured ? 1 : 0,
      'sort': sort,
    }..removeWhere((key, value) => value == null));

    final List data = response.data['data'];
    final meta = PaginationMeta.fromJson(response.data['meta']);

    return PaginatedResponse(
      data: data.map((e) => Product.fromJson(e)).toList(),
      meta: meta,
    );
  }

  Future<Product> getProductDetail(String uuid) async {
    final response = await _apiClient.dio.get('/products/$uuid');
    return Product.fromJson(response.data['data']);
  }
}
