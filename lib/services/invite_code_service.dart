import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/invite_code.dart';

class InviteCodeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _generateRandomCode(int length) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(
      length,
      (index) => chars[random.nextInt(chars.length)],
    ).join();
  }

  Future<InviteCode> createInviteCode(String projectId, String ownerUid) async {
    final code = _generateRandomCode(8);
    final now = DateTime.now();
    final expiresAt = now.add(const Duration(hours: 12));

    final inviteCode = InviteCode(
      code: code,
      projectId: projectId,
      createdBy: ownerUid,
      createdAt: now,
      expiresAt: expiresAt,
    );

    await _firestore
        .collection('invite_codes')
        .doc(code)
        .set(inviteCode.toMap());

    return inviteCode;
  }

  Future<InviteCode?> getInviteCode(String code) async {
    final doc = await _firestore.collection('invite_codes').doc(code).get();
    if (!doc.exists) return null;
    return InviteCode.fromFirestore(doc);
  }

  Future<void> deleteInviteCode(String code) async {
    await _firestore.collection('invite_codes').doc(code).delete();
  }

  Stream<List<InviteCode>> getProjectInviteCodes(String projectId) {
    return _firestore
        .collection('invite_codes')
        .where('projectId', isEqualTo: projectId)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => InviteCode.fromFirestore(doc))
                  .toList(),
        );
  }
}
