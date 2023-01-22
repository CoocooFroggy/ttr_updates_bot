import 'package:ttr_updates_bot/scanner/update_scanner.dart';
import 'package:ttr_updates_bot/utils/discord_utils.dart';
import 'package:ttr_updates_bot/utils/mongo_utils.dart';

void main() async {
  await DiscordUtils.connect();
  await MongoUtils.connectToDb();

  UpdateScanner().startScanner();
}
