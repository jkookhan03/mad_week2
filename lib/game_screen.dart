import 'package:flutter/material.dart';

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int _score = 0;

  void _incrementScore() {
    setState(() {
      _score++;
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
          child: Center(
            child: Text(
              'Score: $_score',
              style: TextStyle(fontSize: 40),
            ),
          ),
        ),
      ),
    );
  }
}
