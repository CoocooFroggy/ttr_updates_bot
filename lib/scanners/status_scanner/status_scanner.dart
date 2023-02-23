import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart';
import 'package:ttr_updates_bot/scanners/status_scanner/objects/ttr_status.dart';
import 'package:ttr_updates_bot/utils/discord_utils.dart';
import 'package:ttr_updates_bot/utils/mongo_utils.dart';

class StatusScanner {
  Timer? timer;

  Future<void> startScanner() async {
    checkTtrStatus();
    timer = Timer.periodic(Duration(seconds: 30), (timer) {
      checkTtrStatus();
    });
  }

  Future<void> checkTtrStatus() async {
    final uri = Uri.parse('https://toontownrewritten.com/api/status');
    final response = await get(uri);
    // Response is always a map
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final status = TTRStatus.fromJson(json);

    final previousStatus = await MongoUtils.fetchLatestStatus();

    if (status != previousStatus) {
      print('New status:\n$status\n----------');
      MongoUtils.insertStatus(status);
      // Report to all the servers
      var servers = await MongoUtils.fetchAllServersWithUpdates();
      for (var settings in servers) {
        // Skip servers who don't have this set up
        if (settings.updatesChannelId == null) {
          continue;
        }
        DiscordUtils.reportNewStatus(
            channelId: settings.updatesChannelId!, status: status);
      }
    }
  }
}
