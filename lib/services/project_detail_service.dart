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
    print('Getting project detail for projectId: $projectId');
    print('Current user: ${_authService.currentUser?.uid}');

    return _firestore
        .collection(_collection)
        .where('projectId', isEqualTo: projectId)
        .limit(1)
        .snapshots()
        .map((snapshot) async {
          print('Firestore snapshot exists: ${snapshot.docs.isNotEmpty}');

          if (snapshot.docs.isEmpty) {
            print('Project detail not found, creating new one');
            final now = DateTime.now();
            final currentUser = _authService.currentUser;
            if (currentUser != null) {
              print(
                'Creating new project detail with user: ${currentUser.uid}',
              );
              final newDetail = ProjectDetail(
                id: generateNewId(),
                projectId: projectId,
                content: '',
                creatorId: currentUser.uid,
                teamLeaderId: currentUser.uid,
                createdAt: now,
                updatedAt: now,
              );
              print('New project detail data: ${newDetail.toJson()}');
              try {
                await createProjectDetail(newDetail);
                print('Successfully created new project detail');
                return newDetail;
              } catch (e) {
                print('Error creating project detail: $e');
                return null;
              }
            }
            print('No current user found');
            return null;
          }

          try {
            final projectDetail = ProjectDetail.fromJson(
              snapshot.docs.first.data(),
            );
            print(
              'Successfully parsed project detail: ${projectDetail.toJson()}',
            );
            return projectDetail;
          } catch (e) {
            print('Error parsing project detail: $e');
            return null;
          }
        })
        .asyncMap((future) => future);
  }

  // Tạo mới project detail
  Future<void> createProjectDetail(ProjectDetail projectDetail) async {
    print('Creating project detail with data: ${projectDetail.toJson()}');
    try {
      await _firestore
          .collection(_collection)
          .doc(projectDetail.id)
          .set(projectDetail.toJson());
      print('Successfully created project detail');
    } catch (e) {
      print('Error creating project detail: $e');
      rethrow;
    }
  }

  // Cập nhật project detail
  Future<void> updateProjectDetail(
    String id,
    ProjectDetail projectDetail,
  ) async {
    print('Updating project detail $id with data: ${projectDetail.toJson()}');
    try {
      await _firestore
          .collection(_collection)
          .doc(id)
          .update(projectDetail.toJson());
      print('Successfully updated project detail');
    } catch (e) {
      print('Error updating project detail: $e');
      rethrow;
    }
  }

  // Xóa project detail (soft delete)
  Future<void> deleteProjectDetail(String id) async {
    print('Deleting project detail $id');
    try {
      await _firestore.collection(_collection).doc(id).update({
        'isDeleted': true,
        'updatedAt': DateTime.now().toIso8601String(),
      });
      print('Successfully deleted project detail');
    } catch (e) {
      print('Error deleting project detail: $e');
      rethrow;
    }
  }

  // Thêm file đính kèm
  Future<void> addAttachment(
    String projectDetailId,
    ProjectAttachment attachment,
  ) async {
    print(
      'Adding attachment to project detail $projectDetailId: ${attachment.toJson()}',
    );
    final docRef = _firestore.collection(_collection).doc(projectDetailId);
    try {
      await _firestore.runTransaction((transaction) async {
        final doc = await transaction.get(docRef);
        if (doc.exists) {
          final projectDetail = ProjectDetail.fromJson(doc.data()!);
          final updatedAttachments = List<ProjectAttachment>.from(
            projectDetail.attachments,
          )..add(attachment);
          final updatedProjectDetail = projectDetail.copyWith(
            attachments: updatedAttachments,
            updatedAt: DateTime.now(),
          );
          transaction.update(docRef, updatedProjectDetail.toJson());
        }
      });
      print('Successfully added attachment');
    } catch (e) {
      print('Error adding attachment: $e');
      rethrow;
    }
  }

  // Xóa file đính kèm
  Future<void> removeAttachment(
    String projectDetailId,
    String attachmentId,
  ) async {
    print(
      'Removing attachment $attachmentId from project detail $projectDetailId',
    );
    final docRef = _firestore.collection(_collection).doc(projectDetailId);
    try {
      await _firestore.runTransaction((transaction) async {
        final doc = await transaction.get(docRef);
        if (doc.exists) {
          final projectDetail = ProjectDetail.fromJson(doc.data()!);
          final updatedAttachments =
              projectDetail.attachments
                  .where((attachment) => attachment.id != attachmentId)
                  .toList();
          final updatedProjectDetail = projectDetail.copyWith(
            attachments: updatedAttachments,
            updatedAt: DateTime.now(),
          );
          transaction.update(docRef, updatedProjectDetail.toJson());
        }
      });
      print('Successfully removed attachment');
    } catch (e) {
      print('Error removing attachment: $e');
      rethrow;
    }
  }
}
