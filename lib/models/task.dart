import 'package:equatable/equatable.dart';
import '../utils/enum_utils.dart' as enum_utils;

class Task extends Equatable {
  final String id;
  final String projectId;
  final String? parentTaskId;
  final String title;
  final String description;
  final enum_utils.TaskStatus status;
  final enum_utils.TaskPriority priority;
  final DateTime dueDate;
  final String? assignedTo;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? imageUrl;
  final int commentCount;
  final int subtaskCount;
  final int completedCount;
  final List<String> collaboratorIds;
  final bool isArchived;
  final bool isDeleted;

  Task({
    required this.id,
    required this.projectId,
    this.parentTaskId,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.dueDate,
    this.assignedTo,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.imageUrl,
    this.commentCount = 0,
    this.subtaskCount = 0,
    this.completedCount = 0,
    required this.collaboratorIds,
    this.isArchived = false,
    this.isDeleted = false,
  }) {
    validate();
  }

  @override
  List<Object?> get props => [
    id,
    projectId,
    parentTaskId,
    title,
    description,
    status,
    priority,
    dueDate,
    assignedTo,
    createdBy,
    createdAt,
    updatedAt,
    imageUrl,
    commentCount,
    subtaskCount,
    completedCount,
    collaboratorIds,
    isArchived,
    isDeleted,
  ];

  void validate() {
    assert(id.isNotEmpty, 'Task ID cannot be empty');
    assert(projectId.isNotEmpty, 'Project ID cannot be empty');
    assert(
      parentTaskId == null || parentTaskId!.isNotEmpty,
      'Parent Task ID cannot be empty if provided',
    );
    assert(title.isNotEmpty, 'Task title cannot be empty');
    assert(
      createdAt.isBefore(updatedAt) || createdAt.isAtSameMomentAs(updatedAt),
      'UpdatedAt must be after or equal to createdAt',
    );
    assert(commentCount >= 0, 'Comment count cannot be negative');
    assert(subtaskCount >= 0, 'Subtask count cannot be negative');
    assert(completedCount >= 0, 'Completed count cannot be negative');
    assert(
      completedCount <= subtaskCount,
      'Completed count cannot exceed subtask count',
    );
    assert(
      assignedTo == null || assignedTo!.isNotEmpty,
      'AssignedTo must be null or non-empty',
    );
    assert(
      createdBy == null || createdBy!.isNotEmpty,
      'CreatedBy must be null or non-empty',
    );
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      projectId: json['projectId'] as String,
      parentTaskId: json['parentTaskId'] as String?,
      title: json['title'] as String,
      description: json['description'] as String,
      status: enum_utils.EnumUtils.stringToEnum(
        json['status'] as String,
        enum_utils.TaskStatus.values,
      ),
      priority: enum_utils.EnumUtils.stringToEnum(
        json['priority'] as String,
        enum_utils.TaskPriority.values,
      ),
      dueDate: DateTime.parse(json['dueDate'] as String),
      assignedTo: json['assignedTo'] as String?,
      createdBy: json['createdBy'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      imageUrl: json['imageUrl'] as String?,
      commentCount: json['commentCount'] as int? ?? 0,
      subtaskCount: json['subtaskCount'] as int? ?? 0,
      completedCount: json['completedCount'] as int? ?? 0,
      collaboratorIds: List<String>.from(json['collaboratorIds'] as List),
      isArchived: json['isArchived'] as bool? ?? false,
      isDeleted: json['isDeleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'parentTaskId': parentTaskId,
      'title': title,
      'description': description,
      'status': enum_utils.EnumUtils.enumToString(status),
      'priority': enum_utils.EnumUtils.enumToString(priority),
      'dueDate': dueDate.toIso8601String(),
      'assignedTo': assignedTo,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'imageUrl': imageUrl,
      'commentCount': commentCount,
      'subtaskCount': subtaskCount,
      'completedCount': completedCount,
      'collaboratorIds': collaboratorIds,
      'isArchived': isArchived,
      'isDeleted': isDeleted,
    };
  }

  Task copyWith({
    String? id,
    String? projectId,
    String? parentTaskId,
    String? title,
    String? description,
    enum_utils.TaskStatus? status,
    enum_utils.TaskPriority? priority,
    DateTime? dueDate,
    String? assignedTo,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? imageUrl,
    int? commentCount,
    int? subtaskCount,
    int? completedCount,
    List<String>? collaboratorIds,
    bool? isArchived,
    bool? isDeleted,
  }) {
    return Task(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      parentTaskId: parentTaskId ?? this.parentTaskId,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      assignedTo: assignedTo ?? this.assignedTo,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      imageUrl: imageUrl ?? this.imageUrl,
      commentCount: commentCount ?? this.commentCount,
      subtaskCount: subtaskCount ?? this.subtaskCount,
      completedCount: completedCount ?? this.completedCount,
      collaboratorIds: collaboratorIds ?? this.collaboratorIds,
      isArchived: isArchived ?? this.isArchived,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
