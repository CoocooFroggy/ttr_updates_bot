import 'package:nyxx/nyxx.dart';
import 'package:nyxx_commands/nyxx_commands.dart';
import 'package:ttr_updates_bot/utils/mongo_utils.dart';

final setUpdatesChannel = ChatCommand(
  'set-updates-channel',
  'Set the channel to send messages in for TTR updates',
  checks: [
    GuildCheck.all(),
    PermissionsCheck(PermissionsConstants.manageGuild),
  ],
  id('set-updates-channel',
      (IChatContext context, ITextGuildChannel channel) async {
    MongoUtils.setUpdatesChannel(context.guild!.id.toString(),
        channelId: channel.id.toString());
    await context.respond(MessageBuilder.content(
        'Got it! I\'ll send messages in ${channel.mention} for every new update.'));
  }),
);
