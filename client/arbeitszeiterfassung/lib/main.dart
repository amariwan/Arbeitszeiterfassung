import 'package:flutter/material.dart';
import 'login.dart';
import 'package:get/get.dart';

void main() => runApp(const TimeRecording());

class TimeRecording extends StatefulWidget {
  const TimeRecording({super.key});

  @override
  State<TimeRecording> createState() => _TimeRecordingState();
}

class _TimeRecordingState extends State<TimeRecording> {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'LogIn',
      home: LogIn(),
    );
  }
}

AppBar buildAppBar(String title) {
  return AppBar(
    title: Row(
      children: [
        Expanded(
            flex: 1,
            child: Container(
                alignment: Alignment.topLeft,
                child: Image.asset('assets/images/Logo.png'))),
        Expanded(flex: 5, child: Text(title)),
      ],
    ),
    backgroundColor: Colors.red,
  );
}
