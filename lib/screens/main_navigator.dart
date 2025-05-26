import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';
import 'project_list_screen.dart';

class MainNavigator extends StatelessWidget {
  const MainNavigator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Nếu chưa đăng nhập hoặc đang đăng nhập ẩn danh, chuyển đến HomeScreen
        if (!snapshot.hasData || snapshot.data?.isAnonymous == true) {
          return const HomeScreen();
        }

        // Nếu đã đăng nhập với tài khoản thật, chuyển đến ProjectListScreen
        return const ProjectListScreen();
      },
    );
  }
}
