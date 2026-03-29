import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vello_app/main.dart';

void main() {
  testWidgets(
    'main navigation contains Home, Scan, Event, and AI',
    (tester) async {
      int tappedIndex = -1;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: MainBottomNavigationBar(
              currentIndex: 0,
              isDark: false,
              homeLabel: 'Home',
              scanLabel: 'Scan',
              eventLabel: 'Event',
              aiLabel: 'AI',
              onItemSelected: (index) => tappedIndex = index,
              onAddTransactionTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Scan'), findsOneWidget);
      expect(find.text('Event'), findsOneWidget);
      expect(find.text('AI'), findsOneWidget);
      expect(find.byKey(const Key('main-nav-add')), findsOneWidget);

      await tester.tap(find.byKey(const Key('main-nav-2')));
      await tester.pump();
      expect(tappedIndex, 2);
    },
  );
}
