import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginState with ChangeNotifier {
  String _accessToken = 'None';
  String _userId = 'None';
  String _userName = 'None';

  String get accessToken => _accessToken;
  String get userId => _userId;
  String get userName => _userName;

  Future<void> checkAutoLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    String? userName = prefs.getString('userName');
    String? token = prefs.getString('token');

    if (userId != null && userName != null && token != null) {
      _userId = userId;
      _userName = userName;
      _accessToken = token;
      notifyListeners();
    }
  }

  Future<bool> login() async {
    NaverLoginResult result = await FlutterNaverLogin.logIn();
    if (result.status == NaverLoginStatus.loggedIn) {
      NaverAccessToken token = await FlutterNaverLogin.currentAccessToken;
      NaverAccountResult accountResult = await FlutterNaverLogin.currentAccount();

      log('Login successful: ${accountResult.id}, ${accountResult.name}');
      log('Access token: ${token.accessToken}');

      try {
        final response = await http.post(
          Uri.parse('http://172.10.7.88:80/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'userId': accountResult.id,
            'userName': accountResult.name,
          }),
        );

        log('Server response: ${response.statusCode}, ${response.body}');

        if (response.statusCode == 200) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('userId', accountResult.id);
          prefs.setString('userName', accountResult.name);

          _accessToken = token.accessToken;
          _userId = accountResult.id;
          _userName = accountResult.name;
          notifyListeners();

          return true;
        } else {
          log('Failed to login to server: ${response.body}');
        }
      } catch (e) {
        log('HTTP request error: $e');
      }
    }
    return false;
  }

  Future<void> logout() async {
    await FlutterNaverLogin.logOut();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('userId');
    prefs.remove('userName');
    prefs.remove('token');

    _accessToken = 'None';
    _userId = 'None';
    _userName = 'None';
    notifyListeners();
  }
}
