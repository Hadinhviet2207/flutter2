import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        '🔔 Đây là màn hình Thông báo',
        style: TextStyle(fontSize: 20),
      ),
    );
  }
}
