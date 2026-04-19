# Razorpay Custom Rules
-keep class com.razorpay.** { *; }
-dontwarn com.razorpay.**
-keepattributes Signature
-keepattributes *Annotation*
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**
-keep class org.json.** { *; }
-keep interface android.webkit.JavascriptInterface

# Flutter Wrappers
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Fix for Google Play Core / Split Install Missing Classes
-dontwarn com.google.android.play.core.splitcompat.**
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**
-keep class com.google.android.play.core.splitcompat.** { *; }
-keep class com.google.android.play.core.splitinstall.** { *; }
-keep class com.google.android.play.core.tasks.** { *; }

# ✅ ADD THIS: Facebook SDK (App Events)
-keep class com.facebook.** { *; }
-keepattributes Signature

# If you use the bidding features/mediation
-keep class com.google.ads.mediation.facebook.** { *; }