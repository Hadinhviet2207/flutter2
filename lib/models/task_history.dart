import 'package:equatable/equatable.dart';
import '../utils/enum_utils.dart';

class TaskHistory extends Equatable {
  final String id;
  final String taskId;
  final String userId;
  final ActionType actionType;
  final String description;
  final DateTime createdAt;

  TaskHistory({
    required this.id,
    required this.taskId,
    required this.userId,
    required this.actionType,
    required this.description,
    required this.createdAt,
  }) {
    validate();
  }

  @override
  List<Object> get props => [
    id,
    taskId,
    userId,
    actionType,
    description,
    createdAt,
  ];

  void validate() {
    assert(id.isNotEmpty, 'History ID cannot be empty');
    assert(taskId.isNotEmpty, 'Task ID cannot be empty');
    assert(userId.isNotEmpty, 'User ID cannot be empty');
    assert(description.isNotEmpty, 'Description cannot be empty');
  }

  factory TaskHistory.fromJson(Map<String, dynamic> json) {
    return TaskHistory(
      id: json['id'] as String,
      taskId: json['taskId'] as String,
      userId: json['userId'] as String,
      actionType: EnumUtils.stringToEnum(
        json['actionType'] as String,
        ActionType.values,
      ),
      description: json['description'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'taskId': taskId,
      'userId': userId,
      'actionType': EnumUtils.enumToString(actionType),
      'description': description,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  TaskHistory copyWith({
    String? id,
    String? taskId,
    String? userId,
    ActionType? actionType,
    String? description,
    DateTime? createdAt,
  }) {
    return TaskHistory(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      userId: userId ?? this.userId,
      actionType: actionType ?? this.actionType,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
