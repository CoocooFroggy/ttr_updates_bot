import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:http/http.dart';
import 'package:path/path.dart';
import 'package:ttr_updates_bot/utils/discord_utils.dart';
import 'package:ttr_updates_bot/utils/mongo_utils.dart';

import 'objects/ttr_file.dart';

class UpdateScanner {
  Timer? timer;

  Future<void> startScanner() async {
    checkForNewFiles();
    timer = Timer.periodic(Duration(seconds: 30), (timer) {
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

    // Queue files to be reported
    List<TTRFile> newFiles = [];
    Map<String, String>? ttrGameAttributes;

    // Compare to database of updates
    for (final file in map.values) {
      // If the file doesn't exist
      if (!await MongoUtils.fileHashExists(file.hash)) {
        print('New file:\n$file\n----------');
        newFiles.add(file);
        // If the file is TTRGame.vlt, extract some info from it
        if (file.name == 'TTRGame.vlt') {
          // Download TTRGame.vlt.XXXXXX.bz2
          File compressedFile = await downloadFile(file.downloadUrl);
          // Decompress it
          final archive =
              BZip2Decoder().decodeBuffer(InputFileStream(compressedFile.path));
          final decode = utf8.decode(archive, allowMalformed: true);
          // Set the attributes to what it can find
          ttrGameAttributes = extractTtrGameAttributes(decode);
        }
        MongoUtils.insertFile(file);
      }
    }

    var servers = await MongoUtils.fetchAllServersWithUpdates();

    for (var settings in servers) {
      // Skip servers who don't have this set up
      if (settings.updatesChannelId == null) {
        continue;
      }
      List<Future<void>> futures = [];
      for (final file in newFiles) {
        // Report each file
        final future = DiscordUtils.reportNewFile(
            file: file, channelId: settings.updatesChannelId!);
        // Add to queue
        futures.add(future);
      }
      // Wait for them all to finish
      await Future.wait(futures);
      // Then send our yellow embed
      if (ttrGameAttributes != null) {
        DiscordUtils.reportAttributes(
            serverSettings: settings, attributes: ttrGameAttributes);
      }
    }
  }

  Future<File> downloadFile(String url) async {
    final client = await HttpClient().getUrl(Uri.parse(url));
    final response = await client.close();
    final compressedFile = File(basename(url));
    await response.pipe(compressedFile.openWrite());
    return compressedFile;
  }

  /// Regular expressions for extracting from TTRGame.vlt
  /// https://regex101.com/r/C2cSvL/1
  final pattern = RegExp(r'\x00([A-Z]+)=([\x20-\x7E]+?)\x00');

  /// Extract interesting properties from TTRGame.vlt
  Map<String, String> extractTtrGameAttributes(String body) {
    final Map<String, String> toReturn = {};
    for (final match in pattern.allMatches(body)) {
      final name = match.group(1)!;
      final value = match.group(2)!;
      toReturn[name] = value;
    }
    return toReturn;
  }
}
