import 'dart:io';

import 'package:path/path.dart';

/// Structure of the git repository:
///
/// ```
/// root/
/// ├─── phase_3.mf
/// ├─── phase_3/
/// │     ├─── maps/
/// │     ├─── models/
/// │     └─── etc...
/// ├─── winter_decorations/
/// │     ├─── winter_decorations.mf
/// │     ├─── phase_3/
/// │     │     ├─── maps/
/// │     │     ├─── models/
/// │     │     └─── etc...
/// │     ├─── phase_5/
/// │     └─── etc...
/// └─── etc...
/// ```
class GitUtils {
  static late Directory directory;

  /// Clones the repo at a given [url]. Returns true if succeeded.
  static Future<bool> cloneRepo(String url) async {
    // https://github.com/CoocooFroggy/ttr_update_files.git
    // ->
    // ttr_update_files
    directory = Directory(basenameWithoutExtension(url));

    // Clear it if it exists already
    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }

    var process = await Process.start('git', ['clone', url]);
    stdout.addStream(process.stdout);
    stderr.addStream(process.stderr);
    if (await process.exitCode != 0) {
      return false;
    }
    await Process.run('git', ['config', 'user.name', 'Froggy Bot'],
        workingDirectory: directory.path);
    await Process.run('git', ['config', 'user.email', '<>'],
        workingDirectory: directory.path);
    return true;
  }

  static Future<void> cleanRepoDir() async {
    // List surface level dirs and files
    final list = await directory.list().toList();
    for (FileSystemEntity entity in list) {
      // Delete everything but .git folder
      if (basename(entity.path) != '.git') {
        await entity.delete(recursive: true);
      }
    }
  }

  static Future<bool> commitAndPush(String? ttrVersion) async {
    print('Adding...');
    var process = await Process.start('git', ['add', '.'],
        workingDirectory: directory.path);
    stdout.addStream(process.stdout);
    stderr.addStream(process.stderr);
    if (await process.exitCode != 0) {
      return false;
    }
    print('Added.');

    print('Committing...');
    process = await Process.start(
        'git', ['commit', '-m', ttrVersion ?? 'Update'],
        workingDirectory: directory.path);
    stdout.addStream(process.stdout);
    stderr.addStream(process.stderr);
    if (await process.exitCode != 0) {
      // Only error if the problem isn't about having nothing to commit
      if (!(process.stdout as String).contains('nothing to commit')) {
        return false;
      }
    }
    print('Committed.');

    print('Config buffer...');
    process = await Process.start(
        'git', ['config', 'http.postBuffer', '524288000'],
        workingDirectory: directory.path);
    stdout.addStream(process.stdout);
    stderr.addStream(process.stderr);
    if (await process.exitCode != 0) {
      return false;
    }
    print('Buffer configured!');

    print('Pushing...');
    process =
        await Process.start('git', ['push'], workingDirectory: directory.path);
    stdout.addStream(process.stdout);
    stderr.addStream(process.stderr);
    if (await process.exitCode != 0) {
      return false;
    }
    print('Pushed!');
    return true;
  }
}
