import 'package:equatable/equatable.dart';
import '../utils/enum_utils.dart';

class ProjectInvite extends Equatable {
  final String id;
  final String projectId;
  final String email;
  final String invitedBy;
  final InviteStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProjectInvite({
    required this.id,
    required this.projectId,
    required this.email,
    required this.invitedBy,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  }) {
    validate();
  }

  @override
  List<Object?> get props => [
    id,
    email,
    invitedBy,
    projectId,
    status,
    createdAt,
    updatedAt,
  ];

  void validate() {
    assert(id.isNotEmpty, 'Invite ID cannot be empty');
    assert(email.isNotEmpty, 'Email cannot be empty');
    assert(invitedBy.isNotEmpty, 'InvitedBy cannot be empty');
    assert(projectId.isNotEmpty, 'Project ID cannot be empty');
    assert(
      createdAt.isBefore(updatedAt) || createdAt.isAtSameMomentAs(updatedAt),
      'UpdatedAt must be after or equal to createdAt',
    );
  }

  factory ProjectInvite.fromJson(Map<String, dynamic> json) {
    return ProjectInvite(
      id: json['id'] as String,
      email: json['email'] as String,
      invitedBy: json['invitedBy'] as String,
      projectId: json['projectId'] as String,
      status: EnumUtils.stringToEnum(
        json['status'] as String,
        InviteStatus.values,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'invitedBy': invitedBy,
      'projectId': projectId,
      'status': EnumUtils.enumToString(status),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  ProjectInvite copyWith({
    String? id,
    String? email,
    String? invitedBy,
    String? projectId,
    InviteStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProjectInvite(
      id: id ?? this.id,
      email: email ?? this.email,
      invitedBy: invitedBy ?? this.invitedBy,
      projectId: projectId ?? this.projectId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
