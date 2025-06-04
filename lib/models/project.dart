import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum ProjectStatus {
  notStarted, // Chưa bắt đầu
  inProgress, // Đang thực hiện
  onHold, // Tạm dừng
  waitingReview, // Chờ kiểm tra
  revisionNeeded, // Cần sửa lại
  completed, // Đã hoàn thành
  canceled, // Đã huỷ
  archived, // Lưu trữ
  delayed, // Bị trễ
}

class Project extends Equatable {
  final String id;
  final String title;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? ownerId;
  final List<String> memberIds;
  final bool isArchived;
  final bool isDeleted;
  final String? parentId;
  final ProjectStatus status;
  final DateTime startDate;
  final DateTime? dueDate;
  final bool isPinned;
  final bool isGlobalPinned;
  final DateTime? pinnedAt;
  final String teamLeaderId;

  Project({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    this.ownerId,
    required this.memberIds,
    this.isArchived = false,
    this.isDeleted = false,
    this.parentId,
    this.status = ProjectStatus.notStarted,
    required this.startDate,
    this.dueDate,
    this.isPinned = false,
    this.isGlobalPinned = false,
    this.pinnedAt,
    required this.teamLeaderId,
  }) {
    validate();
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    createdAt,
    updatedAt,
    ownerId,
    memberIds,
    isArchived,
    isDeleted,
    parentId,
    status,
    startDate,
    dueDate,
    isPinned,
    isGlobalPinned,
    pinnedAt,
    teamLeaderId,
  ];

  void validate() {
    assert(id.isNotEmpty, 'Project ID cannot be empty');
    assert(title.isNotEmpty, 'Project title cannot be empty');
    assert(
      createdAt.isBefore(updatedAt) || createdAt.isAtSameMomentAs(updatedAt),
      'UpdatedAt must be after or equal to createdAt',
    );
    assert(
      ownerId == null || ownerId!.isNotEmpty,
      'Owner ID must be null or non-empty',
    );
    assert(
      memberIds.every((id) => id.isNotEmpty),
      'Member IDs must be non-empty',
    );
    assert(
      parentId == null || parentId!.isNotEmpty,
      'Parent ID must be null or non-empty',
    );
    assert(teamLeaderId.isNotEmpty, 'Team Leader ID cannot be empty');
    assert(
      memberIds.contains(teamLeaderId),
      'Team Leader must be a member of the project',
    );
  }

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      ownerId: json['ownerId'] as String?,
      memberIds: List<String>.from(json['memberIds'] as List),
      isArchived: json['isArchived'] as bool? ?? false,
      isDeleted: json['isDeleted'] as bool? ?? false,
      parentId: json['parentId'] as String?,
      status: ProjectStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => ProjectStatus.notStarted,
      ),
      startDate: DateTime.parse(json['startDate'] as String),
      dueDate:
          json['dueDate'] != null
              ? DateTime.parse(json['dueDate'] as String)
              : null,
      isPinned: json['isPinned'] as bool? ?? false,
      isGlobalPinned: json['isGlobalPinned'] as bool? ?? false,
      pinnedAt:
          json['pinnedAt'] != null
              ? DateTime.parse(json['pinnedAt'] as String)
              : null,
      teamLeaderId: json['teamLeaderId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'ownerId': ownerId,
      'memberIds': memberIds,
      'isArchived': isArchived,
      'isDeleted': isDeleted,
      'parentId': parentId,
      'status': status.toString().split('.').last,
      'startDate': startDate.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'isPinned': isPinned,
      'isGlobalPinned': isGlobalPinned,
      'pinnedAt': pinnedAt?.toIso8601String(),
      'teamLeaderId': teamLeaderId,
    };
  }

  Project copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? ownerId,
    List<String>? memberIds,
    bool? isArchived,
    bool? isDeleted,
    String? parentId,
    ProjectStatus? status,
    DateTime? startDate,
    DateTime? dueDate,
    bool? isPinned,
    bool? isGlobalPinned,
    DateTime? pinnedAt,
    String? teamLeaderId,
  }) {
    return Project(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      ownerId: ownerId ?? this.ownerId,
      memberIds: memberIds ?? this.memberIds,
      isArchived: isArchived ?? this.isArchived,
      isDeleted: isDeleted ?? this.isDeleted,
      parentId: parentId ?? this.parentId,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      dueDate: dueDate ?? this.dueDate,
      isPinned: isPinned ?? this.isPinned,
      isGlobalPinned: isGlobalPinned ?? this.isGlobalPinned,
      pinnedAt: pinnedAt ?? this.pinnedAt,
      teamLeaderId: teamLeaderId ?? this.teamLeaderId,
    );
  }
}
