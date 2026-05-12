import 'package:flutter_test/flutter_test.dart';
import 'package:little_tree_growth/providers/baby_provider.dart';

void main() {
  group('BabyProvider', () {
    late BabyProvider provider;

    setUp(() {
      provider = BabyProvider();
    });

    test('initial state is correct', () {
      expect(provider.babies, isEmpty);
      expect(provider.currentBaby, isNull);
      expect(provider.loading, false);
      expect(provider.error, isNull);
    });

    test('clearError resets error', () {
      provider.clearError();
      expect(provider.error, isNull);
    });
  });
}
