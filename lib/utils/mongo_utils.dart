import 'dart:io';

import 'package:mongo_dart/mongo_dart.dart';
import 'package:ttr_updates_bot/scanner/objects/ttr_file.dart';

class MongoUtils {
  static late final Db _db;

  static connectToDb() async {
    print('Connecting to MongoDB');
    _db = await Db.create(Platform.environment['DB_URL']!);
    await _db.open();
    print('Connected to MongoDB');
  }

  /// Run this before every database attempt.
  static Future<void> _ensureConnection() async {
    if (!_db.isConnected) {
      print('MongoDB disconnected—reconnecting...');
      await _db.close();
      await _db.open();
      print('MongoDB reconnected');
    }
  }

  /// Inserts a TTRFile into the Files collection.
  static Future<void> insertFile(TTRFile file) async {
    await _ensureConnection();
    _db.collection('Files').insert(file.toBson());
  }

  /// Inserts a TTRFile into the Files collection.
  static Future<bool> fileHashExists(String hash) async {
    await _ensureConnection();
    // Strangely, we cannot use findOne because it causes an error
    // after exactly 20 reads.
    final find = _db.collection('Files').find(where.eq('hash', hash));
    // If the hash exists, return true
    return (!await find.isEmpty);
  }
}
