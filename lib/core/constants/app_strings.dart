/// مفاتيح الثوابت والمسارات في تطبيق سوالف
class AppStrings {
  AppStrings._();

  // ===== معرّف التطبيق =====
  static const String appName = 'Sawalif';
  static const String appVersion = '1.0.0';

  // ===== مفاتيح SharedPreferences =====
  static const String keyThemeMode = 'theme_mode';
  static const String keyLocale = 'locale';
  static const String keyOnboardingDone = 'onboarding_done';
  static const String keyFcmToken = 'fcm_token';
  static const String keyNotificationsEnabled = 'notifications_enabled';

  // ===== Firestore Collections =====
  static const String colUsers = 'users';
  static const String colChats = 'chats';
  static const String colMessages = 'messages';
  static const String colUsernames = 'usernames';

  // ===== Firestore Fields =====
  static const String fieldUid = 'uid';
  static const String fieldName = 'name';
  static const String fieldUsername = 'username';
  static const String fieldEmail = 'email';
  static const String fieldReservedAt = 'reservedAt';
  static const String fieldPhotoUrl = 'photoUrl';
  static const String fieldBio = 'bio';
  static const String fieldIsOnline = 'isOnline';
  static const String fieldLastSeen = 'lastSeen';
  static const String fieldCreatedAt = 'createdAt';
  static const String fieldFcmToken = 'fcmToken';
  static const String fieldOneSignalId = 'oneSignalId';
  static const String fieldBlockedUsers = 'blockedUsers';
  static const String fieldParticipants = 'participants';
  static const String fieldLastMessage = 'lastMessage';
  static const String fieldLastMessageTime = 'lastMessageTime';
  static const String fieldLastSenderId = 'lastSenderId';
  static const String fieldUnreadCount = 'unreadCount';
  static const String fieldTyping = 'typing';
  static const String fieldSenderId = 'senderId';
  static const String fieldSenderName = 'senderName';
  static const String fieldContent = 'content';
  static const String fieldType = 'type';
  static const String fieldTimestamp = 'timestamp';
  static const String fieldStatus = 'status';
  static const String fieldImageUrl = 'imageUrl';
  static const String fieldReplyToId = 'replyToId';
  static const String fieldReplyToContent = 'replyToContent';
  static const String fieldReactions = 'reactions';
  static const String fieldIsDeleted = 'isDeleted';
  static const String fieldDeliveredTo = 'deliveredTo';
  static const String fieldReadBy = 'readBy';
  // ===== Group fields =====
  static const String fieldChatType = 'type';
  static const String fieldGroupName = 'groupName';
  static const String fieldGroupPhotoUrl = 'groupPhotoUrl';
  static const String fieldGroupAdminId = 'groupAdminId';
  static const String fieldGroupAdmins = 'groupAdmins';
  static const String fieldGroupDescription = 'groupDescription';

  // ===== Storage Paths =====
  static const String storageProfileImages = 'profile_images';
  static const String storageChatImages = 'chat_images';

  // ===== Default Values =====
  static const String defaultBio = '';
  static const int messagesPaginationLimit = 100;

  // ===== أسماء مستخدمين محجوزة (لا يُسمح بحجزها) =====
  static const Set<String> reservedUsernames = {
    'admin',
    'sawalif',
    'support',
    'help',
    'root',
    'official',
    'system',
    'moderator',
  };

  // ===== Deep Link / QR =====
  static const String qrUriScheme = 'sawalif';
  static const String qrUriUserHost = 'user';

  // ===== Notification Channel =====
  static const String notifChannelId = 'sawalif_messages';
  static const String notifChannelName = 'رسائل سوالف';
  static const String notifChannelDesc = 'إشعارات الرسائل الجديدة';

  // ===== System message markers =====
  // علامات ثابتة (locale-neutral) تُكتب في Firestore بدلاً من نص بلغة معيّنة،
  // وتُترجَم وقت العرض. الاحتفاظ بصيغة `__name__` يُجنّب الاصطدام بأي نص حقيقي.
  static const String markerGroupCreated = '__group_created__';
  static const String markerMessageDeleted = '__deleted__';
}
