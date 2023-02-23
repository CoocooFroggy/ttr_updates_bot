import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart';
import 'package:ttr_updates_bot/release_note_scanner/objects/release_note_full.dart';
import 'package:ttr_updates_bot/release_note_scanner/objects/release_note_summary.dart';
import 'package:ttr_updates_bot/utils/discord_utils.dart';
import 'package:ttr_updates_bot/utils/mongo_utils.dart';

class ReleaseNoteScanner {
  Timer? timer;

  Future<void> startScanner() async {
    checkForNewReleaseNote();
    timer = Timer.periodic(Duration(seconds: 30), (timer) {
      checkForNewReleaseNote();
    });
  }

  Future<void> checkForNewReleaseNote() async {
    final uri = Uri.parse('https://www.toontownrewritten.com/api/releasenotes');
    final response = await get(uri);
    // The JSON response is a list
    List<dynamic> json = jsonDecode(response.body) as List<dynamic>;
    // Each item in the list is a ReleaseNoteSummary
    final map =
        json.map((e) => ReleaseNoteSummary.fromJson(e as Map<String, dynamic>));
    // We assume they only add one release note at a time,
    // and the newest is always first.
    if (!await MongoUtils.noteIdExists(map.first.noteId)) {
      final uri = Uri.parse(
          'https://www.toontownrewritten.com/api/releasenotes/${map.first.noteId}');
      final response = await get(uri);
      // The JSON response is a dictionary
      Map<String, dynamic> json =
          jsonDecode(response.body) as Map<String, dynamic>;
      final releaseNoteFull = ReleaseNoteFull.fromJson(json);
      print('New release note:\n$releaseNoteFull\n----------');
      MongoUtils.insertReleaseNoteFull(releaseNoteFull);

      // Report to all the servers
      var servers = await MongoUtils.fetchAllServersWithUpdates();
      for (var settings in servers) {
        // Skip servers who don't have this set up
        if (settings.updatesChannelId == null) {
          continue;
        }
        DiscordUtils.reportNewReleaseNote(
            releaseNoteFull: releaseNoteFull,
            channelId: settings.updatesChannelId!);
      }
    }
  }
}
