import 'dart:convert';

import 'package:http/http.dart';

import 'objects/ttr_file.dart';

class UpdateScanner {
  Future<void> startScanner() async {
    final uri = Uri.parse(
        'https://cdn.toontownrewritten.com/content/patchmanifest.txt');
    final response = await get(uri);
    // The JSON response is a dictionary
    Map<String, dynamic> json =
        jsonDecode(response.body) as Map<String, dynamic>;
    // Each value in the dictionary is a TTRFile
    final map = json.map((key, value) =>
        MapEntry(key, TTRFile.fromJson(value as Map<String, dynamic>)));
    // TODO: Compare to database of updates
  }
}
