import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  const arbDir = 'lib/core/l10n/arb';
  // Matches template-arb-file in l10n.yaml.
  const templateName = 'app_ru.arb';

  Map<String, dynamic> read(File file) =>
      jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;

  Map<String, String> messages(Map<String, dynamic> arb) => {
    for (final entry in arb.entries)
      if (!entry.key.startsWith('@')) entry.key: entry.value as String,
  };

  final template = read(File(p.join(arbDir, templateName)));
  final templateMessages = messages(template);

  Iterable<String> placeholdersOf(String key) {
    final metadata = template['@$key'] as Map<String, dynamic>?;
    final placeholders = metadata?['placeholders'] as Map<String, dynamic>?;
    return placeholders?.keys ?? const [];
  }

  final files =
      Directory(arbDir)
          .listSync()
          .whereType<File>()
          .where(
            (file) =>
                file.path.endsWith('.arb') &&
                p.basename(file.path) != templateName,
          )
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));

  test('there are translations besides the template', () {
    expect(files, isNotEmpty);
  });

  for (final file in files) {
    group(p.basename(file.path), () {
      final translation = messages(read(file));

      test('has exactly the messages of the template', () {
        expect(translation.keys.toSet(), templateMessages.keys.toSet());
      });

      test('has no empty messages', () {
        for (final entry in translation.entries) {
          expect(entry.value.trim(), isNotEmpty, reason: entry.key);
        }
      });

      test('keeps every placeholder', () {
        for (final key in templateMessages.keys) {
          for (final name in placeholdersOf(key)) {
            expect(
              translation[key],
              matches(RegExp('\\{$name[,}]')),
              reason: '$key must use {$name}',
            );
          }
        }
      });
    });
  }
}
