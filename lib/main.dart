import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  String _accessToken = 'None';
  String _userId = 'None';
  String _userName = 'None';
  String _token = '';

  static List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    LoginScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _checkAutoLogin();
  }

  Future<void> _checkAutoLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    String? userName = prefs.getString('userName');
    String? token = prefs.getString('token');

    if (userId != null && userName != null && token != null) {
      setState(() {
        _userId = userId;
        _userName = userName;
        _token = token;
        _selectedIndex = 0; // Auto-navigate to home screen
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter App with Naver Login'),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.login),
            label: 'Login',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Home Screen',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _accessToken = 'None';
  String _userId = 'None';
  String _userName = 'None';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('AccessToken: $_accessToken'),
            Text('UserID: $_userId'),
            Text('UserName: $_userName'),
            ElevatedButton(
              onPressed: _login,
              child: Text('Login with Naver'),
            ),
            ElevatedButton(
              onPressed: _logout,
              child: Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _login() async {
    NaverLoginResult result = await FlutterNaverLogin.logIn();
    if (result.status == NaverLoginStatus.loggedIn) {
      NaverAccessToken token = await FlutterNaverLogin.currentAccessToken;
      NaverAccountResult accountResult = await FlutterNaverLogin.currentAccount();

      log('Login successful: ${accountResult.id}, ${accountResult.name}');
      log('Access token: ${token.accessToken}');

      setState(() {
        _accessToken = token.accessToken;
        _userId = accountResult.id;
        _userName = accountResult.name;
      });

      log('Sending HTTP request to server...');

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
          final responseData = json.decode(response.body);
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('userId', accountResult.id);
          prefs.setString('userName', accountResult.name);
          prefs.setString('token', responseData['token']);
        } else {
          log('Failed to login to server: ${response.body}');
        }
      } catch (e) {
        log('HTTP request error: $e');
      }
    } else {
      setState(() {
        _accessToken = 'None';
        _userId = 'None';
        _userName = 'None';
      });
    }
  }

  Future<void> _logout() async {
    await FlutterNaverLogin.logOut();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('userId');
    prefs.remove('userName');
    prefs.remove('token');

    setState(() {
      _accessToken = 'None';
      _userId = 'None';
      _userName = 'None';
    });
  }
}
