import 'dart:convert';

import 'package:http/http.dart';
import 'package:ttr_updates_bot/scanner/objects/ttr_file.dart';

Future<void> main() async {
  final uri = Uri.parse('https://cdn.toontownrewritten.com/content/patchmanifest.txt');
  final response = await get(uri);
  Map<String, dynamic> json = jsonDecode(response.body) as Map<String, dynamic>;
  final map = json.map((key, value) {
    return MapEntry(key, TTRFile.fromJson(value as Map<String, dynamic>));
  });
  print(map);
}