# Ma'a Yegue - Système de Rôles et Module Culture

**Date:** 7 Octobre 2025  
**Version:** 1.0.0  
**Mise à jour:** Authentification par Rôle et Accès Invité

---

## 🎭 Système de Rôles Utilisateur

### Rôles Supportés

Le système supporte **4 types d'utilisateurs**:

| Rôle | Authentification | Document Firestore | Accès |
|------|-----------------|-------------------|--------|
| **Guest/Visitor** 👤 | ❌ Non requis | ❌ Aucun | Limité (Module Culture uniquement) |
| **Learner/Student** 📚 | ✅ Requis | ✅ Oui | Complet - Dashboard Étudiant |
| **Teacher** 👨‍🏫 | ✅ Requis | ✅ Oui | Complet - Dashboard Enseignant |
| **Admin** 👑 | ✅ Requis | ✅ Oui | Total - Dashboard Admin |

---

## 🔐 Flux d'Authentification et Routage

### 1. Connexion Réussie
```
Utilisateur entre email/password
    ↓
Vérification Firebase Auth
    ↓
Récupération du document utilisateur Firestore
    ↓
Lecture du champ "role"
    ↓
┌─────────────────────────────────────┐
│ Navigation basée sur le rôle:      │
├─────────────────────────────────────┤
│ • learner/student → /dashboard      │
│ • teacher → /teacher-dashboard      │
│ • admin → /admin-dashboard          │
└─────────────────────────────────────┘
```

### 2. Inscription Réussie
```
Utilisateur remplit le formulaire
    ↓
Création compte Firebase Auth
    ↓
Création document Firestore (rôle: "learner" par défaut)
    ↓
Navigation vers /dashboard (Dashboard Étudiant)
```

### 3. Accès Invité (Guest)
```
Landing Page → Bouton "Explorer en tant qu'Invité"
    ↓
Module Culture (sans authentification)
    ↓
Bannière avec boutons Login/S'inscrire
    ↓
Utilisateur peut s'authentifier quand il veut
```

---

## 📱 Nouveau: Module Culture Accessible aux Invités

### Landing Page - Section Culture

#### Ajout d'une nouvelle section (avant "App Highlights"):

**Contenu:**
- 🏛️ Icône Museum géante
- 📝 Titre: "Découvrez le Module Culture"
- 📖 Description: Exploration de l'histoire et des traditions
- 🎯 4 caractéristiques:
  - Histoire Riche
  - Traditions
  - Musique & Art
  - Gastronomie

**Bouton Principal:**
```
🔍 "Explorer en tant qu'Invité"
→ Navigation vers /culture
→ Aucune authentification requise
```

**Message:**
> "Aucune inscription requise pour explorer la culture camerounaise"

---

## 🎨 Module Culture - Améliorations

### 1. Bannière Mode Invité

Lorsqu'un utilisateur **non authentifié** accède au module Culture:

```
┌──────────────────────────────────────────────┐
│ ⚠️ Mode Invité - Contenu limité             │
│                          [S'inscrire] Button │
└──────────────────────────────────────────────┘
```

**Caractéristiques:**
- Fond orange clair
- Icône d'information
- Message clair sur les limitations
- Bouton "S'inscrire" visible et accessible
- Bouton "Connexion" dans l'AppBar

### 2. Navigation Améliorée

**AppBar:**
- Bouton retour (←) pour revenir à la Landing Page
- Bouton "Connexion" visible si non authentifié
- Titre: "Culture & Histoire"

**Onglets:**
- Culture
- Histoire
- Yemba

---

## 🔒 Règles Firestore Mises à Jour

### Commentaires de Clarification

```javascript
// ============================================
// User Role System:
// - guest/visitor: Unauthenticated users (no Firestore document needed)
// - learner/student: Authenticated users learning languages
// - teacher: Authenticated users creating content
// - admin: Authenticated administrators
// ============================================
```

### Création d'Utilisateur

**Rôles acceptés lors de l'inscription:**
- `learner` ou `student` (par défaut)
- `teacher`
- `admin` (uniquement par promotion)

**Rôles NE nécessitant PAS de document:**
- `guest` / `visitor` (pas de compte Firestore)

---

## 🚀 Fichiers Modifiés

### 1. **firestore.rules**
- ✅ Clarification du système de rôles
- ✅ Support explicite pour guest/visitor (sans document)
- ✅ Validation stricte des rôles lors de la création

### 2. **landing_view.dart**
- ✅ Nouvelle section "Module Culture"
- ✅ Bouton "Explorer en tant qu'Invité"
- ✅ 4 caractéristiques culture présentées
- ✅ Design violet/pourpre pour se démarquer
- ✅ Méthode helper `_buildCultureFeature()`

### 3. **culture_screen.dart**
- ✅ Import `AuthViewModel` pour vérifier l'authentification
- ✅ Détection automatique du mode invité
- ✅ Bannière orange pour utilisateurs non authentifiés
- ✅ Boutons "Connexion" et "S'inscrire" visibles
- ✅ Bouton retour vers landing page
- ✅ AppBar adaptatif selon l'état d'authentification

---

## 🎯 Parcours Utilisateur

### Scénario 1: Invité → Culture → Inscription

```
1. Utilisateur arrive sur Landing Page
   ↓
2. Clique sur "Explorer en tant qu'Invité"
   ↓
3. Navigue vers Module Culture (sans authentification)
   ↓
4. Voit la bannière "Mode Invité - Contenu limité"
   ↓
5. Clique sur "S'inscrire"
   ↓
6. Remplit le formulaire d'inscription
   ↓
7. Redirigé vers /dashboard (Dashboard Étudiant)
   ↓
8. Accès complet débloqué ✅
```

### Scénario 2: Invité → Connexion

```
1. Utilisateur sur Module Culture (mode invité)
   ↓
2. Clique sur "Connexion" (AppBar)
   ↓
3. Entre email/password
   ↓
4. Système vérifie le rôle dans Firestore
   ↓
5. Navigation vers le dashboard approprié:
   • Student → /dashboard
   • Teacher → /teacher-dashboard
   • Admin → /admin-dashboard
```

### Scénario 3: Utilisateur Authentifié

```
1. Utilisateur déjà connecté accède au Module Culture
   ↓
2. ❌ PAS de bannière "Mode Invité"
   ↓
3. ❌ PAS de bouton "S'inscrire"
   ↓
4. Accès complet au contenu culturel ✅
```

---

## 📊 Avantages de cette Implémentation

### Pour les Utilisateurs

1. **Exploration Sans Friction**
   - Pas besoin de créer un compte pour découvrir
   - Accès immédiat au contenu culturel
   - Incitation à s'inscrire visible mais non intrusive

2. **Clarté**
   - Message clair sur le statut (invité)
   - Boutons d'action toujours visibles
   - Navigation intuitive

3. **Flexibilité**
   - Retour facile à la landing page
   - Inscription/connexion accessible à tout moment
   - Pas de perte de contexte

### Pour le Projet

1. **Engagement**
   - Augmentation du taux de conversion
   - Utilisateurs peuvent "tester" avant de s'engager
   - Réduction de la friction à l'inscription

2. **Sécurité**
   - Firestore rules claires et documentées
   - Pas de documents inutiles pour les invités
   - Validation stricte des rôles

3. **Maintenabilité**
   - Code bien structuré
   - Commentaires explicatifs
   - Séparation claire des responsabilités

---

## ✅ Tests Recommandés

### Test 1: Navigation Invité
- [ ] Landing Page affiche la section Culture
- [ ] Clic sur "Explorer en tant qu'Invité" ouvre /culture
- [ ] Module Culture affiche la bannière mode invité
- [ ] Boutons "Connexion" et "S'inscrire" visibles

### Test 2: Connexion Depuis Culture
- [ ] Clic sur "Connexion" ouvre /login
- [ ] Connexion réussie avec role "student"
- [ ] Redirection vers /dashboard
- [ ] Retour au module culture: pas de bannière invité

### Test 3: Inscription Depuis Culture
- [ ] Clic sur "S'inscrire" ouvre /register
- [ ] Inscription réussie crée un document Firestore
- [ ] Rôle par défaut: "learner"
- [ ] Redirection vers /dashboard

### Test 4: Role-Based Routing
- [ ] Student login → /dashboard
- [ ] Teacher login → /teacher-dashboard  
- [ ] Admin login → /admin-dashboard

### Test 5: Navigation Retour
- [ ] Bouton back dans culture_screen fonctionne
- [ ] Retourne à la landing page si pas d'historique
- [ ] Navigation fluide et sans erreur

---

## 🔧 Commandes de Déploiement

```bash
# 1. Déployer les règles Firestore
firebase deploy --only firestore:rules

# 2. Vérifier le code
flutter analyze

# 3. Build et test
flutter run

# 4. Build release
flutter build apk --release
```

---

## 📝 Notes Techniques

### Détection Mode Invité

```dart
final authViewModel = context.watch<AuthViewModel>();
final isGuest = !authViewModel.isAuthenticated;
```

### Navigation Vers Culture

```dart
// Depuis landing page
onPressed: () => context.go(Routes.culture)

// Retour depuis culture
onPressed: () {
  if (Navigator.canPop(context)) {
    Navigator.pop(context);
  } else {
    context.go(Routes.landing);
  }
}
```

### Affichage Conditionnel

```dart
if (isGuest)
  Container(
    // Bannière mode invité
  ),
```

---

## 🎨 Design Guidelines

### Couleurs Module Culture

- **Principal:** `Colors.purple.shade700`
- **Accent:** `Colors.deepPurple.shade900`
- **Bannière Invité:** `Colors.orange.shade100` / `Colors.orange.shade900`

### Espacements

- **Padding section:** `24px`
- **Icon size:** `64px` (hero), `20px` (features)
- **Border radius:** `20-30px` pour boutons, `12px` pour cards

---

## 🚀 Prochaines Étapes

1. **Tester tous les scénarios utilisateur**
2. **Déployer les règles Firestore**
3. **Vérifier analytics des conversions invité → inscrit**
4. **Optionnel:** Ajouter plus de contenu culturel pour les invités
5. **Optionnel:** Tracking des actions invités pour optimisation

---

**Développé avec ❤️ pour promouvoir la culture camerounaise**

✅ **Système de rôles clarifié**  
✅ **Accès invité au module culture**  
✅ **Routing basé sur les rôles**  
✅ **Navigation fluide et intuitive**
