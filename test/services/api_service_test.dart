import 'package:flutter_test/flutter_test.dart';
import 'package:little_tree_growth/services/api_service.dart';

void main() {
  group('ApiService', () {
    test('baseUrl uses HTTPS', () {
      final api = ApiService();
      expect(api.baseUrl.startsWith('https://'), true,
          reason: 'API base URL must use HTTPS');
    });

    test('ApiException toString formats correctly', () {
      final exc = ApiException(404, 'Not found');
      expect(exc.toString(), 'ApiException(404): Not found');
    });

    test('AuthRequiredException is ApiException with 401', () {
      final exc = AuthRequiredException();
      expect(exc.statusCode, 401);
      expect(exc, isA<ApiException>());
    });

    test('AuthRequiredException has default message', () {
      final exc = AuthRequiredException();
      expect(exc.message, contains('登录已过期'));
    });

    test('AuthRequiredException accepts custom message', () {
      final exc = AuthRequiredException('custom error');
      expect(exc.message, 'custom error');
    });
  });
}
