import 'package:final_project_flutter_advanced_nhom_4/services/join_team_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/board_model.dart';

class CardDetailScreen extends StatefulWidget {
  final BoardModel board;

  const CardDetailScreen({super.key, required this.board});

  @override
  State<CardDetailScreen> createState() => _CardDetailScreenState();
}

class _CardDetailScreenState extends State<CardDetailScreen> {
  late List<String> tasks;
  late List<String> members;
  late List<bool> taskCompleted;
  int? expandedTaskIndex;
  final JoinTeamService _joinTeamService = JoinTeamService();

  @override
  void initState() {
    super.initState();
    tasks = ["Chụp ảnh mẫu", "Phân loại đá", "Đính kèm tài liệu"];
    taskCompleted = List.filled(tasks.length, false); // trạng thái
    members = ["Nguyễn Văn A", "Trần Thị B"];
  }

  // Hàm thêm thành viên cho công việc index
  void _addMemberForTask(int taskIndex) async {
    final newMember = await _showInputDialog(
      "Thêm thành viên cho công việc: ${tasks[taskIndex]}",
    );
    if (newMember != null && newMember.trim().isNotEmpty) {
      // Tạm thời mình cho thêm chung danh sách members,
      // nhưng mày có thể làm phức tạp hơn lưu riêng theo task nếu cần
      setState(() {
        members.add(newMember.trim());
      });
    }
  }

  void _addTask() async {
    final newTask = await _showInputDialog("Thêm công việc mới");
    if (newTask != null && newTask.trim().isNotEmpty) {
      setState(() {
        tasks.add(newTask.trim());
      });
    }
  }

  Future<void> showInviteCodeDialog(
    BuildContext context,
    String userId, {
    String? currentInviteCode,
  }) async {
    final TextEditingController inviteCodeController = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Nhập mã mời'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (currentInviteCode != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: SelectableText(
                      'Mã mời hiện tại của bạn: $currentInviteCode',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                TextField(
                  controller: inviteCodeController,
                  decoration: InputDecoration(hintText: 'Mã mời mới'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, inviteCodeController.text.trim());
                },
                child: Text('Tham gia'),
              ),
            ],
          ),
    );

    if (result != null && result.isNotEmpty) {
      try {
        await _joinTeamService.joinTeamWithInviteCode(
          inviteCode: result,
          userId: userId,
        );
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Tham gia team thành công!')));
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: ${e.toString()}')));
      }
    }
  }

  void _addMember(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bạn cần đăng nhập trước khi thêm thành viên')),
      );
      return;
    }

    showInviteCodeDialog(context, userId);
  }

  void _editTask(int index) async {
    final editedTask = await _showInputDialog(
      "Sửa công việc",
      initialText: tasks[index],
    );
    if (editedTask != null && editedTask.trim().isNotEmpty) {
      setState(() {
        tasks[index] = editedTask.trim();
      });
    }
  }

  void _deleteTask(int index) {
    setState(() {
      tasks.removeAt(index);
    });
  }

  // void _addMember() async {
  //   final newMember = await _showInputDialog("Thêm thành viên mới");
  //   if (newMember != null && newMember.trim().isNotEmpty) {
  //     setState(() {
  //       members.add(newMember.trim());
  //     });
  //   }
  // }

  void _editMember(int index) async {
    final editedMember = await _showInputDialog(
      "Sửa thành viên",
      initialText: members[index],
    );
    if (editedMember != null && editedMember.trim().isNotEmpty) {
      setState(() {
        members[index] = editedMember.trim();
      });
    }
  }

  void _deleteMember(int index) {
    setState(() {
      members.removeAt(index);
    });
  }

  Future<String?> _showInputDialog(String title, {String initialText = ""}) {
    final controller = TextEditingController(text: initialText);
    return showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: TextField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(hintText: "Nhập nội dung..."),
              onSubmitted: (value) => Navigator.of(context).pop(value),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Hủy"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(controller.text),
                child: const Text("Lưu"),
              ),
            ],
          ),
    );
  }

  String formatDate(DateTime? date) {
    if (date == null) return "Chưa đặt";
    return DateFormat('dd/MM/yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final board = widget.board;

    return Scaffold(
      backgroundColor: const Color(0xfff4f5f7),
      body: SafeArea(
        child: Column(
          children: [
            // Ảnh bìa + nút đóng
            Stack(
              children: [
                Image.asset(
                  'assets/icon_des1.png',
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  color: Colors.black.withOpacity(0.2),
                  colorBlendMode: BlendMode.darken,
                ),
                Positioned(top: 8, left: 8, child: _coverLabel()),
                Positioned(
                  top: 8,
                  right: 8,
                  child: CircleAvatar(
                    backgroundColor: Colors.black38,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                      tooltip: "Đóng",
                    ),
                  ),
                ),
              ],
            ),

            // Nội dung chính scroll
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title + menu
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            board.title,
                            style: textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        PopupMenuButton<String>(
                          icon: const Icon(
                            Icons.more_horiz,
                            color: Colors.grey,
                            size: 28,
                          ),
                          onSelected: (value) {
                            if (value == 'edit') {
                              print('Edit clicked');
                            } else if (value == 'delete') {
                              print('Delete clicked');
                            }
                          },
                          itemBuilder:
                              (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Text('Sửa'),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Xóa'),
                                ),
                              ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Status
                    Row(
                      children: [
                        _statusTag(board.status, textTheme),
                        const SizedBox(width: 10),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // Ngày bắt đầu và hạn
                    Row(
                      children: [
                        const Icon(Icons.event, size: 18, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          "Bắt đầu: ${formatDate(board.startDate)}",
                          style: textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(width: 20),
                        const Icon(
                          Icons.event_available,
                          size: 18,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Hạn: ${formatDate(board.endDate)}",
                          style: textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Thao tác nhanh
                    Text(
                      "Các thao tác nhanh",
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _quickActionButton(
                          Icons.check_box,
                          "Thêm Danh sách...",
                          onTap: _addTask,
                        ),
                        _quickActionButton(
                          Icons.attachment,
                          "Thêm Tệp đính kèm",
                        ),
                        _quickActionButton(
                          Icons.person,
                          "Thành viên",
                          // onTap: _addMember,
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // Mô tả
                    _sectionHeader(Icons.subject_outlined, "Mô tả", textTheme),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        board.description ?? "Chưa có mô tả",
                        style: textTheme.bodyMedium,
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Tệp đính kèm (tạm giữ nguyên)
                    _sectionHeader(
                      Icons.attach_file,
                      "Tệp đính kèm",
                      textTheme,
                    ),
                    const SizedBox(height: 10),
                    _attachmentItem(textTheme),

                    const SizedBox(height: 30),

                    // Danh sách công việc (với dấu + và dấu 3 chấm)
                    _sectionHeader(
                      Icons.list_alt,
                      "Danh sách công việc",
                      textTheme,
                    ),
                    const SizedBox(height: 12),
                    ...tasks.asMap().entries.map((entry) {
                      final index = entry.key;
                      final task = entry.value;
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Checkbox(value: false, onChanged: (_) {}),
                        title: Text(task, style: textTheme.bodyMedium),
                        trailing: PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert),
                          onSelected: (value) {
                            if (value == 'edit') {
                              _editTask(index);
                            } else if (value == 'delete') {
                              _deleteTask(index);
                            }
                          },
                          itemBuilder:
                              (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Text('Sửa'),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Xóa'),
                                ),
                              ],
                        ),
                      );
                    }),
                    ListTile(
                      leading: const Icon(Icons.add, color: Colors.green),
                      title: Text(
                        "Thêm công việc",
                        style: textTheme.bodyMedium?.copyWith(
                          color: Colors.green,
                        ),
                      ),
                      onTap: _addTask,
                      contentPadding: EdgeInsets.zero,
                    ),

                    const SizedBox(height: 30),

                    // Thành viên (thêm sửa xóa tương tự)
                    _sectionHeader(Icons.person, "Thành viên", textTheme),
                    const SizedBox(height: 12),
                    ...members.asMap().entries.map((entry) {
                      final index = entry.key;
                      final member = entry.value;
                      return ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Colors.purple,
                          child: Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        title: Text(member, style: textTheme.bodyMedium),
                        trailing: PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert),
                          onSelected: (value) {
                            if (value == 'edit') {
                              _editMember(index);
                            } else if (value == 'delete') {
                              _deleteMember(index);
                            }
                          },
                          itemBuilder:
                              (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Text('Sửa'),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Xóa'),
                                ),
                              ],
                        ),
                      );
                    }),
                    ListTile(
                      leading: const Icon(Icons.add, color: Colors.green),
                      title: Text(
                        "Thêm thành viên",
                        style: textTheme.bodyMedium?.copyWith(
                          color: Colors.green,
                        ),
                      ),
                      onTap: () => _addMember(context),
                      contentPadding: EdgeInsets.zero,
                    ),

                    const SizedBox(height: 30),

                    // Bình luận
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.purple,
                          child: Icon(
                            Icons.person,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: TextField(
                            decoration: _inputDecoration(
                              "Bình luận...",
                            ).copyWith(
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.send, size: 22),
                                onPressed: () {},
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 36),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _coverLabel() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(6),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(1, 1)),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.image_outlined, size: 18, color: Colors.black87),
          SizedBox(width: 6),
          Text(
            "Ảnh bìa",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusTag(String status, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue.shade600,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade200.withOpacity(0.6),
            blurRadius: 6,
            offset: const Offset(1, 3),
          ),
        ],
      ),
      child: Text(
        status,
        style: textTheme.bodyMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _quickActionButton(
    IconData icon,
    String label, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 170,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.teal, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(IconData icon, String title, TextTheme textTheme) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[800]),
        const SizedBox(width: 8),
        Text(
          title,
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _attachmentItem(TextTheme textTheme) {
    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: const Icon(Icons.insert_drive_file, color: Colors.blue),
        title: const Text("bao_cao_mau_da.pdf"),
        subtitle: Text("120 KB • PDF", style: textTheme.bodySmall),
        trailing: IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () {},
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}
