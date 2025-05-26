import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:final_project_flutter_advanced_nhom_4/main.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:final_project_flutter_advanced_nhom_4/services/auth_service.dart';

void main() {
  setUpAll(() async {
    // Khởi tạo Firebase cho testing
    TestWidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
  });

  testWidgets('Complete app flow test', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Verify we're on the login screen
    expect(find.text('Đăng nhập'), findsOneWidget);

    // TODO: Thêm các bước test cho luồng đăng nhập -> tạo project -> thêm task
    // Lưu ý: Cần mock Firebase Auth và Firestore cho integration test
  });
}
