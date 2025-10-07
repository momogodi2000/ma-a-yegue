# 🚀 Guide de Démarrage Rapide - Ma'a yegue

**Commencez à développer en 5 minutes !**

---

## ⚡ Installation Express

### 1. Prérequis

Assurez-vous d'avoir installé :
- ✅ Flutter SDK 3.5.0+
- ✅ Android Studio / Xcode
- ✅ Git
- ✅ Node.js (pour Firebase)

### 2. Cloner et Installer

```bash
# Cloner le repository
git clone https://github.com/votre-repo/mayegue-mobile.git
cd mayegue-mobile

# Installer les dépendances
flutter pub get

# Vérifier l'installation
flutter doctor
```

### 3. Configuration Firebase

#### A. Télécharger les fichiers de configuration

1. Aller sur [Firebase Console](https://console.firebase.google.com/)
2. Sélectionner votre projet
3. Télécharger :
   - `google-services.json` (Android) → placer dans `android/app/`
   - `GoogleService-Info.plist` (iOS) → placer dans `ios/Runner/`

#### B. Configurer les variables d'environnement

Créer un fichier `.env` à la racine :

```env
# Firebase
FIREBASE_API_KEY=votre_api_key
FIREBASE_PROJECT_ID=votre_project_id
FIREBASE_APP_ID=votre_app_id

# AI
GEMINI_API_KEY=votre_gemini_key

# Paiements
CAMPAY_API_KEY=votre_campay_key
CAMPAY_USERNAME=votre_username
CAMPAY_PASSWORD=votre_password
NOUPAY_API_KEY=votre_noupay_key
STRIPE_PUBLISHABLE_KEY=pk_test_xxx
```

### 4. Lancer l'Application

```bash
# Mode développement
flutter run

# Avec hot reload activé automatiquement
# Appuyez sur 'r' pour recharger
# Appuyez sur 'R' pour restart complet
```

---

## 📱 Fonctionnalités Principales

### Pour les Apprenants

1. **Choisir une langue**
   - 22 langues camerounaises disponibles
   - Test de niveau initial

2. **Suivre des leçons**
   - Vidéos et audio
   - Exercices interactifs
   - Progression automatique

3. **Pratiquer avec le dictionnaire**
   - 4000+ mots
   - Prononciation audio
   - Exemples contextuels

4. **Passer des quiz**
   - Évaluation des connaissances
   - Certificats de réussite

5. **Utiliser l'IA**
   - Chat avec assistant
   - Traduction instantanée
   - Correction prononciation

### Pour les Enseignants

1. **Créer des cours**
   - Interface intuitive
   - Support multimédia

2. **Gérer les étudiants**
   - Suivi progression
   - Communication directe

3. **Créer des quiz**
   - Questions variées
   - Correction automatique

4. **Analyser les performances**
   - Statistiques détaillées
   - Rapports exportables

---

## 🎮 Commandes Utiles

```bash
# Analyser le code
flutter analyze

# Formater le code
flutter format .

# Lancer les tests
flutter test

# Build Android
flutter build apk --release

# Build iOS
flutter build ios --release

# Nettoyer le projet
flutter clean

# Mettre à jour les dépendances
flutter pub upgrade
```

---

## 🐛 Dépannage Rapide

### Problème : "Firebase not initialized"

**Solution :**
```bash
flutter clean
flutter pub get
flutter run
```

### Problème : "Database not found"

**Solution :**
Vérifier que le fichier `assets/databases/cameroon_languages.db` existe

### Problème : "Google Sign-In failed"

**Solution :**
1. Vérifier SHA-1 dans Firebase Console
2. Re-télécharger `google-services.json`
3. Rebuild

### Problème : "Build failed"

**Solution :**
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

---

## 📖 Documentation Complète

Pour plus de détails, consultez :

- 📘 [Documentation Complète](DOCUMENTATION_COMPLETE_FR.md)
- 🏗️ [Architecture](documentation_architecture.md)
- 🔧 [Guide Technique](documentation_techniques.md)
- 💡 [Fonctionnalités](documentation_fonctionnalites.md)
- 🔥 [Firebase Setup](firebase_setup_guide_fr.md)
- 📦 [Déploiement APK](apk_deployment_guide_fr.md)

---

## 💬 Support

**Besoin d'aide ?**

- 📧 Email : support@maayegue.com
- 💬 Discord : [Lien Discord]
- 📱 WhatsApp : +237 XXX XXX XXX

---

*Dernière mise à jour : 7 octobre 2025*

