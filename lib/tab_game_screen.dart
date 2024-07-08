import 'package:flutter/material.dart';
import 'ranking_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TabGameScreen extends StatefulWidget {
  final int duration;
  final int roomId;
  final String roomName;
  final String userName;
  final String userId;

  TabGameScreen({required this.duration, required this.roomId, required this.roomName, required this.userName, required this.userId});

  @override
  _TabGameScreenState createState() => _TabGameScreenState();
}

class _TabGameScreenState extends State<TabGameScreen> with SingleTickerProviderStateMixin {
  int _score = 0;
  bool _isTapped = false;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.duration),
    )..addListener(() {
      setState(() {});
    })..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _endGame();
      }
    });
    _startGame();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startGame() {
    _score = 0;
    _controller.forward(from: 0.0);
  }

  void _endGame() async {
    final scores = await _sendScoreAndFetchRankings();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => RankingScreen(
          roomId: widget.roomId,
          roomName: widget.roomName,
          userName: widget.userName,
          userId: widget.userId,
          scores: scores,
          gameName: 'Tab Game', // gameName 추가
        ),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _sendScoreAndFetchRankings() async {
    final response = await http.post(
      Uri.parse('http://172.10.7.88:80/api/rooms/${widget.roomId}/score'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': widget.userId, 'score': _score, 'gameName': 'Tab Game'}), // gameName 추가
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to save score');
    }

    // 0.5초 딜레이 추가
    await Future.delayed(Duration(milliseconds: 500));

    final scoresResponse = await http.get(
      Uri.parse('http://172.10.7.88:80/api/rooms/${widget.roomId}/scores'),
    );

    if (scoresResponse.statusCode != 200) {
      throw Exception('Failed to fetch scores');
    }

    return List<Map<String, dynamic>>.from(jsonDecode(scoresResponse.body));
  }

  void _incrementScore() {
    setState(() {
      _score++;
      _isTapped = true;
    });

    Future.delayed(Duration(milliseconds: 50), () {
      setState(() {
        _isTapped = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Click Game'),
      ),
      body: GestureDetector(
        onTap: _incrementScore,
        child: Container(
          color: Colors.white,
          child: Stack(
            children: [
              Center(
                child: Image.asset(
                  _isTapped ? 'assets/KakaoTalk_20240706_235918320_01.png' : 'assets/KakaoTalk_20240706_235918320.png',
                  fit: BoxFit.cover,
                  height: double.infinity,
                  width: double.infinity,
                  alignment: Alignment.center,
                ),
              ),
              Center(
                child: Text(
                  'Score: $_score',
                  style: TextStyle(fontSize: 40, color: Colors.black),
                ),
              ),
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Container(
                  height: 20,
                  width: double.infinity,
                  child: LinearProgressIndicator(
                    value: _controller.value,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
