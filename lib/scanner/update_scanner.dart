import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:ttr_updates_bot/utils/discord_utils.dart';
import 'package:ttr_updates_bot/utils/mongo_utils.dart';

import 'objects/ttr_file.dart';

class UpdateScanner {
  Future<void> startScanner() async {
    checkForNewFiles();
    Timer timer = Timer.periodic(Duration(seconds: 30), (timer) {
      print('Running');
      checkForNewFiles();
    });
  }

  Future<void> checkForNewFiles() async {
    final uri = Uri.parse(
        'https://cdn.toontownrewritten.com/content/patchmanifest.txt');
    final response = await get(uri);
    // The JSON response is a dictionary
    Map<String, dynamic> json =
        jsonDecode(response.body) as Map<String, dynamic>;
    // Each value in the dictionary is a TTRFile
    final map = json.map((key, value) => MapEntry(
        key, TTRFile.fromJson(value as Map<String, dynamic>, name: key)));

    // Compare to database of updates
    for (var file in map.values) {
      print(file);
      // If the file doesn't exist
      if (!(await MongoUtils.fileHashExists(file.hash))) {
        print('New file!');
        MongoUtils.insertFile(file);
        DiscordUtils.reportNewFile(file);
      } else {
        print('Old file, ${file.name}');
      }
      sleep(Duration(milliseconds: 100));
    }
  }
}
