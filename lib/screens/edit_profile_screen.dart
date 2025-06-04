import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController =
      TextEditingController(); // Thêm controller cho email
  final cloudinary = CloudinaryPublic('dua5bpeht', 'planera', cache: false);

  User? user;
  File? _selectedImageFile; // Dùng cho mobile
  Uint8List? _selectedImageBytes; // Dùng cho web
  bool isLoading = false;
  String? _photoURL;

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser;
    _loadUserData();
  }

  // Tải thông tin người dùng từ Firestore
  Future<void> _loadUserData() async {
    if (user != null) {
      try {
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user!.uid).get();
        if (userDoc.exists) {
          Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
          setState(() {
            _nameController.text =
                data['displayName'] ?? user?.displayName ?? '';
            _phoneController.text =
                data['phoneNumber'] ?? user?.phoneNumber ?? '';
            _emailController.text =
                data['email'] ??
                user?.email ??
                'Không có email'; // Gán email vào controller
            _photoURL = data['photoURL'] ?? user?.photoURL;
          });
        }
      } catch (e) {
        print('Lỗi tải thông tin người dùng: $e');
        setState(() {
          _emailController.text = 'Không có email'; // Fallback nếu lỗi
        });
      }
    }
  }

  // Chọn ảnh từ thư viện
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        if (kIsWeb) {
          // Web: Lấy bytes của ảnh
          picked.readAsBytes().then((bytes) => _selectedImageBytes = bytes);
          _selectedImageFile = null;
        } else {
          // Mobile: Lấy File
          _selectedImageFile = File(picked.path);
          _selectedImageBytes = null;
        }
      });
    }
  }

  // Tải ảnh lên Cloudinary
  Future<String?> _uploadImage() async {
    if (user == null) return null;
    try {
      String secureUrl;
      if (kIsWeb && _selectedImageBytes != null) {
        // Web: Tải bytes lên Cloudinary
        final response = await cloudinary.uploadFile(
          CloudinaryFile.fromBytesData(
            _selectedImageBytes!,
            identifier: 'profile_${user!.uid}.jpg',
            resourceType: CloudinaryResourceType.Image,
          ),
        );
        secureUrl = response.secureUrl;
      } else if (!kIsWeb && _selectedImageFile != null) {
        // Mobile: Tải file lên Cloudinary
        final response = await cloudinary.uploadFile(
          CloudinaryFile.fromFile(
            _selectedImageFile!.path,
            resourceType: CloudinaryResourceType.Image,
          ),
        );
        secureUrl = response.secureUrl;
      } else {
        return null;
      }
      return secureUrl;
    } catch (e) {
      print('Lỗi tải ảnh lên Cloudinary: $e');
      return null;
    }
  }

  // Lưu thay đổi
  Future<void> _saveChanges() async {
    setState(() => isLoading = true);
    try {
      final name = _nameController.text.trim();
      final phone = _phoneController.text.trim();
      final email = _emailController.text.trim();

      // Cập nhật tên hiển thị trên Firebase Auth
      await user?.updateDisplayName(name);

      // Tải ảnh lên và lấy URL
      String? newPhotoURL = await _uploadImage();
      if (newPhotoURL != null) {
        await user?.updatePhotoURL(newPhotoURL);
      }

      // Cập nhật thông tin trong Firestore
      await _firestore.collection('users').doc(user!.uid).update({
        'displayName': name,
        'phoneNumber': phone,
        'photoURL': newPhotoURL ?? _photoURL,
        'email': email, // Cập nhật email từ controller
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await user?.reload();
      user = _auth.currentUser;

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Cập nhật thành công!")));
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  Widget _buildAvatar() {
    ImageProvider? imageProvider;
    if (kIsWeb && _selectedImageBytes != null) {
      // Web: Sử dụng MemoryImage cho bytes
      imageProvider = MemoryImage(_selectedImageBytes!);
    } else if (!kIsWeb && _selectedImageFile != null) {
      // Mobile: Sử dụng FileImage
      imageProvider = FileImage(_selectedImageFile!);
    } else if (_photoURL != null && _photoURL!.startsWith("http")) {
      // Ảnh từ URL (Firestore hoặc Firebase Auth)
      imageProvider = NetworkImage(_photoURL!);
    }

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        CircleAvatar(
          radius: 60,
          backgroundImage: imageProvider,
          backgroundColor: Colors.grey.shade300,
          child:
              imageProvider == null
                  ? const Icon(Icons.person, size: 60, color: Colors.white)
                  : null,
        ),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4),
              ],
            ),
            child: const Icon(Icons.edit, size: 20),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Chỉnh sửa hồ sơ'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child:
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Center(child: _buildAvatar()),
                      const SizedBox(height: 24),
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: "Họ và tên",
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                        style: GoogleFonts.inter(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _phoneController,
                        decoration: InputDecoration(
                          labelText: "Số điện thoại",
                          prefixIcon: const Icon(Icons.phone),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                        style: GoogleFonts.inter(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _emailController, // Sử dụng controller
                        enabled: false,
                        decoration: InputDecoration(
                          labelText: "Email",
                          prefixIcon: const Icon(Icons.mail_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                        style: GoogleFonts.inter(fontSize: 16),
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _saveChanges,
                          icon: const Icon(Icons.check_circle_outline),
                          label: const Text("Lưu thay đổi"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            textStyle: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }
}
