// Run with: dart run tool/fetch_web_bible.dart
// Downloads WEB (public domain) Bible JSON by book into assets/bible/web/

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

const books = [
  'genesis','exodus','leviticus','numbers','deuteronomy','joshua','judges','ruth','1-samuel','2-samuel','1-kings','2-kings','1-chronicles','2-chronicles','ezra','nehemiah','esther','job','psalms','proverbs','ecclesiastes','song-of-solomon','isaiah','jeremiah','lamentations','ezekiel','daniel','hosea','joel','amos','obadiah','jonah','micah','nahum','habakkuk','zephaniah','haggai','zechariah','malachi','matthew','mark','luke','john','acts','romans','1-corinthians','2-corinthians','galatians','ephesians','philippians','colossians','1-thessalonians','2-thessalonians','1-timothy','2-timothy','titus','philemon','hebrews','james','1-peter','2-peter','1-john','2-john','3-john','jude','revelation'
];

// This URL is a placeholder. Replace with a reliable source that provides WEB JSON per book in the schema { book, chapters: [[verses..], ...] }
String sourceFor(String book) => 'https://raw.githubusercontent.com/thiagobodruk/bible/master/json/web/$book.json';

Future<void> main() async {
  final targetDir = Directory('assets/bible/web');
  if (!await targetDir.exists()) {
    await targetDir.create(recursive: true);
  }
  int ok = 0, fail = 0;
  for (final book in books) {
    final url = sourceFor(book);
    stdout.writeln('Fetching $book ...');
    try {
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        // Attempt to normalize to { book, chapters }
        final data = jsonDecode(utf8.decode(res.bodyBytes));
        Map<String, dynamic> normalized;
        if (data is Map && data.containsKey('chapters')) {
          normalized = Map<String, dynamic>.from(data);
        } else if (data is List) {
          normalized = { 'book': book, 'chapters': data };
        } else {
          throw Exception('Unsupported schema');
        }
        final file = File('assets/bible/web/${book.replaceAll(' ', '-').toLowerCase()}.json');
        await file.writeAsString(const JsonEncoder.withIndent('  ').convert(normalized));
        ok++;
      } else {
        fail++;
        stderr.writeln('Failed $book: HTTP ${res.statusCode}');
      }
    } catch (e) {
      fail++;
      stderr.writeln('Failed $book: $e');
    }
  }
  stdout.writeln('Done. Success: $ok, Failed: $fail');
}