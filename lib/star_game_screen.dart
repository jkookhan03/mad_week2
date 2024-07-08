import 'package:flutter/material.dart';
import 'ranking_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:math';

class StarGameScreen extends StatefulWidget {
  final int duration;
  final int roomId;
  final String roomName;
  final String userName;
  final String userId;

  StarGameScreen({
    required this.duration,
    required this.roomId,
    required this.roomName,
    required this.userName,
    required this.userId,
  });

  @override
  _StarGameScreenState createState() => _StarGameScreenState();
}

class _StarGameScreenState extends State<StarGameScreen> with SingleTickerProviderStateMixin {
  int _score = 0;
  late AnimationController _controller;
  final Random _random = Random();
  final double _objectSize = 70.0; // 별과 폭탄의 크기
  late Offset _starPosition;
  late List<Offset> _bombPositions;
  List<Offset> _positions = [];
  late Size _screenSize;

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
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _screenSize = MediaQuery.of(context).size;
    _startGame();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startGame() {
    _score = 0;
    _generatePositions();
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
          gameName: 'Star Game',
          gameDuration: widget.duration, // gameDuration 추가
        ),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _sendScoreAndFetchRankings() async {
    final response = await http.post(
      Uri.parse('http://172.10.7.88:80/api/rooms/${widget.roomId}/score'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': widget.userId, 'score': _score, 'gameName': 'Star Game', 'duration': widget.duration}), // gameName 및 duration 추가
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to save score');
    }

    // 0.5초 딜레이 추가
    await Future.delayed(Duration(milliseconds: 500));

    final scoresResponse = await http.get(
      Uri.parse('http://172.10.7.88:80/api/rooms/${widget.roomId}/scores?gameName=Star%20Game&duration=${widget.duration}'), // 게임 이름과 시간을 쿼리 파라미터로 전달
    );

    if (scoresResponse.statusCode != 200) {
      throw Exception('Failed to fetch scores');
    }

    return List<Map<String, dynamic>>.from(jsonDecode(scoresResponse.body));
  }

  void _generatePositions() {
    _positions = [];
    _starPosition = _getRandomPosition();
    _positions.add(_starPosition);

    _bombPositions = List.generate(5, (index) {
      Offset position;
      do {
        position = _getRandomPosition();
      } while (_isOverlapping(position));
      _positions.add(position);
      return position;
    });
  }

  Offset _getRandomPosition() {
    final double x = _random.nextDouble() * (_screenSize.width - _objectSize);
    final double y = _random.nextDouble() * (_screenSize.height - _objectSize - 120) + 50; // 점수 텍스트 아래, 타이머 위
    return Offset(x, y);
  }

  bool _isOverlapping(Offset position) {
    for (Offset pos in _positions) {
      if ((pos - position).distance < _objectSize) {
        return true;
      }
    }
    return false;
  }

  void _onStarTapped() {
    setState(() {
      _score++;
      _generatePositions();
    });
  }

  void _onBombTapped() {
    setState(() {
      _score--;
      _generatePositions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Star Game'),
      ),
      body: Stack(
        children: [
          Positioned(
            top: 20,
            left: 20,
            child: Text('Score: $_score', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ),
          Positioned(
            left: _starPosition.dx,
            top: _starPosition.dy,
            child: GestureDetector(
              onTap: _onStarTapped,
              child: Image.asset('assets/star.png', width: _objectSize, height: _objectSize),
            ),
          ),
          for (Offset position in _bombPositions)
            Positioned(
              left: position.dx,
              top: position.dy,
              child: GestureDetector(
                onTap: _onBombTapped,
                child: Image.asset('assets/bomb.png', width: _objectSize, height: _objectSize),
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
    );
  }
}
