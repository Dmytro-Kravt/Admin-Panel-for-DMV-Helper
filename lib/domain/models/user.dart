
enum UserAccessRole { admin, editor, viewer, }

class UserModel {
  final String userId;
  final String userEmail;
  final UserAccessRole accessRole;
  final bool isApproved;

  const UserModel({
    required this.userId,
    required this.userEmail,
    required this.accessRole,
    required this.isApproved
});

  UserModel copyWith({
    String? userId,
    String? userEmail,
    UserAccessRole? accessRole,
    bool? isApproved,
  }) {
    return UserModel(
        userId: userId ?? this.userId,
        userEmail: userEmail ?? this.userEmail,
        accessRole: accessRole ?? this.accessRole,
        isApproved: isApproved ?? this.isApproved,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final roleString = json['accessRole'] as String;
    UserAccessRole newAccessRole = UserAccessRole.values.firstWhere((item) =>
    item.name == roleString,
    orElse: () => UserAccessRole.viewer);
    return UserModel(
        userId: json['userId'],
        userEmail: json['userEmail'],
        accessRole: newAccessRole,
        isApproved: json['isApproved']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userEmail': userEmail,
      'accessRole': accessRole.name,
      'isApproved': isApproved,
    };
  }
}