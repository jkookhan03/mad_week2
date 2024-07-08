import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:web_socket_channel/io.dart';
import 'tab_game_screen.dart';
import 'balloon_game_screen.dart';
import 'star_game_screen.dart'; // StarGameScreen import 추가

class RoomScreen extends StatefulWidget {
  final int roomId;
  final String roomName;
  final String userName;
  final String userId;

  RoomScreen({required this.roomId, required this.roomName, required this.userName, required this.userId});

  @override
  _RoomScreenState createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _participants = [];
  String? _leaderId;
  Timer? _timer;
  late IOWebSocketChannel _channel;
  String _selectedGame = 'tab_game'; // 기본값을 설정합니다.
  int _selectedDuration = 20; // 기본 게임 시간 설정
  bool _isGameStarted = false; // 게임 시작 플래그 추가

  @override
  void initState() {
    super.initState();
    _fetchParticipants();
    _fetchGameSettings(); // 방장 설정 정보 가져오기
    _startAutoRefresh();
    _connectWebSocket();
  }

  @override
  void dispose() {
    if (!_isGameStarted) { // 게임이 시작되지 않았을 때만 방에서 나가도록 수정
      _leaveRoom();
    }
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
        setState(() {
          _isGameStarted = true; // 게임 시작 플래그 설정
        });
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) {
              if (_selectedGame == 'tab_game') {
                return TabGameScreen(
                  duration: _selectedDuration,
                  roomId: widget.roomId,
                  roomName: widget.roomName,
                  userName: widget.userName,
                  userId: widget.userId,
                ); // 게임 시간 전달
              } else if (_selectedGame == 'balloon_game') {
                return BalloonGameScreen(
                  duration: _selectedDuration,
                  roomId: widget.roomId,
                  roomName: widget.roomName,
                  userName: widget.userName,
                  userId: widget.userId,
                ); // 게임 시간 전달
              } else {
                return StarGameScreen(
                  duration: _selectedDuration,
                  roomId: widget.roomId,
                  roomName: widget.roomName,
                  userName: widget.userName,
                  userId: widget.userId,
                ); // 게임 시간 전달
              }
            },
          ),
        );
      }
    });
  }

  void _startGame() {
    _channel.sink.add(jsonEncode({
      'type': 'start-game',
      'roomId': widget.roomId,
      'game': _selectedGame, // 선택한 게임을 서버로 전송합니다.
      'duration': _selectedDuration, // 선택한 게임 시간 서버로 전송
    }));
  }

  void _startAutoRefresh() {
    _timer = Timer.periodic(Duration(milliseconds: 500), (timer) {
      _fetchParticipants();
      _fetchGameSettings(); // 5초마다 게임 설정을 새로고침합니다.
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

  Future<void> _fetchGameSettings() async {
    try {
      final response = await http.get(
        Uri.parse('http://172.10.7.88:80/api/rooms/${widget.roomId}/settings'),
      );

      print('Fetch game settings response status: ${response.statusCode}');
      print('Fetch game settings response body: ${response.body}');

      if (response.statusCode == 200) {
        final settings = json.decode(response.body);
        setState(() {
          _selectedGame = settings['game'] ?? 'tab_game';
          _selectedDuration = settings['duration'] ?? 20;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('게임 설정 정보를 불러오는데 실패했습니다. 다시 시도해주세요.')),
        );
      }
    } catch (e) {
      print('Fetch game settings error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('게임 설정 정보를 불러오는 중 오류가 발생했습니다.')),
      );
    }
  }

  Future<void> _updateGameSettings() async {
    try {
      final response = await http.post(
        Uri.parse('http://172.10.7.88:80/api/rooms/${widget.roomId}/settings'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'game': _selectedGame, 'duration': _selectedDuration}),
      );

      if (response.statusCode != 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('게임 설정을 업데이트하는 데 실패했습니다. 다시 시도해주세요.')),
        );
      }
    } catch (e) {
      print('Update game settings error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('게임 설정을 업데이트하는 중 오류가 발생했습니다.')),
      );
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
        if (!_isGameStarted) { // 게임이 시작되지 않았을 때만 방에서 나가도록 수정
          await _leaveRoom();
        }
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
            // 게임 선택 UI 추가 (방장만 보이도록 수정)
            if (isLeader)
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedGame = 'tab_game';
                          });
                          _updateGameSettings(); // 방장이 게임 설정을 변경할 때 서버에 전송
                        },
                        child: Text('Tab Game'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedGame == 'tab_game' ? Colors.blue : Colors.grey,
                        ),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedGame = 'balloon_game';
                          });
                          _updateGameSettings(); // 방장이 게임 설정을 변경할 때 서버에 전송
                        },
                        child: Text('Balloon Game'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedGame == 'balloon_game' ? Colors.blue : Colors.grey,
                        ),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedGame = 'star_game';
                          });
                          _updateGameSettings(); // 방장이 게임 설정을 변경할 때 서버에 전송
                        },
                        child: Text('Star Game'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedGame == 'star_game' ? Colors.blue : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  // 게임 시간 선택 UI 추가 (방장만 보이도록 수정)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('게임 시간: ', style: TextStyle(fontSize: 16)),
                      DropdownButton<int>(
                        value: _selectedDuration,
                        items: [10, 20, 30].map((int value) {
                          return DropdownMenuItem<int>(
                            value: value,
                            child: Text('$value초'),
                          );
                        }).toList(),
                        onChanged: (int? newValue) {
                          setState(() {
                            _selectedDuration = newValue ?? 20;
                          });
                          _updateGameSettings(); // 방장이 게임 시간을 변경할 때 서버에 전송
                        },
                      ),
                    ],
                  ),
                ],
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
