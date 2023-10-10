import 'dart:async';

import 'package:arbeitszeiterfassung/login.dart';
import 'package:arbeitszeiterfassung/workedModel.dart';
import 'package:flutter/material.dart';
import 'package:fwidget/widgets.dart';

import 'json.dart';
import 'main.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

import 'package:http/http.dart' as http;
import 'package:cookie_jar/cookie_jar.dart';

class WorkingPage extends StatefulWidget {
  JsonLogin jsonLogin;
  late bool isStarted = false;
  late bool isStopped = true;
  WorkingPage({
    isStarted = false,
    isStopped = true,
    required this.jsonLogin,
    Key? key,
  }) : super(key: key);

  @override
  _WorkingPageState createState() => _WorkingPageState();
  TextEditingController workingPageController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController startTimeController = TextEditingController();
  TextEditingController stopTimeController = TextEditingController();
  TextEditingController requestController = TextEditingController(text: "");
  TextEditingController requestTimerController =
      TextEditingController(text: "");

  Future<String> fetchData() async {
    var response = await http.post(
      Uri.parse('http://localhost:9000/${requestController.text}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode({
        "username": jsonLogin.username,
        "sessionKey": jsonLogin.sessionkey,
      }),
    );

    return response.body;
  }
}

class _WorkingPageState extends State<WorkingPage> {
  //var _postData;

  late Timer _timer;
  String _currentTime =
      DateFormat('dd.MM.yyyy HH:mm:ss').format(DateTime.now());
  late Future<String> data;
  @override
  void initState() {
    super.initState();
    data = widget.fetchData();
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      setState(() {
        _currentTime = DateFormat('dd.MM.yyyy HH:mm:ss').format(DateTime.now());
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  _WorkingPageState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar('Working time recording'),
      body: ListView(
        children: [
          Center(
            child: FutureBuilder<String>(
              future: data,
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                //if (snapshot.connectionState == ConnectionState.waiting) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 50),
                        //  const Icon(Icons.access_time),
                        Card(
                          color: Colors.blue,
                          elevation: 0,
                          shape: const RoundedRectangleBorder(
                            side: BorderSide(
                              color: Colors.grey,
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          child: SizedBox(
                            width: 200,
                            height: 100,
                            child: Center(
                              child: Text(
                                textAlign: TextAlign.center,
                                'Aktuelle Uhrzeit: ${_currentTime.split(' ')[1]}',

                                style: const TextStyle(fontSize: 20),
                                // 'Date: ${formattedDate.split(' ')[0]}',
                                // style: const TextStyle(fontSize: 20),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 50),

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            children: [
                              const SizedBox(height: 100),
                              IgnorePointer(
                                ignoring: !widget.isStopped,
                                child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: widget.isStopped
                                            ? Colors.green
                                            : Colors.grey,
                                        textStyle:
                                            const TextStyle(fontSize: 25)),
                                    child: const Text('Start'),
                                    onPressed: () {
                                      widget.isStopped = false;
                                      widget.isStarted = true;
                                      setState(() {
                                        widget.requestTimerController.text =
                                            'Time: ${_currentTime.split(' ')[1]}';
                                        widget.requestController.text = "start";
                                        data = widget.fetchData();
                                      });
                                    },
                                    key: const Key("Start")),
                              ),
                              const SizedBox(width: 20),
                              IgnorePointer(
                                ignoring: !widget.isStarted,
                                child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: widget.isStarted
                                            ? const Color.fromARGB(
                                                255, 234, 68, 56)
                                            : Colors.grey,
                                        textStyle:
                                            const TextStyle(fontSize: 25)),
                                    child: const Text('Stop'),
                                    onPressed: () {
                                      widget.isStopped = true;
                                      widget.isStarted = false;
                                      setState(() {
                                        widget.requestTimerController.text =
                                            'Time: ${_currentTime.split(' ')[1]}';
                                        widget.requestController.text = "stop";
                                        data = widget.fetchData();
                                      });
                                    },
                                    key: const Key("Stop")),
                              ),
                            ],
                          ),
                        ),
                        IgnorePointer(
                          ignoring: !widget.isStopped,
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 30, horizontal: 60),
                                  backgroundColor: !widget.isStarted
                                      ? const Color.fromARGB(255, 234, 68, 56)
                                      : Colors.grey,
                                  textStyle: const TextStyle(fontSize: 20)),
                              child: const Text('Abmelden'),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LogIn(),
                                  ),
                                );
                              },
                              key: const Key("Logout")),
                        ),

                        const SizedBox(height: 30),
                        if (snapshot.hasData && snapshot.data != '')
                          getWidgetsFromWebsocket(
                              _convertInfoFromWebSocket(snapshot))
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  List<Dayandworkedtime> _convertInfoFromWebSocket(
      AsyncSnapshot<dynamic> snapshot) {
    List<Dayandworkedtime> infoFromWebSocket = [];
    if (snapshot.hasData &&
        !snapshot.data.toString().contains("404 page not found")) {
      var overview = JsonLogin.fromJson(json.decode(snapshot.data));
      print(overview.dayandworkedtimes.toString());
      for (var element in overview.dayandworkedtimes) {
        infoFromWebSocket.add(
          Dayandworkedtime(
              day: WorkingDate(
                  day: element.day.day,
                  month: element.day.month,
                  year: element.day.year),
              hasworked: element.hasworked),
        );
      }
    }
    return infoFromWebSocket;
  }
}

Widget getWidgetsFromWebsocket(List<Dayandworkedtime> infoFromWebSocket) {
  FTableController<WorkedModel> controller;

  List<FTableRowWorkedModel> tableRows = [];
  for (var element in infoFromWebSocket) {
    tableRows.add(
      FTableRowWorkedModel(
        value: WorkedModel(
            datum: element.day,
            hasworked:
                element.hasworked.split('.')[0].contains(RegExp(r'm[0-9]'))
                    ? element.hasworked.split('.')[0] + 's'
                    : element.hasworked.split('.')[0]),
      ),
    );
  }

  controller = FTableController(rows: tableRows);
  var output = Center(
    child: FTable(
      controller: controller,
      headers: FTableRowWorkedModel.headers(),
      columnWidths: const [
        FlexColumnWidth(230),
        FlexColumnWidth(100),
        FlexColumnWidth(100),
        FlexColumnWidth(200),
      ],
      //onChange: widget.onChange,
    ),
  );

  return output;
}

List<String> parseUrl(String url) {
  return url.split('=');
}
