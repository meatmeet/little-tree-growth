import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:little_tree_growth/widgets/timeline_item.dart';

void main() {
  group('TimelineItem', () {
    testWidgets('renders title and icon without photoUrl', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: TimelineItem(
                icon: '⭐',
                title: 'First Steps',
                subtitle: 'Took first steps today',
                time: '5/14',
              ),
            ),
          ),
        ),
      );

      expect(find.text('First Steps'), findsOneWidget);
      expect(find.text('Took first steps today'), findsOneWidget);
      expect(find.text('5/14'), findsOneWidget);
      expect(find.text('⭐'), findsOneWidget);
    });

    testWidgets('renders with photoUrl in test env without crashing', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: TimelineItem(
                icon: '📸',
                title: 'With Photo',
                photoUrl: 'https://example.com/photo.jpg',
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      // Widget renders without crashing even though CachedNetworkImage
      // can't load network images in test environment
      expect(find.text('With Photo'), findsOneWidget);
    });

    testWidgets('renders without subtitle and time', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: const TimelineItem(
                icon: '🎯',
                title: 'Minimal',
              ),
            ),
          ),
        ),
      );

      expect(find.text('Minimal'), findsOneWidget);
      expect(find.text('🎯'), findsOneWidget);
    });
  });
}
