import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'login_service.dart';
import 'home_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LoginState(),
      child: MaterialApp(
        home: InitialScreen(),
      ),
    );
  }
}

class InitialScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final loginState = Provider.of<LoginState>(context, listen: false);

    return FutureBuilder(
      future: loginState.checkAutoLogin(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else {
          if (loginState.userId == 'None') {
            return LoginScreen();
          } else {
            return MyHomePage();
          }
        }
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  static List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    UserScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            icon: Icon(Icons.person),
            label: 'User',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}

class UserScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final loginState = Provider.of<LoginState>(context);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                SizedBox(height: 100),
                Text(
                  '사용자 정보',
                  style: TextStyle(fontSize: 40,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Jua-Regular'),
                ),
                SizedBox(height: 20),
                CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('assets/profile_placeholder.png'), // Replace with user's profile image
                ),
                SizedBox(height: 40),
                Text(
                  '${loginState.userName}',
                  style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'Jua-Regular'),
                ),
                SizedBox(height: 10),
                Text(
                  '유저 ID: ${loginState.userId}',
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(height: 10),
                Text(
                  // '승률: ${loginState.userWinRate}%', // Add win rate if available
                  '승률: ',
                  style: TextStyle(fontSize: 20),
                ),
              ],
            ),
            GestureDetector(
              onTap: () {
                loginState.logout();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => InitialScreen()),
                );
              },
              child: Image.asset(
                'assets/btnG_logout.png',
                width: 200,
                height: 50,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final loginState = Provider.of<LoginState>(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              onTap: () async {
                bool success = await loginState.login();
                if (success) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => MyHomePage()),
                  );
                }
              },
              child: Image.asset(
                  'assets/btnG_login.png',
                  width: 200,
                  height: 50,),
            ),
          ],
        ),
      ),
    );
  }
}
