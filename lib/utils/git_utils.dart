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
      directory.delete(recursive: true);
    }

    var process = await Process.run('git', ['clone', url]);
    if (process.exitCode != 0) {
      stdout.writeln(process.stdout);
      stderr.writeln(process.stderr);
      return false;
    }
    process = await Process.run('git', ['config', 'user.name', 'Froggy Bot'],
        workingDirectory: directory.path);
    process = await Process.run(
        'git',
        [
          'config',
          'user.email',
          '<>'
        ],
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
    var process = await Process.run('git', ['add', '.'],
        workingDirectory: directory.path);
    if (process.exitCode != 0) {
      stdout.writeln(process.stdout);
      stderr.writeln(process.stderr);
      return false;
    }
    process = await Process.run('git', ['commit', '-m', ttrVersion ?? 'Update'],
        workingDirectory: directory.path);
    if (process.exitCode != 0) {
      // Only error if the problem isn't about having nothing to commit
      if (!(process.stdout as String).contains('nothing to commit')) {
        print(process.exitCode);
        stdout.writeln(process.stdout);
        stderr.writeln(process.stderr);
        return false;
      }
    }
    process =
        await Process.run('git', ['push'], workingDirectory: directory.path);
    if (process.exitCode != 0) {
      stdout.writeln(process.stdout);
      stderr.writeln(process.stderr);
      return false;
    }
    return true;
  }
}
