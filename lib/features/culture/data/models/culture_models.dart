import '../../domain/entities/culture_entities.dart';

/// Culture Content Model for data layer
class CultureContentModel extends CultureContentEntity {
  const CultureContentModel({
    required super.id,
    required super.title,
    required super.description,
    required super.content,
    required super.language,
    required super.category,
    super.imageUrl,
    required super.tags,
    required super.metadata,
    required super.createdAt,
    super.updatedAt,
  });

  /// Create from JSON
  factory CultureContentModel.fromJson(Map<String, dynamic> json) {
    return CultureContentModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      content: json['content'] ?? '',
      language: json['language'] ?? '',
      category: CultureCategory.values.firstWhere(
        (e) => e.toString() == 'CultureCategory.${json['category']}',
        orElse: () => CultureCategory.traditions,
      ),
      imageUrl: json['imageUrl'],
      tags: List<String>.from(json['tags'] ?? []),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'content': content,
      'language': language,
      'category': category.toString().split('.').last,
      'imageUrl': imageUrl,
      'tags': tags,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Create from Firestore document
  factory CultureContentModel.fromFirestore(Map<String, dynamic> data, String id) {
    return CultureContentModel.fromJson({...data, 'id': id});
  }
}

/// Historical Content Model for data layer
class HistoricalContentModel extends HistoricalContentEntity {
  const HistoricalContentModel({
    required super.id,
    required super.title,
    required super.description,
    required super.content,
    required super.language,
    required super.period,
    super.eventDate,
    super.location,
    required super.figures,
    super.imageUrl,
    required super.sources,
    required super.metadata,
    required super.createdAt,
    super.updatedAt,
  });

  /// Create from JSON
  factory HistoricalContentModel.fromJson(Map<String, dynamic> json) {
    return HistoricalContentModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      content: json['content'] ?? '',
      language: json['language'] ?? '',
      period: json['period'] ?? '',
      eventDate: json['eventDate'] != null ? DateTime.parse(json['eventDate']) : null,
      location: json['location'],
      figures: List<String>.from(json['figures'] ?? []),
      imageUrl: json['imageUrl'],
      sources: List<String>.from(json['sources'] ?? []),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'content': content,
      'language': language,
      'period': period,
      'eventDate': eventDate?.toIso8601String(),
      'location': location,
      'figures': figures,
      'imageUrl': imageUrl,
      'sources': sources,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Create from Firestore document
  factory HistoricalContentModel.fromFirestore(Map<String, dynamic> data, String id) {
    return HistoricalContentModel.fromJson({...data, 'id': id});
  }
}

/// Yemba Content Model for data layer
class YembaContentModel extends YembaContentEntity {
  const YembaContentModel({
    required super.id,
    required super.title,
    required super.content,
    required super.category,
    required super.difficulty,
    super.audioUrl,
    super.imageUrl,
    required super.examples,
    required super.translations,
    required super.tags,
    required super.metadata,
    required super.createdAt,
    super.updatedAt,
  });

  /// Create from JSON
  factory YembaContentModel.fromJson(Map<String, dynamic> json) {
    return YembaContentModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      category: YembaCategory.values.firstWhere(
        (e) => e.toString() == 'YembaCategory.${json['category']}',
        orElse: () => YembaCategory.vocabulary,
      ),
      difficulty: json['difficulty'] ?? 'beginner',
      audioUrl: json['audioUrl'],
      imageUrl: json['imageUrl'],
      examples: List<String>.from(json['examples'] ?? []),
      translations: Map<String, String>.from(json['translations'] ?? {}),
      tags: List<String>.from(json['tags'] ?? []),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category': category.toString().split('.').last,
      'difficulty': difficulty,
      'audioUrl': audioUrl,
      'imageUrl': imageUrl,
      'examples': examples,
      'translations': translations,
      'tags': tags,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Create from Firestore document
  factory YembaContentModel.fromFirestore(Map<String, dynamic> data, String id) {
    return YembaContentModel.fromJson({...data, 'id': id});
  }
}