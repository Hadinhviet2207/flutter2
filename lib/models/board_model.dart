import 'package:cloud_firestore/cloud_firestore.dart';

class BoardModel {
  final String id;
  final String title;
  final String? description;
  final DateTime? startDate;
  final DateTime? endDate;
  final String status;
  final bool isStartingSoon;
  final String userId;
  final bool isPinned;
  final DateTime createdAt;

  BoardModel({
    required this.id,
    required this.title,
    this.description,
    this.startDate,
    this.endDate,
    required this.status,
    required this.isStartingSoon,
    required this.userId,
    this.isPinned = false,
    required this.createdAt,
  });

  // Factory tạo từ DocumentSnapshot Firestore
  factory BoardModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return BoardModel(
      id: doc.id,
      title: data['title'] as String? ?? '',
      description: data['description'] as String?,
      startDate:
          data['startDate'] != null
              ? (data['startDate'] as Timestamp).toDate()
              : null,
      endDate:
          data['endDate'] != null
              ? (data['endDate'] as Timestamp).toDate()
              : null,
      status: data['status'] as String? ?? 'Đang hoạt động',
      isStartingSoon: data['isStartingSoon'] as bool? ?? false,
      userId: data['userId'] as String? ?? '',
      isPinned: data['isPinned'] as bool? ?? false,
      createdAt:
          data['createdAt'] != null
              ? (data['createdAt'] as Timestamp).toDate()
              : DateTime.now(),
    );
  }

  // Chuyển model thành Map để lưu Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      if (description != null) 'description': description,
      if (startDate != null) 'startDate': Timestamp.fromDate(startDate!),
      if (endDate != null) 'endDate': Timestamp.fromDate(endDate!),
      'status': status,
      'isStartingSoon': isStartingSoon,
      'userId': userId,
      'isPinned': isPinned,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
