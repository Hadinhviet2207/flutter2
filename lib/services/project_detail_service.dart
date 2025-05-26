import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/project_detail.dart';
import '../services/auth_service.dart';

class ProjectDetailService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'project_details';
  final AuthService _authService = AuthService();

  // Tạo ID mới cho project detail
  String generateNewId() {
    return _firestore.collection(_collection).doc().id;
  }

  // Lấy chi tiết của một project
  Stream<ProjectDetail?> getProjectDetail(String projectId) {
    return _firestore
        .collection(_collection)
        .where('projectId', isEqualTo: projectId)
        .where('isDeleted', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) return null;
          return ProjectDetail.fromJson({
            ...snapshot.docs.first.data(),
            'id': snapshot.docs.first.id,
          });
        });
  }

  // Tạo mới project detail
  Future<void> createProjectDetail(ProjectDetail detail) async {
    await _firestore
        .collection(_collection)
        .doc(detail.id)
        .set(detail.toJson());
  }

  // Cập nhật project detail
  Future<void> updateProjectDetail(String id, ProjectDetail detail) async {
    await _firestore.collection(_collection).doc(id).update(detail.toJson());
  }

  // Xóa project detail (soft delete)
  Future<void> deleteProjectDetail(String id) async {
    await _firestore.collection(_collection).doc(id).update({
      'isDeleted': true,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  // Thêm file đính kèm
  Future<void> addAttachment(String id, String attachmentUrl) async {
    await _firestore.collection(_collection).doc(id).update({
      'attachmentUrls': FieldValue.arrayUnion([attachmentUrl]),
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  // Xóa file đính kèm
  Future<void> removeAttachment(String id, String attachmentUrl) async {
    await _firestore.collection(_collection).doc(id).update({
      'attachmentUrls': FieldValue.arrayRemove([attachmentUrl]),
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }
}
