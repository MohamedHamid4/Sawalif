# سوالف ✨ | Sawalif

> تطبيق محادثة اجتماعي دافئ بألوان البرتقالي والأحمر  
> A warm social chat app built with Flutter + Firebase

---

## 📋 المتطلبات | Requirements

- Flutter SDK `>=3.7.0`
- Dart SDK `>=3.7.0`
- Firebase Project (مجاني)
- Android Studio / VS Code

---

## 🚀 خطوات الإعداد | Setup Steps

### 1. تثبيت المكتبات
```bash
flutter pub get
```

### 2. إعداد الخطوط (مطلوب)

قم بتنزيل الخطوط من Google Fonts ووضعها في المجلدات الصحيحة:

**Cairo (للعربي):** https://fonts.google.com/specimen/Cairo
```
assets/fonts/Cairo/
├── Cairo-Regular.ttf
├── Cairo-SemiBold.ttf
└── Cairo-Bold.ttf
```

**Poppins (للإنجليزي):** https://fonts.google.com/specimen/Poppins
```
assets/fonts/Poppins/
├── Poppins-Regular.ttf
├── Poppins-SemiBold.ttf
└── Poppins-Bold.ttf
```

### 3. إعداد Lottie Animations

قم بتنزيل ملفات Lottie المجانية من [LottieFiles](https://lottiefiles.com) ووضعها في `assets/animations/`:

| الملف | الوصف | اقتراح البحث |
|-------|-------|-------------|
| `onboarding_chat.json` | شاشة تعريف 1 | "chat friends" |
| `onboarding_connect.json` | شاشة تعريف 2 | "connect people" |
| `onboarding_secure.json` | شاشة تعريف 3 | "secure lock" |
| `empty_chats.json` | لا توجد محادثات | "empty inbox" |
| `empty_messages.json` | لا توجد رسائل | "no messages" |
| `empty_search.json` | لا نتائج بحث | "not found" |
| `loading.json` | تحميل عام | "loading dots" |

### 4. إعداد Firebase

#### أ. إنشاء مشروع Firebase
1. اذهب إلى [Firebase Console](https://console.firebase.google.com)
2. أنشئ مشروعاً جديداً باسم `sawalif-app`
3. فعّل **Authentication** > Email/Password + Google
4. فعّل **Firestore Database** في وضع Test Mode
5. فعّل **Storage**
6. فعّل **Cloud Messaging**

#### ب. توليد firebase_options.dart
```bash
# تثبيت Firebase CLI
npm install -g firebase-tools

# تسجيل الدخول
firebase login

# تثبيت FlutterFire CLI
dart pub global activate flutterfire_cli

# توليد الملف
flutterfire configure
```

#### ج. رفع قواعد الأمان
```bash
firebase deploy --only firestore:rules
firebase deploy --only storage
```

### 5. إعداد Google Sign-In (Android)

أضف إلى `android/app/build.gradle`:
```gradle
// داخل defaultConfig
minSdkVersion 21
```

احصل على SHA-1 fingerprint:
```bash
cd android && ./gradlew signingReport
```
أضفه في Firebase Console > Project Settings > Android App.

### 6. إعداد FCM (Android)

في `android/app/src/main/AndroidManifest.xml` تأكد من وجود:
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.VIBRATE" />
```

### 7. تشغيل التطبيق
```bash
flutter run
```

---

## 🏗️ هيكل المشروع | Project Structure

```
lib/
├── core/                    # ثوابت، ثيم، أدوات مشتركة
│   ├── constants/           # ألوان، أبعاد، مسارات assets
│   ├── theme/               # Light & Dark themes
│   ├── utils/               # مدققات، تنسيق تاريخ، SnackBar
│   ├── extensions/          # امتدادات Context & String
│   └── routes/              # مسارات التنقل مع أنيميشنز
│
├── data/                    # طبقة البيانات
│   ├── models/              # UserModel, MessageModel, ChatModel
│   ├── services/            # Firebase Auth/Firestore/Storage/FCM
│   └── repositories/        # وسيط بين Services و ViewModels
│
├── viewmodels/              # MVVM - منطق الأعمال
│   ├── auth_viewmodel.dart
│   ├── theme_viewmodel.dart
│   ├── locale_viewmodel.dart
│   ├── chats_viewmodel.dart
│   ├── chat_viewmodel.dart
│   ├── users_viewmodel.dart
│   ├── profile_viewmodel.dart
│   └── settings_viewmodel.dart
│
├── views/                   # الشاشات (UI فقط)
│   ├── splash/
│   ├── onboarding/
│   ├── auth/
│   ├── chats/
│   ├── chat/
│   ├── users/
│   ├── profile/
│   └── settings/
│
├── widgets/                 # Widgets مشتركة وأنيميشنز
│   ├── common/
│   └── animations/
│
├── l10n/                    # ترجمات عربي/إنجليزي
├── firebase_options.dart    # ⚠️ يحتاج flutterfire configure
└── main.dart                # نقطة الدخول + MultiProvider
```

---

## 🎨 الألوان | Color Palette

| اللون | Hex | الاستخدام |
|-------|-----|---------|
| Primary | `#FF6B35` | الأزرار، الـ Gradient الرئيسي |
| Secondary | `#E63946` | Gradient النهاية |
| Accent | `#FFB627` | لمسات ذهبية |
| Success | `#06D6A0` | Online status، نجاح |
| Light BG | `#FFF8F3` | خلفية الوضع الفاتح |
| Dark BG | `#1A0F0A` | خلفية الوضع الداكن |

---

## 📦 المكتبات | Dependencies

| المكتبة | الغرض |
|---------|-------|
| `firebase_core` | تهيئة Firebase |
| `firebase_auth` | المصادقة |
| `cloud_firestore` | قاعدة البيانات |
| `firebase_storage` | رفع الصور |
| `firebase_messaging` | الإشعارات |
| `google_sign_in` | تسجيل الدخول بـ Google |
| `provider` | State Management (MVVM) |
| `cached_network_image` | تخزين مؤقت للصور |
| `image_picker` | اختيار الصور |
| `shimmer` | Loading Shimmer |
| `lottie` | أنيميشنز Lottie |
| `flutter_staggered_animations` | أنيميشنز متتابعة |
| `smooth_page_indicator` | مؤشر الصفحات |
| `intl` | تنسيق التواريخ |
| `shared_preferences` | حفظ الإعدادات محلياً |
| `flutter_local_notifications` | إشعارات محلية |
| `uuid` | توليد IDs فريدة |
| `permission_handler` | إدارة الأذونات |

---

## 🔥 Firestore Schema

### `users/{uid}`
```json
{
  "uid": "string",
  "name": "string",
  "email": "string",
  "photoUrl": "string",
  "bio": "string",
  "isOnline": true,
  "lastSeen": "timestamp",
  "createdAt": "timestamp",
  "fcmToken": "string"
}
```

### `chats/{chatId}`
`chatId` = `uid1_uid2` (مرتبة أبجدياً)
```json
{
  "participants": ["uid1", "uid2"],
  "lastMessage": "string",
  "lastMessageTime": "timestamp",
  "lastSenderId": "string",
  "unreadCount": {"uid1": 0, "uid2": 2},
  "typing": {"uid1": false, "uid2": true}
}
```

### `chats/{chatId}/messages/{messageId}`
```json
{
  "senderId": "string",
  "senderName": "string",
  "content": "string",
  "type": "text | image",
  "timestamp": "timestamp",
  "status": "sent | delivered | read",
  "imageUrl": "string | null",
  "replyToId": "string | null",
  "replyToContent": "string | null",
  "reactions": ["uid:emoji"],
  "isDeleted": false
}
```

---

## 🌍 اللغات | Localization

- **العربية** (افتراضي) - RTL
- **الإنجليزية** - LTR

لإضافة لغة جديدة:
1. أضف ملفاً في `lib/l10n/app_XX.dart`
2. أضف اللغة في `AppLocalizations.supportedLocales`

---

## 📱 الميزات | Features

- ✅ تسجيل دخول Email/Password
- ✅ تسجيل دخول بـ Google
- ✅ نسيت كلمة المرور
- ✅ محادثات فورية Real-time
- ✅ إرسال صور
- ✅ الرد على رسائل
- ✅ ردود فعل بإيموجي
- ✅ حذف الرسائل
- ✅ مؤشر "يكتب الآن"
- ✅ علامات القراءة ✓ ✓✓
- ✅ حالة Online/Offline
- ✅ Splash + Onboarding
- ✅ Dark/Light/System Theme
- ✅ عربي/إنجليزي + RTL
- ✅ Shimmer Loading
- ✅ Empty States بـ Lottie
- ✅ Firebase Cloud Messaging

---

## 👨‍💻 المطور

بُني بـ Flutter + Firebase + MVVM Architecture  
للأسئلة والمساهمات، افتح Issue على GitHub.
