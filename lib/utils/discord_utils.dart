import 'dart:io';

import 'package:nyxx/nyxx.dart';
import 'package:nyxx_commands/nyxx_commands.dart';
import 'package:ttr_updates_bot/commands/ping.dart';
import 'package:ttr_updates_bot/scanner/objects/patch.dart';
import 'package:ttr_updates_bot/scanner/objects/ttr_file.dart';

class DiscordUtils {
  static late final INyxxWebsocket client;

  static Future<void> connect() async {
    if (Platform.environment['CHANNEL_ID'] == null) {
      print('No CHANNEL_ID specified in environment variables.');
      exit(1);
    }

    client = NyxxFactory.createNyxxWebsocket(
      Platform.environment['TOKEN']!,
      GatewayIntents.allUnprivileged,
    );

    final commands = CommandsPlugin(
      prefix: (_) => Platform.environment['PREFIX']!,
      options: CommandsOptions(
        defaultCommandType: CommandType.slashOnly,
      ),
    );

    client
      ..registerPlugin(Logging())
      ..registerPlugin(CliIntegration())
      ..registerPlugin(commands);

    if (Platform.environment['DEBUG'] == null) {
      client.registerPlugin(IgnoreExceptions());
    }

    // Register commands, listeners, services and setup any extra packages here
    commands.addCommand(ping);

    await client.connect();
  }

  static Future<void> reportNewFile(TTRFile file) async {
    EmbedBuilder eb = EmbedBuilder();
    eb
      ..title = 'New file: ${file.name}'
      ..color = DiscordColor.sapGreen
      ..fields = [
        EmbedFieldBuilder('URL', file.downloadUrl, false),
        EmbedFieldBuilder('Hash', file.hash, false),
        _buildPatchesField(file.patches),
      ];
    // Hard-coded ID
    await client.httpEndpoints.sendMessage(
        Snowflake(Platform.environment['CHANNEL_ID']!),
        MessageBuilder.embed(eb));
  }

  static EmbedFieldBuilder _buildPatchesField(Map<String, Patch> patches) {
    List<String> previousHashes = [];
    for (var patch in patches.values) {
      previousHashes.add(patch.previousHash.substring(0, 5));
    }
    // Patches
    // 2 (from 59d4e, 99be4)
    return EmbedFieldBuilder(
        'Patches',
        '${patches.length}${patches.isNotEmpty ? ' (from ${previousHashes.join(", ")})' : ''}',
        false);
  }
}
