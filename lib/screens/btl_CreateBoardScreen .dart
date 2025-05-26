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
  DateTime? endDate;

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
          'Dự án',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Xử lý tạo mới
            },
            child: const Text(
              'Tạo mới',
              style: TextStyle(
                color: CupertinoColors.activeBlue,
                fontWeight: FontWeight.w500,
              ),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Divider(height: 1),
            // Tên dự án
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _titleController,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Dự án mới',
                ),
              ),
            ),
            const Divider(height: 1),
            // Ngày kết thúc
            Container(
              color: Colors.white,
              child: _buildDatePickerTile(),
            ),
            const SizedBox(height: 10),
            // Mô tả
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: TextField(
                controller: _descriptionController,
                maxLines: null,
                minLines: 4,
                style: const TextStyle(fontSize: 16),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Mô tả dự án (tuỳ chọn)',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePickerTile() {
    return ListTile(
      title: const Text("Ngày kết thúc"),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            endDate != null
                ? "${endDate!.day.toString().padLeft(2, '0')}/${endDate!.month.toString().padLeft(2, '0')}/${endDate!.year}"
                : "Chưa chọn",
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.calendar_today_outlined,
              color: Colors.grey, size: 18),
        ],
      ),
      onTap: () async {
        DateTime now = DateTime.now();
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: endDate ?? now,
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
        if (picked != null && picked != endDate) {
          setState(() {
            endDate = picked;
          });
        }
      },
      dense: true,
      visualDensity: const VisualDensity(vertical: -2),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }
}
