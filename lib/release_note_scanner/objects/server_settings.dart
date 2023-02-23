class ServerSettings {
  final String guildId;
  String? updatesRoleId;
  String? updatesChannelId;

  ServerSettings(
    this.guildId, {
    required this.updatesRoleId,
    required this.updatesChannelId,
  });

  Map<String, dynamic> toBson() {
    return {
      'guildId': guildId,
      'updatesRoleId': updatesRoleId,
      'updatesChannelId': updatesChannelId,
    };
  }

  factory ServerSettings.fromJson(Map<String, dynamic> json) {
    return ServerSettings(
      json['guildId'] as String,
      updatesRoleId: json['updatesRoleId'] as String,
      updatesChannelId: json['updatesChannelId'] as String,
    );
  }
//
}
