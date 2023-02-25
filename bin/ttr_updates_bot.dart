import 'dart:io';

import 'package:ttr_updates_bot/scanners/release_note_scanner/release_note_scanner.dart';
import 'package:ttr_updates_bot/scanners/status_scanner/status_scanner.dart';
import 'package:ttr_updates_bot/scanners/update_scanner/update_scanner.dart';
import 'package:ttr_updates_bot/utils/discord_utils.dart';
import 'package:ttr_updates_bot/utils/git_utils.dart';
import 'package:ttr_updates_bot/utils/mongo_utils.dart';

void main() async {
  final cloneSucceeded = await GitUtils.cloneRepo(
      "https://github.com/CoocooFroggy/ttr_update_files.git");
  if (!cloneSucceeded) {
    stderr.writeln('Failed to clone the phase diffing repository.');
    return;
  }
  await DiscordUtils.connect();
  await MongoUtils.connectToDb();

  UpdateScanner().startScanner();
  ReleaseNoteScanner().startScanner();
  StatusScanner().startScanner();
}
