import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RoomScreen extends StatefulWidget {
  final int roomId;
  final String userName;

  RoomScreen({required this.roomId, required this.userName});

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Room: ${widget.userName}'), // 방에 참가한 사용자의 이름을 표시
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _fetchParticipants, // 새로고침 버튼 클릭 시 참가자 목록 갱신
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
