import 'dart:io';

import 'package:nyxx/nyxx.dart';
import 'package:nyxx_commands/nyxx_commands.dart';
import 'package:ttr_updates_bot/commands/ping.dart';
import 'package:ttr_updates_bot/release_note_scanner/objects/release_note_full.dart';
import 'package:ttr_updates_bot/update_scanner/objects/patch.dart';
import 'package:ttr_updates_bot/update_scanner/objects/ttr_file.dart';

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
      // Ignore by slashOnly CommandType
      prefix: (_) => '!',
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

  // region Files
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

  // endregion

  // region Release Notes
  static Future<void> reportNewReleaseNote(
      ReleaseNoteFull releaseNoteFull) async {
    EmbedBuilder eb = EmbedBuilder();
    final description = convertMdToDiscord(releaseNoteFull);
    final allMatches = RegExp(
      r'.{1,2048}(?:\n|$)',
      // Match 1–2048 characters and make the splits at newlines
      dotAll: true,
    ).allMatches(description).toList();
    for (int i = 0; i < allMatches.length; i++) {
      eb = EmbedBuilder();
      final match = allMatches[i];
      // On the first iteration, add the title
      eb
        ..color = DiscordColor.azure
        ..description = match.group(0);
      if (i == 0) {
        eb.title = releaseNoteFull.slug;
      } else if (i == allMatches.length - 1) {
        eb
          ..footer = (EmbedFooterBuilder()
            ..text = 'Note ID: ${releaseNoteFull.noteId}')
          ..timestamp = releaseNoteFull.date;
      }
      await client.httpEndpoints.sendMessage(
          Snowflake(Platform.environment['CHANNEL_ID']!),
          MessageBuilder.embed(eb));
    }
  }

  static String convertMdToDiscord(ReleaseNoteFull releaseNoteFull) {
    var newBody = releaseNoteFull.body
        .replaceAllMapped(
          RegExp(r'^=(.+)', multiLine: true),
          (match) => '__${match.group(1)}__',
        )
        .replaceAllMapped(
          RegExp(r'^\*(.+)', multiLine: true),
          (match) => '•${match.group(1)}',
        );
    print(releaseNoteFull);
    return newBody;
  }
// endregion
}
