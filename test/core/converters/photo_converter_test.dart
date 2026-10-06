import 'package:flutter_test/flutter_test.dart';
import 'package:life_calendar/core/converters/photo_converter.dart';

void main() {
  const converter = PhotoConverter();
  const photos = ['a.jpg', 'folder/b.png', 'c "d".heic'];

  test('round-trips photo paths', () {
    expect(converter.fromJson(converter.toJson(photos)), photos);
  });

  test('round-trips an empty list', () {
    expect(converter.toJson([]), '[]');
    expect(converter.fromJson('[]'), isEmpty);
  });

  test('returns an empty list for a missing value', () {
    expect(converter.fromJson(null), isEmpty);
  });

  test('returns an empty list for malformed input', () {
    expect(converter.fromJson('not json'), isEmpty);
    expect(converter.fromJson('{}'), isEmpty);
    expect(converter.fromJson('[1, 2]'), isEmpty);
  });
}
