import 'package:equatable/equatable.dart';

class ProjectDetail extends Equatable {
  final String id;
  final String projectId;
  final String content;
  final List<String> attachmentUrls;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;
  final bool isDeleted;

  const ProjectDetail({
    required this.id,
    required this.projectId,
    required this.content,
    required this.attachmentUrls,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
    this.isDeleted = false,
  });

  @override
  List<Object?> get props => [
    id,
    projectId,
    content,
    attachmentUrls,
    createdAt,
    updatedAt,
    createdBy,
    isDeleted,
  ];

  factory ProjectDetail.fromJson(Map<String, dynamic> json) {
    return ProjectDetail(
      id: json['id'] as String,
      projectId: json['projectId'] as String,
      content: json['content'] as String,
      attachmentUrls: List<String>.from(json['attachmentUrls'] as List),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      createdBy: json['createdBy'] as String?,
      isDeleted: json['isDeleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'content': content,
      'attachmentUrls': attachmentUrls,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
      'isDeleted': isDeleted,
    };
  }

  ProjectDetail copyWith({
    String? id,
    String? projectId,
    String? content,
    List<String>? attachmentUrls,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    bool? isDeleted,
  }) {
    return ProjectDetail(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      content: content ?? this.content,
      attachmentUrls: attachmentUrls ?? this.attachmentUrls,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
