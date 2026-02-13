class ApiEndpoints {
  static const String baseUrl = 'http://127.0.0.1:8000';
  static const String baseApiUrl = '$baseUrl/api/v1';

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String me = '/auth/me';
  static const String refresh = '/auth/refresh';

  // Cars
  static const String cars = '/cars';
  static const String carMakes = '/cars/makes';
  static const String carModels = '/cars/models';
  static String carDetail(String id) => '/cars/$id';
  static String carPriceHistory(String id) => '/cars/$id/price-history';

  // Applications
  static const String applications = '/applications';
  static String applicationDetail(String id) => '/applications/$id';

  // Stories
  static const String stories = '/stories';
}
