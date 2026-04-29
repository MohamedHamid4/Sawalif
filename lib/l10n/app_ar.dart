/// الترجمات العربية لتطبيق سوالف
const Map<String, String> appAr = {
  // ===== التطبيق =====
  'app_name': 'سوالف ✨',
  'app_subtitle': 'تواصل بسهولة وأمان',
  // legacy alias (لتوافق العكسي - يستخدم نفس قيمة app_subtitle)
  'app_tagline': 'تواصل بسهولة وأمان',

  // ===== المصادقة =====
  'login': 'تسجيل الدخول',
  'signup': 'إنشاء حساب',
  'logout': 'تسجيل الخروج',
  'email': 'البريد الإلكتروني',
  'password': 'كلمة المرور',
  'confirm_password': 'تأكيد كلمة المرور',
  'name': 'الاسم الكامل',
  'forgot_password': 'نسيت كلمة المرور؟',
  'sign_in_google': 'المتابعة بـ Google',
  'dont_have_account': 'ليس لديك حساب؟ ',
  'have_account': 'لديك حساب بالفعل؟ ',
  'create_account': 'إنشاء حساب',
  'reset_password': 'إعادة تعيين كلمة المرور',
  'reset_password_desc': 'أدخل بريدك الإلكتروني وسنرسل لك رابط إعادة التعيين.',
  'send_reset_link': 'إرسال الرابط',
  'reset_link_sent': 'تم إرسال الرابط! تحقق من بريدك الإلكتروني.',
  'email_hint': 'بريدك@الإلكتروني.com',
  'password_hint': '6 أحرف على الأقل',
  'name_hint': 'اسمك الكامل',
  'username': 'اسم المستخدم',
  'username_hint': 'مثلاً: mohamed_2024',
  'username_required': 'اسم المستخدم مطلوب',
  'username_invalid': 'حروف صغيرة وأرقام و _ فقط',
  'username_too_short': 'قصير جداً (3 أحرف على الأقل)',
  'username_too_long': 'طويل جداً (20 حرف كحد أقصى)',
  'username_taken': 'اسم المستخدم محجوز',
  'username_reserved': 'اسم المستخدم محجوز للنظام',
  'username_available': 'متاح ✓',
  'checking_username': 'جاري التحقق...',

  // ===== الإعداد التعريفي =====
  'onboarding_skip': 'تخطي',
  'onboarding_next': 'التالي',
  'onboarding_start': 'ابدأ الآن',
  'onboarding1_title': 'أهلاً بك في سوالف 👋',
  'onboarding1_desc': 'تواصل مع أصدقائك وشارك أحاديثاً دافئة في أي وقت وأي مكان.',
  'onboarding2_title': 'تواصل بسهولة 💬',
  'onboarding2_desc': 'أرسل نصوصاً وصوراً وردود فعل بتجربة سلسة وعصرية.',
  'onboarding3_title': 'خاص وآمن 🔒',
  'onboarding3_desc': 'محادثاتك محمية. أنت وأصدقاؤك فقط من يستطيع رؤيتها.',

  // ===== المحادثات =====
  'chats': 'المحادثات',
  'new_chat': 'محادثة جديدة',
  'no_chats': 'لا توجد محادثات بعد',
  'no_chats_desc': 'ابدأ محادثة جديدة وتواصل مع أصدقائك',
  'start_chat': 'ابدأ محادثة',
  'search_chats': 'ابحث في المحادثات...',

  // ===== شاشة المحادثة =====
  'type_message': 'اكتب رسالة...',
  'send': 'إرسال',
  'online': 'متصل',
  'offline': 'غير متصل',
  'last_seen': 'آخر ظهور',
  'typing': 'يكتب...',
  'message_deleted': 'تم حذف هذه الرسالة',
  'delete_message': 'حذف',
  'reply': 'رد',
  'copy': 'نسخ',
  'react': 'تفاعل',
  'reply_to': 'رداً على',
  'cancel_reply': 'إلغاء',
  'send_image': 'إرسال صورة',
  'image': '📷 صورة',

  // ===== علامات القراءة =====
  'sent': 'مرسل',
  'delivered': 'تم التسليم',
  'read': 'تمت القراءة',

  // ===== المستخدمون =====
  'users': 'الأشخاص',
  'search_users': 'ابحث بالاسم...',
  'no_users': 'لا يوجد مستخدمون',
  'add_friend': 'إضافة صديق',
  'search_by_username': 'البحث بـ @username',
  'search_username_hint': 'أدخل @username للبحث',
  'search_username_empty_title': 'ابحث بـ @username',
  'search_username_empty_subtitle': 'اكتب اسم المستخدم لإيجاد الصديق',
  'user_not_found': 'المستخدم غير موجود',
  'scan_qr_code': 'مسح QR Code',
  'share_profile': 'مشاركة الملف الشخصي',
  'my_qr_code': 'QR الخاص بي',
  'invalid_qr': 'QR Code غير صالح',
  'add_me_on_sawalif': 'أضفني على سوالف!',
  'point_camera_at_qr': 'وجّه الكاميرا نحو رمز QR',
  'scan': 'مسح',

  // ===== الملف الشخصي =====
  'profile': 'الملف الشخصي',
  'edit_profile': 'تعديل الملف الشخصي',
  'bio': 'نبذة عني',
  'bio_hint': 'أخبرنا عن نفسك...',
  'save_changes': 'حفظ التغييرات',
  'change_photo': 'تغيير الصورة',
  'take_photo': 'التقاط صورة',
  'choose_gallery': 'اختيار من المعرض',
  'joined': 'انضم في',

  // ===== الإعدادات =====
  'settings': 'الإعدادات',
  'language': 'اللغة',
  'theme': 'المظهر',
  'dark_mode': 'الوضع الداكن',
  'light_mode': 'الوضع الفاتح',
  'system_mode': 'تابع للنظام',
  'notifications': 'الإشعارات',
  'notifications_desc': 'استقبال إشعارات الرسائل',
  'app_version': 'إصدار التطبيق',
  'account': 'الحساب',
  'appearance': 'المظهر',

  // ===== عام =====
  'save': 'حفظ',
  'cancel': 'إلغاء',
  'delete': 'حذف',
  'confirm': 'تأكيد',
  'loading': 'جاري التحميل...',
  'error': 'خطأ',
  'retry': 'إعادة المحاولة',
  'back': 'رجوع',
  'done': 'تم',
  'or': 'أو',
  'yes': 'نعم',
  'no': 'لا',
  'ok': 'حسناً',

  // ===== أخطاء =====
  'error_loading': 'فشل تحميل البيانات',
  'error_sending': 'فشل إرسال الرسالة',
  'error_uploading': 'فشل رفع الصورة',
  'no_internet': 'تحقق من اتصالك بالإنترنت',
  'error_no_internet': 'لا يوجد اتصال بالإنترنت',
  'error_unknown': 'حدث خطأ غير متوقع',
  'page_not_found': 'الصفحة غير موجودة',
  'error_timeout': 'انتهت مهلة الاتصال',
  'error_server': 'خطأ في الخادم، حاول لاحقاً',
  'profile_updated': 'تم تحديث الملف الشخصي',
  'logout_confirm': 'هل تريد تسجيل الخروج؟',

  // ===== حالات فارغة =====
  'empty_chats_title': 'لا توجد محادثات بعد',
  'empty_chats_subtitle': 'ابدأ محادثة جديدة وتواصل مع أصدقائك',
  'empty_messages_title': 'لا توجد رسائل بعد',
  'empty_messages_subtitle': 'كن أول من يبدأ المحادثة!',
  'empty_search_title': 'لا توجد نتائج',
  'empty_search_subtitle': 'جرب كلمة بحث مختلفة',

  // ===== الوقت =====
  'just_now': 'الآن',
  'minutes_ago': 'منذ دقائق',
  'hours_ago': 'منذ ساعات',
  'days_ago': 'منذ أيام',

  // ===== تأكيدات =====
  'delete_message_confirm': 'هل تريد حذف هذه الرسالة؟',
  'delete_chat_confirm': 'هل تريد حذف هذه المحادثة؟',

  // ===== التحقق من صحة المدخلات =====
  'field_required': 'هذا الحقل مطلوب',
  'invalid_email': 'البريد الإلكتروني غير صالح',
  'password_too_short': 'كلمة المرور يجب أن تكون 6 أحرف على الأقل',
  'name_too_short': 'الاسم يجب أن يكون حرفين على الأقل',
  'passwords_dont_match': 'كلمتا المرور غير متطابقتين',
  'email_required': 'البريد الإلكتروني مطلوب',
  'password_required': 'كلمة المرور مطلوبة',
  'name_required': 'الاسم مطلوب',
  'confirm_password_required': 'تأكيد كلمة المرور مطلوب',
  // ===== رسائل أخطاء المصادقة (مفاتيح ترجمة) =====
  'auth_user_not_found': 'لا يوجد مستخدم بهذا البريد الإلكتروني',
  'auth_email_in_use': 'البريد الإلكتروني مستخدم مسبقاً',
  'auth_too_many_requests': 'محاولات كثيرة، حاول لاحقاً',
  'auth_user_disabled': 'هذا الحساب معطّل',
  'auth_invalid_credential': 'البريد الإلكتروني أو كلمة المرور غير صحيحة',
  // ===== رسائل النظام (group/message markers) =====
  'system_group_created': 'تم إنشاء المجموعة',

  // ===== إجراءات =====
  'mark_as_read': 'تعليم كمقروء',
  'mute_notifications': 'كتم الإشعارات',
  'block_user': 'حظر المستخدم',
  'report_user': 'الإبلاغ عن المستخدم',
  'clear_chat': 'مسح المحادثة',
  'view_profile': 'عرض الملف الشخصي',
  'share': 'مشاركة',
  'forward': 'إعادة توجيه',

  // ===== حالة الإرسال =====
  'sending': 'جاري الإرسال...',
  'seen': 'مقروء',
  'failed': 'فشل الإرسال',

  // ===== الأذونات =====
  'permission_camera': 'يحتاج التطبيق إذن الكاميرا لالتقاط الصور',
  'permission_storage': 'يحتاج التطبيق إذن التخزين للوصول إلى الصور',
  'permission_notifications': 'يحتاج التطبيق إذن الإشعارات لإعلامك بالرسائل الجديدة',
  'permission_denied': 'تم رفض الإذن',
  'permission_camera_title': 'إذن الكاميرا',
  'permission_camera_message': 'يحتاج التطبيق للكاميرا لمسح رموز QR والتقاط الصور',
  'permission_gallery_title': 'إذن المعرض',
  'permission_gallery_message': 'يحتاج التطبيق للوصول للصور لمشاركتها',
  'permission_denied_settings': 'يرجى تفعيل الصلاحية من الإعدادات',
  'open_settings': 'فتح الإعدادات',
  'allow': 'السماح',

  // ===== إعدادات الحساب =====
  'account_settings': 'إعدادات الحساب',
  'change_password': 'تغيير كلمة المرور',
  'current_password': 'كلمة المرور الحالية',
  'new_password': 'كلمة المرور الجديدة',
  'confirm_new_password': 'تأكيد كلمة المرور الجديدة',
  'password_changed': 'تم تغيير كلمة المرور',
  'wrong_password': 'كلمة المرور الحالية خاطئة',
  'reauth_required': 'يرجى تأكيد هويتك',
  'password_too_weak': 'كلمة المرور ضعيفة',

  // ===== تأكيد البريد =====
  'email_not_verified': 'البريد الإلكتروني غير مؤكد',
  'verify_email_message': 'يرجى تأكيد بريدك الإلكتروني',
  'verify_email': 'تأكيد البريد',
  'verification_sent': 'تم إرسال إيميل التأكيد',
  'resend': 'إعادة إرسال',
  'verify_now': 'تحقق الآن',
  'verified_now': '✅ تم تأكيد بريدك الإلكتروني',
  'not_verified_yet': 'لم يتم التأكيد بعد. افتح الرابط في بريدك ثم أعد المحاولة',

  // ===== حذف الحساب =====
  'delete_account': 'حذف الحساب',
  'delete_account_warning':
      'سيتم حذف حسابك وجميع بياناتك بشكل نهائي. لا يمكن التراجع عن هذا الإجراء.',
  'delete_account_items':
      'سيتم حذف:\n• حسابك\n• اسم المستخدم الخاص بك\n• معلومات ملفك الشخصي\n• جميع بياناتك',
  'type_to_confirm': 'اكتب "حذف" للتأكيد',
  'type_delete_word': 'حذف',
  'account_deleted': 'تم حذف الحساب',
  'deletion_failed': 'فشل حذف الحساب',

  // ===== اختيار اسم المستخدم (للمستخدمين القدامى) =====
  'choose_username_title': 'اختر اسم المستخدم',
  'choose_username_subtitle':
      'هذا الاسم سيُستخدم لإيجادك بواسطة الأصدقاء',
  'username_cannot_skip': 'لا يمكن تخطي هذه الخطوة',
  'save_username': 'حفظ',

  // ===== عن التطبيق =====
  'about_app': 'عن التطبيق',
  'about_features': 'المميزات',
  'about_developer': 'المطوّر',
  'visit_website': 'زيارة الموقع',

  // ===== الإشعارات =====
  'new_message': 'رسالة جديدة',
  'sent_image': 'أرسل صورة',

  // ===== المجموعات =====
  'create_group': 'إنشاء مجموعة',
  'group_name': 'اسم المجموعة',
  'group_description': 'وصف المجموعة',
  'add_members': 'إضافة أعضاء',
  'group_info': 'معلومات المجموعة',
  'group_members': 'الأعضاء',
  'leave_group': 'مغادرة المجموعة',
  'group_admin': 'مشرف',
  'make_admin': 'جعله مشرفاً',
  'remove_member': 'إزالة العضو',
  'group_created': 'تم إنشاء المجموعة',
  'leave_group_confirm': 'هل أنت متأكد من مغادرة المجموعة؟',
  'select_members': 'اختر الأعضاء',
  'min_members': 'يجب اختيار عضو واحد على الأقل',

  // ===== الحظر والإبلاغ =====
  'unblock_user': 'إلغاء الحظر',
  'blocked_users': 'المستخدمون المحظورون',
  'no_blocked_users': 'لا يوجد مستخدمون محظورون',
  'block_confirm': 'هل تريد حظر هذا المستخدم؟',
  'user_blocked': 'تم حظر المستخدم',
  'user_unblocked': 'تم إلغاء الحظر',
  'report_message': 'الإبلاغ عن الرسالة',
  'report_reason': 'سبب الإبلاغ',
  'report_inappropriate': 'محتوى غير لائق',
  'report_harassment': 'إساءة أو تنمر',
  'report_spam': 'رسائل مزعجة',
  'report_impersonation': 'انتحال شخصية',
  'report_other': 'سبب آخر',
  'report_details': 'تفاصيل إضافية (اختياري)',
  'submit_report': 'إرسال البلاغ',
  'report_submitted': 'تم إرسال البلاغ',

  // ===== الحالات (Stories) =====
  'my_story': 'حالتي',
  'add_story': 'إضافة حالة',
  'stories': 'الحالات',
  'no_stories': 'لا توجد حالات',
  'story_caption': 'أضف تعليقاً (اختياري)',
  'post_story': 'نشر',
  'story_posted': 'تم نشر الحالة',
  'uploading_story': 'جاري رفع الحالة...',
  'delete_story': 'حذف الحالة',
  'story_viewers': 'المشاهدات',
  'add_more_images': 'إضافة المزيد',
  'view_my_story': 'عرض حالتي',
  'add_new_image': 'إضافة صورة جديدة',

  // ===== البحث في الرسائل =====
  'search_messages': 'البحث في الرسائل',
  'no_search_results': 'لا توجد نتائج',
  'search_placeholder': 'ابحث عن رسالة...',
};
