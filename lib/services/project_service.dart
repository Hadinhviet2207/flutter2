import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/project.dart';
import '../services/auth_service.dart';

class ProjectService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'projects';
  final AuthService _authService = AuthService();

  // Tạo ID mới cho project
  String generateNewId() {
    return _firestore.collection(_collection).doc().id;
  }

  // Lấy tất cả project gốc của người dùng
  Stream<List<Project>> getRootProjects() {
    final currentUser = _authService.currentUser;
    if (currentUser == null) return Stream.value([]);

    return _firestore
        .collection(_collection)
        .where('memberIds', arrayContains: currentUser.uid)
        .where('parentId', isNull: true)
        .where('isArchived', isEqualTo: false)
        .where('isDeleted', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Project.fromJson(doc.data())).toList(),
        );
  }

  // Lấy tất cả project con của một project
  Stream<List<Project>> getChildProjects(String parentId) {
    final currentUser = _authService.currentUser;
    if (currentUser == null) return Stream.value([]);

    return _firestore
        .collection(_collection)
        .where('parentId', isEqualTo: parentId)
        .where('memberIds', arrayContains: currentUser.uid)
        .where('isArchived', isEqualTo: false)
        .where('isDeleted', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Project.fromJson(doc.data())).toList(),
        );
  }

  // Lấy tất cả project mà người dùng là thành viên
  Stream<List<Project>> getAllProjects() {
    final currentUser = _authService.currentUser;
    if (currentUser == null) return Stream.value([]);

    return _firestore
        .collection(_collection)
        .where('isDeleted', isEqualTo: false)
        .where('memberIds', arrayContains: currentUser.uid)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => Project.fromJson({...doc.data(), 'id': doc.id}))
                  .toList(),
        );
  }

  Future<void> createProject(Project project) async {
    await _firestore
        .collection(_collection)
        .doc(project.id)
        .set(project.toJson());
  }

  Future<void> updateProject(String id, Project project) async {
    await _firestore.collection(_collection).doc(id).update(project.toJson());
  }

  Future<void> deleteProject(String id) async {
    await _firestore.collection(_collection).doc(id).update({
      'isDeleted': true,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> archiveProject(String id) async {
    await _firestore.collection(_collection).doc(id).update({
      'isArchived': true,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  // Member Management
  Stream<List<String>> getProjectMembers(String projectId) {
    return _firestore.collection(_collection).doc(projectId).snapshots().map((
      doc,
    ) {
      final data = doc.data();
      if (data == null) return [];
      return List<String>.from(data['memberIds'] as List);
    });
  }

  // Thêm thành viên vào project
  Future<void> addMember(String projectId, String memberId) async {
    await _firestore.collection(_collection).doc(projectId).update({
      'memberIds': FieldValue.arrayUnion([memberId]),
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  // Xóa thành viên khỏi project
  Future<void> removeMember(String projectId, String memberId) async {
    await _firestore.collection(_collection).doc(projectId).update({
      'memberIds': FieldValue.arrayRemove([memberId]),
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> updateProjectStatus(
    String projectId,
    ProjectStatus status,
  ) async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) throw Exception('User not authenticated');

    final projectRef = _firestore.collection(_collection).doc(projectId);
    final projectDoc = await projectRef.get();

    if (!projectDoc.exists) {
      throw Exception('Project not found');
    }

    final project = Project.fromJson(projectDoc.data()!);
    if (!project.memberIds.contains(currentUser.uid)) {
      throw Exception('User is not a member of this project');
    }

    await projectRef.update({
      'status': status.toString().split('.').last,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> togglePin(String projectId, {bool isGlobal = false}) async {
    final currentUser = AuthService().currentUser;
    if (currentUser == null) throw Exception('User not authenticated');

    final projectRef = _firestore.collection('projects').doc(projectId);
    final projectDoc = await projectRef.get();

    if (!projectDoc.exists) {
      throw Exception('Project not found');
    }

    final project = Project.fromJson(projectDoc.data()!);

    // Kiểm tra quyền ghim
    if (isGlobal && project.ownerId != currentUser.uid) {
      throw Exception('Only project owner can set global pin');
    }

    final now = DateTime.now();
    final updates = <String, dynamic>{'updatedAt': now.toIso8601String()};

    if (isGlobal) {
      updates['isGlobalPinned'] = !project.isGlobalPinned;
      updates['pinnedAt'] = now.toIso8601String();
    } else {
      updates['isPinned'] = !project.isPinned;
      updates['pinnedAt'] = now.toIso8601String();
    }

    await projectRef.update(updates);
  }

  Future<void> updateDueDate(String projectId, DateTime dueDate) async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) throw Exception('User not authenticated');

    final projectRef = _firestore.collection(_collection).doc(projectId);
    final projectDoc = await projectRef.get();

    if (!projectDoc.exists) {
      throw Exception('Project not found');
    }

    final project = Project.fromJson(projectDoc.data()!);
    if (project.ownerId != currentUser.uid) {
      throw Exception('Only project owner can update due date');
    }

    await projectRef.update({
      'dueDate': dueDate.toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  Future<Project?> getProject(String projectId) async {
    final doc = await _firestore.collection(_collection).doc(projectId).get();
    if (!doc.exists) return null;
    return Project.fromJson(doc.data()!);
  }
}
