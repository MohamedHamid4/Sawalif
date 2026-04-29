import 'package:cloud_firestore/cloud_firestore.dart';

/// موديل الحالة (Story) - تنتهي صلاحيتها بعد 24 ساعة
class StoryModel {
  final String id;
  final String userId;
  final String userName;
  final String userPhotoUrl;
  final String imageUrl;
  final String caption;
  final DateTime createdAt;
  final DateTime expiresAt;
  final List<String> viewedBy;

  const StoryModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userPhotoUrl,
    required this.imageUrl,
    this.caption = '',
    required this.createdAt,
    required this.expiresAt,
    this.viewedBy = const [],
  });

  factory StoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StoryModel(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      userName: data['userName'] as String? ?? '',
      userPhotoUrl: data['userPhotoUrl'] as String? ?? '',
      imageUrl: data['imageUrl'] as String? ?? '',
      caption: data['caption'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      expiresAt: (data['expiresAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      viewedBy: List<String>.from(data['viewedBy'] as List? ?? []),
    );
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool wasViewedBy(String uid) => viewedBy.contains(uid);
}
