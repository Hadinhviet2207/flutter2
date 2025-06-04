import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProjectAttachment extends Equatable {
  final String id;
  final String projectDetailId;
  final String fileName;
  final String fileUrl;
  final String fileType;
  final int fileSize;
  final DateTime uploadedAt;
  final String uploadedBy;

  ProjectAttachment({
    required this.id,
    required this.projectDetailId,
    required this.fileName,
    required this.fileUrl,
    required this.fileType,
    required this.fileSize,
    required this.uploadedAt,
    required this.uploadedBy,
  });

  @override
  List<Object?> get props => [
    id,
    projectDetailId,
    fileName,
    fileUrl,
    fileType,
    fileSize,
    uploadedAt,
    uploadedBy,
  ];

  factory ProjectAttachment.fromJson(Map<String, dynamic> json) {
    return ProjectAttachment(
      id: json['id'] as String,
      projectDetailId: json['projectDetailId'] as String,
      fileName: json['fileName'] as String,
      fileUrl: json['fileUrl'] as String,
      fileType: json['fileType'] as String,
      fileSize: json['fileSize'] as int,
      uploadedAt: (json['uploadedAt'] as Timestamp).toDate(),
      uploadedBy: json['uploadedBy'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectDetailId': projectDetailId,
      'fileName': fileName,
      'fileUrl': fileUrl,
      'fileType': fileType,
      'fileSize': fileSize,
      'uploadedAt': Timestamp.fromDate(uploadedAt),
      'uploadedBy': uploadedBy,
    };
  }
}

class ProjectDetail extends Equatable {
  final String id;
  final String projectId;
  final String content;
  final String? backgroundImage;
  final String creatorId;
  final String teamLeaderId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final List<ProjectAttachment> attachments;

  ProjectDetail({
    required this.id,
    required this.projectId,
    required this.content,
    this.backgroundImage,
    required this.creatorId,
    required this.teamLeaderId,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
    this.attachments = const [],
  }) {
    validate();
  }

  @override
  List<Object?> get props => [
    id,
    projectId,
    content,
    backgroundImage,
    creatorId,
    teamLeaderId,
    createdAt,
    updatedAt,
    isDeleted,
    attachments,
  ];

  void validate() {
    assert(id.isNotEmpty, 'ProjectDetail ID cannot be empty');
    assert(projectId.isNotEmpty, 'Project ID cannot be empty');
    assert(creatorId.isNotEmpty, 'Creator ID cannot be empty');
    assert(teamLeaderId.isNotEmpty, 'Team Leader ID cannot be empty');
    assert(
      createdAt.isBefore(updatedAt) || createdAt.isAtSameMomentAs(updatedAt),
      'UpdatedAt must be after or equal to createdAt',
    );
  }

  factory ProjectDetail.fromJson(Map<String, dynamic> json) {
    DateTime parseDateTime(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is Timestamp) {
        return value.toDate();
      } else if (value is String) {
        return DateTime.parse(value);
      }
      throw Exception('Invalid date format: $value');
    }

    List<ProjectAttachment> parseAttachments(dynamic value) {
      if (value == null) return [];
      if (value is List) {
        return value.map((item) {
          if (item is String) {
            // Nếu là ID của file, tạo một ProjectAttachment tạm thời
            return ProjectAttachment(
              id: item,
              projectDetailId: json['id'] as String,
              fileName: 'File đang tải...',
              fileUrl: '',
              fileType: 'unknown',
              fileSize: 0,
              uploadedAt: DateTime.now(),
              uploadedBy: json['creatorId'] as String,
            );
          } else if (item is Map<String, dynamic>) {
            return ProjectAttachment.fromJson(item);
          }
          throw Exception('Invalid attachment format: $item');
        }).toList();
      }
      return [];
    }

    return ProjectDetail(
      id: json['id'] as String,
      projectId: json['projectId'] as String,
      content: json['content'] as String,
      backgroundImage: json['backgroundImage'] as String?,
      creatorId: json['creatorId'] as String,
      teamLeaderId: json['teamLeaderId'] as String,
      createdAt: parseDateTime(json['createdAt']),
      updatedAt: parseDateTime(json['updatedAt']),
      isDeleted: json['isDeleted'] as bool? ?? false,
      attachments: parseAttachments(json['attachments']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'content': content,
      'backgroundImage': backgroundImage,
      'creatorId': creatorId,
      'teamLeaderId': teamLeaderId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isDeleted': isDeleted,
      'attachments':
          attachments.map((e) => e.id).toList(), // Chỉ lưu ID của attachments
    };
  }

  ProjectDetail copyWith({
    String? id,
    String? projectId,
    String? content,
    String? backgroundImage,
    String? creatorId,
    String? teamLeaderId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    List<ProjectAttachment>? attachments,
  }) {
    return ProjectDetail(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      content: content ?? this.content,
      backgroundImage: backgroundImage ?? this.backgroundImage,
      creatorId: creatorId ?? this.creatorId,
      teamLeaderId: teamLeaderId ?? this.teamLeaderId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      attachments: attachments ?? this.attachments,
    );
  }
}
