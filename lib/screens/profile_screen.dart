import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:final_project_flutter_advanced_nhom_4/screens/login_screen.dart';
import 'package:final_project_flutter_advanced_nhom_4/screens/edit_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CloudinaryPublic cloudinary = CloudinaryPublic(
    'dua5bpeht',
    'planera',
    cache: false,
  );
  String? displayNameFromFirestore;
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
    getUserData();
  }

  Future<void> getUserData() async {
    final uid = user?.uid;
    if (uid != null) {
      final docSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        setState(() {
          displayNameFromFirestore = data?['displayName'] ?? 'Người dùng';
        });
      }
    }
  }

  Future<void> _uploadImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) {
        print('Không chọn ảnh, thoát hàm');
        return;
      }

      setState(() => isLoading = true);

      String secureUrl;
      if (kIsWeb) {
        // Web: Lấy bytes và tải lên Cloudinary
        final bytes = await pickedFile.readAsBytes();
        final response = await cloudinary.uploadFile(
          CloudinaryFile.fromBytesData(
            bytes,
            identifier: 'avatar_${user!.uid}.jpg',
            resourceType: CloudinaryResourceType.Image,
          ),
        );
        secureUrl = response.secureUrl;
      } else {
        // Mobile: Tải file lên Cloudinary
        final response = await cloudinary.uploadFile(
          CloudinaryFile.fromFile(
            pickedFile.path,
            resourceType: CloudinaryResourceType.Image,
          ),
        );
        secureUrl = response.secureUrl;
      }

      // Cập nhật photoURL trong Firebase Auth và Firestore
      await user!.updatePhotoURL(secureUrl);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .update({
            'photoURL': secureUrl,
            'updatedAt': FieldValue.serverTimestamp(),
          });

      await user!.reload();
      user = _auth.currentUser;

      setState(() {
        photoURL = secureUrl;
        isLoading = false;
      });

      print('Cập nhật ảnh đại diện thành công! URL: $secureUrl');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật ảnh đại diện thành công!')),
      );
    } catch (e) {
      print('Lỗi khi upload ảnh: $e');
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi khi upload ảnh: $e')));
    }
  }

  Future<void> _changePassword() async {
    final TextEditingController currentPasswordController =
        TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController =
        TextEditingController();
    bool isObscureCurrent = true;
    bool isObscureNew = true;
    bool isObscureConfirm = true;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            Widget _buildPasswordField({
              required TextEditingController controller,
              required String label,
              required bool isObscure,
              required VoidCallback onToggle,
            }) {
              return TextField(
                controller: controller,
                obscureText: isObscure,
                style: const TextStyle(fontSize: 18),
                decoration: InputDecoration(
                  labelText: label,
                  labelStyle: const TextStyle(
                    color: Colors.black54,
                    fontSize: 16,
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 18,
                    horizontal: 20,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      isObscure ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey[600],
                    ),
                    onPressed: onToggle,
                  ),
                ),
              );
            }

            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 24,
              ),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 480),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 28,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Đổi mật khẩu',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 28),
                      _buildPasswordField(
                        controller: currentPasswordController,
                        label: 'Mật khẩu hiện tại',
                        isObscure: isObscureCurrent,
                        onToggle:
                            () => setState(
                              () => isObscureCurrent = !isObscureCurrent,
                            ),
                      ),
                      const SizedBox(height: 22),
                      _buildPasswordField(
                        controller: newPasswordController,
                        label: 'Mật khẩu mới',
                        isObscure: isObscureNew,
                        onToggle:
                            () => setState(() => isObscureNew = !isObscureNew),
                      ),
                      const SizedBox(height: 22),
                      _buildPasswordField(
                        controller: confirmPasswordController,
                        label: 'Xác nhận mật khẩu mới',
                        isObscure: isObscureConfirm,
                        onToggle:
                            () => setState(
                              () => isObscureConfirm = !isObscureConfirm,
                            ),
                      ),
                      const SizedBox(height: 36),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.grey[600],
                              textStyle: const TextStyle(fontSize: 18),
                            ),
                            child: const Text('Hủy'),
                          ),
                          const SizedBox(width: 20),
                          SizedBox(
                            height: 40,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1565C0),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 36,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                elevation: 6,
                                shadowColor: Colors.blueAccent.withOpacity(0.5),
                                textStyle: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              onPressed: () async {
                                final currentPass =
                                    currentPasswordController.text.trim();
                                final newPass =
                                    newPasswordController.text.trim();
                                final confirmPass =
                                    confirmPasswordController.text.trim();

                                if (currentPass.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Vui lòng nhập mật khẩu hiện tại',
                                      ),
                                    ),
                                  );
                                  return;
                                }
                                if (newPass.length < 6) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Mật khẩu mới phải ít nhất 6 ký tự',
                                      ),
                                    ),
                                  );
                                  return;
                                }
                                if (newPass != confirmPass) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Xác nhận mật khẩu không khớp',
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                try {
                                  final cred = EmailAuthProvider.credential(
                                    email: user!.email!,
                                    password: currentPass,
                                  );
                                  await user!.reauthenticateWithCredential(
                                    cred,
                                  );
                                  await user!.updatePassword(newPass);
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Đổi mật khẩu thành công!'),
                                    ),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Lỗi: $e')),
                                  );
                                }
                              },
                              child: const Text(
                                'Lưu',
                                style: TextStyle(
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      offset: Offset(0, 1),
                                      blurRadius: 3,
                                      color: Colors.black26,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayName = displayNameFromFirestore ?? 'Người dùng';

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
                  user != null && user!.isAnonymous
                      ? ListTile(
                        leading: const Icon(
                          Icons.link,
                          color: Colors.blueAccent,
                        ),
                        title: const Text('Liên kết tài khoản'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => AuthApp()),
                          );
                        },
                      )
                      : ListTile(
                        leading: const Icon(Icons.edit, color: Colors.green),
                        title: const Text('Chỉnh sửa thông tin cá nhân'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditProfileScreen(),
                            ),
                          );
                        },
                      ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            if (user?.isAnonymous == false)
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
                                    onPressed:
                                        () => Navigator.pop(context, true),
                                    child: const Text('Đăng xuất'),
                                  ),
                                ],
                              ),
                        );

                        if (confirm == true) {
                          try {
                            await _auth.signOut();
                            if (context.mounted) {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => AuthApp(),
                                ),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Đăng xuất thất bại: $e')),
                            );
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
