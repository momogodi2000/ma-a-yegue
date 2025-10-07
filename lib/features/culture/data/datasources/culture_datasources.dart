import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sqflite/sqflite.dart';
import '../../../../core/database/database_helper.dart';
import '../../domain/entities/culture_entities.dart';
import '../models/culture_models.dart';
import 'sample_culture_content.dart';

/// Abstract base class for culture data sources
abstract class CultureDataSource {
  Future<List<CultureContentModel>> getCultureContent({
    String? language,
    CultureCategory? category,
    int? limit,
    int? offset,
  });

  Future<List<HistoricalContentModel>> getHistoricalContent({
    String? language,
    String? period,
    int? limit,
    int? offset,
  });

  Future<List<YembaContentModel>> getYembaContent({
    YembaCategory? category,
    String? difficulty,
    int? limit,
    int? offset,
  });

  Future<CultureContentModel?> getCultureContentById(String id);
  Future<HistoricalContentModel?> getHistoricalContentById(String id);
  Future<YembaContentModel?> getYembaContentById(String id);

  Future<List<CultureContentModel>> searchCultureContent(String query);
  Future<List<HistoricalContentModel>> searchHistoricalContent(String query);
  Future<List<YembaContentModel>> searchYembaContent(String query);
}

/// Local SQLite data source for culture content
class CultureLocalDataSource implements CultureDataSource {
  CultureLocalDataSource();

  Future<Database> get _db => DatabaseHelper.database;

  @override
  Future<List<CultureContentModel>> getCultureContent({
    String? language,
    CultureCategory? category,
    int? limit,
    int? offset,
  }) async {
    try {
      String whereClause = '';
      List<dynamic> whereArgs = [];

      if (language != null) {
        whereClause += 'language = ?';
        whereArgs.add(language);
      }

      if (category != null) {
        if (whereClause.isNotEmpty) whereClause += ' AND ';
        whereClause += 'category = ?';
        whereArgs.add(category.toString().split('.').last);
      }

      final maps = await (await _db).query(
        'culture_content',
        where: whereClause.isNotEmpty ? whereClause : null,
        whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
        limit: limit,
        offset: offset,
        orderBy: 'created_at DESC',
      );

      // If database is empty, return sample content
      if (maps.isEmpty) {
        var sampleContent = SampleCultureContent.getSampleCultureContent();
        
        // Filter by category if specified
        if (category != null) {
          sampleContent = sampleContent.where((c) => c.category == category).toList();
        }
        
        // Filter by language if specified
        if (language != null && language.isNotEmpty) {
          sampleContent = sampleContent.where((c) => c.language.toLowerCase() == language.toLowerCase()).toList();
        }
        
        return sampleContent;
      }

      return maps.map((map) => CultureContentModel.fromJson(map)).toList();
    } catch (e) {
      // Fallback to sample content on error
      return SampleCultureContent.getSampleCultureContent();
    }
  }

  @override
  Future<List<HistoricalContentModel>> getHistoricalContent({
    String? language,
    String? period,
    int? limit,
    int? offset,
  }) async {
    try {
      String whereClause = '';
      List<dynamic> whereArgs = [];

      if (language != null) {
        whereClause += 'language = ?';
        whereArgs.add(language);
      }

      if (period != null) {
        if (whereClause.isNotEmpty) whereClause += ' AND ';
        whereClause += 'period = ?';
        whereArgs.add(period);
      }

      final maps = await (await _db).query(
        'historical_content',
        where: whereClause.isNotEmpty ? whereClause : null,
        whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
        limit: limit,
        offset: offset,
        orderBy: 'created_at DESC',
      );

      // If database is empty, return sample content
      if (maps.isEmpty) {
        var sampleContent = SampleCultureContent.getSampleHistoricalContent();
        
        // Filter by period if specified
        if (period != null) {
          sampleContent = sampleContent.where((c) => c.period == period).toList();
        }
        
        // Filter by language if specified
        if (language != null && language.isNotEmpty) {
          sampleContent = sampleContent.where((c) => c.language.toLowerCase() == language.toLowerCase()).toList();
        }
        
        return sampleContent;
      }

      return maps.map((map) => HistoricalContentModel.fromJson(map)).toList();
    } catch (e) {
      // Fallback to sample content on error
      return SampleCultureContent.getSampleHistoricalContent();
    }
  }

  @override
  Future<List<YembaContentModel>> getYembaContent({
    YembaCategory? category,
    String? difficulty,
    int? limit,
    int? offset,
  }) async {
    try {
      String whereClause = '';
      List<dynamic> whereArgs = [];

      if (category != null) {
        whereClause += 'category = ?';
        whereArgs.add(category.toString().split('.').last);
      }

      if (difficulty != null) {
        if (whereClause.isNotEmpty) whereClause += ' AND ';
        whereClause += 'difficulty = ?';
        whereArgs.add(difficulty);
      }

      final maps = await (await _db).query(
        'yemba_content',
        where: whereClause.isNotEmpty ? whereClause : null,
        whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
        limit: limit,
        offset: offset,
        orderBy: 'created_at DESC',
      );

      // If database is empty, return sample content
      if (maps.isEmpty) {
        var sampleContent = SampleCultureContent.getSampleYembaContent();
        
        // Filter by category if specified
        if (category != null) {
          sampleContent = sampleContent.where((c) => c.category == category).toList();
        }
        
        // Filter by difficulty if specified
        if (difficulty != null) {
          sampleContent = sampleContent.where((c) => c.difficulty == difficulty).toList();
        }
        
        return sampleContent;
      }

      return maps.map((map) => YembaContentModel.fromJson(map)).toList();
    } catch (e) {
      // Fallback to sample content on error
      return SampleCultureContent.getSampleYembaContent();
    }
  }

  @override
  Future<CultureContentModel?> getCultureContentById(String id) async {
    try {
      final maps = await (await _db).query(
        'culture_content',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        return CultureContentModel.fromJson(maps.first);
      }
      
      // Fallback to sample content
      final sampleContent = SampleCultureContent.getSampleCultureContent();
      return sampleContent.firstWhere((c) => c.id == id, orElse: () => sampleContent.first);
    } catch (e) {
      return SampleCultureContent.getSampleCultureContent().first;
    }
  }

  @override
  Future<HistoricalContentModel?> getHistoricalContentById(String id) async {
    try {
      final maps = await (await _db).query(
        'historical_content',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        return HistoricalContentModel.fromJson(maps.first);
      }
      
      // Fallback to sample content
      final sampleContent = SampleCultureContent.getSampleHistoricalContent();
      return sampleContent.firstWhere((c) => c.id == id, orElse: () => sampleContent.first);
    } catch (e) {
      return SampleCultureContent.getSampleHistoricalContent().first;
    }
  }

  @override
  Future<YembaContentModel?> getYembaContentById(String id) async {
    try {
      final maps = await (await _db).query(
        'yemba_content',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        return YembaContentModel.fromJson(maps.first);
      }
      
      // Fallback to sample content
      final sampleContent = SampleCultureContent.getSampleYembaContent();
      return sampleContent.firstWhere((c) => c.id == id, orElse: () => sampleContent.first);
    } catch (e) {
      return SampleCultureContent.getSampleYembaContent().first;
    }
  }

  @override
  Future<List<CultureContentModel>> searchCultureContent(String query) async {
    final maps = await (await _db).query(
      'culture_content',
      where: 'title LIKE ? OR description LIKE ? OR content LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'created_at DESC',
    );

    return maps.map((map) => CultureContentModel.fromJson(map)).toList();
  }

  @override
  Future<List<HistoricalContentModel>> searchHistoricalContent(String query) async {
    final maps = await (await _db).query(
      'historical_content',
      where: 'title LIKE ? OR description LIKE ? OR content LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'created_at DESC',
    );

    return maps.map((map) => HistoricalContentModel.fromJson(map)).toList();
  }

  @override
  Future<List<YembaContentModel>> searchYembaContent(String query) async {
    final maps = await (await _db).query(
      'yemba_content',
      where: 'title LIKE ? OR content LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'created_at DESC',
    );

    return maps.map((map) => YembaContentModel.fromJson(map)).toList();
  }
}

/// Remote Firebase data source for culture content
class CultureRemoteDataSource implements CultureDataSource {
  final FirebaseFirestore _firestore;

  CultureRemoteDataSource(this._firestore);

  CollectionReference get _cultureCollection => _firestore.collection('culture_content');
  CollectionReference get _historicalCollection => _firestore.collection('historical_content');
  CollectionReference get _yembaCollection => _firestore.collection('yemba_content');

  @override
  Future<List<CultureContentModel>> getCultureContent({
    String? language,
    CultureCategory? category,
    int? limit,
    int? offset,
  }) async {
    Query query = _cultureCollection.orderBy('createdAt', descending: true);

    if (language != null) {
      query = query.where('language', isEqualTo: language);
    }

    if (category != null) {
      query = query.where('category', isEqualTo: category.toString().split('.').last);
    }

    if (limit != null) {
      query = query.limit(limit);
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => CultureContentModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  @override
  Future<List<HistoricalContentModel>> getHistoricalContent({
    String? language,
    String? period,
    int? limit,
    int? offset,
  }) async {
    Query query = _historicalCollection.orderBy('createdAt', descending: true);

    if (language != null) {
      query = query.where('language', isEqualTo: language);
    }

    if (period != null) {
      query = query.where('period', isEqualTo: period);
    }

    if (limit != null) {
      query = query.limit(limit);
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => HistoricalContentModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  @override
  Future<List<YembaContentModel>> getYembaContent({
    YembaCategory? category,
    String? difficulty,
    int? limit,
    int? offset,
  }) async {
    Query query = _yembaCollection.orderBy('createdAt', descending: true);

    if (category != null) {
      query = query.where('category', isEqualTo: category.toString().split('.').last);
    }

    if (difficulty != null) {
      query = query.where('difficulty', isEqualTo: difficulty);
    }

    if (limit != null) {
      query = query.limit(limit);
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => YembaContentModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  @override
  Future<CultureContentModel?> getCultureContentById(String id) async {
    final doc = await _cultureCollection.doc(id).get();
    if (!doc.exists) return null;
    return CultureContentModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
  }

  @override
  Future<HistoricalContentModel?> getHistoricalContentById(String id) async {
    final doc = await _historicalCollection.doc(id).get();
    if (!doc.exists) return null;
    return HistoricalContentModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
  }

  @override
  Future<YembaContentModel?> getYembaContentById(String id) async {
    final doc = await _yembaCollection.doc(id).get();
    if (!doc.exists) return null;
    return YembaContentModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
  }

  @override
  Future<List<CultureContentModel>> searchCultureContent(String query) async {
    // Firebase doesn't support full-text search natively
    // This is a basic implementation - in production, consider using Algolia or ElasticSearch
    final snapshot = await _cultureCollection.get();
    final allContent = snapshot.docs
        .map((doc) => CultureContentModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
        .toList();

    return allContent.where((content) =>
        content.title.toLowerCase().contains(query.toLowerCase()) ||
        content.description.toLowerCase().contains(query.toLowerCase()) ||
        content.content.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  @override
  Future<List<HistoricalContentModel>> searchHistoricalContent(String query) async {
    final snapshot = await _historicalCollection.get();
    final allContent = snapshot.docs
        .map((doc) => HistoricalContentModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
        .toList();

    return allContent.where((content) =>
        content.title.toLowerCase().contains(query.toLowerCase()) ||
        content.description.toLowerCase().contains(query.toLowerCase()) ||
        content.content.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  @override
  Future<List<YembaContentModel>> searchYembaContent(String query) async {
    final snapshot = await _yembaCollection.get();
    final allContent = snapshot.docs
        .map((doc) => YembaContentModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
        .toList();

    return allContent.where((content) =>
        content.title.toLowerCase().contains(query.toLowerCase()) ||
        content.content.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }
}