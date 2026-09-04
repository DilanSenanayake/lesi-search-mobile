# Keep Flutter / plugin entry points when R8 minify is on.
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# flutter_secure_storage (EncryptedSharedPreferences / KeyStore)
-keep class com.it_nomads.fluttersecurestorage.** { *; }
-keep class androidx.security.crypto.** { *; }
-dontwarn androidx.security.crypto.**

# WebView / AndroidX fragments used by webview_flutter
-keep class androidx.webkit.** { *; }
-keep class io.flutter.plugins.webviewflutter.** { *; }

# Play Core / deferred components noise from Flutter tooling (harmless)
-dontwarn com.google.android.play.core.**
