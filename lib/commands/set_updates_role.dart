import 'package:nyxx/nyxx.dart';
import 'package:nyxx_commands/nyxx_commands.dart';
import 'package:ttr_updates_bot/utils/mongo_utils.dart';

final setUpdatesRole = ChatCommand(
  'set-updates-role',
  'Set the role to ping for any TTR updates',
  checks: [
    GuildCheck.all(),
    PermissionsCheck(PermissionsConstants.manageGuild),
  ],
  id('set-updates-role', (IChatContext context, IRole role) async {
    MongoUtils.setUpdatesRole(context.guild!.id.toString(),
        roleId: role.id.toString());
    await context.respond(MessageBuilder.content(
        'Got it! I\'ll ping <@&${role.id}> for every new update.')
      ..allowedMentions = AllowedMentions());
  }),
);
