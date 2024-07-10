import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'room_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _roomNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPrivate = false; // 비밀방 여부
  List<Map<String, dynamic>> _rooms = [];

  @override
  void initState() {
    super.initState();
    _fetchRooms();
  }

  Future<void> _fetchRooms() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('http://172.10.7.88:80/api/rooms'),
      );

      print('Fetch rooms response status: ${response.statusCode}');
      print('Fetch rooms response body: ${response.body}');

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _rooms = List<Map<String, dynamic>>.from(json.decode(response.body));
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('방 목록을 불러오는데 실패했습니다. 다시 시도해주세요.'), duration: Duration(seconds: 1),),
          );
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Fetch rooms error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('방 목록을 불러오는 중 오류가 발생했습니다.'), duration: Duration(seconds: 1),),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _createRoom() async {
    final String roomName = _roomNameController.text;
    final String password = _isPrivate ? _passwordController.text : '';

    if (roomName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('방 이름을 입력해주세요.'), duration: Duration(seconds: 1),),
      );
      return;
    }

    final userId = await _loadUserId();
    final userName = await _loadUserName();

    if (userId == null || userName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('사용자 ID와 이름이 설정되지 않았습니다.'), duration: Duration(seconds: 1),),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://172.10.7.88:80/api/rooms'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'roomName': roomName,
          'password': password,
          'userId': userId,
          'userName': userName,
        }),
      );

      print('Create room response status: ${response.statusCode}');
      print('Create room response body: ${response.body}');

      if (response.statusCode == 201) {
        final roomId = jsonDecode(response.body)['roomId'];

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RoomScreen(
              roomId: roomId,
              roomName: roomName, // 방 이름 전달
              userName: userName,
              userId: userId, // userId 추가
            ),
          ),
        );

        _roomNameController.clear();
        _passwordController.clear();
        _fetchRooms();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('방 생성에 실패했습니다. 다시 시도해주세요.'), duration: Duration(seconds: 1),),
        );
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Create room error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('방 생성 중 오류가 발생했습니다.'), duration: Duration(seconds: 1),),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteRoom(int roomId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.delete(
        Uri.parse('http://172.10.7.88:80/api/rooms/$roomId'),
      );

      print('Delete room response status: ${response.statusCode}');
      print('Delete room response body: ${response.body}');

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('방이 성공적으로 삭제되었습니다.'), duration: Duration(seconds: 1),),
        );
        _fetchRooms();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('방 삭제에 실패했습니다. 다시 시도해주세요.'), duration: Duration(seconds: 1),),
        );
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Delete room error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('방 삭제 중 오류가 발생했습니다.'), duration: Duration(seconds: 1),),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _joinRoom(int roomId, String roomName, bool hasPassword) async {
    String? userId = await _loadUserId();
    String? userName = await _loadUserName();
    String? password;

    if (userId == null || userName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('사용자 ID와 이름이 설정되지 않았습니다.'), duration: Duration(seconds: 1),),
      );
      return;
    }

    if (hasPassword) {
      password = await _showPasswordDialog();
      if (password == null) return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://172.10.7.88:80/api/rooms/$roomId/join'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId, 'userName': userName, 'password': password}),
      );

      print('Join room response status: ${response.statusCode}');
      print('Join room response body: ${response.body}');

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('방에 성공적으로 참가하였습니다.'), duration: Duration(seconds: 1),),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RoomScreen(
              roomId: roomId,
              roomName: roomName, // 방 이름 전달
              userName: userName,
              userId: userId, // userId 추가
            ),
          ),
        );
      } else if (response.statusCode == 403) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('비밀번호가 틀렸습니다.'), duration: Duration(seconds: 1),),
        );
        setState(() {
          _isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('방 참가에 실패했습니다. 다시 시도해주세요.'), duration: Duration(seconds: 1),),
        );
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Join room error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('방 참가 중 오류가 발생했습니다.'), duration: Duration(seconds: 1),),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<String?> _showPasswordDialog() async {
    TextEditingController passwordController = TextEditingController();
    return await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('비밀번호 입력'),
          content: TextField(
            controller: passwordController,
            obscureText: true,
            decoration: InputDecoration(hintText: '비밀번호'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('취소'),
              onPressed: () {
                Navigator.of(context).pop(null);
              },
            ),
            TextButton(
              child: Text('확인'),
              onPressed: () {
                Navigator.of(context).pop(passwordController.text);
              },
            ),
          ],
        );
      },
    );
  }

  // 사용자 ID 저장 함수
  Future<void> _saveUserId(String userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
  }

  // 사용자 이름 저장 함수
  Future<void> _saveUserName(String userName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', userName);
  }

  // 사용자 ID 로드 함수
  Future<String?> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  // 사용자 이름 로드 함수
  Future<String?> _loadUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userName');
  }

  void _showCreateRoomBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      controller: _roomNameController,
                      decoration: InputDecoration(
                        labelText: '방 이름',
                        labelStyle: TextStyle(
                          fontFamily: 'Jua-Regular',
                          fontSize: 16,
                        ),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SwitchListTile(
                    title: Text(
                      '비밀방',
                      style: TextStyle(
                        fontFamily: 'Jua-Regular',
                        fontSize: 16,
                      ),
                    ),
                    value: _isPrivate,
                    onChanged: (bool value) {
                      setModalState(() {
                        _isPrivate = value;
                      });
                      if (_isPrivate) {
                        FocusScope.of(context).requestFocus(FocusNode());
                      }
                    },
                  ),
                  if (_isPrivate)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: '비밀번호',
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                      ),
                    ),
                  ElevatedButton(
                    onPressed: () {
                      _createRoom();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.grey,
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      textStyle: TextStyle(
                        fontFamily: 'Jua-Regular',
                        fontSize: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 5,
                    ),
                    child: Text('확인'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '방 목록',
          style: TextStyle(
            fontFamily: 'Jua-Regular',
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _fetchRooms,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: _rooms.isEmpty
                ? Center(
              child: Text(
                '게임 방이 없습니다.',
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'Jua-Regular',
                ),
              ),
            )
                : ListView.builder(
              itemCount: _rooms.length,
              itemBuilder: (context, index) {
                final room = _rooms[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text(
                      room['roomName'],
                      style: TextStyle(
                        fontFamily: 'Jua-Regular',
                      ),
                    ),
                    onTap: () => _joinRoom(room['id'], room['roomName'], room['password'] != ''),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _deleteRoom(room['id']),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateRoomBottomSheet(context),
        child: Icon(Icons.add),
        backgroundColor: Colors.grey,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        )
      ),
    );
  }
}
