# Flutter/Android host keeps and warnings
-keep class io.flutter.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.**

# If you use libraries that rely on reflection, keep their models as needed.
# Examples (uncomment if used):
# -keep class com.google.gson.** { *; }
# -keep class okhttp3.** { *; }
# -dontwarn okhttp3.**

# Keep Kotlin metadata (generally safe)
-keep class kotlin.Metadata { *; }

