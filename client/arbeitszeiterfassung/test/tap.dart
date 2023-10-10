// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fwidget/container/input_dropdown_button.dart';
import 'package:fwidget/widgets/dropdown_button.dart';
import 'finder.dart';

Future<void> expectOneAndTap(
  WidgetTester tester,
  Finder finder, {
  int addTapPumps = 999,
  int addScrollPumps = 999,
}) async {
  await scrollUntilFinderBecomesVisible(tester, finder,
      addScrollPumps: addScrollPumps);

  expect(finder, findsOneWidget);
  await tester.ensureVisible(finder);
  await durationAndPump(tester, 0, 0, 300, addTapPumps: addTapPumps);
  await tester.tap(finder);
  await durationAndPump(tester, 0, 0, 300, addTapPumps: addTapPumps);
}

Future<void> fscroll(
    Finder finder, WidgetTester tester, int addScrollPumps) async {
  var scroll = find.ancestor(of: finder, matching: find.byType(Scrollable));
  var elements = scroll.evaluate();
  if (elements.isNotEmpty) {
    await scrollInAList(scroll.first, finder, tester,
        addScrollPumps: addScrollPumps);
  }
}

Future<void> expectOneAndDoubleTap(
  WidgetTester tester,
  Finder finder, {
  int addTapPumps = 999,
  int addScrollPumps = 999,
}) async {
  await scrollUntilFinderBecomesVisible(tester, finder,
      addScrollPumps: addScrollPumps);
  expect(finder, findsOneWidget);
  await tester.ensureVisible(finder);
  // await durationAndPump(tester, 0, 0, 300,addTapPumps: addTapPumps);
  await tester.tap(finder);
  await tester.pump(kDoubleTapMinTime);
  await tester.tap(finder);
  await durationAndPump(tester, 0, 0, 300, addTapPumps: addTapPumps);
}

Future<Finder> tapWithOneDescendantEnsureVisible(
  WidgetTester tester,
  Finder child,
  Finder parent, {
  int addTapPumps = 999,
  int addScrollPumps = 999,
}) async {
  expect(parent, findsWidgets);
  var button = find.descendant(
    of: parent,
    matching: child,
  );
  await scrollUntilFinderBecomesVisible(tester, button,
      addScrollPumps: addScrollPumps);
  await tester.ensureVisible(button);
  await tester.tap(button);
  await durationAndPump(tester, 0, 0, 300, addTapPumps: addTapPumps);
  return button;
}

Future<void> expectOneAndTapWithoutWarnMissed(
  WidgetTester tester,
  Finder finder, {
  int addTapPumps = 999,
  int addScrollPumps = 999,
}) async {
  await scrollUntilFinderBecomesVisible(tester, finder,
      addScrollPumps: addScrollPumps);
  expect(finder, findsOneWidget);
  await tester.ensureVisible(finder);
  await tester.tap(finder, warnIfMissed: false);
  await durationAndPump(tester, 0, 0, 300, addTapPumps: addTapPumps);
}

Future<Finder> tapWithFindByKey(
  WidgetTester tester,
  Key key, {
  int addTapPumps = 999,
  int addScrollPumps = 999,
}) async {
  var button = find.byKey(key);
  await scrollUntilFinderBecomesVisible(tester, button,
      addScrollPumps: addScrollPumps);
  expect(button, findsOneWidget);
  await tester.ensureVisible(button);
  await tester.tap(button);
  await durationAndPump(tester, 0, 0, 300, addTapPumps: addTapPumps);
  return button;
}

Future<void> expectOneTapWaitAndPump(WidgetTester tester, Finder finder,
    {Duration? duration}) async {
  expect(finder, findsOneWidget);
  await tester.tap(finder);
  await tester.pump(duration ?? const Duration(milliseconds: 300));
}

Future<Finder> tapWithFindText(
  WidgetTester tester,
  String toFindText, {
  int addTapPumps = 999,
  int addScrollPumps = 999,
}) async {
  var button = find.text(toFindText);
  await scrollUntilFinderBecomesVisible(tester, button,
      addScrollPumps: addScrollPumps);
  expect(button, findsOneWidget);
  await tester.ensureVisible(button);
  await tester.tap(button);
  await durationAndPump(tester, 0, 0, 300, addTapPumps: addTapPumps);
  return button;
}

Future<Finder> tapWithFindByType(
  WidgetTester tester,
  Type type, {
  addScrollPumps = 999,
  addTapPumps = 999,
}) async {
  var button = find.byType(type);
  await scrollUntilFinderBecomesVisible(tester, button,
      addScrollPumps: addScrollPumps);
  expect(button, findsOneWidget);
  await tester.ensureVisible(button);
  await tester.tap(button, warnIfMissed: true);
  await durationAndPump(tester, 0, 0, 300, addTapPumps: addTapPumps);
  return button;
}

Future<Finder> tapWithOneDescendantOnKey(
  WidgetTester tester,
  Key son,
  Finder parent, {
  addScrollPumps = 999,
  addTapPumps = 999,
}) async {
  expect(parent, findsWidgets);
  var button = find.descendant(
    of: parent,
    matching: find.byKey(son),
  );
  await scrollUntilFinderBecomesVisible(tester, button,
      addScrollPumps: addScrollPumps);
  await tester.ensureVisible(button);
  await tester.tap(button);
  await durationAndPump(tester, 0, 0, 300, addTapPumps: addTapPumps);
  return button;
}

Future<Finder> tapWithOneDescendant(
  WidgetTester tester,
  Finder child,
  Finder parent, {
  addScrollPumps = 999,
  addTapPumps = 999,
}) async {
  expect(parent, findsWidgets);
  var button = find.descendant(
    of: parent,
    matching: child,
  );
  await scrollUntilFinderBecomesVisible(tester, button,
      addScrollPumps: addScrollPumps);
  await tester.ensureVisible(button);
  await tester.tap(button);
  await durationAndPump(tester, 0, 0, 300, addTapPumps: addTapPumps);
  return button;
}

Future<void> selectOptionFromDropdownButton(
  WidgetTester tester,
  Finder dropDownButton,
  String option,
) async {
  expect(dropDownButton, findsOneWidget);
  tester.ensureVisible(dropDownButton);
  await expectOneAndTap(tester, dropDownButton);

  var optionCandidatesFinder = find.descendant(
      of: find.byType(DropdownMenuItem<String>),
      matching: find.byKey(Key('DropDown: $option')));
  var nonClickableOptionFinder =
      find.descendant(of: dropDownButton, matching: optionCandidatesFinder);
  var optionCandidateElements = optionCandidatesFinder.evaluate().toList();
  var nonClickableOptionElement = nonClickableOptionFinder.evaluate().toList();
  var clickableOptionElement = optionCandidateElements
      .firstWhere((element) => !nonClickableOptionElement.contains(element));
  var clickableOptionFinder =
      find.byElementPredicate((element) => element == clickableOptionElement);
  await expectOneAndTap(tester, clickableOptionFinder);
  await tester.pumpAndSettle();
  await durationAndPump(tester, 0, 0, 300);
}

Future<void> choseInDirectoryList(
  WidgetTester tester,
  Finder buttonNew,
  String option,
  double scroll, [
  int addTapPumps = 999,
]) async {
  await expectOneAndTap(tester, buttonNew);
  await durationAndPump(tester, 0, 0, 300, addTapPumps: addTapPumps);
  //await tester.drag(
  //    find.byKey(const Key('ListOfDirectories')), Offset(0.0, -scroll));
  //await durationAndPump(tester, 0, 0, 300,addTapPumps: addTapPumps);
  await tapWithFindText(tester, option);
  await durationAndPump(tester, 0, 0, 300, addTapPumps: addTapPumps);
  await tapWithFindByKey(tester, const Key('Select'));
}

const Duration kDoubleTapMinTime = Duration(milliseconds: 40);

Future<void> doubleTap(WidgetTester tester, Finder finder) async {
  await tester.tap(finder);
  await tester.pump(kDoubleTapMinTime);
  await tester.tap(finder);
  await tester.pumpAndSettle(); //TODO replace pumpAndSettle!
}

List<Finder> findRightOption(List<Finder> toCheckList) {
  List<Finder> output = [];
  for (int i = 0; i < toCheckList.length; i++) {
    var checkInWrongParent = find.descendant(
      of: find.byType(FInputDropdownButton),
      matching: toCheckList[i],
    );
    var checkInOtherWrongParent = find.descendant(
      of: find.byType(FDropdownButton),
      matching: toCheckList[i],
    );
    if (checkInWrongParent.toString().contains('zero') &&
        checkInOtherWrongParent.toString().contains('zero')) {
      output.add(toCheckList[i]);
    }
  }

  return output;
}
