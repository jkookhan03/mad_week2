import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'login_service.dart';
import 'home_screen.dart';
import 'total_ranking_screen.dart'; // Import the new file

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
        debugShowCheckedModeBanner: false,
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
    TotalRankingScreen(), // RankingScreen 추가
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 1) {
      final loginState = Provider.of<LoginState>(context, listen: false);
      loginState.fetchHighScores(); // Fetch high scores when User tab is selected
    } else if (index == 2) {
      final loginState = Provider.of<LoginState>(context, listen: false);
      loginState.fetchRankings(); // Fetch rankings when Ranking tab is selected
    }
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
          BottomNavigationBarItem(
            icon: Icon(Icons.leaderboard),
            label: 'Ranking',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}

class UserScreen extends StatefulWidget {
  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  int _selectedDuration = 10;

  @override
  Widget build(BuildContext context) {
    final loginState = Provider.of<LoginState>(context);

    // 선택한 duration에 따른 최고 점수 필터링
    final filteredHighScores = loginState.highScores.where((score) => score['duration'] == _selectedDuration).toList();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  SizedBox(height: 80),
                  Text(
                    '사용자 정보',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Jua-Regular',
                    ),
                  ),
                  SizedBox(height: 20),
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: loginState.profileImageUrl != 'None'
                        ? NetworkImage(loginState.profileImageUrl)
                        : AssetImage('assets/profile_placeholder.png'),
                  ),
                  SizedBox(height: 40),
                  Text(
                    '${loginState.userName}',
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'Jua-Regular',
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    '최고 점수',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Jua-Regular',
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    '게임 시간: ',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Jua-Regular',
                    ),
                  ),
                  DropdownButton<int>(
                    value: _selectedDuration,
                    items: [
                      DropdownMenuItem(
                        child: Text('10초',
                            style: TextStyle(fontFamily: 'Jua-Regular')),
                        value: 10,
                      ),
                      DropdownMenuItem(
                        child: Text('20초',
                            style: TextStyle(fontFamily: 'Jua-Regular')),
                        value: 20,
                      ),
                      DropdownMenuItem(
                        child: Text('30초',
                            style: TextStyle(fontFamily: 'Jua-Regular')),
                        value: 30,
                      ),
                    ],
                    onChanged: (int? newValue) {
                      setState(() {
                        _selectedDuration = newValue!;
                      });
                    },
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: filteredHighScores.length,
                    itemBuilder: (context, index) {
                      final highScore = filteredHighScores[index];

                      // 게임 이름 변환 함수
                      String getGameDisplayName(String gameName) {
                        switch (gameName) {
                          case 'Tab Game':
                            return '야옹';
                          case 'Balloon Game':
                            return '풍선 게임';
                          case 'Star Game':
                            return '별 먹기 게임';
                          default:
                            return gameName;
                        }
                      }

                      return ListTile(
                        title: Text(
                          getGameDisplayName(highScore['gameName']),
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Jua-Regular',
                          ),
                        ),
                        trailing: Text('${highScore['highScore']} 점'),
                      );
                    },
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
            Image.asset(
              'assets/logo.png',
              width: 600,
              height: 300,
            ),
            SizedBox(height: 50), // 로고와 로그인 버튼 사이의 간격을 위해 추가
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
                height: 50,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

