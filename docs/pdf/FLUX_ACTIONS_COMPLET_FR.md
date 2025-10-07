# 🔄 Flux d'Actions Complet - Ma'a Yegue v2.0

**Plateforme E-Learning Camerounaise**  
**Version:** 2.0.0  
**Date:** 7 octobre 2025

---

## 📋 Table des Matières

1. [Flux Global de l'Application](#flux-global-de-lapplication)
2. [Parcours par Type d'Utilisateur](#parcours-par-type-dutilisateur)
3. [Interactions et Communications](#interactions-et-communications)
4. [Flux de Données](#flux-de-données)
5. [Diagrammes UML](#diagrammes-uml)

---

## 🚀 Flux Global de l'Application

### De l'Installation au Premier Usage

```
1. INSTALLATION
   ├─ Play Store / App Store
   ├─ Téléchargement (45 MB)
   ├─ Installation
   └─ Icône sur écran d'accueil
            ↓
2. PREMIER LANCEMENT
   ├─ Splash Screen (3 secondes)
   │  └─ Logo Ma'a Yegue animé
   │  └─ Initialisation services
   │  └─ Vérification connexion
   │      ↓
   ├─ Termes et Conditions
   │  └─ Acceptation obligatoire
   │      ↓
   ├─ Landing Page (Page d'Accueil)
   │  ├─ Hero section (stats: 1000+ mots, 6 langues, 500+ apprenants)
   │  ├─ Présentation 22 langues
   │  ├─ Showcase Culture (NOUVEAU v2.0)
   │  ├─ Leçons démo
   │  ├─ Fonctionnalités
   │  ├─ Témoignages
   │  ├─ Tarifs
   │  └─ Call-to-action
   │      ↓
3. CHOIX UTILISATEUR
   ├─ Option A: Continuer en tant qu'invité → Dashboard Visiteur
   ├─ Option B: S'inscrire → Formulaire d'inscription
   └─ Option C: Se connecter → Formulaire de connexion
```

---

## 👤 Parcours par Type d'Utilisateur

### 1. VISITEUR / INVITÉ (Niveau 0)

**Objectif:** Explorer sans engagement, encourager inscription

#### Flux d'Actions Visiteur

```
LANDING PAGE
    ↓
[Clic "Essayer Gratuitement"]
    ↓
GUEST DASHBOARD
    │
    ├─→ Explorer (Menu)
    │   ├─ Présentation app
    │   ├─ Langues disponibles
    │   └─ Fonctionnalités
    │
    ├─→ Culture (Menu NOUVEAU)
    │   ├─ Culture (6 articles)
    │   ├─ Histoire (2 articles)
    │   └─ Yemba (3 leçons)
    │
    ├─→ Langues
    │   ├─ Liste 22 langues
    │   ├─ Aperçu gratuit
    │   └─ Démonstration audio
    │
    ├─→ Dictionnaire (Limité)
    │   ├─ 50 mots gratuits
    │   ├─ Recherche basique
    │   └─ Invitation à s'inscrire
    │
    ├─→ Leçons Démo (3 max)
    │   ├─ Leçon 1: Salutations
    │   ├─ Leçon 2: Nombres
    │   ├─ Leçon 3: Famille
    │   └─ "Inscrivez-vous pour plus"
    │
    └─→ S'Inscrire / Se Connecter
        └─ Redirection authentification
```

**Limitations Visiteur:**
- ❌ Pas de sauvegarde progression
- ❌ Pas d'accès IA
- ❌ Pas de communauté
- ❌ Pas de certificats
- ❌ Contenu limité (20%)

**Encouragements Inscription:**
- Bannière visible sur chaque page
- "Débloquez tout en vous inscrivant"
- Comparaison gratuit vs premium
- Boutons CTA stratégiques

---

### 2. ÉLÈVE / STUDENT (Niveau 1)

**Profil:** Paul, 12 ans, 6ème, École Publique Yaoundé

#### Flux d'Inscription Élève

```
INSCRIPTION
    ↓
Formulaire Complet:
├─ Informations Personnelles
│  ├─ Nom, Prénom
│  ├─ Date de naissance → Calcul âge
│  ├─ Email
│  └─ Téléphone
│
├─ Informations Scolaires (NOUVEAU v2.0)
│  ├─ Établissement (liste déroulante)
│  ├─ Niveau scolaire (CP → Terminale)
│  ├─ Classe (ex: 6ème A)
│  └─ Année académique (2024-2025)
│
├─ Langues d'Intérêt
│  ├─ Langue maternelle
│  ├─ Langues à apprendre
│  └─ Niveau actuel
│
├─ Consentement Parental (si mineur)
│  ├─ Email parent
│  ├─ Validation parent
│  └─ Autorisation collecte données
│
└─ Mot de passe sécurisé
    └─ Validation (min 8 caractères)
        ↓
Création compte Firebase
    ↓
Email de vérification
    ↓
[Clic lien email]
    ↓
ONBOARDING (5 écrans)
    ↓
DASHBOARD ÉLÈVE (adapté âge)
```

---

#### Dashboard Élève (Adapté par Âge)

**Interface 6ème (12 ans - Niveau Moyen):**

```
╔════════════════════════════════════════╗
║  Bonjour Paul! 👋                      ║
║  6ème A - École Publique Yaoundé       ║
╠════════════════════════════════════════╣
║                                        ║
║  📊 MA PROGRESSION                     ║
║  ├─ Moyenne Générale: 15.2/20         ║
║  ├─ Rang: 3ème/38                      ║
║  ├─ Niveau Gamification: 5            ║
║  └─ Prochain badge: 250 XP            ║
║                                        ║
║  📚 MES COURS AUJOURD'HUI              ║
║  ├─ 08h00 - Ewondo (Salutations)      ║
║  ├─ 10h00 - Français                   ║
║  └─ 14h00 - Mathématiques              ║
║                                        ║
║  ✍️ DEVOIRS À FAIRE (3)                ║
║  ├─ Ewondo: Vocabulaire (Lundi)       ║
║  ├─ Français: Rédaction (Mercredi)    ║
║  └─ Maths: Exercices (Vendredi)       ║
║                                        ║
║  📖 CONTINUE TON APPRENTISSAGE         ║
║  ├─ Leçon suivante: Les Nombres       ║
║  ├─ Quiz du jour: Culture Bamiléké    ║
║  └─ Challenge: 100 mots cette semaine ║
║                                        ║
║  🎮 GAMIFICATION                       ║
║  ├─ Points XP: 2,450                   ║
║  ├─ Badges débloqués: 8/20            ║
║  └─ Classement: 12ème national        ║
╚════════════════════════════════════════╝
```

**Menu Navigation Élève:**
```
┌─────────────────────────────┐
│ 🏠 Tableau de Bord          │
│ 📚 Mes Leçons               │
│ ✍️ Mes Devoirs              │
│ 📊 Mes Notes                │
│ 📖 Dictionnaire             │
│ 🎮 Jeux Éducatifs           │
│ 🏛️ Culture & Histoire       │
│ 👥 Communauté               │
│ 🤖 Assistant IA             │
│ 🏆 Mes Réalisations         │
│ 👤 Mon Profil               │
└─────────────────────────────┘
```

---

#### Flux Typique Élève - Journée Complète

```
MATIN (Avant l'école)
07:00 - Connexion app
      ↓
07:05 - Vérification emploi du temps
      ↓
07:10 - Révision rapide (flashcards Ewondo)
      ↓
07:30 - Départ pour l'école

APRÈS-MIDI (Après l'école)
15:00 - Connexion app
      ↓
15:05 - Consultation nouvelles notes (Prof a mis notes du quiz)
      │    └─ Ewondo Quiz: 17/20 ✅ "Excellent!"
      ↓
15:10 - Faire devoir Ewondo
      ├─ Lire consigne
      ├─ Écouter prononciations
      ├─ Compléter exercices
      ├─ Vérifier avec IA
      └─ Soumettre (Upload fichier)
      ↓
15:40 - Leçon interactive "Les Nombres en Ewondo"
      ├─ Lire contenu (adapté 12 ans, temps: 10 min)
      ├─ Regarder vidéo (3 min)
      ├─ Écouter prononciations
      ├─ Faire exercices (5 questions)
      └─ Quiz final (10 questions)
      ↓
16:15 - Résultat quiz: 9/10 ✅
      └─ +50 XP, progression sauvegardée
      ↓
16:20 - Jeu éducatif (10 min)
      └─ "Trouve le mot" en Ewondo
      └─ +30 XP, nouveau badge débloqué! 🎉
      ↓
16:30 - Vérifier classement
      └─ 12ème national, 2ème de ma classe!
      ↓
16:35 - Déconnexion

SOIR (Révision)
20:00 - Connexion rapide
      ↓
20:05 - Flashcards révision (spaced repetition)
      └─ 20 cartes en 5 minutes
      ↓
20:10 - Conversation IA en Ewondo
      └─ "Bonjour, comment vas-tu aujourd'hui?"
      └─ Pratique orale 10 min
      ↓
20:20 - Déconnexion, bonne nuit! 😴
```

**Temps Total:** ~2h sur l'app par jour  
**Engagement:** Élevé (gamification + contenu adapté)

---

### 3. ENSEIGNANT / TEACHER (Niveau 2)

**Profil:** Marie Ngono, 35 ans, Professeure Ewondo, CM2 A (35 élèves)

#### Flux d'Inscription Enseignant

```
INSCRIPTION ENSEIGNANT
    ↓
Formulaire Spécifique:
├─ Informations Personnelles
│  ├─ Nom, Prénom
│  ├─ Email professionnel
│  └─ Téléphone
│
├─ Qualifications
│  ├─ Diplômes (upload scan)
│  ├─ Spécialité (Ewondo, Duala, etc.)
│  ├─ Années d'expérience
│  └─ Certifications
│
├─ Affectation (NOUVEAU v2.0)
│  ├─ Établissement
│  ├─ Classes assignées (ex: CM2 A, CM2 B)
│  ├─ Matières enseignées
│  ├─ Professeur principal? (Oui/Non)
│  └─ Heures hebdomadaires
│
├─ Validation
│  └─ Vérification par Directeur
│      └─ Approbation sous 24-48h
│          ↓
ONBOARDING ENSEIGNANT (7 écrans)
├─ Visite guidée dashboard
├─ Tutoriel prise présences
├─ Tutoriel création devoirs
├─ Tutoriel saisie notes
├─ Tutoriel communication parents
└─ Tutoriel génération bulletins
    ↓
TEACHER DASHBOARD
```

---

#### Teacher Dashboard - Vue Complète

```
╔════════════════════════════════════════════════════════╗
║  Bienvenue Madame Marie Ngono 👩‍🏫                       ║
║  Professeure Ewondo - CM2 A (35 élèves)                ║
╠════════════════════════════════════════════════════════╣
║                                                        ║
║  📅 AUJOURD'HUI - Lundi 7 Octobre 2025                 ║
║  ├─ 1er Trimestre - Semaine 5/15                      ║
║  ├─ Jours restants: 69 jours                          ║
║  └─ Prochain événement: Conseil de Classe (10 déc)    ║
║                                                        ║
║  🏫 MES CLASSES                                        ║
║  ├─ CM2 A (35 élèves) - Professeur Principal          ║
║  │  ├─ Présences aujourd'hui: 33/35 ✅                ║
║  │  ├─ Moyenne classe: 14.2/20                        ║
║  │  └─ Devoirs non rendus: 3                          ║
║  │                                                     ║
║  └─ CM2 B (32 élèves) - Ewondo uniquement             ║
║     ├─ Présences: Pas encore marquées ⚠️              ║
║     ├─ Moyenne classe: 13.8/20                        ║
║     └─ Devoirs non rendus: 5                          ║
║                                                        ║
║  ✍️ ACTIONS RAPIDES                                    ║
║  ├─ [Prendre Présences CM2 B]                         ║
║  ├─ [Créer Nouveau Devoir]                            ║
║  ├─ [Saisir Notes]                                     ║
║  └─ [Voir Messages Parents (2 non lus)]               ║
║                                                        ║
║  📊 À FAIRE CETTE SEMAINE                              ║
║  ├─ ⚠️ Corriger 12 devoirs (deadline mercredi)        ║
║  ├─ ⚠️ Saisir notes quiz (deadline vendredi)          ║
║  ├─ ℹ️ Préparer leçon semaine prochaine               ║
║  └─ ℹ️ Répondre à 2 messages parents                  ║
║                                                        ║
║  📈 STATISTIQUES CLASSE CM2 A                          ║
║  ├─ Taux présence: 94.5%                              ║
║  ├─ Taux soumission devoirs: 88%                      ║
║  ├─ Progression moyenne: +2.1 points ce trimestre     ║
║  └─ Élèves en difficulté: 3 (Pierre, Marie, Jean)     ║
╚════════════════════════════════════════════════════════╝
```

---

#### Flux Quotidien Enseignant

```
MATIN
08:00 - Connexion Teacher Dashboard
      ↓
08:05 - Vérifier emploi du temps
      ├─ CM2 A: 08h15 - Ewondo
      └─ CM2 B: 10h30 - Ewondo
      ↓
08:15 - COURS CM2 A
      ├─ [Pendant le cours] Ouvrir app
      ├─ Prendre présences (2 minutes)
      │  └─ Liste 35 élèves
      │  └─ Tap: Présent (vert), Absent (rouge), Retard (orange)
      │  └─ Si absent: Raison? Justifié?
      │  └─ Sauvegarde auto
      │  └─ Notification auto parents absents
      ↓
09:00 - Fin cours, noter observations
      └─ Paul: Excellente participation (+note conduite positive)
      └─ Pierre: Distrait (note conduite négative mineure)
      ↓
10:30 - COURS CM2 B
      └─ Répéter processus présences
      ↓
11:30 - Pause déjeuner

APRÈS-MIDI
14:00 - Connexion app (salle des profs)
      ↓
14:05 - Créer devoir pour la semaine prochaine
      ├─ Titre: "Vocabulaire de la Famille en Ewondo"
      ├─ Description: Apprendre 20 mots + créer arbre généalogique
      ├─ Date assignation: Aujourd'hui
      ├─ Date limite: Lundi prochain (7 jours)
      ├─ Note sur: /20
      ├─ Upload: Document PDF (liste mots)
      └─ [Publier] → Notification 67 élèves (CM2 A + B)
      ↓
14:20 - Corriger devoirs rendus (12 devoirs)
      ├─ Ouvrir soumission élève
      ├─ Lire travail
      ├─ Noter sur /20
      ├─ Feedback écrit (encouragements)
      └─ [Valider] → Notification élève + parent
      ↓
15:30 - Saisir notes du quiz de vendredi
      ├─ Importer liste classe
      ├─ Saisir notes (clavier rapide)
      │  └─ Paul: 17/20
      │  └─ Marie: 12/20
      │  └─ ... (35 élèves)
      ├─ Calcul auto: Moyenne, classement
      └─ [Publier] → Visible élèves + parents
      ↓
16:00 - Répondre messages parents (2)
      ├─ Message 1: "Comment va Paul en Ewondo?"
      │  └─ Réponse: "Excellent! 17/20 au dernier quiz..."
      │
      └─ Message 2: "RDV pour discuter de Marie?"
         └─ Réponse: "Avec plaisir, jeudi 14h?"
         └─ [Planifier RDV] → Confirmation auto
      ↓
16:30 - Préparer plan de leçon semaine prochaine
      ├─ Cahier de textes numérique
      ├─ Sujet: "Les Nombres 1-100"
      ├─ Objectifs pédagogiques
      ├─ Matériel: Flashcards, audio
      ├─ Durée: 60 minutes
      └─ Devoir associé: Exercices nombres
      ↓
17:00 - Consulter analytics classe
      ├─ Graphique progression moyenne
      ├─ Identification élèves en difficulté
      ├─ Recommandations IA pour remédiation
      └─ Export rapport pour directeur
      ↓
17:15 - Déconnexion

FIN DE TRIMESTRE (décembre)
      ↓
Génération Bulletins (1 clic!)
├─ Sélectionner: CM2 A
├─ Trimestre: 1er Trimestre 2024-2025
├─ [Générer 35 bulletins]
│  ├─ Calcul auto toutes moyennes
│  ├─ Calcul auto classements
│  ├─ Remplissage auto données
│  └─ Ajout commentaires personnalisés
│      ↓
├─ Révision individulle (optionnel)
├─ Signature numérique
└─ [Publier] → Notification 35 élèves + parents
    ↓
Conseil de Classe (10 décembre)
├─ Dashboard stats classe
├─ Présentation au directeur
└─ Validation passages de classe
```

**Temps Économisé:** ~80 heures/trimestre

---

### 4. PARENT / TUTEUR (Niveau 1)

**Profil:** Jean Mbarga, 42 ans, Papa de Paul (6ème) et Sophie (CE2)

#### Flux d'Inscription Parent

```
INSCRIPTION PARENT
    ↓
Formulaire:
├─ Informations Personnelles
├─ Email, Téléphone
├─ Lien avec élève(s)
│  ├─ Enfant 1: Paul Mbarga (6ème A)
│  │  └─ Type relation: Père
│  │  └─ Tuteur principal: Oui
│  │
│  └─ Enfant 2: Sophie Mbarga (CE2 B)
│     └─ Type relation: Père
│     └─ Tuteur principal: Oui
│
└─ Permissions
   ├─ Voir notes: ✅
   ├─ Voir présences: ✅
   ├─ Recevoir notifications: ✅
   └─ Contacter enseignants: ✅
       ↓
Validation par École (Directeur)
    ↓
Approbation (24-48h)
    ↓
ONBOARDING PARENT
    ↓
PARENT PORTAL
```

---

#### Parent Portal Dashboard

```
╔════════════════════════════════════════════════════╗
║  Bienvenue Jean Mbarga 👨                          ║
║  Parent de 2 enfants                               ║
╠════════════════════════════════════════════════════╣
║                                                    ║
║  👦 PAUL MBARGA - 6ème A                           ║
║  ├─ Moyenne: 15.2/20 (Très Bien) ✅                ║
║  ├─ Rang: 3ème/38                                  ║
║  ├─ Présences: 42/45 (93%) ✅                      ║
║  ├─ Devoirs: 8/10 rendus ⚠️                        ║
║  └─ Dernier message prof: Il y a 2 jours           ║
║     [Voir Détails] [Contacter Prof]               ║
║                                                    ║
║  👧 SOPHIE MBARGA - CE2 B                          ║
║  ├─ Moyenne: 13.5/20 (Bien) ✅                     ║
║  ├─ Rang: 12ème/32                                 ║
║  ├─ Présences: 44/45 (98%) ✅                      ║
║  ├─ Devoirs: 10/10 rendus ✅                       ║
║  └─ Dernier message prof: Il y a 1 semaine         ║
║     [Voir Détails] [Contacter Prof]               ║
║                                                    ║
║  📬 MESSAGES (2 non lus)                           ║
║  ├─ Mme Ngono (Prof Paul): Excellent progrès!     ║
║  └─ M. Kamga (Prof Sophie): RDV disponible?       ║
║     [Lire Messages]                                ║
║                                                    ║
║  📅 RENDEZ-VOUS PLANIFIÉS                          ║
║  ├─ Jeudi 10 oct, 14h00                            ║
║  │  └─ Avec Mme Ngono (Prof Paul)                  ║
║  │  └─ Sujet: Progression Ewondo                   ║
║  │  └─ Lieu: Salle des profs                       ║
║  └─ [Planifier Nouveau RDV]                        ║
║                                                    ║
║  📢 ANNONCES ÉCOLE (1 nouvelle)                    ║
║  └─ Vacances Noël: 16 déc - 4 janvier              ║
║     [Voir Toutes Annonces]                         ║
╚════════════════════════════════════════════════════╝
```

**Menu Navigation Parent:**
```
┌──────────────────────────────┐
│ 🏠 Tableau de Bord           │
│ 👦 Paul (6ème)               │
│ 👧 Sophie (CE2)              │
│ 📊 Notes & Bulletins         │
│ 📅 Présences                 │
│ ✍️ Devoirs                   │
│ 💬 Messages Professeurs      │
│ 📅 Rendez-vous               │
│ 📢 Annonces École            │
│ 📈 Progression               │
│ ⚙️ Paramètres                │
└──────────────────────────────┘
```

---

#### Flux Typique Parent - Semaine

```
LUNDI MATIN
07:00 - Notification push
      └─ "Paul a un devoir Ewondo à rendre vendredi"
      ↓
07:30 - Ouverture app (vérification rapide)
      ├─ Paul: Présent aujourd'hui ✅
      └─ Sophie: Présente aujourd'hui ✅

LUNDI SOIR
18:00 - Connexion portail parent
      ↓
18:05 - Vérifier devoirs enfants
      ├─ Paul: Devoir Ewondo (à faire)
      │  └─ [Rappeler à Paul]
      │
      └─ Sophie: Devoir Français (fait) ✅
      ↓
18:10 - Consulter notes récentes
      └─ Paul: Nouveau quiz Ewondo 17/20 ✅
         └─ Lire commentaire prof: "Excellent travail!"
         └─ [Féliciter Paul]

MERCREDI
19:00 - Notification
      └─ "Nouveau message de Mme Ngono (Prof Paul)"
      ↓
19:05 - Lire message
      └─ "Bonjour M. Mbarga, Paul fait d'excellents progrès 
          en Ewondo! Félicitations pour votre suivi."
      ↓
19:10 - Répondre
      └─ "Merci Madame, nous sommes très fiers! 
          Il pratique tous les soirs 😊"
      ↓
19:15 - [Envoyer]
      └─ Notification instantanée prof

VENDREDI
15:00 - Notification
      └─ "Bulletin 1er trimestre de Paul disponible"
      ↓
15:30 - Connexion urgente
      ↓
15:35 - Télécharger bulletin Paul
      ├─ PDF officiel généré
      ├─ Consulter en ligne
      │  ├─ Ewondo: 16.5/20 (Très Bien)
      │  ├─ Français: 14/20 (Bien)
      │  ├─ Maths: 15/20 (Bien)
      │  ├─ Moyenne générale: 15.2/20
      │  ├─ Rang: 3ème/38 🏆
      │  ├─ Commentaire prof: "Élève sérieux, continuez!"
      │  └─ Commentaire directeur: "Félicitations"
      │
      ├─ [Télécharger PDF]
      ├─ [Partager avec famille]
      └─ [Imprimer]
      ↓
15:45 - Consulter bulletin Sophie
      └─ Répéter processus

SAMEDI
10:00 - Planifier RDV avec prof Paul
      ├─ [Demander RDV]
      ├─ Sujet: "Progression et orientation"
      ├─ Préférence: Jeudi après-midi
      ├─ Mode: En personne
      └─ [Envoyer Demande]
          ↓
      Notification prof
      ↓
      Prof propose: Jeudi 14h00
          ↓
      [Accepter] → RDV confirmé
      └─ Ajout auto calendrier (Google Calendar sync)
```

**Fréquence Usage:** 3-4 fois/semaine, 10-15 min/session

---

### 5. DIRECTEUR D'ÉTABLISSEMENT (Niveau 5)

**Profil:** Dr. Emmanuel Nkomo, 50 ans, Directeur École Publique Yaoundé (600 élèves, 18 classes)

#### Director Dashboard

```
╔════════════════════════════════════════════════════════╗
║  Dashboard Directeur - Dr. Emmanuel Nkomo 🎓           ║
║  École Publique et Secondaire de Yaoundé               ║
║  Code MINEDUC: YDE-PUB-001                             ║
╠════════════════════════════════════════════════════════╣
║                                                        ║
║  🏫 VUE D'ENSEMBLE ÉTABLISSEMENT                       ║
║  ├─ Effectif total: 585/600 élèves (97.5%)            ║
║  ├─ Classes: 18 (CP à Terminale)                      ║
║  ├─ Enseignants: 24                                    ║
║  ├─ Personnel admin: 6                                 ║
║  └─ Année académique: 2024-2025 (1er Trimestre)       ║
║                                                        ║
║  📊 INDICATEURS CLÉS (Cette semaine)                   ║
║  ├─ Taux présence global: 92.3% ✅                    ║
║  ├─ Moyenne établissement: 13.8/20                     ║
║  ├─ Taux soumission devoirs: 85%                      ║
║  ├─ Messages parents: 45 (8 non traités)              ║
║  └─ Incidents conduite: 3 (2 mineurs, 1 modéré)       ║
║                                                        ║
║  ⚠️ ALERTES & ACTIONS REQUISES                         ║
║  ├─ 🔴 5 élèves taux présence <80% (convocation)      ║
║  ├─ 🟠 Classe 3ème B: Moyenne 11.2/20 (remédiation)   ║
║  ├─ 🟡 3 devoirs non corrigés >7 jours                ║
║  └─ ℹ️ Conseil de classe: 10 décembre (préparer)      ║
║                                                        ║
║  📅 ÉVÉNEMENTS PROCHAINS                               ║
║  ├─ 10 oct: Réunion enseignants                       ║
║  ├─ 15 oct: Journée portes ouvertes                   ║
║  ├─ 10 déc: Conseils de classe                        ║
║  └─ 15 déc: Remise bulletins                          ║
║                                                        ║
║  🎯 ACTIONS RAPIDES                                    ║
║  ├─ [Publier Annonce Générale]                        ║
║  ├─ [Créer Nouvelle Classe]                           ║
║  ├─ [Affecter Enseignant]                             ║
║  ├─ [Voir Rapports MINEDUC]                           ║
║  └─ [Analyser Performances]                           ║
╚════════════════════════════════════════════════════════╝
```

**Menu Navigation Directeur:**
```
┌──────────────────────────────┐
│ 🏫 Mon Établissement         │
│ 🎓 Classes                   │
│ 👨‍🏫 Enseignants               │
│ 👨‍🎓 Élèves                   │
│ 👨‍👩‍👧 Parents                  │
│ 📊 Statistiques              │
│ 📢 Annonces                  │
│ 📅 Calendrier Scolaire       │
│ 📈 Rapports MINEDUC          │
│ ⚙️ Configuration             │
└──────────────────────────────┘
```

---

#### Flux Mensuel Directeur

```
DÉBUT DE MOIS
Jour 1: Revue Statistiques Mois Précédent
    ├─ Taux présence global
    ├─ Moyennes par classe
    ├─ Incidents conduite
    └─ Performance enseignants
    ↓
Jour 2-3: Réunion Enseignants
    ├─ Présentation stats
    ├─ Identification problèmes
    ├─ Plan d'action collectif
    └─ Objectifs du mois
    ↓
Jour 5: Communication Parents
    ├─ Annonce générale (résultats, événements)
    ├─ Convocation parents élèves en difficulté
    └─ Newsletter mensuelle

MI-MOIS
Jour 15: Suivi Intermédiaire
    ├─ Vérification plan d'action
    ├─ Ajustements si nécessaire
    └─ Support enseignants

FIN DE MOIS
Jour 28-30: Préparation Mois Suivant
    ├─ Rapport mensuel MINEDUC
    ├─ Budget et dépenses
    ├─ Planification événements
    └─ Revue objectifs

FIN DE TRIMESTRE (tous les 3 mois)
    ↓
Conseil de Classe (toutes classes)
    ├─ Révision bulletins
    ├─ Décisions passages
    ├─ Convocation parents
    └─ Signature bulletins
    ↓
Rapport Trimestriel MINEDUC
    ├─ Export statistiques auto
    ├─ Indicateurs éducatifs
    └─ Soumission officielle
```

---

### 6. INSPECTEUR MINEDUC (Niveau 6)

**Profil:** Mme Françoise Atangana, Inspectrice Région Centre

#### Inspector Dashboard

```
╔════════════════════════════════════════════════════════╗
║  Dashboard Inspectrice - Mme Françoise Atangana       ║
║  Inspection Académique - Région Centre                 ║
╠════════════════════════════════════════════════════════╣
║                                                        ║
║  🌍 MA RÉGION - CENTRE (45 établissements)             ║
║  ├─ Écoles publiques: 32                               ║
║  ├─ Écoles privées: 13                                 ║
║  ├─ Élèves total: 28,500                               ║
║  ├─ Enseignants: 890                                   ║
║  └─ Taux adoption Ma'a Yegue: 24% (11 écoles)          ║
║                                                        ║
║  📊 INDICATEURS RÉGIONAUX (1er Trimestre)              ║
║  ├─ Moyenne régionale: 13.2/20                         ║
║  ├─ Taux présence: 89.5%                               ║
║  ├─ Taux réussite: 78%                                 ║
║  ├─ Écoles performantes: 15 (>14/20)                   ║
║  └─ Écoles en difficulté: 5 (<12/20)                   ║
║                                                        ║
║  🎯 ÉCOLES À INSPECTER (Ce mois)                       ║
║  ├─ École Publique Yaoundé (10 oct)                    ║
║  ├─ Lycée Bilingue Mfou (15 oct)                       ║
║  └─ Collège Privé Mbalmayo (22 oct)                    ║
║                                                        ║
║  📈 RAPPORTS NATIONAUX                                 ║
║  └─ [Générer Rapport Trimestriel] → MINEDUC           ║
╚════════════════════════════════════════════════════════╝
```

**Fonctionnalités Inspecteur:**
- Vue consolidée région
- Comparaison établissements
- Identification écoles en difficulté
- Recommandations pédagogiques
- Rapports automatiques MINEDUC
- Supervision qualité enseignement

---

## 🔄 Interactions et Communications

### Matrice de Communication

| Émetteur | Destinataire | Moyen | Fréquence | Exemple |
|----------|--------------|-------|-----------|---------|
| **Élève** | Enseignant | Soumission devoir | Hebdomadaire | Rendre travail |
| **Élève** | IA | Chat | Quotidien | Pratique conversation |
| **Élève** | Élèves | Forum communauté | Variable | Entraide |
| **Enseignant** | Élève | Notes/Feedback | Quotidien | Correction devoirs |
| **Enseignant** | Parent | Messages | Hebdomadaire | Suivi progression |
| **Enseignant** | Directeur | Rapports | Mensuel | Stats classe |
| **Parent** | Enseignant | Messages | Hebdomadaire | Questions, RDV |
| **Parent** | Élève | Via app | Quotidien | Vérification devoirs |
| **Directeur** | Enseignants | Annonces | Hebdomadaire | Circulaires |
| **Directeur** | Parents | Annonces | Mensuel | Infos générales |
| **Directeur** | Inspecteur | Rapports | Trimestriel | Stats établissement |
| **Inspecteur** | MINEDUC | Rapports | Trimestriel | Stats régionales |

---

### Flux de Communication Parent-Enseignant

```
SCÉNARIO: Parent veut discuter des notes de son enfant

ÉTAPE 1: Initiation Parent
Parent (app) → [Messages] → [Nouveau Message]
    ├─ Destinataire: Mme Ngono (Prof Ewondo)
    ├─ Enfant concerné: Paul Mbarga (6ème A)
    ├─ Sujet: "Question sur notes trimestre"
    ├─ Priorité: Normale
    └─ Message: "Bonjour Madame, je souhaiterais discuter
                 de la progression de Paul en Ewondo..."
        ↓
[Envoyer] → Firebase Firestore
    ↓
Notification Push Enseignant
    └─ "Nouveau message de M. Mbarga (Parent de Paul)"

ÉTAPE 2: Réponse Enseignant
Enseignant (app) → Notification → [Ouvrir Message]
    ↓
Lire message parent
    ↓
[Répondre]
    └─ "Bonjour M. Mbarga, Paul fait d'excellents progrès!
        Sa moyenne est 16.5/20. Souhaitez-vous un RDV
        pour en discuter davantage?"
        ↓
[Envoyer] → Firebase
    ↓
Notification Push Parent

ÉTAPE 3: Planification RDV
Parent → [Oui, je souhaite un RDV]
    ↓
Enseignant → [Proposer créneaux]
    ├─ Jeudi 10 oct, 14h00
    ├─ Vendredi 11 oct, 15h30
    └─ Lundi 14 oct, 13h00
        ↓
Parent → [Accepter: Jeudi 14h00]
    ↓
Création ParentTeacherMeeting
    ├─ Status: Confirmé
    ├─ Lieu: Salle des profs
    ├─ Mode: En personne
    └─ Calendrier: Ajout auto Google Calendar
        ↓
Notifications Rappel
    ├─ J-2: Rappel parent + enseignant
    ├─ J-1: Rappel parent + enseignant
    └─ H-2h: Rappel final

ÉTAPE 4: Après RDV
Enseignant → [Compléter notes RDV]
    ├─ Discussion tenue
    ├─ Points abordés
    ├─ Actions décidées
    └─ Outcome: Positif
        ↓
Parent → Notification
    └─ "Notes de votre RDV disponibles"
        ↓
Parent → [Consulter notes]
    └─ Historique complet archivé
```

**Temps de Réponse Moyen:** 24-48h  
**Satisfaction:** Transparence totale

---

### Flux de Communication Directeur → Communauté

```
SCÉNARIO: Annonce vacances de Noël

ÉTAPE 1: Création Annonce
Directeur (app) → [Annonces] → [Nouvelle Annonce]
    ├─ Type: Vacances
    ├─ Titre: "Vacances de Noël 2024"
    ├─ Contenu: "Les vacances débutent le 16 décembre..."
    ├─ Date publication: Aujourd'hui
    ├─ Date expiration: 15 janvier
    ├─ Cibles: Tous niveaux
    ├─ Notification push: ✅ Oui
    └─ Pièce jointe: Calendrier trimestre 2 (PDF)
        ↓
[Publier]
    ↓
Diffusion Automatique
    ├─ Firebase: Enregistrement annonce
    ├─ Notifications Push: 
    │  ├─ 24 enseignants
    │  ├─ 585 élèves
    │  └─ 950 parents (certains ont plusieurs enfants)
    │
    └─ Email (optionnel):
       └─ Envoi via Firebase Functions

ÉTAPE 2: Réception
Utilisateurs reçoivent:
    ├─ Notification mobile
    │  └─ "École Publique Yaoundé: Vacances de Noël"
    │      └─ [Tap] → Ouverture annonce
    │
    ├─ Badge notification dans app
    │  └─ Icône 📢 avec pastille rouge (1)
    │
    └─ Email (si activé)
       └─ HTML formaté avec logo école

ÉTAPE 3: Consultation
Utilisateur → [Annonces] → [Vacances Noël]
    ├─ Lecture contenu complet
    ├─ Téléchargement PDF calendrier
    ├─ Ajout auto calendrier personnel
    └─ [Marquer comme lu]
        ↓
Statistiques Directeur
    └─ Taux lecture: 89% (850/950 destinataires)
```

---

## 📊 Flux de Données - Cycles Complets

### Cycle 1: Création Compte Élève → Première Leçon

```
1. INSCRIPTION
   Formulaire web → Firebase Auth
       ↓
   CreateUser (uid, email, password)
       ↓
   Firebase Functions → CreateUserProfile
       ├─ Firestore: users/{uid}
       │  ├─ role: "student"
       │  ├─ gradeLevel: "sixieme"
       │  ├─ schoolId: "school_001"
       │  └─ classroomId: "class_6eme_a"
       │
       └─ Firestore: students/{uid}
          ├─ personalInfo: {...}
          ├─ academicInfo: {...}
          └─ preferences: {...}
              ↓
2. EMAIL VÉRIFICATION
   Firebase → Send Verification Email
       ↓
   Élève → Clic lien email
       ↓
   Email verified = true
       ↓
3. ONBOARDING
   5 écrans guidés
   ├─ Choisir langues d'intérêt
   ├─ Définir objectifs
   ├─ Configurer notifications
   ├─ Visite guidée interface
   └─ [Commencer]
       ↓
4. DASHBOARD
   Load initial data:
   ├─ Firestore: user progress
   ├─ Firestore: recommended lessons
   ├─ SQLite: offline lessons cache
   └─ Display dashboard
       ↓
5. PREMIÈRE LEÇON
   [Clic "Salutations en Ewondo"]
       ↓
   Load lesson:
   ├─ Firebase Storage: Audio files
   ├─ Firestore: Lesson content
   └─ SQLite: Cache local
       ↓
   Display interactive lesson:
   ├─ Texte adapté niveau
   ├─ Audio prononciation
   ├─ Exercices (5 questions)
   └─ Quiz final (10 questions)
       ↓
   Complétion leçon
       ↓
   Score quiz: 8/10 (80%)
       ↓
   Update progression:
   ├─ Firestore: user_progress/{uid}
   │  ├─ lessonsCompleted: +1
   │  ├─ xpEarned: +50
   │  ├─ score: 80%
   │  └─ timestamp
   │
   ├─ Gamification:
   │  ├─ Check badge unlocked?
   │  ├─ Check level up?
   │  └─ Update leaderboard
   │
   └─ Recommendations:
      └─ ML: Next lesson suggestion
          ↓
   Notification: "Bravo! +50 XP, Leçon complétée!"
       ↓
   Retour dashboard avec progression mise à jour
```

---

### Cycle 2: Enseignant Crée Devoir → Élève Soumet → Notation → Bulletin

```
ÉTAPE 1: CRÉATION DEVOIR (Enseignant)
Teacher Dashboard → [Devoirs] → [Créer Nouveau]
    ├─ Classe: CM2 A (35 élèves)
    ├─ Matière: Ewondo
    ├─ Titre: "Vocabulaire de la Famille"
    ├─ Description: "Apprendre 20 mots + exercices"
    ├─ Date assignation: 7 oct 2024
    ├─ Date limite: 14 oct 2024 (7 jours)
    ├─ Note sur: /20
    ├─ Type: Homework
    └─ [Publier]
        ↓
Firebase: homework/{hw_id}
    ├─ classroomId: "class_cm2_a"
    ├─ teacherId: "teacher_marie"
    ├─ studentIds: [35 élèves]
    ├─ dueDate: "2024-10-14"
    └─ maxPoints: 20
        ↓
Cloud Function: NotifyStudents
    └─ 35 notifications push élèves
    └─ 35 notifications push parents
        ↓
Élèves reçoivent: "Nouveau devoir Ewondo à rendre lundi"

---

ÉTAPE 2: SOUMISSION ÉLÈVE (Paul)
Student Dashboard → [Devoirs] → [Vocabulaire Famille]
    ↓
[Lire Consigne]
    ├─ 20 mots à apprendre
    ├─ Créer phrases exemples
    └─ Compléter exercices
        ↓
[Travailler sur devoir]
    ├─ Utiliser dictionnaire app
    ├─ Écouter prononciations
    ├─ Pratiquer avec IA
    └─ Rédiger réponses
        ↓
[Sauvegarder Brouillon] (optionnel)
    └─ Firestore: submissions/{sub_id}
       └─ status: "draft"
           ↓
[Finaliser et Soumettre]
    ├─ Upload fichier (optionnel)
    ├─ Saisir réponses
    └─ [Soumettre Définitif]
        ↓
Firestore: submissions/{sub_id}
    ├─ status: "submitted"
    ├─ submittedDate: "2024-10-12"
    ├─ content: {...}
    └─ late: false (dans les temps)
        ↓
Notification Enseignant
    └─ "Paul Mbarga a rendu son devoir Ewondo"
        ↓
Notification Parent
    └─ "Paul a soumis son devoir Ewondo (dans les temps ✅)"

---

ÉTAPE 3: CORRECTION ENSEIGNANT (Marie)
Teacher Dashboard → [Devoirs] → [Soumissions à Corriger]
    ├─ Vocabulaire Famille: 35 soumissions
    ├─ Dont 32 rendues, 3 non rendues
    └─ [Ouvrir soumission Paul]
        ↓
Interface Correction
    ├─ Affichage réponses Paul
    ├─ Grille de correction
    ├─ Note: __/20
    └─ Feedback textuel
        ↓
[Noter: 18/20]
[Feedback: "Excellent travail Paul! Très bon vocabulaire."]
    ↓
[Valider Correction]
    ↓
Firestore: submissions/{sub_id}
    ├─ grade: 18
    ├─ feedback: "Excellent..."
    └─ status: "graded"
        ↓
Firestore: grades/{grade_id} (NOUVEAU)
    ├─ studentId: "paul_001"
    ├─ classroomId: "class_cm2_a"
    ├─ subject: "Ewondo"
    ├─ assessmentType: "homework"
    ├─ score: 18.0
    ├─ maxScore: 20.0
    ├─ termId: "2024-2025_term1"
    ├─ date: "2024-10-12"
    └─ teacherId: "teacher_marie"
        ↓
Notification Élève
    └─ "Ton devoir Ewondo est corrigé: 18/20 (Excellent!) 🎉"
        ↓
Notification Parent
    └─ "Paul a obtenu 18/20 en Ewondo (Excellent)"
        ↓
Update Gamification
    ├─ +100 XP pour Paul
    ├─ Badge débloqué: "Maître de Famille"
    └─ Update leaderboard

---

ÉTAPE 4: CALCUL MOYENNE (Automatique)
Trigger: Nouvelle note ajoutée
    ↓
Cloud Function: CalculateAverages
    ├─ Query: Toutes notes Paul, Ewondo, Trimestre 1
    │  └─ Quiz 1: 17/20
    │  └─ Devoir 1: 18/20
    │  └─ Quiz 2: 16/20
    │      ↓
    ├─ Calcul moyenne: (17+18+16)/3 = 17.0/20
    ├─ Appreciation: "Excellent"
    └─ Update Firestore: student_averages/{paul_term1}
        └─ subjects: { Ewondo: 17.0, ... }
            ↓
Update Dashboard Élève
    └─ Moyenne Ewondo: 17.0/20 ✅

---

ÉTAPE 5: GÉNÉRATION BULLETIN (Fin Trimestre)
Enseignant → [Bulletins] → [Générer Trimestre 1]
    ↓
Cloud Function: GenerateReportCards
    │
    Pour chaque élève (35):
    ├─ Query toutes notes trimestre 1
    ├─ Grouper par matière
    ├─ Calculer moyennes matières
    ├─ Calculer moyenne générale
    ├─ Calculer rang classe (tri décroissant moyennes)
    ├─ Remplir template bulletin
    └─ Generate PDF
        ↓
    Firestore: report_cards/{paul_t1}
        ├─ studentId: "paul_001"
        ├─ termId: "2024-2025_term1"
        ├─ subjectGrades: [
        │    { subject: "Ewondo", average: 17.0, ... },
        │    { subject: "Français", average: 14.0, ... },
        │    { subject: "Maths", average: 15.0, ... }
        │  ]
        ├─ overallAverage: 15.3/20
        ├─ rank: 3
        ├─ totalStudents: 38
        ├─ teacherComment: "Élève sérieux, continuez!"
        ├─ directorComment: "Félicitations"
        └─ pdfUrl: "storage/bulletins/paul_t1.pdf"
            ↓
    Notification Élève + Parent
        └─ "Bulletin 1er Trimestre disponible"
            ↓
    Consultation Bulletin
        ├─ Vue en ligne
        ├─ Téléchargement PDF
        └─ Partage famille
```

**Cycle Complet:** 1 semaine (création) + 3 mois (accumulation notes) + 1 jour (bulletin)

---

## 🎓 Flux Pédagogique Complet

### Parcours d'Apprentissage Élève sur 1 Trimestre

```
SEMAINE 1 (Rentrée)
Jour 1: Découverte app + Évaluation diagnostique
    ├─ Test niveau initial Ewondo
    ├─ Résultat: Niveau Débutant
    └─ Recommandation: Commencer Module 1
        ↓
Jour 2-5: Module 1 - Salutations
    ├─ 4 leçons interactives
    ├─ 20 nouveaux mots
    ├─ 4 quiz (80% moyen)
    └─ Badge: "Premier Pas" débloqué

SEMAINE 2-4: Modules 2-4
    ├─ Nombres, Famille, Maison
    ├─ 60 mots cumulés
    ├─ Progression: 15% curriculum
    └─ 3 nouveaux badges

SEMAINE 5: PREMIER DEVOIR
    ├─ Assigné par prof
    ├─ Travail personnel
    ├─ Soumission app
    └─ Note: 18/20 ✅

SEMAINE 6-10: Modules 5-8 + Devoir 2
    ├─ Progression: 40% curriculum
    ├─ 150 mots maîtrisés
    └─ Note devoir 2: 16/20 ✅

SEMAINE 11: QUIZ INTERMÉDIAIRE
    ├─ Évaluation prof (dans app)
    ├─ 20 questions
    ├─ Note: 17/20 ✅
    └─ Moyenne à ce stade: 17.0/20

SEMAINE 12-14: Révisions + Modules 9-10
    ├─ Flashcards révision
    ├─ Conversations IA
    ├─ Jeux éducatifs
    └─ Progression: 65% curriculum

SEMAINE 15: EXAMEN FINAL TRIMESTRE 1
    ├─ Examen complet (papier + oral)
    ├─ Note finale: 16.5/20 ✅
    └─ Moyenne trimestre calculée: 17.0/20

FIN TRIMESTRE
    ↓
Bulletin Généré Auto
    ├─ Ewondo: 17.0/20 (Excellent)
    ├─ Rang: 3ème/38
    └─ Commentaire: "Très bon travail!"
        ↓
Passage Trimestre 2
    ├─ Continue progression
    ├─ Objectif: Niveau Intermédiaire
    └─ Nouveaux modules débloqués
```

**Engagement:** Quotidien (30-60 min)  
**Résultats Mesurables:** Notes, badges, progression curriculum

---

### Cycle 2: Gestion Classe Enseignant (1 Trimestre)

```
DÉBUT TRIMESTRE (Septembre)
Semaine 1: Setup
    ├─ Création classes CM2 A + CM2 B
    ├─ Import liste élèves (CSV ou manuel)
    ├─ Configuration emploi du temps
    ├─ Planification curriculum trimestre
    └─ Publication plan trimestre (cahier de textes)

SEMAINES 2-5: Routine Quotidienne
Chaque Jour:
    ├─ 08:00 - Prise présences CM2 A (2 min)
    ├─ 10:30 - Prise présences CM2 B (2 min)
    └─ Soir - Préparation cours lendemain (15 min)

Chaque Semaine:
    ├─ Lundi - Création 1-2 devoirs
    ├─ Mercredi - Correction devoirs (1h)
    ├─ Vendredi - Saisie notes quiz (30 min)
    └─ Dimanche - Planification semaine suivante (30 min)

SEMAINE 6: ÉVALUATION INTERMÉDIAIRE
    ├─ Quiz intermédiaire (en classe papier)
    ├─ Saisie notes 67 élèves (app)
    ├─ Analyse résultats (dashboard analytics)
    ├─ Identification 5 élèves en difficulté
    └─ Plan remédiation personnalisé

SEMAINES 7-12: Remédiation + Routine
    ├─ Sessions soutien élèves difficulté
    ├─ Exercices supplémentaires (app)
    ├─ Suivi rapproché
    └─ Communication parents intensifiée

SEMAINE 13-14: RÉVISIONS
    ├─ Leçons récapitulatives
    ├─ Quiz blancs
    ├─ Conseils examens
    └─ Révisions guidées

SEMAINE 15: EXAMENS FINAUX
    ├─ Examen écrit (en classe)
    ├─ Examen oral (évaluation individuelle)
    ├─ Saisie notes 67 élèves
    └─ Vérification complétude notes

POST-TRIMESTRE
    ├─ [Générer Bulletins 67 élèves] (1 clic)
    ├─ Révision bulletins (ajout commentaires)
    ├─ Conseil de classe (présentation stats)
    ├─ Signature numérique bulletins
    └─ Publication bulletins
        ↓
    Notifications 67 élèves + parents
        ↓
    Début Trimestre 2 (Janvier)
```

**Gain de Temps vs Papier:** 80 heures économisées

---

## 🔗 Diagrammes UML

### Diagramme de Cas d'Utilisation (Use Case)

```
                    Système Ma'a Yegue
                           
┌────────────────────────────────────────────────────┐
│                                                    │
│                   VISITEUR                         │
│  ┌─────────────────────────────────────┐          │
│  │ • Explorer contenu gratuit          │          │
│  │ • Consulter culture                 │          │
│  │ • Tester leçons démo                │          │
│  │ • S'inscrire                        │          │
│  └─────────────────────────────────────┘          │
│                      ↓                             │
│                   ÉLÈVE                            │
│  ┌─────────────────────────────────────┐          │
│  │ • Suivre leçons                     │          │
│  │ • Faire devoirs                     │          │
│  │ • Consulter notes                   │          │
│  │ • Jouer jeux éducatifs              │          │
│  │ • Utiliser IA conversationnelle     │          │
│  │ • Participer communauté             │          │
│  │ • Gagner badges                     │          │
│  └─────────────────────────────────────┘          │
│                      ↓                             │
│                 ENSEIGNANT                         │
│  ┌─────────────────────────────────────┐          │
│  │ • Gérer classes (création)          │          │
│  │ • Prendre présences                 │          │
│  │ • Créer devoirs                     │          │
│  │ • Corriger travaux                  │          │
│  │ • Noter élèves (/20)                │          │
│  │ • Générer bulletins                 │          │
│  │ • Communiquer parents               │          │
│  │ • Planifier leçons (cahier textes)  │          │
│  │ • Analyser performances classe      │          │
│  └─────────────────────────────────────┘          │
│                      ↓                             │
│                   PARENT                           │
│  ┌─────────────────────────────────────┐          │
│  │ • Suivre enfant(s) temps réel       │          │
│  │ • Consulter notes/bulletins         │          │
│  │ • Voir présences/absences           │          │
│  │ • Contacter enseignants             │          │
│  │ • Planifier RDV                     │          │
│  │ • Recevoir annonces école           │          │
│  │ • Justifier absences                │          │
│  └─────────────────────────────────────┘          │
│                      ↓                             │
│              DIRECTEUR D'ÉCOLE                     │
│  ┌─────────────────────────────────────┐          │
│  │ • Gérer établissement               │          │
│  │ • Créer classes                     │          │
│  │ • Affecter enseignants              │          │
│  │ • Publier annonces                  │          │
│  │ • Analyser performances             │          │
│  │ • Générer rapports MINEDUC          │          │
│  │ • Organiser conseils de classe      │          │
│  │ • Valider bulletins                 │          │
│  └─────────────────────────────────────┘          │
│                      ↓                             │
│                 INSPECTEUR                         │
│  ┌─────────────────────────────────────┐          │
│  │ • Superviser région                 │          │
│  │ • Comparer établissements           │          │
│  │ • Identifier écoles difficulté      │          │
│  │ • Recommandations pédagogiques      │          │
│  │ • Rapports statistiques MINEDUC     │          │
│  └─────────────────────────────────────┘          │
│                      ↓                             │
│             ADMINISTRATEUR MINEDUC                 │
│  ┌─────────────────────────────────────┐          │
│  │ • Vue nationale                     │          │
│  │ • Statistiques toutes régions       │          │
│  │ • Indicateurs éducatifs             │          │
│  │ • Accréditation établissements      │          │
│  │ • Validation curriculum             │          │
│  └─────────────────────────────────────┘          │
│                                                    │
└────────────────────────────────────────────────────┘

SERVICES EXTERNES:
├─ Firebase (Auth, Firestore, Storage, Functions)
├─ Gemini AI (Conversations)
├─ Mobile Money (Paiements)
├─ SMS Gateway (Notifications)
└─ Email Service (Communications)
```

---

### Diagramme de Séquence - Soumission Devoir

```
Élève    App      Firebase     Cloud      Enseignant  Parent
  │       │          │        Function       │          │
  │──[1]─→│          │           │           │          │
  │ Soumet│          │           │           │          │
  │ devoir│          │           │           │          │
  │       │──[2]────→│           │           │          │
  │       │  Save    │           │           │          │
  │       │ submission          │           │          │
  │       │          │───[3]───→│           │          │
  │       │          │  Trigger │           │          │
  │       │          │  Function│           │          │
  │       │          │          │───[4]────→│          │
  │       │          │          │  Notif    │          │
  │       │          │          │  Prof     │          │
  │       │          │          │──[5]─────────────────→│
  │       │          │          │  Notif Parent        │
  │       │←─[6]─────│          │           │          │
  │  Confirmation    │          │           │          │
  │  + Notif         │          │           │          │
  │       │          │          │           │          │
  
  ... Quelques jours plus tard ...
  
  │       │          │          │           │          │
  │       │          │          │           │          │
  │       │          │          │      [7]  │          │
  │       │          │          │←──── Prof │          │
  │       │          │          │    Corrige│          │
  │       │          │          │    Note   │          │
  │       │          │←────[8]──│           │          │
  │       │          │   Save   │           │          │
  │       │          │   Grade  │           │          │
  │       │          │───[9]───→│           │          │
  │       │          │  Trigger │           │          │
  │       │←─[10]────│  Calc    │           │          │
  │  Notif│          │  Average │           │          │
  │  Note │          │          │           │          │
  │       │          │          │──[11]────────────────→│
  │       │          │          │  Notif Parent        │
  │       │          │          │  Note publiée        │
```

**Légende:**
1. Élève soumet devoir via app
2. App sauvegarde dans Firebase
3. Trigger Cloud Function (notifications)
4. Notification push enseignant
5. Notification push parent
6. Confirmation à l'élève
7. Enseignant corrige et note
8. Sauvegarde note Firebase
9. Trigger calcul moyenne
10. Notification élève (note publiée)
11. Notification parent (note publiée)

---

### Diagramme de Classes - Système Éducatif

```
┌─────────────────────┐
│   <<enumeration>>   │
│    GradeLevel       │
├─────────────────────┤
│ + cp                │
│ + ce1, ce2          │
│ + cm1, cm2          │
│ + sixieme, ...      │
│ + terminale         │
├─────────────────────┤
│ + code: String      │
│ + fullName: String  │
│ + level: int        │
│ + typicalAge: int   │
└─────────────────────┘
          △
          │ uses
          │
┌─────────────────────┐         ┌──────────────────┐
│      School         │1      * │   Classroom      │
├─────────────────────┤────────┤──────────────────┤
│ - id: String        │  has   │ - id: String     │
│ - name: String      │        │ - schoolId: ref  │
│ - code: String      │        │ - name: String   │
│ - type: SchoolType  │        │ - gradeLevel: ref│
│ - directorId: ref   │        │ - teacherId: ref │
│ - region: String    │        │ - studentIds: [] │
├─────────────────────┤        │ - maxCapacity: int│
│ + toJson()          │        ├──────────────────┤
│ + fromJson()        │        │ + isFull: bool   │
└─────────────────────┘        │ + toJson()       │
                               └──────────────────┘
                                       △
                                       │ belongs to
                                       │
┌──────────────────┐                   │
│     Student      │ *                 │
├──────────────────┤───────────────────┘
│ - id: String     │
│ - name: String   │
│ - gradeLevel: ref│
│ - classroomId:ref│
│ - parentIds: []  │
├──────────────────┤
│ + age: int       │
└──────────────────┘
         │
         │ receives
         ↓
┌──────────────────┐         ┌──────────────────┐
│      Grade       │  part   │   ReportCard     │
├──────────────────┤   of    ├──────────────────┤
│ - studentId: ref │────────→│ - studentId: ref │
│ - score: double  │  *    1 │ - termId: ref    │
│ - maxScore: 20   │         │ - subjectGrades[]│
│ - subject: String│         │ - overallAvg: dbl│
│ - termId: ref    │         │ - rank: int      │
├──────────────────┤         ├──────────────────┤
│ + percentage: dbl│         │ + toJson()       │
│ + letterGrade: St│         │ + fromJson()     │
│ + appreciation:St│         └──────────────────┘
└──────────────────┘
         △
         │ creates
         │
┌──────────────────┐
│     Teacher      │
├──────────────────┤
│ - id: String     │
│ - classrooms: [] │
│ - subjects: []   │
├──────────────────┤
│ + createHomework │
│ + gradeStudent   │
│ + markAttendance │
└──────────────────┘
         △
         │ monitors
         │
┌──────────────────┐
│      Parent      │
├──────────────────┤
│ - id: String     │
│ - childrenIds: []│
├──────────────────┤
│ + viewGrades     │
│ + sendMessage    │
│ + scheduleMeeting│
└──────────────────┘
```

---

### Diagramme d'États - Statut Devoir

```
┌──────────┐
│  CRÉÉ    │ (Enseignant crée devoir)
└────┬─────┘
     │ Publication
     ↓
┌──────────┐
│ ASSIGNÉ  │ (Élève reçoit notification)
└────┬─────┘
     │ Élève commence
     ↓
┌──────────┐
│ BROUILLON│ (Élève travaille, sauvegarde)
└────┬─────┘
     │ Élève soumet
     ↓
┌──────────┐
│  SOUMIS  │ (En attente correction)
└────┬─────┘
     │ Enseignant corrige
     ↓
┌──────────┐
│  CORRIGÉ │ (Note + feedback publiés)
└────┬─────┘
     │ Archivage
     ↓
┌──────────┐
│ ARCHIVÉ  │ (Fin d'année)
└──────────┘

ÉTAT PARALLÈLE (Délai):
┌──────────┐
│ À TEMPS  │ (submitted before dueDate)
└──────────┘
     OU
┌──────────┐
│EN RETARD │ (submitted after dueDate)
└──────────┘
     OU
┌──────────┐
│NON RENDU │ (dueDate passed, no submission)
└──────────┘
```

---

### Diagramme d'Activité - Génération Bulletin

```
                 [DÉBUT]
                    ↓
         ┌──────────────────────┐
         │ Enseignant demande   │
         │ génération bulletins │
         └──────────┬───────────┘
                    ↓
         ┌──────────────────────┐
         │ Sélectionner:        │
         │ - Classe             │
         │ - Trimestre          │
         └──────────┬───────────┘
                    ↓
         ┌──────────────────────┐
         │ Pour chaque élève    │
         └──────────┬───────────┘
                    ↓
         ┌──────────────────────┐
         │ Récupérer toutes     │
         │ notes trimestre      │
         └──────────┬───────────┘
                    ↓
              ┌─────────┐
              │ Notes   │ OUI
              │ existe? ├──────→ ┌────────────────┐
              └────┬────┘        │ Grouper par    │
                   │ NON         │ matière        │
                   ↓             └───────┬────────┘
         ┌──────────────────┐           ↓
         │ Erreur: Aucune   │  ┌────────────────────┐
         │ note pour élève  │  │ Calculer moyennes  │
         └──────────────────┘  │ par matière        │
                               └───────┬────────────┘
                                       ↓
                            ┌──────────────────────┐
                            │ Calculer moyenne     │
                            │ générale             │
                            └───────┬──────────────┘
                                    ↓
                            ┌──────────────────────┐
                            │ Calculer rang dans   │
                            │ la classe            │
                            └───────┬──────────────┘
                                    ↓
                            ┌──────────────────────┐
                            │ Remplir template     │
                            │ bulletin (PDF)       │
                            └───────┬──────────────┘
                                    ↓
                            ┌──────────────────────┐
                            │ Ajouter commentaires │
                            │ enseignant           │
                            └───────┬──────────────┘
                                    ↓
                            ┌──────────────────────┐
                            │ Ajouter commentaires │
                            │ directeur (optionnel)│
                            └───────┬──────────────┘
                                    ↓
                            ┌──────────────────────┐
                            │ Signature numérique  │
                            │ enseignant + directeur│
                            └───────┬──────────────┘
                                    ↓
                            ┌──────────────────────┐
                            │ Sauvegarder Firestore│
                            │ + Storage (PDF)      │
                            └───────┬──────────────┘
                                    ↓
                            ┌──────────────────────┐
                            │ Envoyer notifications│
                            │ élève + parent       │
                            └───────┬──────────────┘
                                    ↓
                                 [FIN]
```

---

## 🎯 Points Clés pour Jury

### 1. Architecture Exemplaire
> "L'application utilise **Clean Architecture** avec séparation stricte des couches (Presentation, Domain, Data, Infrastructure), garantissant **maintenabilité et testabilité maximales**."

### 2. Expérience Utilisateur Différenciée
> "Chaque type d'utilisateur (12 rôles) a une interface **adaptée à ses besoins** et son **niveau hiérarchique**, du simple visiteur au représentant MINEDUC."

### 3. Flux de Données Optimisés
> "Utilisation de **Firebase** pour scalabilité automatique, **SQLite** pour fonctionnement hors ligne, et **Cloud Functions** pour logique métier côté serveur."

### 4. Communication Multi-Niveaux
> "Communication **temps réel** entre tous les acteurs (élèves, parents, enseignants, direction) avec **notifications push intelligentes** et **messagerie sécurisée**."

### 5. Conformité Système Camerounais
> "Respecte à 100% les **normes MINEDUC**: calendrier scolaire, notation /20, structure hiérarchique, programmes officiels."

---

**Document créé pour:** Présentation Jury Master  
**Usage:** Référence technique complète  
**Niveau:** Professionnel - Académique  
**Complément:** GUIDE_PRESENTATION_JURY_MASTER.md

