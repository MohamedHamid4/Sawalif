# ============================================================================
# ProGuard/R8 rules for sawalif_app release builds.
# تُستخدم مع isMinifyEnabled + isShrinkResources لخفض حجم الـ APK.
# ============================================================================

# ----- Flutter -----
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }

# ----- Firebase / Google Play services -----
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# ----- Firestore (uses reflection for model serialization) -----
-keepclassmembers class * {
    @com.google.firebase.firestore.PropertyName <fields>;
    @com.google.firebase.firestore.PropertyName <methods>;
}

# ----- OneSignal -----
-keep class com.onesignal.** { *; }
-dontwarn com.onesignal.**

# ----- Kotlin -----
-keep class kotlin.** { *; }
-keep class kotlinx.** { *; }
-dontwarn kotlin.**
-dontwarn kotlinx.**
-keepclassmembers class kotlin.Metadata {
    public <methods>;
}

# ----- Gson / JSON serialization (for Firestore + REST) -----
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses
-keepattributes SourceFile,LineNumberTable

# ----- App models (prevent stripping data classes used via reflection) -----
-keep class com.example.sawalif_app.** { *; }

# ----- Suppress warnings on common transitive deps -----
-dontwarn org.jetbrains.annotations.**
-dontwarn javax.annotation.**
