// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:arbeitszeiterfassung/json.dart';
import 'package:arbeitszeiterfassung/login.dart';
import 'package:arbeitszeiterfassung/workingTime.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:arbeitszeiterfassung/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:get/get.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'helper_text.dart';
import 'tap.dart';

void main() {
  testWidgets('Check Login Page', (WidgetTester tester) async {
    await tester.pumpWidget(
      Material(
        child: GetMaterialApp(
          home: LogIn(),
        ),
      ),
    );
    var login = find.byKey(const Key('Login'));
    expect(login, findsOneWidget);
    await tapWithFindByKey(
      tester,
      const Key('Login'),
    );

    var username = find.byKey(const Key('TextField: Username'));
    expect(username, findsOneWidget);
    await tester.enterText(username, "inputText:Username");

    var inputUsername = find.text("inputText:Username");
    expect(inputUsername, findsOneWidget);

    var password = find.byKey(const Key('TextField: Password'));
    expect(password, findsOneWidget);

    await tester.enterText(username, "inputText:Password");

    var inputPassword = find.text("inputText:Password");
    expect(inputPassword, findsOneWidget);
  });

  testWidgets('startStop', (WidgetTester tester) async {
    await tester.pumpWidget(
      Material(
        child: GetMaterialApp(
          home: WorkingPage(
            jsonLogin: JsonLogin(
                username: "user", sessionkey: "123", dayandworkedtimes: []),
          ),
        ),
      ),
    );

    var start = find.byKey(const Key('Start'));
    expect(start, findsOneWidget);

    var stop = find.byKey(const Key('Stop'));
    expect(stop, findsOneWidget);
  });
}
