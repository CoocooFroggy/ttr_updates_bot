import 'package:intl/intl.dart';

class ReleaseNoteFull {
  int noteId;
  String slug;
  DateTime date;
  String body;

  ReleaseNoteFull(
      {required this.noteId,
      required this.slug,
      required this.date,
      required this.body});

  Map<String, dynamic> toBson() {
    return {
      "noteId": noteId,
      "slug": slug,
      "date": date,
      "body": body,
    };
  }

  factory ReleaseNoteFull.fromJson(Map<String, dynamic> json) {
    return ReleaseNoteFull(
      noteId: json["noteId"] as int,
      slug: json["slug"] as String,
      date: DateFormat('MMMM d, yyyy \'at\' h:mm a')
          .parse(json["date"] as String),
      body: json['body'] as String,
    );
  }

  @override
  String toString() {
    return 'ReleaseNoteFull{noteId: $noteId, slug: $slug, date: $date, body: $body}';
  }
}
