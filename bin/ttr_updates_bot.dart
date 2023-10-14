import 'dart:io';

import 'package:args/args.dart';
import 'package:ttr_updates_bot/scanners/release_note_scanner/release_note_scanner.dart';
import 'package:ttr_updates_bot/scanners/status_scanner/status_scanner.dart';
import 'package:ttr_updates_bot/scanners/update_scanner/manual_update_scanner.dart';
import 'package:ttr_updates_bot/scanners/update_scanner/update_scanner.dart';
import 'package:ttr_updates_bot/utils/discord_utils.dart';
import 'package:ttr_updates_bot/utils/git_utils.dart';
import 'package:ttr_updates_bot/utils/mongo_utils.dart';

void main(List<String> args) async {
  final ghToken = Platform.environment['GH_TOKEN'];
  print('Cloning repo...');
  final cloneSucceeded = await GitUtils.cloneRepo(
      "https://coocoofroggy:$ghToken@github.com/CoocooFroggy/ttr_update_files.git");
  if (!cloneSucceeded) {
    stderr.writeln('Failed to clone the phase diffing repository.');
    return;
  } else {
    print('Clone finished.');
  }

  final parser = ArgParser();
  // The --manual flag only downloads files from a local source and pushes them.
  // It does not interact with Discord or MongoDB.
  parser.addFlag('manual');
  parser.addFlag('generate');
  final results = parser.parse(args);
  
  if (results['manual'] as bool) {
    ManualUpdateScanner().checkForNewFiles();
  } else if (results['generate'] as bool) {
    
  } else {
    await DiscordUtils.connect();
    await MongoUtils.connectToDb();

    UpdateScanner().startScanner();
    ReleaseNoteScanner().startScanner();
    StatusScanner().startScanner();
  }
}
