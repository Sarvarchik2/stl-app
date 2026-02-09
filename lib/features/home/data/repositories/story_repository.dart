import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../models/story_model.dart';

class StoryRepository {
  final ApiClient _apiClient;

  StoryRepository(this._apiClient);

  Future<List<StoryModel>> getStories() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.stories);
      if (response.data != null && response.data is List) {
        return (response.data as List)
            .map((json) => StoryModel.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }
}
