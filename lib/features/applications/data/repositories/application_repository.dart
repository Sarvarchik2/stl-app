import 'package:stl_app/core/api/api_client.dart';
import 'package:stl_app/core/api/api_endpoints.dart';
import 'package:stl_app/features/applications/data/models/application_model.dart';

class ApplicationRepository {
  final ApiClient _apiClient;

  ApplicationRepository(this._apiClient);

  Future<void> createApplication({
    required String carId,
    bool agreedTerms = true,
  }) async {
    await _apiClient.post(
      ApiEndpoints.applications,
      data: {
        'car_id': carId,
        'agreed_terms': agreedTerms,
      },
    );
  }

  Future<List<ApplicationModel>> getApplications() async {
    final response = await _apiClient.get(ApiEndpoints.applications);
    
    if (response.statusCode == 200) {
      final List<dynamic> items = response.data['items'] ?? [];
      return items.map((json) => ApplicationModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load applications');
    }
  }

  Future<ApplicationModel> getApplicationById(String id) async {
    final response = await _apiClient.get(ApiEndpoints.applicationDetail(id));
    
    if (response.statusCode == 200) {
      return ApplicationModel.fromJson(response.data);
    } else {
      throw Exception('Failed to load application details');
    }
  }
}
