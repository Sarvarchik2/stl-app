import 'package:stl_app/core/api/api_client.dart';
import 'package:stl_app/core/api/api_endpoints.dart';
import 'package:stl_app/features/catalog/data/models/car_model.dart';

class CatalogRepository {
  final ApiClient _apiClient;

  CatalogRepository(this._apiClient);

  Future<CarListResponse> getCars({
    String? search,
    String? make,
    String? model,
    int? yearFrom,
    int? yearTo,
    int page = 1,
    int perPage = 20,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'per_page': perPage,
    };
    if (search != null) queryParams['search'] = search;
    if (make != null) queryParams['make'] = make;
    if (model != null) queryParams['model'] = model;
    if (yearFrom != null) queryParams['year_from'] = yearFrom;
    if (yearTo != null) queryParams['year_to'] = yearTo;
    
    final response = await _apiClient.get(
      ApiEndpoints.cars,
      queryParameters: queryParams,
    );

    if (response.statusCode == 200) {
      return CarListResponse.fromJson(response.data);
    } else {
      throw Exception('Failed to load cars');
    }
  }

  Future<CarModel> getCarById(String id) async {
    final response = await _apiClient.get(ApiEndpoints.carDetail(id));

    if (response.statusCode == 200) {
      return CarModel.fromJson(response.data);
    } else {
      throw Exception('Failed to load car details');
    }
  }
}
