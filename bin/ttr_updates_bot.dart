import 'dart:io';

import 'package:nyxx/nyxx.dart';
import 'package:nyxx_commands/nyxx_commands.dart';
import 'package:ttr_updates_bot/commands/ping.dart';

void main() async {
  final client = NyxxFactory.createNyxxWebsocket(
    Platform.environment['TOKEN']!,
    GatewayIntents.allUnprivileged,
  );

  final commands = CommandsPlugin(
    prefix: (_) => Platform.environment['PREFIX']!,
  );

  client
    ..registerPlugin(Logging())
    ..registerPlugin(CliIntegration())
    ..registerPlugin(commands);

  if (Platform.environment['DEBUG'] != null) {
    client.registerPlugin(IgnoreExceptions());
  }

  // Register commands, listeners, services and setup any extra packages here
  commands.addCommand(ping);

  await client.connect();

  // TODO: Start scanner
}
