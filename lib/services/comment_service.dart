import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/comment.dart';
import '../services/auth_service.dart';

class CommentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'comments';
  final AuthService _authService = AuthService();

  // Tạo ID mới cho comment
  String generateNewId() {
    return _firestore.collection(_collection).doc().id;
  }

  // Lấy tất cả comment của một project
  Stream<List<Comment>> getProjectComments(String projectId) {
    return _firestore
        .collection(_collection)
        .where('projectId', isEqualTo: projectId)
        .where('isDeleted', isEqualTo: false)
        .where('parentId', isNull: true) // Chỉ lấy các comment gốc
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => Comment.fromJson({...doc.data(), 'id': doc.id}))
                  .toList(),
        );
  }

  // Lấy các comment con của một comment
  Stream<List<Comment>> getReplies(String commentId) {
    return _firestore
        .collection(_collection)
        .where('parentId', isEqualTo: commentId)
        .where('isDeleted', isEqualTo: false)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => Comment.fromJson({...doc.data(), 'id': doc.id}))
                  .toList(),
        );
  }

  // Tạo comment mới
  Future<void> createComment(Comment comment) async {
    final commentId = comment.id.isEmpty ? generateNewId() : comment.id;
    final commentWithId = comment.copyWith(id: commentId);
    await _firestore
        .collection(_collection)
        .doc(commentId)
        .set(commentWithId.toJson());
  }

  // Cập nhật comment
  Future<void> updateComment(Comment comment) async {
    await _firestore
        .collection(_collection)
        .doc(comment.id)
        .update(comment.toJson());
  }

  // Xóa comment (soft delete)
  Future<void> deleteComment(String commentId) async {
    await _firestore.collection(_collection).doc(commentId).update({
      'isDeleted': true,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  // Tạo reply cho một comment
  Future<void> createReply(String parentCommentId, Comment reply) async {
    final replyId = generateNewId();
    final replyWithId = reply.copyWith(id: replyId, parentId: parentCommentId);
    await _firestore
        .collection(_collection)
        .doc(replyId)
        .set(replyWithId.toJson());
  }
}
