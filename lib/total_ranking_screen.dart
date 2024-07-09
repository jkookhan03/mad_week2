import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'login_service.dart';

class TotalRankingScreen extends StatefulWidget {
  @override
  _TotalRankingScreenState createState() => _TotalRankingScreenState();
}

class _TotalRankingScreenState extends State<TotalRankingScreen> {
  int _selectedDuration = 10;
  String _selectedGame = ''; // 기본 선택된 게임 이름

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final loginState = Provider.of<LoginState>(context, listen: false);
      loginState.fetchRankings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final loginState = Provider.of<LoginState>(context);

    // 선택한 게임과 duration에 따른 랭킹 필터링
    final filteredRankings = loginState.rankings
        .where((ranking) =>
    ranking['duration'] == _selectedDuration &&
        ranking['gameName'] == _selectedGame)
        .toList();

    // 게임 목록 가져오기
    final games = loginState.rankings
        .map((ranking) => ranking['gameName'])
        .toSet()
        .toList();

    if (_selectedGame.isEmpty && games.isNotEmpty) {
      _selectedGame = games[0]; // 기본 게임 설정
    }

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
                    '랭킹',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Jua-Regular',
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    '게임: ',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Jua-Regular',
                    ),
                  ),
                  DropdownButton<String>(
                    value: _selectedGame,
                    items: games.map((game) {
                      return DropdownMenuItem<String>(
                        value: game,
                        child: Text(
                          game,
                          style: TextStyle(fontFamily: 'Jua-Regular'),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedGame = newValue!;
                      });
                    },
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
                    itemCount: filteredRankings.length,
                    itemBuilder: (context, index) {
                      final ranking = filteredRankings[index];
                      return ListTile(
                        title: Text(
                          '${ranking['userName']} (${ranking['duration']}초)',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Jua-Regular',
                          ),
                        ),
                        trailing: Text('${ranking['highScore']} 점'),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
