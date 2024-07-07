import 'package:flutter/material.dart';

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int _score = 0;
  bool _isTapped = false;

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
            ],
          ),
        ),
      ),
    );
  }
}
