import 'package:flutter_test/flutter_test.dart';

import 'package:fwidget/widgets.dart';
import 'finder.dart';

Future<Finder> enterTextAndPump(
    WidgetTester tester, String textFields, String inputText,
    {int addTapPumps = 999,
    int addScrollPumps = 999,
    Finder? parent,
    Finder? textFieldsFinderF}) async {
  var textFieldsFinder = find.descendant(
    of: find.byKey(Key('TextField: $textFields')),
    matching: find.byKey(Key(textFields)),
  );

  if (parent != null) {
    var textFieldsFinderWithParent = find.descendant(
      of: parent,
      matching: textFieldsFinder,
    );
    return await scrollAndEnterText(textFieldsFinderWithParent, tester,
        addScrollPumps, inputText, addTapPumps);
  }

  if (textFieldsFinderF != null) {
    return await scrollAndEnterText(
        textFieldsFinderF, tester, addScrollPumps, inputText, addTapPumps);
  }
  return await scrollAndEnterText(
      textFieldsFinder, tester, addScrollPumps, inputText, addTapPumps);
}

Future<Finder> scrollAndEnterText(Finder textFieldsFinder, WidgetTester tester,
    int addScrollPumps, String inputText, int addTapPumps) async {
  await scrollUntilFinderBecomesVisible(tester, textFieldsFinder,
      addScrollPumps: addScrollPumps);
  expect(textFieldsFinder, findsOneWidget);
  await tester.enterText(textFieldsFinder, inputText);
  await durationAndPump(tester, 0, 0, 300, addTapPumps: addTapPumps);
  return textFieldsFinder;
}

Finder findTextAndExpectNothing(String toFindText) {
  final finder = find.text(toFindText);
  expect(finder, findsNothing);
  return finder;
}

//await scrollInAList(find.byKey(key))
//const Key('ContentOfDialog'))
Finder findTextAndExpectOne(String toFindText) {
  final finder = find.text(toFindText);
  expect(finder, findsOneWidget);
  return finder;
}

Finder findTextAndExpectNothingOffStage(String toFindText) {
  final finder = find.text(toFindText, skipOffstage: true);
  expect(finder, findsNothing);
  return finder;
}

Finder findTextAndExpectOneOffStage(String toFindText) {
  final finder = find.text(toFindText, skipOffstage: true);
  expect(finder, findsOneWidget);
  return finder;
}

Future<Finder> enterTextWithOneDescendantOnKey(
  WidgetTester tester,
  Key key,
  Finder parent,
  String inputText, {
  int addTapPumps = 999,
  int addScrollPumps = 999,
}) async {
  expect(parent, findsWidgets);
  var son = find.byKey(key);
  var button = find.descendant(
    of: parent,
    matching: son,
  );
  await scrollUntilFinderBecomesVisible(tester, button,
      addScrollPumps: addScrollPumps);
  await tester.enterText(button, inputText);
  await durationAndPump(tester, 0, 0, 300, addTapPumps: addTapPumps);
  return button;
}
