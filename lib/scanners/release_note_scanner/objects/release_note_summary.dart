import 'package:intl/intl.dart';

class ReleaseNoteSummary {
  int noteId;
  String slug;
  DateTime date;

  ReleaseNoteSummary(
      {required this.noteId, required this.slug, required this.date});

  Map<String, dynamic> toBson() {
    return {
      'noteId': noteId,
      'slug': slug,
      'date': date,
    };
  }

  factory ReleaseNoteSummary.fromJson(Map<String, dynamic> json) {
    return ReleaseNoteSummary(
      noteId: json['noteId'] as int,
      slug: json['slug'] as String,
      date: DateFormat('MMMM d, yyyy \'at\' h:mm a').parse(json['date'] as String),
    );
  }

  @override
  String toString() {
    return 'ReleaseNoteSummary{noteId: $noteId, slug: $slug, date: $date}';
  }
}
