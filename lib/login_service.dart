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
  String _profileImageUrl = 'None';
  List<Map<String, dynamic>> _highScores = [];

  String get accessToken => _accessToken;
  String get userId => _userId;
  String get userName => _userName;
  String get profileImageUrl => _profileImageUrl;
  List<Map<String, dynamic>> get highScores => _highScores;

  Future<void> checkAutoLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    String? userName = prefs.getString('userName');
    String? token = prefs.getString('token');
    String? profileImageUrl = prefs.getString('profileImageUrl');

    if (userId != null && userName != null && token != null && profileImageUrl != null) {
      _userId = userId;
      _userName = userName;
      _accessToken = token;
      _profileImageUrl = profileImageUrl;
      await fetchHighScores(); // Fetch high scores after auto login
      notifyListeners();
    }
  }

  Future<void> fetchHighScores() async {
    final url = 'http://172.10.7.88:80/api/users/$_userId/high-scores';
    print('Fetching high scores from $url');
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        _highScores = List<Map<String, dynamic>>.from(json.decode(response.body));
        print('High scores fetched successfully: $_highScores');
      } else {
        print('Failed to fetch high scores: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Error fetching high scores: $e');
    }
    notifyListeners();
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
          prefs.setString('token', token.accessToken);
          prefs.setString('profileImageUrl', accountResult.profileImage);

          _accessToken = token.accessToken;
          _userId = accountResult.id;
          _userName = accountResult.name;
          _profileImageUrl = accountResult.profileImage;
          await fetchHighScores(); // Fetch high scores after login
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
    prefs.remove('profileImageUrl');

    _accessToken = 'None';
    _userId = 'None';
    _userName = 'None';
    _profileImageUrl = 'None';
    _highScores = [];
    notifyListeners();
  }
}
