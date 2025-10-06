import 'package:equatable/equatable.dart';

/// Culture Content Entity
class CultureContentEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String content;
  final String language;
  final CultureCategory category;
  final String? imageUrl;
  final List<String> tags;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const CultureContentEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.content,
    required this.language,
    required this.category,
    this.imageUrl,
    required this.tags,
    required this.metadata,
    required this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        content,
        language,
        category,
        imageUrl,
        tags,
        metadata,
        createdAt,
        updatedAt,
      ];

  CultureContentEntity copyWith({
    String? id,
    String? title,
    String? description,
    String? content,
    String? language,
    CultureCategory? category,
    String? imageUrl,
    List<String>? tags,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CultureContentEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      content: content ?? this.content,
      language: language ?? this.language,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      tags: tags ?? this.tags,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Historical Content Entity
class HistoricalContentEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String content;
  final String language;
  final String period; // e.g., "Pre-colonial", "Colonial", "Post-colonial"
  final DateTime? eventDate;
  final String? location;
  final List<String> figures; // Important historical figures
  final String? imageUrl;
  final List<String> sources;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const HistoricalContentEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.content,
    required this.language,
    required this.period,
    this.eventDate,
    this.location,
    required this.figures,
    this.imageUrl,
    required this.sources,
    required this.metadata,
    required this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        content,
        language,
        period,
        eventDate,
        location,
        figures,
        imageUrl,
        sources,
        metadata,
        createdAt,
        updatedAt,
      ];

  HistoricalContentEntity copyWith({
    String? id,
    String? title,
    String? description,
    String? content,
    String? language,
    String? period,
    DateTime? eventDate,
    String? location,
    List<String>? figures,
    String? imageUrl,
    List<String>? sources,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HistoricalContentEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      content: content ?? this.content,
      language: language ?? this.language,
      period: period ?? this.period,
      eventDate: eventDate ?? this.eventDate,
      location: location ?? this.location,
      figures: figures ?? this.figures,
      imageUrl: imageUrl ?? this.imageUrl,
      sources: sources ?? this.sources,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Yemba Language Content Entity
class YembaContentEntity extends Equatable {
  final String id;
  final String title;
  final String content;
  final YembaCategory category;
  final String difficulty; // 'beginner', 'intermediate', 'advanced'
  final String? audioUrl;
  final String? imageUrl;
  final List<String> examples;
  final Map<String, String> translations; // Map of language codes to translations
  final List<String> tags;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const YembaContentEntity({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.difficulty,
    this.audioUrl,
    this.imageUrl,
    required this.examples,
    required this.translations,
    required this.tags,
    required this.metadata,
    required this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        content,
        category,
        difficulty,
        audioUrl,
        imageUrl,
        examples,
        translations,
        tags,
        metadata,
        createdAt,
        updatedAt,
      ];

  YembaContentEntity copyWith({
    String? id,
    String? title,
    String? content,
    YembaCategory? category,
    String? difficulty,
    String? audioUrl,
    String? imageUrl,
    List<String>? examples,
    Map<String, String>? translations,
    List<String>? tags,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return YembaContentEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      audioUrl: audioUrl ?? this.audioUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      examples: examples ?? this.examples,
      translations: translations ?? this.translations,
      tags: tags ?? this.tags,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Enums
enum CultureCategory {
  traditions,
  ceremonies,
  folklore,
  cuisine,
  music,
  dance,
  art,
  socialStructure,
  spirituality,
  dailyLife,
}

enum YembaCategory {
  vocabulary,
  grammar,
  phrases,
  stories,
  songs,
  proverbs,
  greetings,
  numbers,
  colors,
  family,
  pronunciation,
  conversation,
  culture,
}