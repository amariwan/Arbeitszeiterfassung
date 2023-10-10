// ignore_for_file: avoid_print

import 'package:flutter_test/flutter_test.dart';

import 'package:fwidget/widgets.dart';

Finder findByKeyAndExpectOne(Key key) {
  final finder = find.byKey(key);
  expect(finder, findsOneWidget);
  return finder;
}

Future<void> durationAndPump(
  WidgetTester tester,
  int minute,
  int seconds,
  int milliseconds, {
  addTapPumps = 999,
}) async {
  if (seconds != 0) {
    await tester.pump(Duration(seconds: seconds));
  }
  if (milliseconds != 0) {
    await tester.pump(Duration(milliseconds: milliseconds));
  }
  if (minute != 0) {
    await tester.pump(Duration(minutes: minute));
  }
  if (addTapPumps > 99) {
    await tester.pumpAndSettle();
    // int count = await tester.pumpAndSettle();
    // debugPrint(
    //     'Instead of calling pump() $addTapPumps times, pumpAndSettle() was called (count = $count).');
  } else {
    for (int i = 0; i < addTapPumps; i++) {
      await tester.pump();
    }
  }
  // int count = await tester.pumpAndSettle();
  // debugPrint('pumped $count times in pumpAndSettle()');
}

Finder findByKeyAndExpectNothing(Key key) {
  final finder = find.byKey(key);
  expect(finder, findsNothing);
  return finder;
}

Finder findByTypeAndExpectOne(Type type) {
  final finder = find.byType(type);
  expect(finder, findsOneWidget);
  return finder;
}

Finder findByTypeAndExpectNothing(Type type) {
  final finder = find.byType(type);
  expect(finder, findsNothing);
  return finder;
}

Finder nestedDescendant(Finder grandfather, Finder father, Finder son) {
  expect(grandfather, findsWidgets);
  expect(father, findsWidgets);
  expect(son, findsWidgets);

  var parent = find.descendant(
    of: grandfather,
    matching: father,
  );

  var grandchild = find.descendant(
    of: parent,
    matching: son,
  );

  return grandchild;
}

bool isNotSon(List<String> otherWrongParent, Finder finder) {
  for (int j = 0; j < otherWrongParent.length; j++) {
    var newWrongParent = find.byKey(Key('TextField: ${otherWrongParent[j]}'));
    print(j);
    var deepSearchToChooseOption = find.descendant(
      of: newWrongParent,
      matching: finder,
    );
    print(deepSearchToChooseOption.toString());
    if (!deepSearchToChooseOption.toString().contains('zero')) {
      return false;
    }
  }
  return true;
}

Future<void> scrollInAList(
  Finder scrollable,
  Finder byValueKey,
  WidgetTester tester, {
  int addScrollPumps = 999,
}) async {
  var scrollableWidgets = tester.widgetList<Widget>(scrollable);
  if (scrollableWidgets.first is! Scrollable) {
    scrollable =
        find.descendant(of: scrollable, matching: find.byType(Scrollable));
  }

  await tester.scrollUntilVisible(byValueKey, 200.0, scrollable: scrollable);

  // int count = await tester.pumpAndSettle();
  // debugPrint('pumped $count times in scrollInList()');
  if (addScrollPumps > 99) {
    await tester.pumpAndSettle();
    // int count = await tester.pumpAndSettle();
    // debugPrint(
    //     'Instead of calling pump() $addScrollPumps times, pumpAndSettle() was called (count = $count).');
  } else {
    for (int i = 0; i < addScrollPumps; i++) {
      await tester.pump();
    }
  }
}

Future<void> scrollUntilFinderBecomesVisible(
  WidgetTester tester,
  Finder finder, {
  int addScrollPumps = 999,
}) async {
  var scrollable = find.ancestor(of: finder, matching: find.byType(Scrollable));
  try {
    await scrollInAList(scrollable.first, finder, tester,
        addScrollPumps: addScrollPumps);
  } catch (_) {}
}
