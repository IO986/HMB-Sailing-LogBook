# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.embedding.** { *; }
-dontwarn io.flutter.embedding.**

# flutter_secure_storage
-keep class androidx.security.crypto.** { *; }

# flutter_background_service
-keep class id.flutter.flutter_background_service.** { *; }

# Kotlin internals
-keep class kotlin.** { *; }
-keepclassmembers class **$WhenMappings { <fields>; }

# Debug info
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception
