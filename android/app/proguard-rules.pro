-keep class com.dexguard.** { *; }
-keep class class_surrogates.** { *; }
-keep class encrypted.** { *; }

-keepattributes Signature,*Annotation*,EnclosingMethod,InnerClasses
-keepclassmembers class * {
    @org.json.JSONObject *;
}
-dontwarn com.google.crypto.tink.**
