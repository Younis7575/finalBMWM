# Flutter and Dart
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.embedding.engine.FlutterEngine
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }

# Keep all annotations
-keepattributes *Annotation*

# Gson / JSON serialization
-keep class com.google.gson.** { *; }
-dontwarn com.google.gson.**

# Retrofit / OkHttp (if used)
-keep class retrofit2.** { *; }
-dontwarn retrofit2.**
-keep class okhttp3.** { *; }
-dontwarn okhttp3.**

# Firebase / Play Services (if used)
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# Glide (if used)
-keep class com.bumptech.glide.** { *; }
-dontwarn com.bumptech.glide.**

# Prevent warnings for generated classes
-dontwarn sun.misc.**
-dontwarn javax.annotation.**
-dontwarn org.codehaus.mojo.**

# --- Flutter / Play Core dependencies ---
-keep class com.google.android.play.core.tasks.** { *; }
-dontwarn com.google.android.play.core.tasks.**

-keep class com.google.android.play.core.assetpacks.** { *; }
-dontwarn com.google.android.play.core.assetpacks.**

-keep class com.google.android.play.core.splitinstall.** { *; }
-dontwarn com.google.android.play.core.splitinstall.**
