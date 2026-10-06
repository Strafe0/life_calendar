import 'package:flutter_test/flutter_test.dart';
import 'package:life_calendar/core/extensions/string/file_string_extension.dart';

void main() {
  test('recognizes image files by extension in any case', () {
    for (final path in [
      'a.jpg',
      'a.JPEG',
      'dir/b.png',
      '/abs/c.Gif',
      'd.bmp',
      'e.webp',
      'f.HEIC',
    ]) {
      expect(path.isImage, isTrue, reason: path);
    }
  });

  test('rejects other files', () {
    for (final path in ['a.pdf', 'b.mov', 'c', 'archive.jpg.zip', 'jpg']) {
      expect(path.isImage, isFalse, reason: path);
    }
  });
}
