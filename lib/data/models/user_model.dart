import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_strings.dart';

/// موديل المستخدم في تطبيق سوالف
class UserModel {
  final String uid;
  final String name;
  final String username;
  final String email;
  final String photoUrl;
  final String bio;
  final bool isOnline;
  final DateTime? lastSeen;
  final DateTime createdAt;
  final String fcmToken;
  final String oneSignalId;
  final List<String> blockedUsers;

  const UserModel({
    required this.uid,
    required this.name,
    this.username = '',
    required this.email,
    this.photoUrl = '',
    this.bio = '',
    this.isOnline = false,
    this.lastSeen,
    required this.createdAt,
    this.fcmToken = '',
    this.oneSignalId = '',
    this.blockedUsers = const [],
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: data[AppStrings.fieldUid] as String? ?? doc.id,
      name: data[AppStrings.fieldName] as String? ?? '',
      username: data[AppStrings.fieldUsername] as String? ?? '',
      email: data[AppStrings.fieldEmail] as String? ?? '',
      photoUrl: data[AppStrings.fieldPhotoUrl] as String? ?? '',
      bio: data[AppStrings.fieldBio] as String? ?? '',
      isOnline: data[AppStrings.fieldIsOnline] as bool? ?? false,
      lastSeen: (data[AppStrings.fieldLastSeen] as Timestamp?)?.toDate(),
      createdAt: (data[AppStrings.fieldCreatedAt] as Timestamp?)?.toDate() ?? DateTime.now(),
      fcmToken: data[AppStrings.fieldFcmToken] as String? ?? '',
      oneSignalId: data[AppStrings.fieldOneSignalId] as String? ?? '',
      blockedUsers:
          List<String>.from(data[AppStrings.fieldBlockedUsers] as List? ?? []),
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      uid: data[AppStrings.fieldUid] as String? ?? '',
      name: data[AppStrings.fieldName] as String? ?? '',
      username: data[AppStrings.fieldUsername] as String? ?? '',
      email: data[AppStrings.fieldEmail] as String? ?? '',
      photoUrl: data[AppStrings.fieldPhotoUrl] as String? ?? '',
      bio: data[AppStrings.fieldBio] as String? ?? '',
      isOnline: data[AppStrings.fieldIsOnline] as bool? ?? false,
      lastSeen: (data[AppStrings.fieldLastSeen] as Timestamp?)?.toDate(),
      createdAt: (data[AppStrings.fieldCreatedAt] as Timestamp?)?.toDate() ?? DateTime.now(),
      fcmToken: data[AppStrings.fieldFcmToken] as String? ?? '',
      oneSignalId: data[AppStrings.fieldOneSignalId] as String? ?? '',
      blockedUsers:
          List<String>.from(data[AppStrings.fieldBlockedUsers] as List? ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      AppStrings.fieldUid: uid,
      AppStrings.fieldName: name,
      AppStrings.fieldUsername: username,
      AppStrings.fieldEmail: email,
      AppStrings.fieldPhotoUrl: photoUrl,
      AppStrings.fieldBio: bio,
      AppStrings.fieldIsOnline: isOnline,
      AppStrings.fieldLastSeen: lastSeen != null ? Timestamp.fromDate(lastSeen!) : null,
      AppStrings.fieldCreatedAt: Timestamp.fromDate(createdAt),
      AppStrings.fieldFcmToken: fcmToken,
      AppStrings.fieldOneSignalId: oneSignalId,
      AppStrings.fieldBlockedUsers: blockedUsers,
    };
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? username,
    String? email,
    String? photoUrl,
    String? bio,
    bool? isOnline,
    DateTime? lastSeen,
    DateTime? createdAt,
    String? fcmToken,
    String? oneSignalId,
    List<String>? blockedUsers,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      username: username ?? this.username,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      bio: bio ?? this.bio,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      createdAt: createdAt ?? this.createdAt,
      fcmToken: fcmToken ?? this.fcmToken,
      oneSignalId: oneSignalId ?? this.oneSignalId,
      blockedUsers: blockedUsers ?? this.blockedUsers,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is UserModel && uid == other.uid;

  @override
  int get hashCode => uid.hashCode;
}
