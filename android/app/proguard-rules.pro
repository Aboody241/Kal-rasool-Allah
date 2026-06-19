# Flutter local notifications and Gson obfuscation rules
-keepattributes Signature
-keepattributes *Annotation*

# Prevent R8/ProGuard from stripping generic types and signatures needed by Gson
-keep class * implements com.google.gson.TypeAdapter
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# Prevent obfuscation of flutter_local_notifications classes
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-keep class com.google.gson.** { *; }
