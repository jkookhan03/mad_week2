import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:web_socket_channel/io.dart';
import 'game_screen.dart';  // game_screen import 추가

class RoomScreen extends StatefulWidget {
  final int roomId;
  final String roomName;
  final String userName;
  final String userId; // userId 추가

  RoomScreen({required this.roomId, required this.roomName, required this.userName, required this.userId}); // userId 추가

  @override
  _RoomScreenState createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _participants = [];
  String? _leaderId;
  Timer? _timer;
  late IOWebSocketChannel _channel;

  @override
  void initState() {
    super.initState();
    _fetchParticipants();
    _startAutoRefresh();
    _connectWebSocket();
  }

  @override
  void dispose() {
    _leaveRoom();
    _timer?.cancel();
    _channel.sink.close();
    super.dispose();
  }

  void _connectWebSocket() {
    _channel = IOWebSocketChannel.connect('ws://172.10.7.88:80');
    _channel.sink.add(jsonEncode({
      'type': 'join',
      'roomId': widget.roomId,
    }));

    _channel.stream.listen((message) {
      final parsedMessage = jsonDecode(message);
      if (parsedMessage['type'] == 'game-started' && parsedMessage['roomId'] == widget.roomId) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => GameScreen(),
          ),
        );
      }
    });
  }

  void _startGame() {
    _channel.sink.add(jsonEncode({
      'type': 'start-game',
      'roomId': widget.roomId,
    }));
  }

  void _startAutoRefresh() {
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      _fetchParticipants();
    });
  }

  Future<void> _fetchParticipants() async {
    try {
      final response = await http.get(
        Uri.parse('http://172.10.7.88:80/api/rooms/${widget.roomId}/participants'),
      );

      print('Fetch participants response status: ${response.statusCode}');
      print('Fetch participants response body: ${response.body}');

      if (response.statusCode == 200) {
        List<Map<String, dynamic>> participants = List<Map<String, dynamic>>.from(json.decode(response.body));
        participants = participants.map((p) => {
          'userId': p['userId'],
          'userName': p['userName'],
          'isLeader': p['isLeader'] == 1,
          'isReady': p['isReady'] == 1,
        }).toList();

        setState(() {
          _participants = participants;
          _leaderId = _participants.firstWhere((p) => p['isLeader'], orElse: () => {'userId': null})['userId'];
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
        body: jsonEncode({'userId': widget.userId}), // 올바른 userId 전달
      );

      if (response.statusCode == 200) {
        print('Left the room successfully');
      } else {
        print('Failed to leave the room: ${response.body}');
      }
    } catch (e) {
      print('Error leaving the room: $e');
    }
  }

  Future<void> _updateReadyState() async {
    final currentUser = _participants.firstWhere((p) => p['userName'] == widget.userName, orElse: () => {});
    if (currentUser.isEmpty) return;

    final newReadyState = !currentUser['isReady'];

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://172.10.7.88:80/api/rooms/${widget.roomId}/ready'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': currentUser['userId'], 'isReady': newReadyState}),
      );

      print('Update ready state response status: ${response.statusCode}');
      print('Update ready state response body: ${response.body}');

      if (response.statusCode == 200) {
        setState(() {
          currentUser['isReady'] = newReadyState;
        });
        _fetchParticipants(); // 서버에 업데이트 후 참가자 목록 갱신
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('준비 상태를 업데이트하는 데 실패했습니다. 다시 시도해주세요.')),
        );
      }
    } catch (e) {
      print('Update ready state error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('준비 상태를 업데이트하는 중 오류가 발생했습니다.')),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _transferLeadership(String newLeaderId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://172.10.7.88:80/api/rooms/${widget.roomId}/transfer-leadership'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'currentLeaderId': widget.userId, 'newLeaderId': newLeaderId}), // currentLeaderId 수정
      );

      if (response.statusCode == 200) {
        _fetchParticipants();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('방장 권한을 넘기는 데 실패했습니다. 다시 시도해주세요.')),
        );
      }
    } catch (e) {
      print('Transfer leadership error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('방장 권한을 넘기는 중 오류가 발생했습니다.')),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  bool _allParticipantsReadyExceptLeader() {
    return _participants
        .where((p) => p['userId'] != _leaderId)
        .every((p) => p['isReady']);
  }

  @override
  Widget build(BuildContext context) {
    final isLeader = _leaderId == widget.userId; // userName 대신 userId 사용
    final allReadyExceptLeader = _allParticipantsReadyExceptLeader();

    return WillPopScope(
      onWillPop: () async {
        await _leaveRoom();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Room: ${widget.roomName}'),
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
                  final isLeader = participant['isLeader'];
                  final userName = participant['userName'];
                  final readyStatus = participant['isReady'] ? '준비됨' : '준비 안됨';
                  final displayName = isLeader ? '$userName (방장)' : userName;

                  return ListTile(
                    title: Text(
                      '$displayName ($readyStatus)',
                    ),
                    trailing: isLeader && participant['userId'] != widget.userId // userName 대신 userId 사용
                        ? IconButton(
                      icon: Icon(Icons.person_add),
                      onPressed: () => _transferLeadership(participant['userId']), // userName 대신 userId 사용
                    )
                        : null,
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: isLeader
                  ? (allReadyExceptLeader ? _startGame : null)
                  : _updateReadyState,
              child: Text(isLeader ? '게임 시작' : (_participants.firstWhere((p) => p['userId'] == widget.userId, orElse: () => {'isReady': false})['isReady'] ? '준비 해제' : '준비')), // userName 대신 userId 사용
            ),
          ],
        ),
      ),
    );
  }
}
