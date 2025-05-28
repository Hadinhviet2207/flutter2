// lib/services/join_team_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class JoinTeamService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Lấy teamId từ mã mời
  Future<String?> getTeamIdByInviteCode(String inviteCode) async {
    final snapshot =
        await _firestore
            .collection('teams')
            .where('inviteCode', isEqualTo: inviteCode)
            .limit(1)
            .get();

    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first.id;
    } else {
      return null;
    }
  }

  /// Thêm user vào team và lưu teamId vào user
  Future<void> joinTeamWithInviteCode({
    required String inviteCode,
    required String userId,
  }) async {
    final teamId = await getTeamIdByInviteCode(inviteCode);

    if (teamId == null) {
      throw Exception("Mã mời không hợp lệ!");
    }

    final teamRef = _firestore.collection('teams').doc(teamId);
    final userRef = _firestore.collection('users').doc(userId);

    await _firestore.runTransaction((transaction) async {
      // Cập nhật team
      transaction.update(teamRef, {
        'members': FieldValue.arrayUnion([userId]),
      });

      // Cập nhật user
      transaction.set(userRef, {
        'joinedTeams': FieldValue.arrayUnion([teamId]),
      }, SetOptions(merge: true));
    });
  }

  /// Lấy danh sách team mà user đã tham gia
  Future<List<DocumentSnapshot>> getUserJoinedTeams(String userId) async {
    final userDoc = await _firestore.collection('users').doc(userId).get();
    final List<dynamic> joinedTeams = userDoc.data()?['joinedTeams'] ?? [];

    if (joinedTeams.isEmpty) return [];

    final teamsSnapshot =
        await _firestore
            .collection('teams')
            .where(FieldPath.documentId, whereIn: joinedTeams)
            .get();

    return teamsSnapshot.docs;
  }
}
