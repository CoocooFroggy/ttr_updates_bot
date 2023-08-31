import 'dart:io';

import 'package:nyxx/nyxx.dart';
import 'package:nyxx_commands/nyxx_commands.dart';
import 'package:ttr_updates_bot/commands/set_updates_channel.dart';
import 'package:ttr_updates_bot/commands/set_updates_role.dart';
import 'package:ttr_updates_bot/scanners/release_note_scanner/objects/release_note_full.dart';
import 'package:ttr_updates_bot/scanners/release_note_scanner/objects/server_settings.dart';
import 'package:ttr_updates_bot/scanners/status_scanner/objects/ttr_status.dart';
import 'package:ttr_updates_bot/scanners/update_scanner/objects/patch.dart';
import 'package:ttr_updates_bot/scanners/update_scanner/objects/ttr_file.dart';

class DiscordUtils {
  static late final INyxxWebsocket client;

  static Future<void> connect() async {
    client = NyxxFactory.createNyxxWebsocket(
      Platform.environment['TOKEN']!,
      GatewayIntents.allUnprivileged,
    );

    final commands = CommandsPlugin(
        prefix: (_) => '!',
        options: CommandsOptions(
          type: CommandType.slashOnly,
        ));

    client
      ..registerPlugin(Logging())
      ..registerPlugin(CliIntegration())
      ..registerPlugin(commands);

    if (Platform.environment['DEBUG'] == null) {
      client.registerPlugin(IgnoreExceptions());
    }

    // Register commands, listeners, services and setup any extra packages here
    commands.addCommand(setUpdatesRole);
    commands.addCommand(setUpdatesChannel);

    await client.connect();
  }

  // region Files
  static Future<void> reportNewFile({
    required String channelId,
    required TTRFile file,
  }) async {
    EmbedBuilder eb = EmbedBuilder();
    eb
      ..title = 'New file: ${file.name}'
      ..color = DiscordColor.sapGreen
      ..fields = [
        EmbedFieldBuilder('URL', file.downloadUrl, false),
        EmbedFieldBuilder('Hash', file.hash, false),
        _buildPatchesField(file.patches),
      ];
    await client.httpEndpoints
        .sendMessage(Snowflake(channelId), MessageBuilder.embed(eb));
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
        '${patches.length}${patches.isNotEmpty ? ' (from ${previousHashes.join(', ')})' : ''}',
        false);
  }

  // endregion

  // region Release Notes
  static Future<void> reportNewReleaseNote({
    required String channelId,
    required ReleaseNoteFull releaseNoteFull,
  }) async {
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
      await client.httpEndpoints
          .sendMessage(Snowflake(channelId), MessageBuilder.embed(eb));
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

  /// When TTRGame.vlt is released, we will parse some attributes from it
  /// and send it to Discord.
  static Future<void> reportAttributes(
      {required ServerSettings serverSettings,
      required Map<String, String> attributes}) async {
    EmbedBuilder eb = EmbedBuilder();
    eb
      ..title = 'New update!'
      ..color = DiscordColor.yellow;
    for (var entry in attributes.entries) {
      eb.addField(name: entry.key, content: entry.value);
    }
    // Build the message
    final builder = MessageBuilder()
      ..allowedMentions = (AllowedMentions()..allow(roles: true))
      ..embeds = [eb];
    // Add optional ping
    if (serverSettings.updatesRoleId != null) {
      builder.content = '<@&${serverSettings.updatesRoleId}>';
    }
    // Send the message
    await client.httpEndpoints
        .sendMessage(Snowflake(serverSettings.updatesChannelId), builder);
  }

  // region Status

  static Future<void> reportNewStatus({
    required String channelId,
    required TTRStatus status,
  }) async {
    EmbedBuilder eb = EmbedBuilder();
    eb
      ..title = 'Status update'
      ..color = status.open ? DiscordColor.green : DiscordColor.red
      ..description = status.banner;
    // Send the message
    await client.httpEndpoints
        .sendMessage(Snowflake(channelId), MessageBuilder.embed(eb));
  }

// endregion
}
