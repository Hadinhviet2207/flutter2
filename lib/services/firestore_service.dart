import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/project.dart';
import '../models/user.dart';
import '../models/comment.dart';
import '../models/project_invite.dart';
import '../utils/enum_utils.dart' as enum_utils;
import 'user_service.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final UserService _userService = UserService();

  Future<String> getCurrentUserId() async {
    final firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;
    return firebaseUser?.uid ?? await _userService.getOrCreateAnonymousUserId();
  }

  Future<void> addProject(Project project) async {
    final userId = await getCurrentUserId();
    await _db
        .collection('projects')
        .doc(project.id)
        .set(
          project
              .copyWith(
                ownerId: userId,
                memberIds: [...project.memberIds, userId],
              )
              .toJson(),
        );
  }

  Stream<List<Project>> getProjects() async* {
    final userId = await getCurrentUserId();
    yield* _db
        .collection('projects')
        .where('isDeleted', isEqualTo: false)
        .where('memberIds', arrayContains: userId)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Project.fromJson(doc.data())).toList(),
        );
  }

  Future<void> createProjectInvite(ProjectInvite invite) async {
    final firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) {
      throw Exception('Must be logged in to invite users');
    }
    await _db.collection('invites').doc(invite.id).set(invite.toJson());
  }

  Future<void> acceptProjectInvite(String inviteId, String userId) async {
    final inviteDoc = await _db.collection('invites').doc(inviteId).get();
    final invite = ProjectInvite.fromJson(inviteDoc.data()!);
    if (invite.status != enum_utils.InviteStatus.pending) {
      throw Exception('Invite is not pending');
    }
    await _db.collection('invites').doc(inviteId).update({
      'status': enum_utils.EnumUtils.enumToString(
        enum_utils.InviteStatus.accepted,
      ),
      'updatedAt': DateTime.now().toIso8601String(),
    });
    await _db.collection('projects').doc(invite.projectId).update({
      'memberIds': FieldValue.arrayUnion([userId]),
    });
    await _db.collection('users').doc(userId).update({
      'projectIds': FieldValue.arrayUnion([invite.projectId]),
    });
  }

  Future<void> rejectProjectInvite(String inviteId) async {
    await _db.collection('invites').doc(inviteId).update({
      'status': enum_utils.EnumUtils.enumToString(
        enum_utils.InviteStatus.rejected,
      ),
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  Stream<List<ProjectInvite>> getPendingInvites(String email) {
    return _db
        .collection('invites')
        .where('email', isEqualTo: email)
        .where(
          'status',
          isEqualTo: enum_utils.EnumUtils.enumToString(
            enum_utils.InviteStatus.pending,
          ),
        )
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => ProjectInvite.fromJson(doc.data()))
                  .toList(),
        );
  }

  Future<String> uploadAttachment(File file, String projectId) async {
    try {
      final ref = _storage.ref().child(
        'projects/$projectId/attachments/${DateTime.now().millisecondsSinceEpoch}',
      );
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Upload failed: $e');
    }
  }

  Future<void> addComment(Comment comment) async {
    final firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) {
      throw Exception('Must be logged in to comment');
    }
    await _db.collection('comments').doc(comment.id).set(comment.toJson());
  }

  Future<bool> canEditProject(String projectId, String? userId) async {
    if (userId == null) {
      final anonymousUserId = await _userService.getOrCreateAnonymousUserId();
      final projectDoc = await _db.collection('projects').doc(projectId).get();
      final project = Project.fromJson(projectDoc.data()!);
      return project.memberIds.contains(anonymousUserId);
    }

    final isAdmin =
        (await _db.collection('users').doc(userId).get()).data()?['role'] ==
        enum_utils.EnumUtils.enumToString(enum_utils.UserRole.admin);
    final projectDoc = await _db.collection('projects').doc(projectId).get();
    final project = Project.fromJson(projectDoc.data()!);
    final isOwner = project.ownerId == userId;
    final isMember = project.memberIds.contains(userId);

    return isAdmin || isOwner || isMember;
  }
}
