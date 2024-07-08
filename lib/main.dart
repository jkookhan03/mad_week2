// main.dart
import 'package:flutter/material.dart';
import 'balloon_game_screen.dart';

void main() {
  runApp(BalloonGame());
}

class BalloonGame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BalloonGameScreen(),
    );
  }
}
