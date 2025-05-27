import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project_flutter_advanced_nhom_4/models/board_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CreateBoardScreen extends StatefulWidget {
  const CreateBoardScreen({Key? key}) : super(key: key);

  @override
  State<CreateBoardScreen> createState() => _CreateBoardScreenState();
}

class _CreateBoardScreenState extends State<CreateBoardScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  DateTime? startDate;
  DateTime? endDate;

  String _status = 'Đang hoạt động';

  bool get isStartingSoon => _status == 'Sắp bắt đầu';

  bool _isLoading = false;

  final List<String> statusOptions = [
    'Đang hoạt động',
    'Sắp bắt đầu',
    'Hoàn thành',
    'Tạm dừng',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<DateTime?> _pickDateTime(DateTime? initial) async {
    final now = DateTime.now();

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initial ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: CupertinoColors.activeBlue,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate == null) return null;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime:
          initial != null
              ? TimeOfDay(hour: initial.hour, minute: initial.minute)
              : TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: CupertinoColors.activeBlue,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime == null) return null;

    return DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );
  }

  Future<void> _createBoard() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    if (userId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Lỗi')));
      return;
    }

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tên dự án không được để trống')),
      );
      return;
    }

    if (isStartingSoon && startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ngày bắt đầu')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Tạo document ref với id tự sinh
      final docRef = FirebaseFirestore.instance.collection('boards').doc();

      // Tạo model với id lấy từ docRef.id
      final newBoard = BoardModel(
        id: docRef.id,
        title: title,
        description: description.isEmpty ? null : description,
        startDate: startDate,
        endDate: endDate,
        status: _status,
        isStartingSoon: isStartingSoon,
        userId: userId,
        isPinned: false,
        createdAt: DateTime.now(),
      );

      // Lưu data
      await docRef.set(newBoard.toMap());

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Tạo dự án thành công!')));

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi khi tạo dự án: $e')));
      print('Error creating board: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildDateTimePickerTile({
    required String title,
    DateTime? dateTime,
    required Function(DateTime) onDateTimePicked,
  }) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            dateTime != null
                ? "${dateTime.day.toString().padLeft(2, '0')}/"
                    "${dateTime.month.toString().padLeft(2, '0')}/"
                    "${dateTime.year} "
                    "${dateTime.hour.toString().padLeft(2, '0')}:"
                    "${dateTime.minute.toString().padLeft(2, '0')}"
                : "Chưa chọn",
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          const SizedBox(width: 6),
          const Icon(
            Icons.calendar_today_outlined,
            color: Colors.grey,
            size: 20,
          ),
        ],
      ),
      onTap: () async {
        final picked = await _pickDateTime(dateTime);
        if (picked != null) {
          setState(() {
            onDateTimePicked(picked);
          });
        }
      },
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Tạo dự án mới',
          style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _createBoard,
            child:
                _isLoading
                    ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    )
                    : const Text(
                      'Tạo mới',
                      style: TextStyle(
                        color: CupertinoColors.activeBlue,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            // Tên dự án
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _titleController,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
                decoration: InputDecoration(
                  hintText: 'Tên dự án mới',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Dropdown chọn trạng thái (có Sắp bắt đầu)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
                items:
                    statusOptions
                        .map(
                          (status) => DropdownMenuItem(
                            value: status,
                            child: Text(
                              status,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _status = val;
                      if (_status != 'Sắp bắt đầu') {
                        startDate = null;
                      }
                    });
                  }
                },
              ),
            ),

            // Nếu chọn Sắp bắt đầu thì show picker ngày bắt đầu
            if (isStartingSoon)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: _buildDateTimePickerTile(
                  title: 'Ngày bắt đầu',
                  dateTime: startDate,
                  onDateTimePicked: (picked) {
                    startDate = picked;
                  },
                ),
              ),

            const SizedBox(height: 16),

            // Ngày kết thúc picker
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: _buildDateTimePickerTile(
                title: 'Ngày kết thúc',
                dateTime: endDate,
                onDateTimePicked: (picked) {
                  setState(() {
                    endDate = picked;
                  });
                },
              ),
            ),

            const SizedBox(height: 20),

            // Mô tả
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _descriptionController,
                maxLines: null,
                minLines: 5,
                style: const TextStyle(fontSize: 16),
                decoration: const InputDecoration(
                  hintText: 'Mô tả thêm (tùy chọn)',
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
