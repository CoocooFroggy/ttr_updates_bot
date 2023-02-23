class Patch {
  String previousHash;
  String filename;
  String patchHash;
  String compPatchHash;

  String get downloadUrl {
    return 'https://download.toontownrewritten.com/patches/$filename';
  }

  Patch(
      {required this.previousHash,
      required this.filename,
      required this.patchHash,
      required this.compPatchHash});

  Map<String, dynamic> toBson() {
    return {
      'filename': filename,
      'patchHash': patchHash,
      'compPatchHash': compPatchHash,
    };
  }

  factory Patch.fromJson(Map<String, dynamic> json, {required String id}) {
    return Patch(
      previousHash: id,
      filename: json['filename'] as String,
      patchHash: json['patchHash'] as String,
      compPatchHash: json['compPatchHash'] as String,
    );
  }

  @override
  String toString() {
    return 'Patch{filename: $filename, patchHash: $patchHash, compPatchHash: $compPatchHash}';
  }
}
