import 'package:ttr_updates_bot/scanners/release_note_scanner/release_note_scanner.dart';
import 'package:ttr_updates_bot/scanners/status_scanner/status_scanner.dart';
import 'package:ttr_updates_bot/scanners/update_scanner/update_scanner.dart';
import 'package:ttr_updates_bot/utils/discord_utils.dart';
import 'package:ttr_updates_bot/utils/mongo_utils.dart';

void main() async {
  await DiscordUtils.connect();
  await MongoUtils.connectToDb();

  UpdateScanner().startScanner();
  ReleaseNoteScanner().startScanner();
  StatusScanner().startScanner();
}
