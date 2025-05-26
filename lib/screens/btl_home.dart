import 'package:final_project_flutter_advanced_nhom_4/screens/btl_CardDetailScreen%20.dart';
import 'package:final_project_flutter_advanced_nhom_4/screens/btl_CreateBoardScreen%20.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;

  final List<Map<String, dynamic>> boards = [
    {'title': 'Abc', 'image': 'assets/icon_des1.png'},
    {'title': 'Ghh', 'image': 'assets/icon_des1.png'},
    {'title': 'Hhh', 'color': Colors.blue},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
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
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.add, color: Colors.black87),
            position: PopupMenuPosition.under,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (value) {
              if (value == 'create_board') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateBoardScreen(),
                  ),
                );
              }
            },
            itemBuilder:
                (BuildContext context) => const [
                  PopupMenuItem<String>(
                    value: 'create_board',
                    child: Text('Tạo bảng'),
                  ),
                ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
                  hintText: 'Bảng',
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
            const Row(
              children: [
                Icon(Icons.group, color: Colors.black54),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'không gian làm việc của Đinh Việt Hà',
                    style: TextStyle(color: Colors.black87),
                  ),
                ),
                Text('Bảng', style: TextStyle(color: Colors.blue)),
                Icon(Icons.arrow_forward_ios, size: 16, color: Colors.blue),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: boards.length,
                itemBuilder: (context, index) {
                  final board = boards[index];
                  return ListTile(
                    leading:
                        board['image'] != null
                            ? Image.asset(
                              board['image'],
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                            )
                            : Container(
                              width: 40,
                              height: 40,
                              color: board['color'] ?? Colors.grey,
                            ),
                    title: Text(
                      board['title'],
                      style: const TextStyle(color: Colors.black87),
                    ),
                    onTap: () {
                      // Hiệu ứng ripple tự có rồi, thêm điều hướng
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CardDetailScreen(),
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
