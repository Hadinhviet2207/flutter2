import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/comment.dart';

class CommentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'comments';

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
        .where('parentId', isNull: true)
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Comment.fromJson(doc.data()))
              .toList();
        });
  }

  // Lấy các comment con của một comment
  Stream<List<Comment>> getReplies(String parentId, String projectId) {
    return _firestore
        .collection(_collection)
        .where('parentId', isEqualTo: parentId)
        .where('projectId', isEqualTo: projectId)
        .where('isDeleted', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Comment.fromJson(doc.data()))
              .toList();
        });
  }

  // Tạo comment mới
  Future<void> createComment(Comment comment) async {
    await _firestore
        .collection(_collection)
        .doc(comment.id)
        .set(comment.toJson());
  }

  // Cập nhật comment
  Future<void> updateComment(String id, Comment comment) async {
    await _firestore.collection(_collection).doc(id).update(comment.toJson());
  }

  // Xóa comment (soft delete)
  Future<void> deleteComment(String id) async {
    await _firestore.collection(_collection).doc(id).update({
      'isDeleted': true,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  // Tạo reply cho một comment
  Future<void> createReply(String parentCommentId, Comment reply) async {
    final replyId = generateNewId();
    final replyWithId = reply.copyWith(
      id: replyId,
      parentId: parentCommentId,
      projectId: reply.projectId,
    );
    await _firestore
        .collection(_collection)
        .doc(replyId)
        .set(replyWithId.toJson());
  }
}
