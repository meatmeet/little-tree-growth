import 'package:flutter_test/flutter_test.dart';
import 'package:little_tree_growth/providers/growth_provider.dart';

void main() {
  group('GrowthProvider', () {
    late GrowthProvider provider;

    setUp(() {
      provider = GrowthProvider();
    });

    test('initial state is correct', () {
      expect(provider.records, isEmpty);
      expect(provider.milestones, isEmpty);
      expect(provider.loading, false);
      expect(provider.error, isNull);
      expect(provider.latestRecord, isNull);
    });

    test('clearError resets error', () {
      provider.clearError();
      expect(provider.error, isNull);
    });
  });
}
