import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_client.dart';
import '../../features/auth/data/repositories/auth_repository.dart';
import '../../features/catalog/data/repositories/catalog_repository.dart';
import '../../features/applications/data/repositories/application_repository.dart';
import '../../features/home/data/repositories/story_repository.dart';
import '../../features/catalog/data/repositories/favorites_repository.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External
  final prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(prefs);

  // Core
  sl.registerLazySingleton<ApiClient>(() => ApiClient(sl()));

  // Repositories
  sl.registerLazySingleton<AuthRepository>(() => AuthRepository(sl(), sl()));
  sl.registerLazySingleton<CatalogRepository>(() => CatalogRepository(sl()));
  sl.registerLazySingleton<ApplicationRepository>(() => ApplicationRepository(sl()));
  sl.registerLazySingleton<StoryRepository>(() => StoryRepository(sl<ApiClient>()));
  sl.registerLazySingleton<FavoritesRepository>(() => FavoritesRepository(sl()));
}
