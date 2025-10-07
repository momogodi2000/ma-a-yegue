import '../../domain/entities/culture_entities.dart';
import '../models/culture_models.dart';

/// Sample Culture Content for Guest Users and Demo Purposes
/// This provides rich, authentic Cameroonian cultural content across all categories
class SampleCultureContent {
  
  /// Get sample culture content (traditions, ceremonies, folklore, etc.)
  static List<CultureContentModel> getSampleCultureContent() {
    final now = DateTime.now();
    
    return [
      // TRADITIONS
      CultureContentModel(
        id: 'culture_001',
        title: 'La Chefferie Traditionnelle Bamiléké',
        description: 'Découvrez l\'organisation sociale et politique des royaumes Bamiléké, avec leurs chefs traditionnels (Fo) et leur système de gouvernance ancestral.',
        content: '''
# La Chefferie Traditionnelle Bamiléké

## Organisation Hiérarchique

La société Bamiléké est structurée autour du **Fo** (chef traditionnel), considéré comme le représentant des ancêtres et le garant de la stabilité du royaume.

### Structure du Pouvoir

1. **Le Fo (Chef)** - Leader suprême spirituel et politique
2. **Les Notables (Kamveu)** - Conseillers et représentants des clans
3. **Les Sociétés Secrètes** - Gardiens des traditions (Mkem, Kwosi)
4. **Les Serviteurs Royaux** - Administrateurs du palais

## Symboles de Pouvoir

- **Le Trône Royal (Nji)** - Siège sacré du pouvoir
- **Le Chapeau à Plumes** - Signe distinctif de royauté
- **Le Bâton de Commandement** - Symbole d\'autorité
- **Les Masques Sacrés** - Connexion avec les ancêtres

## Rôles et Responsabilités

Le Fo assure:
- La justice traditionnelle
- La protection spirituelle du peuple
- La médiation entre vivants et ancêtres
- La préservation des terres et traditions

## Succession

La succession suit des règles strictes:
- Transmission généralement au fils aîné
- Validation par les notables
- Rituels d\'initiation secrets
- Bénédiction des ancêtres
''',
        language: 'Français',
        category: CultureCategory.traditions,
        imageUrl: 'https://images.unsplash.com/photo-1547471080-7cc2caa01a7e?w=800',
        tags: ['chefferie', 'bamiléké', 'tradition', 'organisation sociale', 'pouvoir'],
        metadata: {
          'region': 'Ouest Cameroun',
          'ethnic_group': 'Bamiléké',
          'complexity': 'intermediate',
          'estimated_read_time': '5 minutes',
        },
        createdAt: now.subtract(const Duration(days: 10)),
      ),

      CultureContentModel(
        id: 'culture_002',
        title: 'Les Cérémonies de Mariage Traditionnel',
        description: 'Le mariage traditionnel camerounais est une célébration riche en rituels, symboles et étapes qui unissent deux familles.',
        content: '''
# Le Mariage Traditionnel Camerounais

## Les Étapes du Mariage

### 1. La Demande en Mariage (Nkap Nkong)

La famille du prétendant envoie des émissaires pour manifester l\'intérêt:
- Présentation officielle
- Remise de cadeaux symboliques (vin de palme, noix de kola)
- Dialogue avec la famille de la jeune fille

### 2. La Dot (Nkap)

La dot représente la reconnaissance et le respect:
- **Éléments traditionnels**: chèvres, vin de palme, huile, sel
- **Éléments modernes**: argent, tissus, bijoux
- **Valeur symbolique** plus qu\'économique

### 3. La Cérémonie Principale

**Déroulement:**
- Accueil des familles
- Présentation de la dot
- Bénédictions des anciens
- Union officielle par les parents
- Partage du vin de palme
- Festin communautaire

## Symboles Importants

### Le Vin de Palme
- Symbole de vie et de fertilité
- Partage entre les deux familles
- Sceau de l\'union

### Les Tenues Traditionnelles
- **Toghu** pour les hommes (robe brodée)
- **Kabba** pour les femmes (wrapper et blouse)
- Couleurs vives et motifs symboliques

### Les Danses
- Bikutsi (Centre)
- Makossa (Littoral)
- Assiko (Sud)
- Danses bamiléké de célébration

## Valeurs Transmises

Le mariage traditionnel incarne:
- L\'union de deux familles (pas seulement deux individus)
- Le respect des aînés et des traditions
- La bénédiction des ancêtres
- La continuité de la lignée
''',
        language: 'Français',
        category: CultureCategory.ceremonies,
        imageUrl: 'https://images.unsplash.com/photo-1519741497674-611481863552?w=800',
        tags: ['mariage', 'cérémonie', 'dot', 'famille', 'tradition'],
        metadata: {
          'region': 'National',
          'complexity': 'beginner',
          'estimated_read_time': '6 minutes',
        },
        createdAt: now.subtract(const Duration(days: 8)),
      ),

      // FOLKLORE
      CultureContentModel(
        id: 'culture_003',
        title: 'Le Conte de la Tortue et l\'Éléphant',
        description: 'Un conte traditionnel africain enseignant que l\'intelligence vaut mieux que la force brute.',
        content: '''
# La Tortue et l\'Éléphant - Conte Traditionnel

## Le Récit

Il était une fois, dans la grande forêt camerounaise, une **tortue** très rusée nommée Kulu et un **éléphant** puissant appelé Njoku.

### Le Défi

Un jour, l\'éléphant se moqua de la tortue:
> "Tu es si petite et lente ! À quoi sers-tu dans cette forêt ?"

La tortue répondit calmement:
> "La taille n\'est pas tout, mon ami. L\'intelligence surpasse la force."

Vexé, l\'éléphant proposa un défi:
> "Prouve-le ! Nous tirerons chacun un bout d\'une liane. Celui qui fait tomber l\'autre gagne."

### La Ruse de Kulu

La tortue accepta, mais secrètement, elle attacha l\'autre bout de la liane à un **hippopotame** endormi au bord de la rivière.

Quand l\'éléphant commença à tirer, il se retrouva en fait en compétition avec l\'hippopotame ! Chacun pensait affronter la petite tortue.

Après des heures d\'efforts épuisants, les deux géants abandonnèrent, impressionnés par la "force" de la tortue.

### La Leçon

La tortue révéla sa ruse aux animaux de la forêt:
> "Vous voyez, mes amis, j\'ai utilisé mon intelligence plutôt que ma force. C\'est la sagesse qui l\'emporte toujours."

## Morale du Conte

**L\'intelligence et la ruse triomphent de la force brute.**

Ce conte enseigne aux enfants:
- La valeur de la réflexion
- L\'importance de l\'humilité
- Le danger de sous-estimer les autres
- La force de l\'ingéniosité

## Utilisation Pédagogique

**Valeurs transmises:**
- Respect de tous, peu importe la taille
- Résolution créative de problèmes
- Prudence face à l\'arrogance
- Sagesse ancestrale

**Discussion avec les enfants:**
- Quelles autres solutions la tortue aurait-elle pu trouver ?
- Pourquoi l\'éléphant était-il arrogant ?
- Comment appliquer cette leçon à l\'école ?
''',
        language: 'Français',
        category: CultureCategory.folklore,
        imageUrl: 'https://images.unsplash.com/photo-1601001815894-4bb6c81416d7?w=800',
        tags: ['conte', 'folklore', 'sagesse', 'enfants', 'morale'],
        metadata: {
          'age_group': 'Tous âges',
          'complexity': 'beginner',
          'estimated_read_time': '4 minutes',
          'educational_value': 'high',
        },
        createdAt: now.subtract(const Duration(days: 5)),
      ),

      // CUISINE
      CultureContentModel(
        id: 'culture_004',
        title: 'Le Ndolé - Plat National du Cameroun',
        description: 'Découvrez la recette authentique du Ndolé, ce délicieux mélange d\'épinards amers, d\'arachides et de viande/poisson.',
        content: '''
# Le Ndolé - Fierté Culinaire Camerounaise

## Qu\'est-ce que le Ndolé ?

Le **Ndolé** est considéré comme le **plat national du Cameroun**, particulièrement apprécié dans les régions du Littoral et du Centre.

### Ingrédients Principaux

**Base végétale:**
- Feuilles de ndolé (vernonia amara) - épinards amers
- Pâte d\'arachide (cacahuètes grillées et moulues)

**Protéines:**
- Viande de bœuf
- Poisson fumé et séché
- Crevettes séchées
- Tripes (facultatif)

**Assaisonnement:**
- Oignons, ail, gingembre
- Piment rouge
- Cubes Maggi
- Huile de palme

### Recette Traditionnelle

**Étape 1: Préparation des Feuilles**
1. Laver les feuilles de ndolé plusieurs fois
2. Faire bouillir 3 fois pour réduire l\'amertume
3. Hacher finement

**Étape 2: Cuisson des Protéines**
1. Faire bouillir la viande avec assaisonnement
2. Ajouter poisson et crevettes
3. Laisser mijoter

**Étape 3: Assemblage**
1. Diluer la pâte d\'arachide avec le bouillon
2. Ajouter les feuilles de ndolé
3. Incorporer huile de palme
4. Laisser mijoter 30 minutes
5. Rectifier l\'assaisonnement

**Accompagnement:**
- Miondo (bâtons de manioc)
- Riz
- Bobolo (tapioca)
- Plantain mûr

## Signification Culturelle

### Plat de Célébration

Le ndolé est servi lors de:
- Mariages traditionnels
- Baptêmes
- Funérailles
- Fêtes familiales

### Transmission Intergénérationnelle

La recette se transmet de mère en fille:
- Techniques de lavage des feuilles
- Dosage de l\'amertume
- Équilibre des saveurs
- Secrets familiaux

## Valeurs Nutritionnelles

**Bienfaits pour la santé:**
- Riche en protéines (viande, arachides)
- Fer et vitamines (épinards)
- Oméga-3 (poisson)
- Fibres alimentaires

## Variantes Régionales

- **Douala:** Plus d\'huile de palme, très riche
- **Yaoundé:** Version plus légère
- **Bafoussam:** Ajout d\'épices locales
- **Version moderne:** Sans viande (végétarien)

## Proverbe Associé

> "Le ndolé ne se mange pas avec une seule main"
> 
> Signifiant: Les bonnes choses nécessitent effort et collaboration
''',
        language: 'Français',
        category: CultureCategory.cuisine,
        imageUrl: 'https://images.unsplash.com/photo-1604908176997-125f25cc6f3d?w=800',
        tags: ['cuisine', 'ndolé', 'recette', 'gastronomie', 'tradition'],
        metadata: {
          'difficulty': 'intermediate',
          'preparation_time': '2 heures',
          'servings': '6-8 personnes',
          'complexity': 'intermediate',
        },
        createdAt: now.subtract(const Duration(days: 3)),
      ),

      // MUSIC & DANCE
      CultureContentModel(
        id: 'culture_005',
        title: 'Le Makossa - Musique de l\'Âme Camerounaise',
        description: 'Explorez l\'histoire et l\'évolution du Makossa, genre musical né à Douala qui a conquis l\'Afrique et le monde.',
        content: '''
# Le Makossa - Rythme du Cameroun

## Origines et Évolution

### Naissance (Années 1950-1960)

Le **Makossa** est né dans les quartiers populaires de **Douala**, capitale économique du Cameroun.

**Étymologie:**
- Mot Duala: "makossa" = "je danse"
- Expression de joie et de célébration

**Influences:**
- Rythmes traditionnels Sawa
- Ambiance des soirées populaires
- Jazz américain
- Highlife ghanéen

### L\'Âge d\'Or (1970-1980)

**Pionniers légendaires:**
- **Manu Dibango** - "Soul Makossa" (1972) - Hit mondial
- **Sam Fan Thomas** - "African Typic Collection"
- **Toto Guillaume**
- **Eboa Lotin**

**Caractéristiques musicales:**
- Tempo rapide et dansant
- Basse proéminente
- Cuivres énergiques
- Chant en Duala et Français
- Guitare rythmique syncopée

## Instruments Traditionnels

### Instruments Modernes
- Guitare basse électrique
- Guitare lead
- Batterie
- Cuivres (saxophones, trompettes)
- Synthétiseurs

### Instruments Traditionnels Intégrés
- **Balafon** - Xylophone africain
- **Tam-tam** - Tambours traditionnels
- **Hochets** - Percussions
- **Sanza** - Piano à pouces

## Danse Makossa

### Style de Danse

**Mouvements caractéristiques:**
- Déhanchements rapides
- Rotations des hanches
- Pas chassés
- Jeu des épaules
- Énergie communicative

**Contextes:**
- Mariages et baptêmes
- Fêtes populaires
- Nightclubs
- Célébrations nationales

### Apprentissage

La danse se transmet:
- Dans les quartiers populaires
- Lors des soirées festives
- Par imitation et pratique
- Créativité personnelle encouragée

## Impact Culturel

### Au Cameroun
- Symbole d\'identité nationale
- Unification des ethnies
- Expression de la fierté camerounaise

### International
- "Soul Makossa" samplé par Michael Jackson
- Influence sur la musique mondiale
- Représentation du Cameroun à l\'étranger

## Artistes Contemporains

**Nouvelle génération:**
- Petit Pays - Variante "Makossa Love"
- Charlotte Dipanda - Fusion moderne
- Stanley Enow - Makossa-Hip Hop

## Événements Majeurs

**Festivals:**
- Journée Nationale du Makossa (15 août)
- Festival Ngondo à Douala
- Concerts commémoratifs

## Citations Célèbres

> "Le Makossa, c\'est le cœur du Cameroun qui bat"
> - Manu Dibango

> "Quand le Makossa joue, les ethnies dansent ensemble"
> - Proverbe populaire

## Pour Aller Plus Loin

**Écouter:**
- Manu Dibango - "Soul Makossa"
- Sam Fan Thomas - "African Typic Collection"
- Toto Guillaume - "E Lam Mba"

**Apprendre:**
- Cours de danse Makossa à Douala
- Documentaires sur l\'histoire du genre
- Ateliers de percussions
''',
        language: 'Français',
        category: CultureCategory.music,
        imageUrl: 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=800',
        tags: ['makossa', 'musique', 'danse', 'Manu Dibango', 'culture'],
        metadata: {
          'complexity': 'intermediate',
          'estimated_read_time': '7 minutes',
          'region': 'Littoral - Douala',
          'international_impact': 'high',
        },
        createdAt: now.subtract(const Duration(days: 1)),
      ),

      // SPIRITUAL & ART
      CultureContentModel(
        id: 'culture_006',
        title: 'Les Masques Sacrés et leur Signification',
        description: 'Les masques traditionnels camerounais sont bien plus que des œuvres d\'art - ils sont des liens spirituels avec le monde des ancêtres.',
        content: '''
# Les Masques Sacrés du Cameroun

## Rôle Spirituel des Masques

Dans les cultures camerounaises, les **masques ne sont pas de simples objets décoratifs**. Ils sont:
- Incarnations des esprits ancestraux
- Médiateurs entre vivants et morts
- Gardiens des traditions sacrées
- Symboles de pouvoir et de sagesse

## Types de Masques par Région

### Région de l\'Ouest (Bamiléké)

**1. Masque du Roi (Mask du Fo)**
- Représente la puissance royale
- Utilisé lors des cérémonies d\'investiture
- Décoré de perles, cauris et plumes
- Accès réservé au chef et notables

**2. Masque de la Société Kwosi**
- Société secrète des guerriers
- Masque zoomorphe (animal)
- Protège le village
- Apparaît lors des funérailles importantes

### Région du Nord-Ouest (Grassfields)

**3. Masque Fon**
- Visage humain stylisé
- Corne symbolique de pouvoir
- Bois sculpté et patiné
- Symbolise la sagesse

### Région du Littoral (Duala)

**4. Masque Ngondo**
- Utilisé lors du festival Ngondo
- Lien avec l\'eau et les esprits aquatiques
- Cérémonies de purification
- Rituels de divination

## Matériaux et Fabrication

### Matériaux Traditionnels
- **Bois sacré** (fromager, ébène)
- **Raphia** tissé
- **Perles** et cauris
- **Plumes** d\'oiseaux rares
- **Peaux** d\'animaux
- **Pigments naturels** (argile, charbon)

### Processus de Création

**Étapes sacrées:**
1. Sélection du bois par divination
2. Prières et offrandes
3. Sculpture par artisan initié
4. Rites de consécration
5. Activation spirituelle

## Cérémonies et Utilisation

### Contextes d\'Apparition

**Occasions sacrées:**
- Funérailles de personnalités
- Intronisation de chefs
- Fêtes des moissons
- Rites d\'initiation
- Cérémonies de purification

### Règles Strictes

**Interdictions:**
- Les femmes ne peuvent souvent pas voir certains masques
- Toucher un masque sans initiation est tabou
- Nommer l\'esprit du masque à haute voix
- Photographier sans permission

## Symbolisme des Formes

### Éléments Visuels

**Cornes:**
- Pouvoir et domination
- Connexion spirituelle
- Force masculine

**Grands Yeux:**
- Vision au-delà du visible
- Surveillance des ancêtres
- Sagesse et connaissance

**Bouche Ouverte:**
- Transmission de la parole sacrée
- Cris rituels
- Communication avec les esprits

**Couleurs:**
- **Noir:** Fertilité, nuit, mystère
- **Blanc:** Pureté, esprits, mort
- **Rouge:** Pouvoir, sang, vie
- **Jaune/Or:** Richesse, soleil, divinité

## Conservation et Transmission

### Gardiens des Masques

- Conservés dans des lieux sacrés
- Gardés par des initiés désignés
- Entretien rituel régulier
- Transmission de père en fils

### Menaces Actuelles

**Défis contemporains:**
- Vol et trafic illicite
- Perte des connaissances rituelles
- Modernisation et conversion religieuse
- Commercialisation touristique

**Efforts de préservation:**
- Musées culturels locaux
- Documentation audiovisuelle
- Enseignement aux jeunes générations
- Protection juridique

## Masques et Art Contemporain

### Influence Mondiale

Les masques camerounais ont inspiré:
- Pablo Picasso et le cubisme
- Mouvement d\'art africain
- Designers contemporains
- Collectionneurs internationaux

### Artistes Modernes

Sculpteurs contemporains qui perpétuent:
- Intégration dans l\'art moderne
- Respect des traditions sacrées
- Fusion tradition-modernité

## Proverbe Traditionnel

> "Le masque ne danse jamais seul - c\'est l\'esprit qui le guide"
> 
> Rappel que les masques sont habités par des forces spirituelles

## Visite et Découverte

**Où voir les masques:**
- Musée National de Yaoundé
- Palais des Chefferies (Foumban)
- Festival Ngondo (Douala - décembre)
- Cérémonies traditionnelles (sur invitation)

**Règles de respect:**
- Demander permission avant photos
- Écouter les explications des gardiens
- Ne pas toucher sans autorisation
- Observer le silence lors des rituels
''',
        language: 'Français',
        category: CultureCategory.art,
        imageUrl: 'https://images.unsplash.com/photo-1582555172866-f73bb12a2ab3?w=800',
        tags: ['masques', 'art', 'spiritualité', 'tradition', 'ancêtres'],
        metadata: {
          'complexity': 'advanced',
          'estimated_read_time': '10 minutes',
          'sacred_content': true,
          'respect_required': 'high',
        },
        createdAt: now,
      ),
    ];
  }

  /// Get sample historical content
  static List<HistoricalContentModel> getSampleHistoricalContent() {
    final now = DateTime.now();
    
    return [
      HistoricalContentModel(
        id: 'history_001',
        title: 'L\'Indépendance du Cameroun - 1er Janvier 1960',
        description: 'Retour sur la lutte pour l\'indépendance et la naissance de la République du Cameroun.',
        content: '''
# L\'Indépendance du Cameroun

## Contexte Historique

### Période Coloniale

Le Cameroun fut sous domination:
- **Allemande** (1884-1916) - "Kamerun"
- **Franco-Britannique** (1919-1960) - Mandat SDN puis ONU

### Mouvements Nationalistes

**Figures clés:**
- **Um Nyobé Ruben** - Leader de l\'UPC (Union des Populations du Cameroun)
- **Ahmadou Ahidjo** - Premier Président
- **Félix-Roland Moumié** - Militant indépendantiste

## 1er Janvier 1960 - Jour de Liberté

**Événements:**
- Cérémonie officielle à Yaoundé
- Descente du drapeau français
- Levée du drapeau camerounais (vert-rouge-jaune)
- Discours d\'Ahmadou Ahidjo
- Liesse populaire

## Héritage

L\'indépendance apporte:
- Souveraineté nationale
- Siège à l\'ONU
- Développement économique
- Affirmation culturelle

## Célébration Annuelle

Chaque 1er janvier, le Cameroun célèbre:
- Défilés militaires
- Discours présidentiel
- Activités culturelles
- Jour férié national
''',
        language: 'Français',
        period: 'Indépendance',
        eventDate: DateTime(1960, 1, 1),
        location: 'Yaoundé, Cameroun',
        figures: ['Ahmadou Ahidjo', 'Um Nyobé Ruben', 'Félix-Roland Moumié'],
        imageUrl: 'https://images.unsplash.com/photo-1555992336-fb0d29498b13?w=800',
        sources: ['Archives nationales', 'Bibliothèque nationale du Cameroun'],
        metadata: {
          'importance': 'majeure',
          'complexity': 'intermediate',
          'estimated_read_time': '5 minutes',
        },
        createdAt: now.subtract(const Duration(days: 20)),
      ),

      HistoricalContentModel(
        id: 'history_002',
        title: 'Les Royaumes Bamoun - Histoire de Foumban',
        description: 'L\'histoire fascinante du royaume Bamoun et de sa capitale Foumban, centre culturel et artistique.',
        content: '''
# Le Royaume Bamoun

## Fondation et Dynastie

Le royaume Bamoun fut fondé vers **1394** par **Nchare Yen**, figure légendaire.

### Succession des Rois (Sultans)

Liste des 19 sultans jusqu\'à aujourd\'hui:
1. Nchare Yen (Fondateur)
2. Ngouonmbe
...
19. Ibrahim Mbombo Njoya (Sultan actuel)

## Sultan Njoya - Innovateur Visionnaire

**Règne:** 1889-1933

**Réalisations majeures:**
- Création de l\'**alphabet Bamoun** (A-ka-u-ku)
- Construction du palais royal de Foumban
- Modernisation du royaume
- Cartographie et architecture

### L\'Alphabet A-ka-u-ku

Un système d\'écriture unique:
- 80+ caractères originaux
- Inspiré des rêves du Sultan
- Utilisé pour archives royales
- Enseigné dans les écoles du royaume

## Patrimoine Culturel

### Le Palais Royal

- Architecture unique mêlant styles
- Musée des Arts et Traditions Bamoun
- Collections d\'objets royaux
- Site touristique majeur

### Artisanat Renommé

Foumban est célèbre pour:
- **Sculpture sur bois**
- **Tissage et broderie**
- **Travail du bronze**
- **Poterie traditionnelle**

## Importance Actuelle

Foumban reste:
- Centre culturel majeur
- Pôle touristique
- Gardien des traditions
- Symbole de fierté nationale
''',
        language: 'Français',
        period: 'Précolonial et Colonial',
        eventDate: DateTime(1394),
        location: 'Foumban, Région de l\'Ouest',
        figures: ['Nchare Yen', 'Sultan Njoya', 'Ibrahim Mbombo Njoya'],
        imageUrl: 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800',
        sources: ['Palais Royal de Foumban', 'Archives Bamoun'],
        metadata: {
          'dynasty_duration': '600+ ans',
          'complexity': 'advanced',
          'estimated_read_time': '6 minutes',
        },
        createdAt: now.subtract(const Duration(days: 15)),
      ),
    ];
  }

  /// Get sample Yemba language content
  static List<YembaContentModel> getSampleYembaContent() {
    final now = DateTime.now();
    
    return [
      YembaContentModel(
        id: 'yemba_001',
        title: 'Salutations de Base en Yemba',
        content: '''
# Salutations Essentielles

## Salutations du Matin

**Yemba:** Mbèhguà
**Prononciation:** [mbè-gwa]
**Français:** Bonjour (matin)

## Salutations Générales

**Yemba:** Mètèghe
**Prononciation:** [mè-tè-ghè]
**Français:** Bonjour / Bonsoir

## Comment ça va ?

**Question:** Ghà mbè ?
**Prononciation:** [gha mbè]
**Réponse:** Ghè mbè (Ça va bien)

## Réponses Courantes

- **Ghè mbè** - Ça va bien
- **Ghè mbè pù** - Ça va très bien
- **Ghà nè ka mbè** - Ça ne va pas bien
''',
        category: YembaCategory.greetings,
        difficulty: 'beginner',
        audioUrl: null, // Can be populated with real audio files
        imageUrl: 'https://images.unsplash.com/photo-1582213782179-e0d53f98f2ca?w=800',
        examples: [
          'Mbèhguà ! Comment vas-tu ce matin ?',
          'Mètèghe, ghà mbè ? - Bonjour, comment vas-tu ?',
          'Ghè mbè pù ! - Je vais très bien !',
        ],
        translations: {
          'fr': 'Salutations de base',
          'en': 'Basic Greetings',
        },
        tags: ['salutations', 'débutant', 'essentiel', 'quotidien'],
        metadata: {
          'lesson_number': 1,
          'complexity': 'beginner',
          'practice_exercises': 5,
        },
        createdAt: now.subtract(const Duration(days: 7)),
      ),

      YembaContentModel(
        id: 'yemba_002',
        title: 'Les Nombres en Yemba (1-20)',
        content: '''
# Compter en Yemba

## Nombres de 1 à 10

1. **Pò** - Un
2. **Pà** - Deux  
3. **Tà** - Trois
4. **Nà** - Quatre
5. **Tàhù** - Cinq
6. **Ntùkèh** - Six
7. **Sàmbà** - Sept
8. **Mbàhù** - Huit
9. **Vò** - Neuf
10. **Fù** - Dix

## Nombres de 11 à 20

11. **Fù nè pò** - Dix et un
12. **Fù nè pà** - Dix et deux
13. **Fù nè tà** - Dix et trois
...
20. **Mbù** - Vingt

## Utilisation

**Compter des objets:**
- Tà mèsù - Trois jours
- Pà ngù - Deux personnes
- Tàhù ndà - Cinq maisons
''',
        category: YembaCategory.numbers,
        difficulty: 'beginner',
        examples: [
          'Compter jusqu\'à 10',
          'Dire son âge: Mè ntàhù mèbù - J\'ai 5 ans',
          'Compter des objets quotidiens',
        ],
        translations: {
          'fr': 'Nombres 1-20',
          'en': 'Numbers 1-20',
        },
        tags: ['nombres', 'compter', 'mathématiques', 'débutant'],
        metadata: {
          'lesson_number': 2,
          'complexity': 'beginner',
          'quiz_available': true,
        },
        createdAt: now.subtract(const Duration(days: 5)),
      ),

      YembaContentModel(
        id: 'yemba_003',
        title: 'Proverbe: "La sagesse vient avec l\'âge"',
        content: '''
# Proverbe Yemba

## Le Proverbe

**Yemba:** Ntùè tù kàh nè mbèlè

**Traduction littérale:** La sagesse marche avec les cheveux blancs

**Sens:** L\'expérience et la sagesse viennent avec l\'âge

## Contexte d\'Utilisation

Ce proverbe est utilisé pour:
- Montrer respect aux aînés
- Enseigner l\'humilité aux jeunes
- Valoriser l\'expérience de vie
- Justifier l\'écoute des conseils anciens

## Leçon Culturelle

Dans la culture Bamiléké/Yemba:
- Les anciens sont très respectés
- Leurs conseils sont précieux
- L\'âge apporte la sagesse
- Les jeunes doivent écouter

## Exemples d\'Application

**À l\'école:**
"Écoute ton professeur, ntùè tù kàh nè mbèlè"

**En famille:**
"Grand-père sait mieux, il a la sagesse des années"

**Dans la communauté:**
Les chefs et notables sont consultés car ils portent la sagesse
''',
        category: YembaCategory.proverbs,
        difficulty: 'intermediate',
        examples: [
          'Contexte familial',
          'Conseils communautaires',
          'Transmission intergénérationnelle',
        ],
        translations: {
          'fr': 'La sagesse vient avec l\'âge',
          'en': 'Wisdom comes with age',
        },
        tags: ['proverbe', 'sagesse', 'respect', 'ancêtres', 'culture'],
        metadata: {
          'cultural_value': 'high',
          'complexity': 'intermediate',
          'discussion_topic': true,
        },
        createdAt: now.subtract(const Duration(days: 2)),
      ),
    ];
  }
}
