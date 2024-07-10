import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'home_screen.dart';
import 'room_screen.dart';
import 'main.dart'; // MyHomePage import 추가

class RankingScreen extends StatelessWidget {
  final int roomId;
  final String roomName;
  final String userName;
  final String userId;
  final List<Map<String, dynamic>> scores;
  final String gameName;
  final int gameDuration; // 게임 시간을 추가합니다.

  RankingScreen({
    required this.roomId,
    required this.roomName,
    required this.userName,
    required this.userId,
    required this.scores,
    required this.gameName,
    required this.gameDuration,
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
          MaterialPageRoute(builder: (context) => MyHomePage()), // MyHomePage로 변경
              (Route<dynamic> route) => false,
        );
      } else {
        print('Failed to leave the room: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('방에서 나가는데 실패했습니다. 다시 시도해주세요.'), duration: Duration(seconds: 1),),
        );
      }
    } catch (e) {
      print('Error leaving the room: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('방에서 나가는 중 오류가 발생했습니다.'), duration: Duration(seconds: 1),),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 게임 종류와 시간으로 필터링
    final filteredScores = scores.where((score) => score['gameName'] == gameName && score['duration'] == gameDuration).toList();
    filteredScores.sort((a, b) => b['score'].compareTo(a['score'])); // 점수를 기준으로 내림차순 정렬

    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: 60),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '게임 결과',
                style: TextStyle(
                  fontFamily: 'Jua-Regular',
                  fontSize: 30,
                ),
              ),
              SizedBox(width: 8),
              Text(
                '($gameName - $gameDuration초)',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontFamily: 'Jua-Regular',
                ),
              )
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredScores.length,
              itemBuilder: (context, index) {
                final scoreEntry = filteredScores[index];
                return ListTile(
                  title: Text(
                    '${index + 1}. ${scoreEntry['userName']}',
                    style: TextStyle(
                      fontFamily: 'Jua-Regular',
                      fontSize: 20,
                    ),
                  ),
                  trailing: Text(
                    '${scoreEntry['score']} 점',
                    style: TextStyle(
                      fontFamily: 'Jua-Regular',
                      fontSize: 20,
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            width: double.infinity, // 가로 전체에 퍼지게 하기
            margin: EdgeInsets.only(bottom: 20.0), // 아래에서 위로 띄우기
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _leaveRoom(context), // 로비로 나가기 전에 방 나가기 요청을 보냅니다.
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.grey,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      textStyle: TextStyle(
                        fontFamily: 'Jua-Regular',
                        fontSize: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8), // 둥근 모서리
                      ),
                      elevation: 5, // 그림자 깊이
                    ),
                    child: Text('로비로 나가기'),
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: ElevatedButton(
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
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.grey,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      textStyle: TextStyle(
                        fontFamily: 'Jua-Regular',
                        fontSize: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8), // 둥근 모서리
                      ),
                      elevation: 5, // 그림자 깊이
                    ),
                    child: Text('게임 다시하기'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
