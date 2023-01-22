class Patch {
  String filename;
  String patchHash;
  String compPatchHash;

  Patch(
      {required this.filename,
      required this.patchHash,
      required this.compPatchHash});

  Map<String, dynamic> toJson() {
    return {
      "filename": filename,
      "patchHash": patchHash,
      "compPatchHash": compPatchHash,
    };
  }

  factory Patch.fromJson(Map<String, dynamic> json) {
    return Patch(
      filename: json["filename"] as String,
      patchHash: json["patchHash"] as String,
      compPatchHash: json["compPatchHash"] as String,
    );
  }

  @override
  String toString() {
    return 'Patch{filename: $filename, patchHash: $patchHash, compPatchHash: $compPatchHash}';
  }
}
