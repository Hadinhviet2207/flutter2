import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user.dart' as app_user;
import 'user_service.dart';

class AuthService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UserService _userService = UserService();

  // Lấy người dùng hiện tại
  firebase_auth.User? get currentUser => _auth.currentUser;

  // Lấy ID của người dùng ẩn danh nếu đang đăng nhập ẩn danh, ngược lại trả về null
  String? get anonymousUserId {
    final user = _auth.currentUser;
    if (user != null && user.isAnonymous) {
      return user.uid;
    }
    return null;
  }

  // Stream để theo dõi trạng thái đăng nhập
  Stream<firebase_auth.User?> get authStateChanges => _auth.authStateChanges();

  // Đăng nhập ẩn danh
  Future<firebase_auth.UserCredential> signInAnonymously() async {
    try {
      final userCredential = await _auth.signInAnonymously();

      // Tạo document user trong Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'id': userCredential.user!.uid,
        'email': null,
        'photoURL': null,
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

      // Cập nhật thông tin user trong Firestore
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

      // Tạo document user trong Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'id': userCredential.user!.uid,
        'email': email,
        'photoURL': null,
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
      if (currentUser == null) {
        throw Exception('Không có người dùng đang đăng nhập');
      }

      // Tạo credential từ email và password
      final credential = firebase_auth.EmailAuthProvider.credential(
        email: email,
        password: password,
      );

      // Liên kết credential với tài khoản hiện tại
      final userCredential = await currentUser.linkWithCredential(credential);

      // Cập nhật thông tin user trong Firestore
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

  // Đăng nhập bằng email (cho người dùng mới, không liên kết)
  Future<firebase_auth.User?> signInWithEmail(
    String email,
    String password,
  ) async {
    try {
      firebase_auth.UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password);
      firebase_auth.User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        // Tạo hoặc cập nhật User trong Firestore
        await _createOrUpdateUserDoc(firebaseUser);
      }

      return firebaseUser;
    } catch (e) {
      print('Lỗi đăng nhập email: $e');
      return null;
    }
  }

  // Đăng ký bằng email (cho người dùng mới)
  Future<firebase_auth.User?> signUpWithEmail(
    String email,
    String password,
  ) async {
    try {
      firebase_auth.UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      firebase_auth.User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        // Tạo User trong Firestore
        await _createOrUpdateUserDoc(firebaseUser);
      }

      return firebaseUser;
    } catch (e) {
      print('Lỗi đăng ký email: $e');
      return null;
    }
  }

  // Tạo hoặc cập nhật document User trong Firestore
  Future<void> _createOrUpdateUserDoc(firebase_auth.User firebaseUser) async {
    try {
      DocumentSnapshot userDoc =
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

  // Liên kết tài khoản Google
  Future<bool> linkWithGoogle() async {
    try {
      if (_auth.currentUser != null && _auth.currentUser!.isAnonymous) {
        String anonymousUid = _auth.currentUser!.uid;

        // Đăng nhập Google
        final GoogleSignIn googleSignIn = GoogleSignIn();
        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
        if (googleUser == null) return false; // Người dùng hủy đăng nhập

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final firebase_auth.AuthCredential credential = firebase_auth
            .GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // Liên kết tài khoản
        firebase_auth.UserCredential userCredential = await _auth.currentUser!
            .linkWithCredential(credential);
        firebase_auth.User? newUser = userCredential.user;

        if (newUser != null) {
          // Cập nhật document User trong Firestore
          await _updateUserAfterLink(
            newUid: newUser.uid,
            anonymousUid: anonymousUid,
            email: newUser.email ?? googleUser.email,
            displayName:
                newUser.displayName ?? googleUser.displayName ?? 'User',
            photoUrl: newUser.photoURL ?? googleUser.photoUrl,
          );
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Lỗi liên kết Google: $e');
      return false;
    }
  }

  // Hàm phụ để cập nhật User và chuyển dữ liệu sau khi liên kết
  Future<void> _updateUserAfterLink({
    required String newUid,
    required String anonymousUid,
    required String email,
    required String displayName,
    String? photoUrl,
  }) async {
    try {
      // Lấy document User cũ (ẩn danh)
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(anonymousUid).get();

      if (userDoc.exists) {
        app_user.User oldUser = app_user.User.fromJson(
          userDoc.data() as Map<String, dynamic>,
        );

        // Tạo hoặc cập nhật document User mới
        final updatedUser = oldUser.copyWith(
          id: newUid,
          email: email,
          displayName: displayName,
          photoUrl: photoUrl,
          previousAnonymousId: anonymousUid,
          updatedAt: DateTime.now(),
        );

        await _firestore
            .collection('users')
            .doc(newUid)
            .set(updatedUser.toJson());

        // Cập nhật dữ liệu liên quan (Projects, Tasks, Comments)
        await _transferUserData(anonymousUid, newUid);
      }
    } catch (e) {
      print('Lỗi cập nhật user sau liên kết: $e');
    }
  }

  // Chuyển dữ liệu từ anonymousUid sang newUid
  Future<void> _transferUserData(String anonymousUid, String newUid) async {
    try {
      // Cập nhật ownerId trong Projects
      QuerySnapshot projects =
          await _firestore
              .collection('projects')
              .where('ownerId', isEqualTo: anonymousUid)
              .get();
      for (var doc in projects.docs) {
        await doc.reference.update({'ownerId': newUid});
      }

      // Cập nhật memberIds trong Projects
      projects =
          await _firestore
              .collection('projects')
              .where('memberIds', arrayContains: anonymousUid)
              .get();
      for (var doc in projects.docs) {
        List<String> memberIds = List<String>.from(
          doc['memberIds'] as List<dynamic>,
        );
        memberIds.remove(anonymousUid);
        memberIds.add(newUid);
        await doc.reference.update({'memberIds': memberIds});
      }

      // Cập nhật createdBy và assignedTo trong Tasks
      QuerySnapshot tasks =
          await _firestore
              .collectionGroup('tasks')
              .where('createdBy', isEqualTo: anonymousUid)
              .get();
      for (var doc in tasks.docs) {
        await doc.reference.update({'createdBy': newUid});
      }

      tasks =
          await _firestore
              .collectionGroup('tasks')
              .where('assignedTo', isEqualTo: anonymousUid)
              .get();
      for (var doc in tasks.docs) {
        await doc.reference.update({'assignedTo': newUid});
      }

      // Cập nhật collaboratorIds trong Tasks
      tasks =
          await _firestore
              .collectionGroup('tasks')
              .where('collaboratorIds', arrayContains: anonymousUid)
              .get();
      for (var doc in tasks.docs) {
        List<String> collaboratorIds = List<String>.from(
          doc['collaboratorIds'] as List<dynamic>,
        );
        collaboratorIds.remove(anonymousUid);
        collaboratorIds.add(newUid);
        await doc.reference.update({'collaboratorIds': collaboratorIds});
      }

      // Cập nhật userId trong Comments
      QuerySnapshot comments =
          await _firestore
              .collectionGroup('comments')
              .where('userId', isEqualTo: anonymousUid)
              .get();
      for (var doc in comments.docs) {
        await doc.reference.update({'userId': newUid});
      }

      // Cập nhật userId trong History
      QuerySnapshot history =
          await _firestore
              .collectionGroup('history')
              .where('userId', isEqualTo: anonymousUid)
              .get();
      for (var doc in history.docs) {
        await doc.reference.update({'userId': newUid});
      }

      // Cập nhật invitedBy trong Invites
      QuerySnapshot invites =
          await _firestore
              .collection('invites')
              .where('invitedBy', isEqualTo: anonymousUid)
              .get();
      for (var doc in invites.docs) {
        await doc.reference.update({'invitedBy': newUid});
      }
    } catch (e) {
      print('Lỗi chuyển dữ liệu user: $e');
    }
  }
}
