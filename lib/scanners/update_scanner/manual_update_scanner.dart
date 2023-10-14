import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:io/io.dart';
import 'package:path/path.dart';
import 'package:ttr_updates_bot/utils/git_utils.dart';

import 'objects/ttr_file.dart';

class ManualUpdateScanner {
  Timer? timer;

  Future<void> startScanner() async {
    checkForNewFiles();
    timer = Timer.periodic(Duration(seconds: 30), (timer) {
      checkForNewFiles();
    });
  }

  Future<void> checkForNewFiles() async {
    final file = File('patchmanifest.json');
    // The JSON response is a dictionary
    Map<String, dynamic> json =
        jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    // Each value in the dictionary is a TTRFile
    final map = json.map((key, value) => MapEntry(
        key, TTRFile.fromJson(value as Map<String, dynamic>, name: key)));

    // Queue files to be reported
    List<TTRFile> newFiles = [];
    Map<String, String>? ttrGameAttributes;

    // Compare to database of updates
    for (final file in map.values) {
      // If the file doesn't exist
      // if (!await MongoUtils.fileHashExists(file.hash)) {
        print('New file:\n$file\n----------');
        newFiles.add(file);
        // MongoUtils.insertFile(file);
      // }
    }

    // Quit early if there's nothing new
    if (newFiles.isEmpty) {
      return;
    }

    // Download files to tmp/
    final tmpDir = Directory('tmp');
    // Clear the directory in case it was already used
    if (await tmpDir.exists()) {
      await tmpDir.delete(recursive: true);
    }
    await tmpDir.create();

    print('Decoding and extracting files...');
    for (var ttrFile in newFiles) {
      File file = await downloadFile(url: ttrFile.downloadUrl, path: 'tmp');
      // If the file is compressed
      if (extension(file.path) == '.bz2') {
        // Decompress it
        final inputStream = InputFileStream(file.path);
        final archive = BZip2Decoder().decodeBuffer(inputStream);
        final outputStream = OutputFileStream(join(tmpDir.path, ttrFile.name));
        outputStream.writeBytes(archive);
        await outputStream.close();
        await inputStream.close();
        // Delete the archive
        await file.delete();
        file = File(join(tmpDir.path, ttrFile.name));
        // If the file is TTRGame.vlt, extract some info from it
        if (ttrFile.name == 'TTRGame.vlt') {
          final decode = utf8.decode(archive, allowMalformed: true);
          // Set the attributes to what it can find
          ttrGameAttributes = extractTtrGameAttributes(decode);
        }
      }
      if (ttrFile.name.endsWith('.mf')) {
        if (ttrFile.name.startsWith('phase')) {
          // Extract multifile
          await Process.run('multify', ['-xf', ttrFile.name],
              workingDirectory: tmpDir.path);
        } else {
          // Any other multifiles that aren't base game "phases" should
          // have their own directory, as they could overwrite real
          // phases. For example, winter_decorations overwrites actual
          // textures, like a content pack.

          // Creates 'winter_decorations' folder
          Directory subdir = await Directory(
                  join(tmpDir.path, basenameWithoutExtension(ttrFile.name)))
              .create();
          // Move the multifile into this folder
          file.rename(join(subdir.path, ttrFile.name));
          // Extract multifile
          await Process.run('multify', ['-xf', ttrFile.name],
              workingDirectory: subdir.path);
        }
      }
    }
    print('Finished!');

    // Copy the entire tmp dir to the github
    await copyPath(tmpDir.path, GitUtils.directory.path);
    final commitSuccess =
        await GitUtils.commitAndPush(ttrGameAttributes?['VERSION']);
    if (!commitSuccess) {
      stderr.writeln('Unable to commit!');
    }

    // var servers = await MongoUtils.fetchAllServersWithUpdates();
    //
    // for (var settings in servers) {
    //   // Skip servers who don't have this set up
    //   if (settings.updatesChannelId == null) {
    //     continue;
    //   }
    //   List<Future<void>> futures = [];
    //   for (final file in newFiles) {
    //     // Report each file
    //     final future = DiscordUtils.reportNewFile(
    //         file: file, channelId: settings.updatesChannelId!);
    //     // Add to queue
    //     futures.add(future);
    //   }
    //   // Wait for them all to finish
    //   await Future.wait(futures);
    //   // Then send our yellow embed
    //   if (ttrGameAttributes != null) {
    //     DiscordUtils.reportAttributes(
    //         serverSettings: settings, attributes: ttrGameAttributes);
    //   }
    // }
  }

  Future<File> downloadFile({required String url, required String path}) async {
    final client = await HttpClient().getUrl(Uri.parse(url));
    final response = await client.close();
    // "tmp/" + "TTRGame.vlt.XXXXX.bz2"
    final compressedFile = File(join(path, basename(url)));
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
