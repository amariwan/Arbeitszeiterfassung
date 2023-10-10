import 'package:flutter/material.dart';

import 'json.dart';
import 'main.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'workingTime.dart';

class LogIn extends StatefulWidget {
  LogIn({
    Key? key,
  }) : super(key: key);

  @override
  _LogInState createState() => _LogInState();

  late final TextEditingController usernameController = TextEditingController();
  late final TextEditingController passwordController = TextEditingController();
  late final bool notToLogin = false;
}

class _LogInState extends State<LogIn> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    JsonLogin jsonLogin =
        JsonLogin(username: '', sessionkey: '', dayandworkedtimes: []);
    widget.usernameController.selection = TextSelection(
        baseOffset: widget.usernameController.text.length,
        extentOffset: widget.usernameController.text.length);
    widget.passwordController.selection = TextSelection(
        baseOffset: widget.passwordController.text.length,
        extentOffset: widget.passwordController.text.length);
    return Scaffold(
      appBar: buildAppBar('Login Page'),
      body: Center(
        child: FutureBuilder<String>(
          future: fetchData(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            //if (snapshot.connectionState == ConnectionState.waiting)
            if (snapshot.hasData && snapshot.data != "") {
              jsonLogin = JsonLogin.fromJson(json.decode(snapshot.data!));
            }
            return Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 100),
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              width: 500,
                              child: TextFormField(
                                  decoration: const InputDecoration(
                                    labelText: 'Username',
                                    border: OutlineInputBorder(),
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      widget.usernameController.text = value;
                                    });
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Username is required.';
                                    }
                                    return null;
                                  },
                                  controller: widget.usernameController,
                                  key: const Key("TextField: Username")),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              width: 500,
                              child: TextFormField(
                                  obscureText: true,
                                  decoration: const InputDecoration(
                                    labelText: 'Password',
                                    border: OutlineInputBorder(),
                                  ),
                                  onChanged: (passValue) {
                                    setState(() {
                                      widget.passwordController.text =
                                          passValue;
                                    });
                                  },
                                  validator: (passValue) {
                                    if (passValue == null ||
                                        passValue.isEmpty) {
                                      return 'Password is required.';
                                    }
                                    return null;
                                  },
                                  controller: widget.passwordController,
                                  key: const Key("TextField: Password")),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: 100,
                          child: ElevatedButton(
                              child: const Text('Anmelden',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  if (!(jsonLogin.sessionkey == "" &&
                                      jsonLogin.username == "")) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => WorkingPage(
                                          jsonLogin: jsonLogin,
                                        ),
                                      ),
                                    );
                                  } else {
                                    popupDialog(context);
                                  }
                                }
                              },
                              key: const Key("Login")),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<String> fetchData() async {
    var response = await http.post(
      Uri.parse('http://localhost:9000/login'),
      body: json.encode({
        "username": widget.usernameController.text,
        "password": widget.passwordController.text
      }),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    return response.body;
  }

  Future<dynamic> popupDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Warning'),
          content: const Text('Username or Password is wrong'),
          actions: [
            TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                key: const Key("OK")),
          ],
        );
      },
    );
  }
}
