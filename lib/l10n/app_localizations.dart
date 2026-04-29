import 'package:flutter/material.dart';
import 'app_ar.dart';
import 'app_en.dart';

/// كلاس الترجمة الرئيسي لتطبيق سوالف
/// يدعم العربي والإنجليزي مع RTL تلقائي
class AppLocalizations {
  final Locale locale;

  const AppLocalizations(this.locale);

  /// الحصول على الكلاس من السياق
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('ar'),
    Locale('en'),
  ];

  bool get isArabic => locale.languageCode == 'ar';

  /// الحصول على نص مترجم بالمفتاح
  String translate(String key) {
    final map = isArabic ? appAr : appEn;
    return map[key] ?? key;
  }

  // ===== Getters مختصرة لأكثر المفاتيح استخداماً =====
  String get appName => translate('app_name');
  String get appSubtitle => translate('app_subtitle');
  String get appTagline => translate('app_tagline');
  String get login => translate('login');
  String get signup => translate('signup');
  String get logout => translate('logout');
  String get email => translate('email');
  String get password => translate('password');
  String get confirmPassword => translate('confirm_password');
  String get name => translate('name');
  String get forgotPassword => translate('forgot_password');
  String get signInGoogle => translate('sign_in_google');
  String get dontHaveAccount => translate('dont_have_account');
  String get haveAccount => translate('have_account');
  String get createAccount => translate('create_account');
  String get resetPassword => translate('reset_password');
  String get resetPasswordDesc => translate('reset_password_desc');
  String get sendResetLink => translate('send_reset_link');
  String get resetLinkSent => translate('reset_link_sent');
  String get emailHint => translate('email_hint');
  String get passwordHint => translate('password_hint');
  String get nameHint => translate('name_hint');
  String get username => translate('username');
  String get usernameHint => translate('username_hint');
  String get usernameRequired => translate('username_required');
  String get usernameInvalid => translate('username_invalid');
  String get usernameTooShort => translate('username_too_short');
  String get usernameTooLong => translate('username_too_long');
  String get usernameTaken => translate('username_taken');
  String get usernameReserved => translate('username_reserved');
  String get usernameAvailable => translate('username_available');
  String get checkingUsername => translate('checking_username');

  String get onboardingSkip => translate('onboarding_skip');
  String get onboardingNext => translate('onboarding_next');
  String get onboardingStart => translate('onboarding_start');
  String get onboarding1Title => translate('onboarding1_title');
  String get onboarding1Desc => translate('onboarding1_desc');
  String get onboarding2Title => translate('onboarding2_title');
  String get onboarding2Desc => translate('onboarding2_desc');
  String get onboarding3Title => translate('onboarding3_title');
  String get onboarding3Desc => translate('onboarding3_desc');

  String get chats => translate('chats');
  String get newChat => translate('new_chat');
  String get noChats => translate('no_chats');
  String get noChatsDesc => translate('no_chats_desc');
  String get startChat => translate('start_chat');
  String get searchChats => translate('search_chats');

  String get typeMessage => translate('type_message');
  String get send => translate('send');
  String get online => translate('online');
  String get offline => translate('offline');
  String get lastSeen => translate('last_seen');
  String get typing => translate('typing');
  String get messageDeleted => translate('message_deleted');
  String get deleteMessage => translate('delete_message');
  String get reply => translate('reply');
  String get copy => translate('copy');
  String get react => translate('react');
  String get replyTo => translate('reply_to');
  String get cancelReply => translate('cancel_reply');
  String get sendImage => translate('send_image');

  String get users => translate('users');
  String get searchUsers => translate('search_users');
  String get noUsers => translate('no_users');
  String get addFriend => translate('add_friend');
  String get searchByUsername => translate('search_by_username');
  String get searchUsernameHint => translate('search_username_hint');
  String get searchUsernameEmptyTitle =>
      translate('search_username_empty_title');
  String get searchUsernameEmptySubtitle =>
      translate('search_username_empty_subtitle');
  String get userNotFound => translate('user_not_found');
  String get scanQrCode => translate('scan_qr_code');
  String get shareProfile => translate('share_profile');
  String get myQrCode => translate('my_qr_code');
  String get invalidQr => translate('invalid_qr');
  String get addMeOnSawalif => translate('add_me_on_sawalif');
  String get pointCameraAtQr => translate('point_camera_at_qr');
  String get scan => translate('scan');

  String get profile => translate('profile');
  String get editProfile => translate('edit_profile');
  String get bio => translate('bio');
  String get bioHint => translate('bio_hint');
  String get saveChanges => translate('save_changes');
  String get changePhoto => translate('change_photo');
  String get takePhoto => translate('take_photo');
  String get chooseGallery => translate('choose_gallery');
  String get joined => translate('joined');

  String get settings => translate('settings');
  String get language => translate('language');
  String get theme => translate('theme');
  String get darkMode => translate('dark_mode');
  String get lightMode => translate('light_mode');
  String get systemMode => translate('system_mode');
  String get notifications => translate('notifications');
  String get notificationsDesc => translate('notifications_desc');
  String get appVersion => translate('app_version');
  String get account => translate('account');
  String get appearance => translate('appearance');

  String get save => translate('save');
  String get cancel => translate('cancel');
  String get delete => translate('delete');
  String get confirm => translate('confirm');
  String get loading => translate('loading');
  String get error => translate('error');
  String get retry => translate('retry');
  String get back => translate('back');
  String get done => translate('done');
  String get or => translate('or');
  String get yes => translate('yes');
  String get no => translate('no');
  String get ok => translate('ok');

  String get errorLoading => translate('error_loading');
  String get errorSending => translate('error_sending');
  String get errorUploading => translate('error_uploading');
  String get noInternet => translate('no_internet');
  String get errorNoInternet => translate('error_no_internet');
  String get errorUnknown => translate('error_unknown');
  String get pageNotFound => translate('page_not_found');
  String get errorTimeout => translate('error_timeout');
  String get errorServer => translate('error_server');
  String get profileUpdated => translate('profile_updated');
  String get logoutConfirm => translate('logout_confirm');

  // ===== حالات فارغة =====
  String get emptyChatsTitle => translate('empty_chats_title');
  String get emptyChatsSubtitle => translate('empty_chats_subtitle');
  String get emptyMessagesTitle => translate('empty_messages_title');
  String get emptyMessagesSubtitle => translate('empty_messages_subtitle');
  String get emptySearchTitle => translate('empty_search_title');
  String get emptySearchSubtitle => translate('empty_search_subtitle');

  // ===== الوقت =====
  String get justNow => translate('just_now');
  String get minutesAgo => translate('minutes_ago');
  String get hoursAgo => translate('hours_ago');
  String get daysAgo => translate('days_ago');

  // ===== تأكيدات =====
  String get deleteMessageConfirm => translate('delete_message_confirm');
  String get deleteChatConfirm => translate('delete_chat_confirm');

  // ===== التحقق من صحة المدخلات =====
  String get fieldRequired => translate('field_required');
  String get invalidEmail => translate('invalid_email');
  String get passwordTooShort => translate('password_too_short');
  String get nameTooShort => translate('name_too_short');
  String get passwordsDontMatch => translate('passwords_dont_match');
  String get emailRequired => translate('email_required');
  String get passwordRequired => translate('password_required');
  String get nameRequired => translate('name_required');
  String get confirmPasswordRequired => translate('confirm_password_required');

  // ===== Auth error keys =====
  String get authUserNotFound => translate('auth_user_not_found');
  String get authEmailInUse => translate('auth_email_in_use');
  String get authTooManyRequests => translate('auth_too_many_requests');
  String get authUserDisabled => translate('auth_user_disabled');
  String get authInvalidCredential => translate('auth_invalid_credential');

  // ===== System message markers =====
  String get systemGroupCreated => translate('system_group_created');

  // ===== إجراءات =====
  String get markAsRead => translate('mark_as_read');
  String get muteNotifications => translate('mute_notifications');
  String get blockUser => translate('block_user');
  String get reportUser => translate('report_user');
  String get clearChat => translate('clear_chat');
  String get viewProfile => translate('view_profile');
  String get share => translate('share');
  String get forward => translate('forward');

  // ===== حالة الإرسال =====
  String get sending => translate('sending');
  String get seen => translate('seen');
  String get failed => translate('failed');

  // ===== الأذونات =====
  String get permissionCamera => translate('permission_camera');
  String get permissionStorage => translate('permission_storage');
  String get permissionNotifications => translate('permission_notifications');
  String get permissionDenied => translate('permission_denied');
  String get permissionCameraTitle => translate('permission_camera_title');
  String get permissionCameraMessage => translate('permission_camera_message');
  String get permissionGalleryTitle => translate('permission_gallery_title');
  String get permissionGalleryMessage => translate('permission_gallery_message');
  String get permissionDeniedSettings => translate('permission_denied_settings');
  String get openSettings => translate('open_settings');
  String get allow => translate('allow');

  // ===== Account =====
  String get accountSettings => translate('account_settings');
  String get changePassword => translate('change_password');
  String get currentPassword => translate('current_password');
  String get newPassword => translate('new_password');
  String get confirmNewPassword => translate('confirm_new_password');
  String get passwordChanged => translate('password_changed');
  String get wrongPassword => translate('wrong_password');
  String get reauthRequired => translate('reauth_required');
  String get passwordTooWeak => translate('password_too_weak');

  // ===== Email Verification =====
  String get emailNotVerified => translate('email_not_verified');
  String get verifyEmailMessage => translate('verify_email_message');
  String get verifyEmail => translate('verify_email');
  String get verificationSent => translate('verification_sent');
  String get resend => translate('resend');
  String get verifyNow => translate('verify_now');
  String get verifiedNow => translate('verified_now');
  String get notVerifiedYet => translate('not_verified_yet');

  // ===== Delete Account =====
  String get deleteAccount => translate('delete_account');
  String get deleteAccountWarning => translate('delete_account_warning');
  String get deleteAccountItems => translate('delete_account_items');
  String get typeToConfirm => translate('type_to_confirm');
  String get typeDeleteWord => translate('type_delete_word');
  String get accountDeleted => translate('account_deleted');
  String get deletionFailed => translate('deletion_failed');

  // ===== Choose Username =====
  String get chooseUsernameTitle => translate('choose_username_title');
  String get chooseUsernameSubtitle => translate('choose_username_subtitle');
  String get usernameCannotSkip => translate('username_cannot_skip');
  String get saveUsername => translate('save_username');

  // ===== About =====
  String get aboutApp => translate('about_app');
  String get aboutFeatures => translate('about_features');
  String get aboutDeveloper => translate('about_developer');
  String get visitWebsite => translate('visit_website');

  // ===== Notifications =====
  String get newMessage => translate('new_message');
  String get sentImage => translate('sent_image');

  // ===== Group Chats =====
  String get createGroup => translate('create_group');
  String get groupName => translate('group_name');
  String get groupDescription => translate('group_description');
  String get addMembers => translate('add_members');
  String get groupInfo => translate('group_info');
  String get groupMembers => translate('group_members');
  String get leaveGroup => translate('leave_group');
  String get groupAdmin => translate('group_admin');
  String get makeAdmin => translate('make_admin');
  String get removeMember => translate('remove_member');
  String get groupCreated => translate('group_created');
  String get leaveGroupConfirm => translate('leave_group_confirm');
  String get selectMembers => translate('select_members');
  String get minMembers => translate('min_members');

  // ===== Block & Report =====
  String get unblockUser => translate('unblock_user');
  String get blockedUsers => translate('blocked_users');
  String get noBlockedUsers => translate('no_blocked_users');
  String get blockConfirm => translate('block_confirm');
  String get userBlocked => translate('user_blocked');
  String get userUnblocked => translate('user_unblocked');
  String get reportMessage => translate('report_message');
  String get reportReason => translate('report_reason');
  String get reportInappropriate => translate('report_inappropriate');
  String get reportHarassment => translate('report_harassment');
  String get reportSpam => translate('report_spam');
  String get reportImpersonation => translate('report_impersonation');
  String get reportOther => translate('report_other');
  String get reportDetails => translate('report_details');
  String get submitReport => translate('submit_report');
  String get reportSubmitted => translate('report_submitted');

  // ===== Stories =====
  String get myStory => translate('my_story');
  String get addStory => translate('add_story');
  String get stories => translate('stories');
  String get noStories => translate('no_stories');
  String get storyCaption => translate('story_caption');
  String get postStory => translate('post_story');
  String get storyPosted => translate('story_posted');
  String get uploadingStory => translate('uploading_story');
  String get deleteStory => translate('delete_story');
  String get storyViewers => translate('story_viewers');
  String get addMoreImages => translate('add_more_images');
  String get viewMyStory => translate('view_my_story');
  String get addNewImage => translate('add_new_image');

  // ===== Search in Chat =====
  String get searchMessages => translate('search_messages');
  String get noSearchResults => translate('no_search_results');
  String get searchPlaceholder => translate('search_placeholder');
}

/// Delegate للترجمة
class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['ar', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
