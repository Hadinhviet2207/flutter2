import 'package:equatable/equatable.dart';

class Comment extends Equatable {
  final String id;
  final String projectId;
  final String content;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? imageUrl;
  final List<String> mentionedUserIds;
  final List<String> attachmentUrls;
  final bool isDeleted;
  final String? parentId;

  Comment({
    required this.id,
    required this.projectId,
    required this.content,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.imageUrl,
    required this.mentionedUserIds,
    required this.attachmentUrls,
    this.isDeleted = false,
    this.parentId,
  }) {
    validate();
  }

  @override
  List<Object?> get props => [
    id,
    projectId,
    content,
    createdBy,
    createdAt,
    updatedAt,
    imageUrl,
    mentionedUserIds,
    attachmentUrls,
    isDeleted,
    parentId,
  ];

  void validate() {
    assert(id.isNotEmpty, 'Comment ID cannot be empty');
    assert(projectId.isNotEmpty, 'Project ID cannot be empty');
    assert(content.isNotEmpty, 'Comment content cannot be empty');
    assert(
      createdAt.isBefore(updatedAt) || createdAt.isAtSameMomentAs(updatedAt),
      'UpdatedAt must be after or equal to createdAt',
    );
  }

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as String,
      projectId: json['projectId'] as String,
      content: json['content'] as String,
      createdBy: json['createdBy'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      imageUrl: json['imageUrl'] as String?,
      mentionedUserIds: List<String>.from(json['mentionedUserIds'] as List),
      attachmentUrls: List<String>.from(json['attachmentUrls'] as List),
      isDeleted: json['isDeleted'] as bool? ?? false,
      parentId: json['parentId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'content': content,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'imageUrl': imageUrl,
      'mentionedUserIds': mentionedUserIds,
      'attachmentUrls': attachmentUrls,
      'isDeleted': isDeleted,
      'parentId': parentId,
    };
  }

  Comment copyWith({
    String? id,
    String? projectId,
    String? content,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? imageUrl,
    List<String>? mentionedUserIds,
    List<String>? attachmentUrls,
    bool? isDeleted,
    String? parentId,
  }) {
    return Comment(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      content: content ?? this.content,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      imageUrl: imageUrl ?? this.imageUrl,
      mentionedUserIds: mentionedUserIds ?? this.mentionedUserIds,
      attachmentUrls: attachmentUrls ?? this.attachmentUrls,
      isDeleted: isDeleted ?? this.isDeleted,
      parentId: parentId ?? this.parentId,
    );
  }
}
