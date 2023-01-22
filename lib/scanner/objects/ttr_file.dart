import 'dart:convert';

import 'patch.dart';

class TTRFile {
  String dl;
  String hash;
  String compHash;
  Map<String, Patch> patches;
  List<String> only;

  TTRFile(
      {required this.dl,
      required this.hash,
      required this.compHash,
      required this.patches,
      required this.only});

  Map<String, dynamic> toJson() {
    return {
      "dl": dl,
      "hash": hash,
      "compHash": compHash,
      "patches": patches,
      "only": jsonEncode(only),
    };
  }

  factory TTRFile.fromJson(Map<String, dynamic> json) {
    return TTRFile(
      dl: json["dl"] as String,
      hash: json["hash"] as String,
      compHash: json["compHash"] as String,
      patches: (json["patches"] as Map<String, dynamic>).map((key, value) {
        return MapEntry(key, Patch.fromJson(value as Map<String, dynamic>));
      }),
      only: List.from(json["only"] as Iterable),
    );
  }

  @override
  String toString() {
    return 'TTRFile{dl: $dl, hash: $hash, compHash: $compHash, patches: $patches, only: $only}';
  }
}
