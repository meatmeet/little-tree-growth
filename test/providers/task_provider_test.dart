import 'package:flutter_test/flutter_test.dart';
import 'package:little_tree_growth/providers/task_provider.dart';

void main() {
  group('TaskProvider', () {
    late TaskProvider provider;

    setUp(() {
      provider = TaskProvider();
    });

    test('initial state is correct', () {
      expect(provider.todayTasks, isEmpty);
      expect(provider.todayPlan, isNull);
      expect(provider.streakDays, 0);
      expect(provider.loading, false);
      expect(provider.error, isNull);
      expect(provider.completedCount, 0);
      expect(provider.totalCount, 0);
      expect(provider.progress, 0);
    });

    test('clearError resets error', () {
      provider.clearError();
      expect(provider.error, isNull);
    });

    test('progress is 0 when no tasks', () {
      expect(provider.progress, 0);
    });
  });
}
