import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _roomNameController = TextEditingController();
  bool _isLoading = false;
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
        Uri.parse('http://172.10.7.88:80/api/rooms'),  // 포트를 80으로 수정
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
            SnackBar(content: Text('방 목록을 불러오는데 실패했습니다. 다시 시도해주세요.')),
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
          SnackBar(content: Text('방 목록을 불러오는 중 오류가 발생했습니다.')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _createRoom() async {
    final String roomName = _roomNameController.text;

    if (roomName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('방 이름을 입력해주세요.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://172.10.7.88:80/api/rooms'),  // 포트를 80으로 수정
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'roomName': roomName}),
      );

      print('Create room response status: ${response.statusCode}');
      print('Create room response body: ${response.body}');

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('방이 성공적으로 생성되었습니다.')),
        );
        _roomNameController.clear();
        _fetchRooms(); // 방 생성 후 방 목록 갱신
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('방 생성에 실패했습니다. 다시 시도해주세요.')),
          );
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Create room error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('방 생성 중 오류가 발생했습니다.')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteRoom(int roomId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.delete(
        Uri.parse('http://172.10.7.88:80/api/rooms/$roomId'),  // 포트를 80으로 수정
      );

      print('Delete room response status: ${response.statusCode}');
      print('Delete room response body: ${response.body}');

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('방이 성공적으로 삭제되었습니다.')),
        );
        _fetchRooms(); // 방 삭제 후 방 목록 갱신
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('방 삭제에 실패했습니다. 다시 시도해주세요.')),
          );
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Delete room error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('방 삭제 중 오류가 발생했습니다.')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _fetchRooms, // 새로고침 버튼 클릭 시 방 목록 갱신
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _roomNameController,
              decoration: InputDecoration(
                labelText: '방 이름',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _createRoom,
            child: Text('방 만들기'),
          ),
          SizedBox(height: 32),
          Text(
            '방 목록',
            style: TextStyle(fontSize: 24),
          ),
          Expanded(
            child: _rooms.isEmpty
                ? Center(
              child: Text(
                '게임 방이 없습니다.',
                style: TextStyle(fontSize: 20),
              ),
            )
                : ListView.builder(
              itemCount: _rooms.length,
              itemBuilder: (context, index) {
                final room = _rooms[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text(room['roomName']),
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
    );
  }
}
