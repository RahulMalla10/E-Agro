import 'dart:async';

import 'package:krishi_smart/core/errors/app_exception.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// Offline-first SQLite store for crop advice, scans, and sync queue.
class AppDatabase {
  AppDatabase._(this._db);

  final Database _db;
  static const _dbName = 'krishi_smart.db';
  static const _dbVersion = 4;

  static AppDatabase? _instance;

  static Future<AppDatabase> open() async {
    if (_instance != null) return _instance!;
    final dbPath = p.join(await getDatabasesPath(), _dbName);
    final db = await openDatabase(
      dbPath,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
    _instance = AppDatabase._(db);
    return _instance!;
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE farmer_profile (
        id TEXT PRIMARY KEY,
        phone TEXT,
        full_name TEXT,
        district TEXT,
        municipality TEXT,
        land_size_ropani REAL,
        main_crops TEXT,
        preferred_language TEXT DEFAULT 'ne',
        consent_location INTEGER DEFAULT 0,
        consent_photos INTEGER DEFAULT 0,
        updated_at TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE crop_advice (
        id TEXT PRIMARY KEY,
        crop_id TEXT NOT NULL,
        stage TEXT NOT NULL,
        title TEXT NOT NULL,
        body TEXT NOT NULL,
        locale TEXT DEFAULT 'ne'
      )
    ''');
    await db.execute('''
      CREATE TABLE disease_scans (
        id TEXT PRIMARY KEY,
        crop_id TEXT,
        disease_label TEXT NOT NULL,
        confidence REAL NOT NULL,
        remedy TEXT,
        image_path TEXT,
        scanned_at TEXT NOT NULL,
        synced INTEGER DEFAULT 0
      )
    ''');
    await db.execute('''
      CREATE TABLE sync_queue (
        id TEXT PRIMARY KEY,
        entity_type TEXT NOT NULL,
        entity_id TEXT NOT NULL,
        action TEXT NOT NULL,
        payload TEXT,
        created_at TEXT NOT NULL,
        attempts INTEGER DEFAULT 0
      )
    ''');
    await db.execute(
      'CREATE INDEX idx_disease_scans_date ON disease_scans(scanned_at DESC)',
    );
    await _createMarketplaceTables(db);
  }

  static Future<void> _createMarketplaceTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS farmer_products (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        name_ne TEXT,
        category TEXT NOT NULL,
        image_paths TEXT,
        stock_quantity REAL NOT NULL DEFAULT 0,
        stock_unit TEXT NOT NULL DEFAULT 'kg',
        price_npr REAL NOT NULL DEFAULT 0,
        seller_id TEXT,
        created_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS marketplace_orders (
        id TEXT PRIMARY KEY,
        product_id TEXT NOT NULL,
        quantity REAL NOT NULL,
        unit TEXT NOT NULL,
        unit_price_npr REAL NOT NULL,
        total_npr REAL NOT NULL,
        buyer_name TEXT NOT NULL,
        buyer_phone TEXT NOT NULL,
        buyer_address TEXT NOT NULL,
        buyer_landmark TEXT,
        payment_status TEXT NOT NULL DEFAULT 'pending',
        esewa_ref TEXT,
        created_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS seller_reviews (
        id TEXT PRIMARY KEY,
        seller_id TEXT NOT NULL,
        buyer_id TEXT,
        product_id TEXT,
        rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
        comment TEXT,
        created_at TEXT NOT NULL
      )
    ''');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_products_category ON farmer_products(category)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_seller_reviews_seller ON seller_reviews(seller_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_seller_reviews_date ON seller_reviews(created_at DESC)',
    );
  }

  static Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      await _createMarketplaceTables(db);
    }
    if (oldVersion < 3) {
      await db.execute('DROP TABLE IF EXISTS farmer_products');
      await _createMarketplaceTables(db);
    }
    if (oldVersion < 4) {
      await db.execute('DROP TABLE IF EXISTS seller_reviews');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS seller_reviews (
          id TEXT PRIMARY KEY,
          seller_id TEXT NOT NULL,
          buyer_id TEXT,
          product_id TEXT,
          rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
          comment TEXT,
          created_at TEXT NOT NULL
        )
      ''');
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_seller_reviews_seller ON seller_reviews(seller_id)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_seller_reviews_date ON seller_reviews(created_at DESC)',
      );
    }
  }

  Future<void> close() async {
    await _db.close();
    _instance = null;
  }

  Future<Map<String, Object?>?> getFarmerProfile() async {
    final rows = await _db.query('farmer_profile', limit: 1);
    return rows.isEmpty ? null : rows.first;
  }

  Future<void> upsertFarmerProfile(Map<String, Object?> profile) async {
    try {
      await _db.insert(
        'farmer_profile',
        profile,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw LocalDatabaseException('Failed to save profile: $e');
    }
  }

  Future<List<Map<String, Object?>>> getCropAdvice({String? cropId}) async {
    if (cropId == null) {
      return _db.query('crop_advice', orderBy: 'crop_id, stage');
    }
    return _db.query(
      'crop_advice',
      where: 'crop_id = ?',
      whereArgs: [cropId],
      orderBy: 'stage',
    );
  }

  Future<void> seedCropAdvice(List<Map<String, Object?>> rows) async {
    final batch = _db.batch();
    for (final row in rows) {
      batch.insert(
        'crop_advice',
        row,
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<void> insertDiseaseScan(Map<String, Object?> scan) async {
    await _db.insert('disease_scans', scan);
  }

  Future<List<Map<String, Object?>>> getDiseaseScans({int limit = 20}) {
    return _db.query('disease_scans', orderBy: 'scanned_at DESC', limit: limit);
  }

  Future<void> enqueueSync(Map<String, Object?> item) async {
    await _db.insert('sync_queue', item);
  }

  Future<List<Map<String, Object?>>> pendingSyncItems({int limit = 50}) {
    return _db.query('sync_queue', orderBy: 'created_at ASC', limit: limit);
  }

  Future<void> markSyncComplete(String id) async {
    await _db.delete('sync_queue', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, Object?>>> getProducts({String? category}) async {
    if (category == null || category == 'all') {
      return _db.query('farmer_products', orderBy: 'created_at DESC');
    }
    return _db.query(
      'farmer_products',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'created_at DESC',
    );
  }

  Future<void> insertProduct(Map<String, Object?> product) async {
    await _db.insert(
      'farmer_products',
      product,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteProduct(String id) async {
    await _db.delete('farmer_products', where: 'id = ?', whereArgs: [id]);
  }

  Future<Map<String, Object?>?> getProductById(String id) async {
    final rows = await _db.query(
      'farmer_products',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }

  Future<void> updateProductStock(String id, double newQuantity) async {
    await _db.update(
      'farmer_products',
      {'stock_quantity': newQuantity},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> insertOrder(Map<String, Object?> order) async {
    await _db.insert('marketplace_orders', order);
  }

  Future<List<Map<String, Object?>>> getOrdersForSeller(String sellerId) async {
    return _db.rawQuery(
      '''
      SELECT o.*, p.name AS product_name, p.name_ne AS product_name_ne,
             p.category AS product_category, p.stock_quantity AS current_stock,
             p.stock_unit AS stock_unit, p.seller_id AS seller_id
      FROM marketplace_orders o
      INNER JOIN farmer_products p ON o.product_id = p.id
      WHERE p.seller_id = ? OR p.seller_id IS NULL
      ORDER BY o.created_at DESC
      ''',
      [sellerId],
    );
  }

  Future<List<Map<String, Object?>>> getProductsForSeller(
    String sellerId,
  ) async {
    return _db.query(
      'farmer_products',
      where: 'seller_id = ? OR seller_id IS NULL',
      whereArgs: [sellerId],
      orderBy: 'created_at DESC',
    );
  }

  // Seller Review Methods
  Future<void> insertReview(Map<String, Object?> review) async {
    await _db.insert('seller_reviews', review);
  }

  Future<List<Map<String, Object?>>> getReviewsForSeller(
    String sellerId,
  ) async {
    return _db.query(
      'seller_reviews',
      where: 'seller_id = ?',
      whereArgs: [sellerId],
      orderBy: 'created_at DESC',
    );
  }

  Future<double> getAverageRatingForSeller(String sellerId) async {
    final result = await _db.rawQuery(
      'SELECT AVG(rating) as avg_rating FROM seller_reviews WHERE seller_id = ?',
      [sellerId],
    );
    if (result.isEmpty || result.first['avg_rating'] == null) {
      return 0.0;
    }
    return (result.first['avg_rating'] as num).toDouble();
  }

  Future<int> getReviewCountForSeller(String sellerId) async {
    final result = await _db.rawQuery(
      'SELECT COUNT(*) as count FROM seller_reviews WHERE seller_id = ?',
      [sellerId],
    );
    return (result.first['count'] as int?) ?? 0;
  }

  Future<List<Map<String, Object?>>> getReviewsForProduct(
    String productId,
  ) async {
    return _db.query(
      'seller_reviews',
      where: 'product_id = ?',
      whereArgs: [productId],
      orderBy: 'created_at DESC',
    );
  }
}
