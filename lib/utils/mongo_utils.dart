import 'dart:io';

import 'package:mongo_dart/mongo_dart.dart';
import 'package:ttr_updates_bot/scanners/release_note_scanner/objects/release_note_full.dart';
import 'package:ttr_updates_bot/scanners/release_note_scanner/objects/server_settings.dart';
import 'package:ttr_updates_bot/scanners/status_scanner/objects/ttr_status.dart';
import 'package:ttr_updates_bot/scanners/update_scanner/objects/ttr_file.dart';

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

  // region Server Settings

  /// Replaces the role that should be pinged on new updates
  static Future<void> upsertServerSettings(ServerSettings settings) async {
    await _ensureConnection();
    _db.collection('Server Settings').replaceOne(
          where.eq('guildId', settings.guildId),
          settings.toBson(),
          upsert: true,
        );
  }

  static Future<ServerSettings?> fetchSettings(String guildId) async {
    await _ensureConnection();
    // Strangely, we cannot use findOne because it causes an error
    // after exactly 20 reads.
    final findResult = await _db
        .collection('Server Settings')
        .find(where.eq('guildId', guildId))
        .toList();
    if (findResult.isEmpty) {
      return null;
    }
    final bson = findResult.first;
    return ServerSettings.fromJson(bson);
  }

  static Future<void> setUpdatesRole(
    String guildId, {
    required String roleId,
  }) async {
    await _ensureConnection();
    _db.collection('Server Settings').updateOne(
          where.eq('guildId', guildId),
          modify.set('updatesRoleId', roleId),
          upsert: true,
        );
  }

  static Future<void> setUpdatesChannel(
    String guildId, {
    required String channelId,
  }) async {
    await _ensureConnection();
    _db.collection('Server Settings').updateOne(
          where.eq('guildId', guildId),
          modify.set('updatesChannelId', channelId),
          upsert: true,
        );
  }

  static Future<List<ServerSettings>> fetchAllServersWithUpdates() async {
    final List<Map<String, dynamic>> list = await _db
        .collection('Server Settings')
        .find(where.exists('updatesChannelId'))
        .toList();
    return list.map((e) => ServerSettings.fromJson(e)).toList();
  }

  // endregion

  // region Files
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

  // endregion

  // region Release Notes
  static Future<void> insertReleaseNoteFull(
      ReleaseNoteFull releaseNoteFull) async {
    await _ensureConnection();
    _db.collection('Release Notes').insert(releaseNoteFull.toBson());
  }

  static Future<bool> noteIdExists(int noteId) async {
    await _ensureConnection();
    // Strangely, we cannot use findOne because it causes an error
    // after exactly 20 reads.
    final find =
        _db.collection('Release Notes').find(where.eq('noteId', noteId));
    // If the noteId exists, return true
    return (!await find.isEmpty);
  }

  // endregion

  // region Status

  static Future<void> insertStatus(TTRStatus status) async {
    await _ensureConnection();
    _db.collection('Status').insert(status.toBson());
  }

  static Future<TTRStatus?> fetchLatestStatus() async {
    await _ensureConnection();
    // Strangely, we cannot use findOne because it causes an error
    // after exactly 20 reads.
    var findResult = await _db
        .collection('Status')
        .find(where.sortBy('_id', descending: true))
        .toList();
    if (findResult.isEmpty) {
      return null;
    }
    final bson = findResult.first;
    return TTRStatus.fromJson(bson);
  }

// endregion
}
