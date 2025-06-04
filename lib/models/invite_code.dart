import 'package:cloud_firestore/cloud_firestore.dart';

class InviteCode {
  final String code;
  final String projectId;
  final String createdBy;
  final DateTime createdAt;
  final DateTime expiresAt;

  InviteCode({
    required this.code,
    required this.projectId,
    required this.createdBy,
    required this.createdAt,
    required this.expiresAt,
  });

  factory InviteCode.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return InviteCode(
      code: data['code'] as String,
      projectId: data['projectId'] as String,
      createdBy: data['createdBy'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      expiresAt: (data['expiresAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'projectId': projectId,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'expiresAt': Timestamp.fromDate(expiresAt),
    };
  }
}
