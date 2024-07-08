// balloon_game_screen.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class Balloon {
  Color color;
  bool isBursting;

  Balloon({required this.color, this.isBursting = false});
}

class BalloonGameScreen extends StatefulWidget {
  @override
  _BalloonGameScreenState createState() => _BalloonGameScreenState();
}

class _BalloonGameScreenState extends State<BalloonGameScreen>
    with SingleTickerProviderStateMixin {
  final List<Color> balloonColors = [
    Colors.red,
    Colors.yellow,
    Colors.green,
    Colors.blue,
    Colors.black,
    Colors.orange,
    Colors.pink,
    Colors.purple,
    Colors.grey,
    Colors.brown,
    Colors.lightBlue,
  ];

  final List<String> colorNames = [
    '빨강',
    '노랑',
    '초록',
    '파랑',
    '검정',
    '주황',
    '분홍',
    '보라',
    '회색',
    '갈색',
    '하늘',
  ];

  final Map<String, String> colorToImage = {
    '빨강': 'assets/red_balloon.png',
    '노랑': 'assets/yellow_balloon.png',
    '초록': 'assets/green_balloon.png',
    '파랑': 'assets/blue_balloon.png',
    '검정': 'assets/black_balloon.png',
    '주황': 'assets/orange_balloon.png',
    '분홍': 'assets/pink_balloon.png',
    '보라': 'assets/purple_balloon.png',
    '회색': 'assets/grey_balloon.png',
    '갈색': 'assets/brown_balloon.png',
    '하늘': 'assets/lightblue_balloon.png',
  };

  final Map<String, String> colorToBurstImage = {
    '빨강': 'assets/red_burst_balloon.png',
    '노랑': 'assets/yellow_burst_balloon.png',
    '초록': 'assets/green_burst_balloon.png',
    '파랑': 'assets/blue_burst_balloon.png',
    '검정': 'assets/black_burst_balloon.png',
    '주황': 'assets/orange_burst_balloon.png',
    '분홍': 'assets/pink_burst_balloon.png',
    '보라': 'assets/purple_burst_balloon.png',
    '회색': 'assets/grey_burst_balloon.png',
    '갈색': 'assets/brown_burst_balloon.png',
    '하늘': 'assets/lightblue_burst_balloon.png',
  };

  List<Balloon> balloons = [];
  String targetColorName = '';
  String decoyColorName = '';
  Color targetTextColor = Colors.black;
  Color decoyTextColor = Colors.black;
  int score = 0;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 20),
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
    score = 0;
    _generateTargetAndDecoy();
    _generateBalloons();
    _controller.forward(from: 0.0);
  }

  void _endGame() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('게임 종료'),
        content: Text('점수: $score'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _startGame();
            },
            child: Text('다시 시작'),
          ),
        ],
      ),
    );
  }

  void _generateBalloons() {
    final random = Random();
    Set<int> targetIndices = Set<int>();
    while (targetIndices.length < 2) {
      targetIndices.add(random.nextInt(12));
    }
    setState(() {
      balloons = List<Balloon>.generate(12, (index) {
        if (index == targetIndices.first) {
          return Balloon(color: balloonColors[colorNames.indexOf(targetColorName)]);
        } else if (index == targetIndices.last) {
          return Balloon(color: balloonColors[colorNames.indexOf(decoyColorName)]);
        } else {
          return Balloon(color: balloonColors[random.nextInt(balloonColors.length)]);
        }
      });
    });
  }

  void _generateTargetAndDecoy() {
    final random = Random();
    setState(() {
      final targetIndex = random.nextInt(colorNames.length);
      targetColorName = colorNames[targetIndex];
      targetTextColor = balloonColors[targetIndex];

      // 미끼 색상 이름 설정
      int decoyIndex;
      do {
        decoyIndex = random.nextInt(colorNames.length);
      } while (decoyIndex == targetIndex);
      decoyColorName = colorNames[decoyIndex];
      decoyTextColor = balloonColors[decoyIndex];
    });
  }

  Future<void> _checkBalloon(int index) async {
    setState(() {
      balloons[index].isBursting = true;
    });

    await Future.delayed(Duration(milliseconds: 500));

    setState(() {
      final colorIndex = balloonColors.indexOf(balloons[index].color);
      final colorName = colorNames[colorIndex];

      if (colorName == targetColorName) {
        score++;
      } else if (colorName != targetColorName) {
        score--;
      }

      balloons[index].isBursting = false;
      _generateTargetAndDecoy();
      _generateBalloons();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: 60),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '풍선 게임',
              style: TextStyle(
                fontSize: 32,
                fontFamily: 'Jua-Regular',
              ),
            ),
          ),
          Center(
            child: Text(
              targetColorName,
              style: TextStyle(
                color: decoyTextColor,
                fontSize: 40,
                fontFamily: 'Jua-Regular',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '',
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'Jua-Regular',
                  ),
                ),
                Text(
                  'Score: $score',
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'Jua-Regular',
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(8.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 8.0,
                crossAxisSpacing: 8.0,
              ),
              itemCount: balloons.length,
              itemBuilder: (context, index) {
                final balloon = balloons[index];
                final colorIndex = balloonColors.indexOf(balloon.color);
                final colorName = colorNames[colorIndex];
                final balloonImage = balloon.isBursting
                    ? colorToBurstImage[colorName]!
                    : colorToImage[colorName]!;

                return GestureDetector(
                  onTap: () => _checkBalloon(index),
                  child: Transform.scale(
                    scale: 0.8,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: AssetImage(balloonImage),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            height: 20,
            width: double.infinity,
            child: LinearProgressIndicator(
              value: _controller.value,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ),
        ],
      ),
    );
  }
}
