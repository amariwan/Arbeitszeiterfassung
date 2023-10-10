// To parse this JSON data, do
//
//     final jsonLogin = jsonLoginFromJson(jsonString);

import 'dart:convert';

JsonLogin jsonLoginFromJson(String str) => JsonLogin.fromJson(json.decode(str));

String jsonLoginToJson(JsonLogin data) => json.encode(data.toJson());

class JsonLogin {
  JsonLogin({
    required this.username,
    required this.sessionkey,
    required this.dayandworkedtimes,
  });

  String username;
  String sessionkey;
  List<Dayandworkedtime> dayandworkedtimes = [];

  factory JsonLogin.fromJson(Map<String, dynamic> json) {
    List<Dayandworkedtime> dayandworkedtimes = [];
    if (json['dayandworkedtime'] != null) {
      dayandworkedtimes = [];
      json['dayandworkedtime'].forEach((v) {
        dayandworkedtimes.add(Dayandworkedtime.fromJson(v));
      });
    }
    return JsonLogin(
      username: json["username"],
      sessionkey: json["sessionkey"],
      dayandworkedtimes: dayandworkedtimes,
    );
  }

  Map<String, dynamic> toJson() => {
        "username": username,
        "sessionkey": sessionkey,
        "dayandworkedtime": dayandworkedtimes.map((v) => v.toJson()).toList(),
      };
}

class Dayandworkedtime {
  WorkingDate day = WorkingDate(month: 0, day: 0, year: 0);
  String hasworked = "";
  Dayandworkedtime({
    required this.day,
    required this.hasworked,
  });
  Dayandworkedtime.fromJson(Map<String, dynamic> json) {
    day = WorkingDate.fromJson(json['day']);
    hasworked = json['hasworked'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['day'] = day;
    data['hasworked'] = hasworked;
    return data;
  }
}

class WorkingDate {
  int year = 0;
  int month = 0;
  int day = 0;
  WorkingDate({
    required this.month,
    required this.day,
    required this.year,
  });

  WorkingDate.fromJson(Map<String, dynamic> json) {
    year = json['year'] ?? '';
    month = json['month'] ?? '';
    day = json['day'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['year'] = year;
    data['month'] = month;
    data['day'] = day;
    return data;
  }
}
