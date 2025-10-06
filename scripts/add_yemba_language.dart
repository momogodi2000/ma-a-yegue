import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Utility script to add Yemba language to the languages collection
/// Run this once to initialize Yemba as a language option
Future<void> addYembaLanguage() async {
  final firestore = FirebaseFirestore.instance;

  // Yemba language data
  final yembaLanguage = {
    'name': 'Yemba',
    'group': 'Bantu',
    'region': 'Centre Region, Cameroon',
    'type': 'traditional',
    'status': 'active',
    'createdAt': Timestamp.now(),
    'updatedAt': Timestamp.now(),
  };

  try {
    // Add Yemba to languages collection
    await firestore.collection('languages').add(yembaLanguage);
    debugPrint('Successfully added Yemba language to Firestore');

    // Also add some sample Yemba content to culture collections
    await _addSampleYembaContent(firestore);
  } catch (e) {
    debugPrint('Error adding Yemba language: $e');
  }
}

Future<void> _addSampleYembaContent(FirebaseFirestore firestore) async {
  // Sample Yemba vocabulary content
  final yembaVocabulary = {
    'id': 'yemba_vocab_001',
    'title': 'Basic Greetings in Yemba',
    'content': 'Mbot\'a - Hello\nNde - Thank you\nMbe - Goodbye',
    'category': 'vocabulary',
    'difficulty': 'beginner',
    'examples': [
      'Mbot\'a! - Hello!',
      'Nde mingi - Thank you very much',
      'Mbe, nkome - Goodbye, see you later'
    ],
    'translations': {
      'Mbot\'a': 'Hello',
      'Nde': 'Thank you',
      'Mbe': 'Goodbye'
    },
    'tags': ['greetings', 'basic', 'everyday'],
    'metadata': {
      'source': 'Community contribution',
      'verified': true
    },
    'createdAt': Timestamp.now(),
    'updatedAt': Timestamp.now(),
  };

  // Sample Yemba grammar content
  final yembaGrammar = {
    'id': 'yemba_grammar_001',
    'title': 'Yemba Verb Conjugation',
    'content': 'Yemba verbs conjugate based on tense and subject.\nPresent: me + verb\nPast: a + verb\nFuture: e + verb',
    'category': 'grammar',
    'difficulty': 'intermediate',
    'examples': [
      'me yian - I eat (present)',
      'a yian - I ate (past)',
      'e yian - I will eat (future)'
    ],
    'translations': {
      'me yian': 'I eat',
      'a yian': 'I ate',
      'e yian': 'I will eat'
    },
    'tags': ['verbs', 'conjugation', 'tense'],
    'metadata': {
      'source': 'Linguistic research',
      'verified': true
    },
    'createdAt': Timestamp.now(),
    'updatedAt': Timestamp.now(),
  };

  try {
    // Add to yemba_content collection
    await firestore.collection('yemba_content').add(yembaVocabulary);
    await firestore.collection('yemba_content').add(yembaGrammar);

    // Add some culture content about Yemba
    final yembaCulture = {
      'id': 'culture_yemba_001',
      'title': 'The Yemba People',
      'description': 'Learn about the Yemba ethnic group and their cultural heritage',
      'content': 'The Yemba people are part of the Beti-Pahuin group in Cameroon. They are known for their rich oral traditions, music, and dance.',
      'language': 'fr', // Content in French
      'category': 'traditions',
      'tags': ['ethnic_group', 'beti_pahuin', 'cameroon'],
      'metadata': {
        'region': 'Centre Region',
        'population': 'Approximately 100,000',
        'source': 'Cultural documentation'
      },
      'createdAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
    };

    await firestore.collection('culture_content').add(yembaCulture);

    debugPrint('Successfully added sample Yemba content');
  } catch (e) {
    debugPrint('Error adding sample Yemba content: $e');
  }
}

/// Main function to run the seeding
void main() async {
  // Note: This would need to be run in a Flutter environment with Firebase initialized
  // For now, this serves as documentation of what needs to be added
  debugPrint('Yemba language seeding script');
  debugPrint('To run this, initialize Firebase and call addYembaLanguage()');
}