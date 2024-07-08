import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'home_screen.dart';
import 'room_screen.dart';

class RankingScreen extends StatelessWidget {
  final int roomId;
  final String roomName;
  final String userName;
  final String userId;
  final List<Map<String, dynamic>> scores;
  final String gameName;

  RankingScreen({
    required this.roomId,
    required this.roomName,
    required this.userName,
    required this.userId,
    required this.scores,
    required this.gameName,
  });

  Future<void> _leaveRoom(BuildContext context) async {
    try {
      final response = await http.post(
        Uri.parse('http://172.10.7.88:80/api/rooms/$roomId/leave'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId}), // 올바른 userId 전달
      );

      if (response.statusCode == 200) {
        print('Left the room successfully');
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
              (Route<dynamic> route) => false,
        );
      } else {
        print('Failed to leave the room: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('방에서 나가는데 실패했습니다. 다시 시도해주세요.')),
        );
      }
    } catch (e) {
      print('Error leaving the room: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('방에서 나가는 중 오류가 발생했습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredScores = scores.where((score) => score['gameName'] == gameName).toList();
    filteredScores.sort((a, b) => b['score'].compareTo(a['score'])); // 점수를 기준으로 내림차순 정렬

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Ranking'),
            SizedBox(width: 8),
            Text(
              '($gameName)',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: filteredScores.length,
              itemBuilder: (context, index) {
                final scoreEntry = filteredScores[index];
                return ListTile(
                  title: Text('${index + 1}. ${scoreEntry['userName']}'),
                  trailing: Text('${scoreEntry['score']} 점'),
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => _leaveRoom(context), // 로비로 나가기 전에 방 나가기 요청을 보냅니다.
                child: Text('로비로 나가기'),
              ),
              SizedBox(width: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => RoomScreen(
                      roomId: roomId,
                      roomName: roomName,
                      userName: userName,
                      userId: userId,
                    )),
                        (Route<dynamic> route) => false,
                  );
                },
                child: Text('게임 다시하기'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
