import 'package:final_project_flutter_advanced_nhom_4/screens/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:final_project_flutter_advanced_nhom_4/screens/btl_login.dart';
import 'package:final_project_flutter_advanced_nhom_4/services/auth_service.dart';
import 'config/firebase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (Firebase.apps.isEmpty) {
      print('Đang khởi tạo Firebase...');
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: FirebaseConfig.apiKey,
          authDomain: FirebaseConfig.authDomain,
          projectId: FirebaseConfig.projectId,
          storageBucket: FirebaseConfig.storageBucket,
          messagingSenderId: FirebaseConfig.messagingSenderId,
          appId: FirebaseConfig.appId,
        ),
      );
      print('Firebase đã được khởi tạo thành công');
    } else {
      print('Firebase đã được khởi tạo trước đó');
    }
  } catch (e) {
    print('Lỗi khởi tạo Firebase: $e');
    rethrow;
  }

  runApp(const MyApp());
}

final AuthService _authService = AuthService();

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _checkAndSignIn();
  }

  Future<void> _checkAndSignIn() async {
    try {
      // Đảm bảo user được duy trì lâu dài
      await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
    } catch (e) {
      print('Lỗi setPersistence: $e');
    }

    if (_authService.currentUser == null) {
      try {
        print('Chưa có user, đang đăng nhập ẩn danh...');
        await _authService.signInAnonymously();
        print('Đăng nhập ẩn danh thành công!');
      } catch (e) {
        print('Lỗi đăng nhập ẩn danh: $e');
      }
    }

    setState(() {
      _initialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return MaterialApp(
      title: 'Ứng dụng quản lý công việc',
      debugShowCheckedModeBanner: false, // Ẩn banner debug
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white, // Đặt background màu trắng
      ),
      home: StreamBuilder<User?>(
        stream: _authService.authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            final user = snapshot.data;
            return user == null ? const AuthApp() : const MainScreen();
          } else {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
        },
      ),
    );
  }
}
