import '../api/api_endpoints.dart';

class UrlUtil {
  /// Sanitizes a URL by replacing 'localhost' with the actual API base URL host.
  /// Also handles potential relative paths by prepending the base URL.
  static String sanitize(String url) {
    if (url.isEmpty) return url;
    
    // Replace localhost with the base URL's host if needed
    // This is useful for local development where the server might return 'localhost'
    // but the mobile device/simulator needs '127.0.0.1' or a specific IP.
    if (url.contains('localhost')) {
      final host = Uri.parse(ApiEndpoints.baseUrl).host;
      final port = Uri.parse(ApiEndpoints.baseUrl).port;
      return url.replaceFirst('localhost', host).replaceFirst(':8000', ':$port');
    }
    
    // If it's a relative path, prepend the base URL
    if (url.startsWith('/')) {
      return '${ApiEndpoints.baseUrl}$url';
    }
    
    return url;
  }
}
