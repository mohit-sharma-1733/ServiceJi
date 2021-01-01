import 'dart:convert';

import 'package:http/http.dart';
import 'package:ServiceJi/main.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:ServiceJi/utils/constants.dart';

bool isSuccessful(int code) {
  return code >= 200 && code <= 206;
}

Future buildTokenHeader() async {
  var pref = await getSharedPref();

  var header = {
    "token": "${pref.getString(TOKEN)}",
    "id": "${pref.getInt(USER_ID)}",
    "Content-Type": "application/json",
    //"Accept": "application/json",
  };
  log(jsonEncode(header));
  return header;
}

getRequest(String endPoint, {bool requireToken}) async {
  if (await isNetworkAvailable()) {
    Response response = await get('$BaseUrl$endPoint');
    return response;
  } else {
    throw 'You are not connected to Internet';
  }
}

postRequest(String endPoint, {Map request, bool requireToken}) async {
  if (await isNetworkAvailable()) {
    log('URL: $BaseUrl$endPoint');
    log('Request: $request');
    Response response = await post('$BaseUrl$endPoint', body: jsonEncode(request));
    log('Request: ${response.body}');
    return response;
  } else {
    throw 'You are not connected to Internet';
  }
}

deleteRequest(String endPoint, {bool requireToken}) async {
  var pref = await getSharedPref();

  var header = {
    "token": "${pref.getString(TOKEN)}",
    "id": "${pref.getInt(USER_ID)}",
    "Content-Type": "application/json",
  };

  if (await isNetworkAvailable()) {
    log('URL: $BaseUrl$endPoint');
    Response response = await post(
      '$BaseUrl$endPoint',
      headers: header,
    );
    log('Request: ${response.body}');
    return response;
  } else {
    throw 'You are not connected to Internet';
  }
}

Future handleResponse(Response response) async {
  if (!await isNetworkAvailable()) {
    throw 'You are not connected to Internet';
  }
  String body = response.body;
  if (isSuccessful(response.statusCode)) {
    return jsonDecode(body);
  } else {
    var string = await isJsonValid(body);
    if (string.isNotEmpty) {
      throw string;
    } else {
      throw 'Please try again later.';
    }
  }
}

extension json on Map {
  toJson() {
    return jsonEncode(this);
  }
}

extension on String {
  toJson() {
    return jsonEncode(this);
  }
}

Future<String> isJsonValid(json) async {
  try {
    var f = jsonDecode(json) as Map<String, dynamic>;
    return f[msg];
  } catch (e) {
    log(e.toString());
    return "";
  }
}
