import 'package:final_project_flutter_advanced_nhom_4/screens/btl_login.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user;

  String? photoURL;
  String? email;
  bool isLoading = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser;
    photoURL = user?.photoURL;
    email = user?.email;
  }

  Future<void> _uploadImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    setState(() => isLoading = true);

    final newPhotoURL = pickedFile.path; // Chưa upload lên Firebase Storage
    try {
      await user?.updatePhotoURL(newPhotoURL);
      await user?.reload();
      user = _auth.currentUser;
      setState(() {
        photoURL = user?.photoURL;
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật ảnh đại diện thành công!')),
      );
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi cập nhật ảnh: $e')));
    }
  }

  Future<void> _changePassword() async {
    final TextEditingController _passwordController = TextEditingController();

    if (user == null || user!.email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bạn không thể đổi mật khẩu với tài khoản ẩn danh.'),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Đổi mật khẩu'),
            content: TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Mật khẩu mới',
                hintText: 'Nhập mật khẩu mới (ít nhất 6 ký tự)',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final newPassword = _passwordController.text.trim();
                  if (newPassword.length < 6) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Mật khẩu phải ít nhất 6 ký tự'),
                      ),
                    );
                    return;
                  }

                  try {
                    await user!.updatePassword(newPassword);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đổi mật khẩu thành công!')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Lỗi đổi mật khẩu: $e')),
                    );
                  }
                },
                child: const Text('Xác nhận'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayName = user?.displayName ?? 'Người dùng';

    final avatar = GestureDetector(
      onTap: _uploadImage,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage:
                photoURL != null && photoURL!.startsWith('http')
                    ? NetworkImage(photoURL!)
                    : null,
            backgroundColor: Colors.grey[300],
            child:
                (photoURL == null || !photoURL!.startsWith('http'))
                    ? Text(
                      displayName[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    )
                    : null,
          ),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 2),
              ],
            ),
            child: const Icon(
              Icons.camera_alt,
              size: 20,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Trang cá nhân',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Center(child: avatar),
            const SizedBox(height: 16),
            Center(
              child: Text(
                displayName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                email ?? 'Chưa có email',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 3,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.lock_reset, color: Colors.red),
                    title: const Text('Đổi mật khẩu'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: _changePassword,
                  ),
                  const Divider(height: 0),
                  ListTile(
                    leading: const Icon(Icons.link, color: Colors.blue),
                    title: const Text('Liên kết tài khoản'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AuthApp()),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Nút Đăng xuất ở cuối màn hình
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.logout),
                    label: const Text('Đăng xuất'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.red,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: const Text('Xác nhận đăng xuất'),
                              content: const Text(
                                'Bạn có chắc chắn muốn đăng xuất không?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed:
                                      () => Navigator.pop(context, false),
                                  child: const Text('Hủy'),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Đăng xuất'),
                                ),
                              ],
                            ),
                      );

                      if (confirm == true) {
                        await _auth.signOut();
                        if (context.mounted) {
                          Navigator.of(context).pushReplacementNamed('/login');
                        }
                      }
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
            if (isLoading) const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}
