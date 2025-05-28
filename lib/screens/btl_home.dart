import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project_flutter_advanced_nhom_4/models/board_model.dart';
import 'package:final_project_flutter_advanced_nhom_4/screens/btl_CardDetailScreen%20.dart';
import 'package:final_project_flutter_advanced_nhom_4/screens/btl_CreateBoardScreen%20.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CollectionReference boardsCollection = FirebaseFirestore.instance
      .collection('boards');

  String? userId;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      setState(() {
        userId = user?.uid;
      });
    });
  }

  // Sắp xếp boards, đẩy bảng đã gim lên đầu
  List<BoardModel> sortBoards(List<BoardModel> list) {
    list.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return 0;
    });
    return list;
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'Đang hoạt động':
        return Colors.green;
      case 'Tạm dừng':
        return Colors.orange;
      case 'Hoàn thành':
        return Colors.grey;
      default:
        return Colors.blueGrey;
    }
  }

  IconData getStatusIcon(String status) {
    switch (status) {
      case 'Đang hoạt động':
        return Icons.play_circle_fill;
      case 'Tạm dừng':
        return Icons.pause_circle_filled;
      case 'Hoàn thành':
        return Icons.check_circle;
      default:
        return Icons.info;
    }
  }

  Future<void> _deleteBoard(String id) async {
    if (id.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('ID bảng không hợp lệ')));
      return;
    }

    try {
      print('Đang xóa bảng có id = $id');
      await boardsCollection.doc(id).delete();
      print('Xóa thành công');

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã xóa bảng')));

      // Cập nhật lại UI nếu cần
      setState(() {});
    } catch (e) {
      print('Lỗi khi xóa bảng: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Xóa thất bại: $e')));
    }
  }

  Future<void> _togglePin(BoardModel board) async {
    await boardsCollection.doc(board.id).update({'isPinned': !board.isPinned});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          board.isPinned
              ? 'Bỏ gim "${board.title}"'
              : 'Đã gim "${board.title}" lên đầu',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (userId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Quản lý công việc'),
          backgroundColor: Colors.blue,
        ),
        body: const Center(
          child: Text('Vui lòng đăng nhập để xem bảng công việc'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/icon_des1.png', height: 24),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                "Quản lý công việc",
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black87),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateBoardScreen()),
              );
            },
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const TextField(
                style: TextStyle(color: Colors.black87),
                decoration: InputDecoration(
                  hintText: 'Tìm bảng...',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  icon: Icon(Icons.search, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'KHÔNG GIAN LÀM VIỆC CỦA BẠN',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.group, color: Colors.black54),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Không gian làm việc của bạn',
                    style: TextStyle(color: Colors.black87),
                  ),
                ),
                const Text('Bảng', style: TextStyle(color: Colors.blue)),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.blue,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    boardsCollection
                        .where('userId', isEqualTo: userId)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    print('Firestore error: ${snapshot.error}');
                    return Center(
                      child: Text('Lỗi tải dữ liệu: ${snapshot.error}'),
                    );
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  List<BoardModel> boards =
                      snapshot.data!.docs
                          .map((doc) => BoardModel.fromDocument(doc))
                          .toList();

                  boards = sortBoards(boards);

                  if (boards.isEmpty) {
                    return const Center(child: Text('Chưa có bảng nào'));
                  }

                  return ListView.builder(
                    itemCount: boards.length,
                    itemBuilder: (context, index) {
                      final board = boards[index];
                      return Slidable(
                        key: ValueKey(board.id),
                        endActionPane: ActionPane(
                          motion: const ScrollMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (_) => _deleteBoard(board.id),
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              icon: Icons.delete,
                              label: 'Xóa',
                            ),
                          ],
                        ),
                        startActionPane: ActionPane(
                          motion: const ScrollMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (_) => _togglePin(board),
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              icon:
                                  board.isPinned
                                      ? Icons.push_pin
                                      : Icons.push_pin_outlined,
                              label: board.isPinned ? 'Bỏ gim' : 'Gim',
                            ),
                            SlidableAction(
                              onPressed: (_) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Chỉnh sửa "${board.title}" (Chưa làm)',
                                    ),
                                  ),
                                );
                              },
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              icon: Icons.edit,
                              label: 'Sửa',
                            ),
                          ],
                        ),
                        child: ListTile(
                          leading: Image.asset(
                            'assets/icon_des1.png',
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  board.title,
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontWeight:
                                        board.isPinned
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                  ),
                                ),
                              ),
                              if (board.isPinned)
                                const Icon(
                                  Icons.push_pin,
                                  color: Colors.blueAccent,
                                  size: 18,
                                ),
                            ],
                          ),
                          subtitle: Row(
                            children: [
                              Icon(
                                getStatusIcon(board.status),
                                size: 16,
                                color: getStatusColor(board.status),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                board.status,
                                style: TextStyle(
                                  color: getStatusColor(board.status),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CardDetailScreen(board: board),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
