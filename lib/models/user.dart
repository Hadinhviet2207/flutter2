import 'package:equatable/equatable.dart';
import '../utils/enum_utils.dart';

enum UserRole { admin, member }

class User extends Equatable {
  final String id;
  final String? email;
  final String? password;
  final String? displayName;
  final String? photoUrl;
  final UserRole role;
  final List<String> projectIds;
  final String? previousAnonymousId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;

  const User({
    required this.id,
    this.email,
    this.password,
    this.displayName,
    this.photoUrl,
    required this.role,
    required this.projectIds,
    this.previousAnonymousId,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
  });

  @override
  List<Object?> get props => [
    id,
    email,
    password,
    displayName,
    photoUrl,
    role,
    projectIds,
    previousAnonymousId,
    createdAt,
    updatedAt,
    isDeleted,
  ];

  void validate() {
    assert(id.isNotEmpty, 'User ID cannot be empty');
    assert(email == null || email!.isNotEmpty, 'Email cannot be empty');
    assert(
      password == null || password!.isNotEmpty,
      'Password cannot be empty',
    );
    assert(
      displayName == null || displayName!.isNotEmpty,
      'Display name cannot be empty',
    );
    assert(
      createdAt.isBefore(updatedAt) || createdAt.isAtSameMomentAs(updatedAt),
      'UpdatedAt must be after or equal to createdAt',
    );
    assert(
      previousAnonymousId == null || previousAnonymousId!.isNotEmpty,
      'Previous anonymous ID must be null or non-empty',
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String?,
      password: json['password'] as String?,
      displayName: json['displayName'] as String?,
      photoUrl: json['photoUrl'] as String?,
      role: EnumUtils.stringToEnum(json['role'] as String, UserRole.values),
      projectIds: List<String>.from(json['projectIds'] as List),
      previousAnonymousId: json['previousAnonymousId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isDeleted: json['isDeleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'password': password,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'role': EnumUtils.enumToString(role),
      'projectIds': projectIds,
      'previousAnonymousId': previousAnonymousId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isDeleted': isDeleted,
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? password,
    String? displayName,
    String? photoUrl,
    UserRole? role,
    List<String>? projectIds,
    String? previousAnonymousId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      password: password ?? this.password,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      projectIds: projectIds ?? this.projectIds,
      previousAnonymousId: previousAnonymousId ?? this.previousAnonymousId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
