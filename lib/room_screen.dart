import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RoomScreen extends StatefulWidget {
  final int roomId;
  final String roomName; // 방 이름 추가
  final String userName;

  RoomScreen({required this.roomId, required this.roomName, required this.userName});

  @override
  _RoomScreenState createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  bool _isLoading = false;
  List<String> _participants = [];

  @override
  void initState() {
    super.initState();
    _fetchParticipants();
  }

  @override
  void dispose() {
    _leaveRoom();
    super.dispose();
  }

  Future<void> _fetchParticipants() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('http://172.10.7.88:80/api/rooms/${widget.roomId}/participants'),
      );

      print('Fetch participants response status: ${response.statusCode}');
      print('Fetch participants response body: ${response.body}');

      if (response.statusCode == 200) {
        setState(() {
          _participants = List<String>.from(json.decode(response.body).map((item) => item['userName']));
          _isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('참가자 목록을 불러오는데 실패했습니다. 다시 시도해주세요.')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Fetch participants error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('참가자 목록을 불러오는 중 오류가 발생했습니다.')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _leaveRoom() async {
    try {
      final response = await http.post(
        Uri.parse('http://172.10.7.88:80/api/rooms/${widget.roomId}/leave'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userName': widget.userName}),
      );

      print('Leave room response status: ${response.statusCode}');
      print('Leave room response body: ${response.body}');

      if (response.statusCode != 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('방에서 나가는 데 실패했습니다. 다시 시도해주세요.')),
        );
      }
    } catch (e) {
      print('Leave room error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('방에서 나가는 중 오류가 발생했습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Room: ${widget.roomName}'), // 방 이름 표시
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _fetchParticipants,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          SizedBox(height: 32),
          Text(
            '참가자 목록',
            style: TextStyle(fontSize: 24),
          ),
          Expanded(
            child: _participants.isEmpty
                ? Center(
              child: Text(
                '참가자가 없습니다.',
                style: TextStyle(fontSize: 20),
              ),
            )
                : ListView.builder(
              itemCount: _participants.length,
              itemBuilder: (context, index) {
                final participant = _participants[index];
                return ListTile(
                  title: Text(participant),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
