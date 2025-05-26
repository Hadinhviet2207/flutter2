class EnumUtils {
  static String enumToString(dynamic enumValue) {
    return enumValue.toString().split('.').last;
  }

  static T stringToEnum<T>(String value, List<T> values) {
    return values.firstWhere(
      (e) => enumToString(e) == value,
      orElse: () => throw ArgumentError('Invalid enum value: $value'),
    );
  }
}

enum TaskStatus { backlog, todo, inProgress, blocked, done, cancelled }

enum TaskPriority { low, medium, high }

enum UserRole { admin, member }

enum ActionType { create, update, delete, assign, complete }

enum InviteStatus { pending, accepted, rejected }
