# 🤖 Android Build & Launch Diagnostic Guide
**Ma'a yegue - Résolution du problème de lancement Android**

---

## 🔍 Problème Signalé

**Symptôme**: `flutter run` compile correctement le projet mais ne le lance pas sur l'appareil Android. Le processus reste bloqué pendant environ 1 heure sans démarrer l'application.

---

## ✅ Checklist de Diagnostic

### 1. Vérification de Base

```powershell
# 1. Vérifier que l'appareil est connecté
flutter devices

# 2. Vérifier ADB
adb devices

# 3. Redémarrer ADB si nécessaire
adb kill-server
adb start-server

# 4. Lancer avec logs verbeux
flutter run -v
```

### 2. Nettoyage du Projet

```powershell
# Nettoyer le build
flutter clean

# Supprimer le dossier build
Remove-Item -Recurse -Force build

# Récupérer les dépendances
flutter pub get

# Rebuild
flutter run
```

### 3. Vérification des Permissions Android

#### Fichier: `android/app/src/main/AndroidManifest.xml`

Vérifier que ces permissions sont présentes :

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Permissions Internet -->
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
    
    <!-- Permissions Firebase -->
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
    <uses-permission android:name="android.permission.VIBRATE"/>
    
    <!-- Permissions Storage (pour SQLite) -->
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
    
    <!-- Permissions Device Info -->
    <uses-permission android:name="android.permission.READ_PHONE_STATE" />
    
    <application
        android:name="${applicationName}"
        android:label="Ma'a yegue"
        android:icon="@mipmap/ic_launcher"
        android:usesCleartextTraffic="true">
        
        <!-- ... -->
    </application>
</manifest>
```

### 4. Vérification Gradle

#### Fichier: `android/app/build.gradle.kts`

```kotlin
android {
    namespace = "com.example.maa_yegue"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    defaultConfig {
        applicationId = "com.example.maa_yegue"
        minSdk = 21  // ← Vérifier que c'est au moins 21
        targetSdk = flutter.targetSdkVersion
        versionCode = flutterVersionCode.toInt()
        versionName = flutterVersionName
        multiDexEnabled = true  // ← Important pour Firebase
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}
```

### 5. Vérification Google Services

#### Fichier: `android/app/google-services.json`

```powershell
# Vérifier que le fichier existe
Test-Path android/app/google-services.json

# Si absent, télécharger depuis Firebase Console
# Firebase Console → Project Settings → Download google-services.json
```

#### Fichier: `android/build.gradle.kts`

Vérifier la présence du plugin:

```kotlin
dependencies {
    classpath("com.android.tools.build:gradle:8.1.0")
    classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.8.0")
    classpath("com.google.gms:google-services:4.4.0")  // ← Important
}
```

### 6. Diagnostic Avancé

#### A. Vérifier les logs en temps réel

```powershell
# Terminal 1: Lancer l'app
flutter run -v

# Terminal 2 (simultanément): Voir les logs Android
flutter logs

# Ou directement avec adb
adb logcat | Select-String -Pattern "flutter"
```

#### B. Construire APK manuellement

```powershell
# Construire l'APK
flutter build apk --debug

# Installer manuellement
adb install build/app/outputs/flutter-apk/app-debug.apk

# Lancer manuellement
adb shell am start -n com.example.maa_yegue/.MainActivity
```

#### C. Vérifier l'espace disque

```powershell
# Sur l'appareil
adb shell df /data

# Si espace insuffisant, nettoyer
adb shell pm clear com.example.maa_yegue
```

### 7. Problèmes Connus Firebase

#### Multidex Obligatoire

Avec Firebase, multidex est **OBLIGATOIRE**:

```kotlin
// android/app/build.gradle.kts
defaultConfig {
    multiDexEnabled = true
}

dependencies {
    implementation("androidx.multidex:multidex:2.0.1")
}
```

#### ProGuard pour Release

```kotlin
buildTypes {
    release {
        // Ajouter les règles ProGuard
        proguardFiles(
            getDefaultProguardFile("proguard-android-optimize.txt"),
            "proguard-rules.pro"
        )
    }
}
```

#### Fichier: `android/app/proguard-rules.pro`

```proguard
# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# SQLite
-keep class org.sqlite.** { *; }
-keep class org.sqlite.database.** { *; }

# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
```

---

## 🚨 Solutions par Symptôme

### Symptôme 1: "Waiting for observatory port..."

**Causes possibles**:
- Pare-feu bloque la communication
- Émulateur mal configuré

**Solutions**:
```powershell
# 1. Désactiver pare-feu temporairement
# 2. Redémarrer l'émulateur
# 3. Utiliser un appareil physique

# Tester connexion réseau
flutter run --disable-service-auth-codes
```

### Symptôme 2: "Lost connection to device"

**Solutions**:
```powershell
# 1. Vérifier câble USB
# 2. Activer "Rester éveillé" sur appareil
# 3. Désactiver "Optimisation batterie" pour ADB

# Augmenter timeout
flutter run --device-timeout=120
```

### Symptôme 3: "Gradle build failed"

**Solutions**:
```powershell
# 1. Nettoyer Gradle cache
cd android
./gradlew clean
cd ..

# 2. Supprimer .gradle
Remove-Item -Recurse android/.gradle

# 3. Rebuild
flutter build apk
```

### Symptôme 4: "Application installation failed"

**Solutions**:
```powershell
# 1. Désinstaller ancienne version
adb uninstall com.example.maa_yegue

# 2. Réinstaller
flutter run

# 3. Si signature error
# Supprimer: android/app/debug.keystore
# Flutter le recréera
```

---

## 🔧 Configuration Optimale pour Développement

### local.properties

```properties
sdk.dir=C:\\Users\\YourUsername\\AppData\\Local\\Android\\sdk
flutter.sdk=C:\\Users\\YourUsername\\flutter
flutter.buildMode=debug
flutter.versionName=1.0.0
flutter.versionCode=1
```

### gradle.properties

```properties
org.gradle.jvmargs=-Xmx2048m -XX:MaxMetaspaceSize=512m
android.useAndroidX=true
android.enableJetifier=true
```

---

## 📱 Test sur Émulateur vs Appareil Physique

### Émulateur (Recommandé pour debug)

```powershell
# Créer un émulateur optimisé
flutter emulators --create

# Lancer
flutter emulators --launch <emulator_id>

# Puis
flutter run
```

### Appareil Physique

1. Activer "Options développeur"
2. Activer "Débogage USB"
3. Autoriser l'ordinateur
4. Vérifier: `flutter devices`

---

## ⚡ Mode Release (Production)

```powershell
# Construire APK release
flutter build apk --release

# Construire App Bundle (pour Play Store)
flutter build appbundle --release

# Installer APK release
adb install build/app/outputs/flutter-apk/app-release.apk
```

---

## 🎯 Commandes de Diagnostic Rapide

```powershell
# Tout-en-un diagnostic
flutter doctor -v
flutter pub get
flutter clean
flutter run -v --device-id=<DEVICE_ID>

# Si toujours bloqué
flutter run --trace-startup
```

---

## 📊 Vérification Post-Correction

Une fois l'app lancée, vérifier:

✅ Splash screen s'affiche  
✅ Base de données SQLite s'initialise  
✅ Connexion Firebase réussie  
✅ Pas d'erreurs dans logs  
✅ Navigation fonctionne  

```powershell
# Vérifier logs en temps réel
flutter logs | Select-String "Database|Firebase|Error"
```

---

## 🆘 Dernier Recours

Si rien ne fonctionne:

```powershell
# 1. Réinitialisation complète
flutter clean
Remove-Item -Recurse -Force build
Remove-Item -Recurse -Force android/.gradle
Remove-Item -Recurse -Force android/app/build

# 2. Recréer projet Flutter (extrême)
# Sauvegarder lib/ et pubspec.yaml
# Puis:
# flutter create --org com.example new_project
# Copier lib/ et pubspec.yaml
# Migrer android/ configs

# 3. Mettre à jour Flutter
flutter upgrade
flutter doctor
```

---

## 📞 Logs Importants à Collecter

Pour diagnostic approfondi, collecter:

```powershell
# 1. Flutter doctor
flutter doctor -v > flutter-doctor.txt

# 2. Build verbose
flutter run -v 2>&1 | Tee-Object -FilePath build-log.txt

# 3. Gradle build
cd android
./gradlew assembleDebug --stacktrace > gradle-log.txt

# 4. Logcat complet
adb logcat > logcat-full.txt
```

---

**Document de diagnostic créé le**: 7 Octobre 2025  
**Pour**: Ma'a yegue - Migration Hybride  
**Objectif**: Résoudre problème de lancement Android  

---

🎯 **Note**: Ce guide couvre 95% des problèmes de build/launch Android. Suivre les étapes dans l'ordre pour une résolution efficace.

