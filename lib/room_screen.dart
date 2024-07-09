import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:web_socket_channel/io.dart';
import 'tab_game_screen.dart';
import 'balloon_game_screen.dart';
import 'star_game_screen.dart';

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
  String _selectedGame = 'tab_game';
  int _selectedDuration = 20;
  bool _isGameStarted = false;

  @override
  void initState() {
    super.initState();
    _fetchParticipants();
    _fetchGameSettings();
    _startAutoRefresh();
    _connectWebSocket();
  }

  @override
  void dispose() {
    if (!_isGameStarted) {
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
          _isGameStarted = true;
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
                );
              } else if (_selectedGame == 'balloon_game') {
                return BalloonGameScreen(
                  duration: _selectedDuration,
                  roomId: widget.roomId,
                  roomName: widget.roomName,
                  userName: widget.userName,
                  userId: widget.userId,
                );
              } else {
                return StarGameScreen(
                  duration: _selectedDuration,
                  roomId: widget.roomId,
                  roomName: widget.roomName,
                  userName: widget.userName,
                  userId: widget.userId,
                );
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
      'game': _selectedGame,
      'duration': _selectedDuration,
    }));
  }

  void _startAutoRefresh() {
    _timer = Timer.periodic(Duration(milliseconds: 500), (timer) {
      _fetchParticipants();
      _fetchGameSettings();
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
        body: jsonEncode({'userId': widget.userId}),
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
        _fetchParticipants();
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
        body: jsonEncode({'currentLeaderId': widget.userId, 'newLeaderId': newLeaderId}),
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
    final isLeader = _leaderId == widget.userId;
    final allReadyExceptLeader = _allParticipantsReadyExceptLeader();

    return WillPopScope(
      onWillPop: () async {
        if (!_isGameStarted) {
          await _leaveRoom();
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Room: ${widget.roomName}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.black,
              fontFamily: 'Jua-Regular',
            ),
          ),
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
              style: TextStyle(
                fontSize: 30,
                fontFamily: 'Jua-Regular',
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: _participants.isEmpty
                  ? Center(
                child: Text(
                  '참가자가 없습니다.',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Jua-Regular',
                  ),
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
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          displayName,
                          style: TextStyle(
                            fontSize: 18,
                            fontFamily: 'Jua-Regular',
                            color: Colors.black,
                          ),
                        ),
                        if (!isLeader)
                          Row(
                            children: [
                              Text(
                                readyStatus,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'Jua-Regular',
                                  color: readyStatus == '준비됨' ? Colors.green : Colors.red,
                                ),
                              ),
                              if (!isLeader && participant['userId'] != widget.userId)
                                IconButton(
                                  icon: Icon(Icons.person_add),
                                  onPressed: () => _transferLeadership(participant['userId']),
                                ),
                            ],
                          ),
                      ],
                    ),
                    trailing: null,
                  );
                },
              ),
            ),
            if (isLeader)
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ToggleButtons(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text('Tab Game'),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text('Balloon Game'),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text('Star Game'),
                          ),
                        ],
                        isSelected: [
                          _selectedGame == 'tab_game',
                          _selectedGame == 'balloon_game',
                          _selectedGame == 'star_game',
                        ],
                        onPressed: (int index) {
                          setState(() {
                            if (index == 0) {
                              _selectedGame = 'tab_game';
                            } else if (index == 1) {
                              _selectedGame = 'balloon_game';
                            } else if (index == 2) {
                              _selectedGame = 'star_game';
                            }
                            _updateGameSettings();
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                          '게임 시간: ',
                          style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Jua-Regular'
                          ),
                      ),
                      DropdownButton<int>(
                        value: _selectedDuration,
                        items: [
                          DropdownMenuItem(
                              child: Text(
                                '10초',
                                style: TextStyle(
                                  fontSize: 16, fontFamily: 'Jua-Regular'
                                ),
                              ),
                            value: 10,
                          ),
                          DropdownMenuItem(
                            child: Text(
                              '20초',
                              style: TextStyle(
                                  fontSize: 16, fontFamily: 'Jua-Regular'
                              ),
                            ),
                            value: 20,
                          ),
                          DropdownMenuItem(
                            child: Text(
                              '30초',
                              style: TextStyle(
                                  fontSize: 16, fontFamily: 'Jua-Regular'
                              ),
                            ),
                            value: 30,
                          ),
                        ],
                        onChanged: (int? newValue){
                          setState(() {
                            _selectedDuration = newValue!;
                            _updateGameSettings();
                          });
                        },
                      )
                    ],
                  ),
                ],
              ),
            Container(
              width: double.infinity, // 가로 전체에 퍼지게 하기
              margin: EdgeInsets.only(bottom: 20.0), // 아래에서 위로 띄우기
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: ElevatedButton(
                onPressed: isLeader
                    ? (allReadyExceptLeader ? _startGame : null)
                    : _updateReadyState,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.grey,
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
                child: Text(
                  isLeader
                      ? '게임 시작'
                      : (_participants.firstWhere(
                          (p) => p['userId'] == widget.userId,
                      orElse: () => {'isReady': false})['isReady']
                      ? '준비 해제'
                      : '준비'),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
