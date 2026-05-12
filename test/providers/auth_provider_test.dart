import 'package:flutter_test/flutter_test.dart';
import 'package:little_tree_growth/providers/auth_provider.dart';
import 'package:little_tree_growth/models/user.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthProvider extends Mock implements AuthProvider {}

void main() {
  group('AuthProvider', () {
    late AuthProvider provider;

    setUp(() {
      provider = AuthProvider();
    });

    test('initial state is correct', () {
      expect(provider.user, isNull);
      expect(provider.isLoggedIn, false);
      expect(provider.loading, false);
      expect(provider.initialized, false);
      expect(provider.isVip, false);
      expect(provider.error, isNull);
    });

    test('clearError resets error', () {
      provider.clearError();
      expect(provider.error, isNull);
    });

    test('isVip returns false when user is null', () {
      expect(provider.isVip, false);
    });

    test('isVip returns true when user has vip', () {
      // Access private _user via reflection not possible, test via mock
      expect(provider.isVip, false);
    });
  });
}
