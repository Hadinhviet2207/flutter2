import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import '../models/user.dart' as app_user;
import 'user_service.dart';

class AuthService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UserService _userService = UserService();

  // Lấy người dùng hiện tại
  firebase_auth.User? get currentUser => _auth.currentUser;

  // Lấy ID người dùng ẩn danh
  String? get anonymousUserId =>
      currentUser?.isAnonymous ?? false ? currentUser!.uid : null;

  // Theo dõi trạng thái đăng nhập
  Stream<firebase_auth.User?> get authStateChanges => _auth.authStateChanges();

  // Đăng nhập ẩn danh
  Future<firebase_auth.UserCredential> signInAnonymously() async {
    try {
      final userCredential = await _auth.signInAnonymously();
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'id': userCredential.user!.uid,
        'email': null,
        'photoURL': null,
        'displayName': 'Người dùng ẩn danh',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isAnonymous': true,
      });
      return userCredential;
    } catch (e) {
      print('Lỗi đăng nhập ẩn danh: $e');
      rethrow;
    }
  }

  // Đăng nhập với email và mật khẩu
  Future<firebase_auth.UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _firestore.collection('users').doc(userCredential.user!.uid).update(
        {'lastLoginAt': FieldValue.serverTimestamp(), 'isAnonymous': false},
      );
      return userCredential;
    } catch (e) {
      print('Lỗi đăng nhập: $e');
      rethrow;
    }
  }

  // Đăng ký với email và mật khẩu
  Future<firebase_auth.UserCredential> registerWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'id': userCredential.user!.uid,
        'email': email,
        'photoURL': null,
        'displayName': 'User ${userCredential.user!.uid}',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isAnonymous': false,
      });
      return userCredential;
    } catch (e) {
      print('Lỗi đăng ký: $e');
      rethrow;
    }
  }

  // Liên kết tài khoản email với tài khoản ẩn danh
  Future<firebase_auth.UserCredential> linkEmailPassword(
    String email,
    String password,
  ) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null)
        throw Exception('Không có người dùng đang đăng nhập');
      final credential = firebase_auth.EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      final userCredential = await currentUser.linkWithCredential(credential);
      await _firestore.collection('users').doc(currentUser.uid).update({
        'email': email,
        'isAnonymous': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return userCredential;
    } catch (e) {
      print('Lỗi liên kết tài khoản: $e');
      rethrow;
    }
  }

  // Đăng xuất
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Lỗi đăng xuất: $e');
      rethrow;
    }
  }

  // Gửi email lấy lại mật khẩu
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Lỗi gửi email quên mật khẩu: $e');
      rethrow;
    }
  }

  // Tạo hoặc cập nhật document User trong Firestore
  Future<void> _createOrUpdateUserDoc(firebase_auth.User firebaseUser) async {
    try {
      final userDoc =
          await _firestore.collection('users').doc(firebaseUser.uid).get();
      if (!userDoc.exists) {
        final now = DateTime.now();
        final newUser = app_user.User(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? 'user@${firebaseUser.uid}.com',
          displayName: firebaseUser.displayName ?? 'User',
          photoUrl: firebaseUser.photoURL,
          role: app_user.UserRole.member,
          projectIds: [],
          createdAt: now,
          updatedAt: now,
        );
        await _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .set(newUser.toJson());
      }
    } catch (e) {
      print('Lỗi tạo/cập nhật user doc: $e');
    }
  }
}
