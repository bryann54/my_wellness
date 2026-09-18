# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.embedding.android.** { *; }
-keep class io.flutter.embedding.engine.** { *; }
-dontwarn io.flutter.embedding.**

# Keep MainActivity
-keep class com.seed4va.mywellness.** { *; }
-keep class com.seed4va.mywellness.MainActivity { *; }

# Flutter plugins
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.plugins.**

# Kotlin
-keep class kotlin.** { *; }
-keep class kotlinx.** { *; }
-dontwarn kotlin.**

# Google
-keep class com.google.** { *; }
-dontwarn com.google.**

# Firebase
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Gson / serialization
-keepattributes Signature
-keepattributes *Annotation*
-keep class sun.misc.Unsafe { *; }

# Dio / Retrofit / OkHttp
-dontwarn okhttp3.**
-dontwarn okio.**
-keep class okhttp3.** { *; }
-keep class okio.** { *; }