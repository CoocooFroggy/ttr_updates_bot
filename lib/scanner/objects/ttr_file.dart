import 'dart:convert';

import 'patch.dart';

class TTRFile {
  String name;
  String dl;
  String hash;
  String compHash;
  Map<String, Patch> patches;
  List<String> only;

  String get downloadUrl {
    return 'https://download.toontownrewritten.com/patches/$dl';
  }

  TTRFile(
      {required this.name,
      required this.dl,
      required this.hash,
      required this.compHash,
      required this.patches,
      required this.only});

  Map<String, dynamic> toBson() {
    return {
      "name": name,
      "dl": dl,
      "hash": hash,
      "compHash": compHash,
      "patches": patches.map((key, value) => MapEntry(key, value.toBson())),
      "only": jsonEncode(only),
    };
  }

  factory TTRFile.fromJson(Map<String, dynamic> json, {required String name}) {
    return TTRFile(
      name: name,
      dl: json["dl"] as String,
      hash: json["hash"] as String,
      compHash: json["compHash"] as String,
      patches: (json["patches"] as Map<String, dynamic>).map((key, value) =>
          MapEntry(
              key, Patch.fromJson(value as Map<String, dynamic>, id: key))),
      only: List.from(json["only"] as Iterable),
    );
  }

  @override
  String toString() {
    return 'TTRFile{name: $name, dl: $dl, hash: $hash, compHash: $compHash, patches: $patches, only: $only}';
  }
}
