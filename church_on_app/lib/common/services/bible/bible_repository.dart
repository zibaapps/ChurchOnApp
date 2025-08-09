import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:hive/hive.dart';

class BibleRepository {
  BibleRepository({HiveInterface? hive}) : _hive = hive ?? Hive;
  final HiveInterface _hive;
  static const String _boxName = 'bible_cache';

  Future<void> init() async {
    if (!_hive.isBoxOpen(_boxName)) {
      await _hive.openBox<String>(_boxName);
    }
  }

  Future<bool> hasBookCached({required String version, required String book}) async {
    await init();
    final key = _key(version, book);
    return _hive.box<String>(_boxName).containsKey(key);
  }

  Future<void> cacheBook({required String version, required String book}) async {
    await init();
    final data = await _loadAsset(version: version, book: book);
    await _hive.box<String>(_boxName).put(_key(version, book), jsonEncode(data));
  }

  Future<Map<String, dynamic>> getBook({required String version, required String book}) async {
    await init();
    final key = _key(version, book);
    final box = _hive.box<String>(_boxName);
    if (!box.containsKey(key)) {
      await cacheBook(version: version, book: book);
    }
    final raw = box.get(key);
    if (raw == null) return <String, dynamic>{};
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<void> evictBook({required String version, required String book}) async {
    await init();
    final key = _key(version, book);
    final box = _hive.box<String>(_boxName);
    if (box.containsKey(key)) {
      await box.delete(key);
    }
  }

  // Returns list of verses for a chapter (1-based)
  Future<List<String>> getChapter({required String version, required String book, required int chapter}) async {
    final data = await getBook(version: version, book: book);
    final chapters = (data['chapters'] as List?) ?? const [];
    if (chapter < 1 || chapter > chapters.length) return const <String>[];
    final List<dynamic> verses = chapters[chapter - 1] as List<dynamic>;
    return verses.map((e) => e.toString()).toList();
  }

  // Version assets follow: assets/bible/<version>/<book>.json
  Future<Map<String, dynamic>> _loadAsset({required String version, required String book}) async {
    try {
      final path = 'assets/bible/$version/${book.toLowerCase()}.json';
      final raw = await rootBundle.loadString(path);
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (e) {
      if (kDebugMode) {
        print('Bible load error: $e');
      }
      return <String, dynamic>{'chapters': []};
    }
  }

  String _key(String version, String book) => '$version::$book';
}