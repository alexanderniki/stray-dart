import 'dart:io';

import 'package:stray_dart/stray_dart.dart';
import 'package:test/test.dart';

void main() {
  late Directory tempDir;
  late StringBuffer stdoutBuffer;
  late StringBuffer stderrBuffer;
  late CliRunner runner;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('stray_test_');
    stdoutBuffer = StringBuffer();
    stderrBuffer = StringBuffer();
    runner = CliRunner(
      stringPicker: StringPicker(
        lineReader: const FileLineReader(),
        randomGenerator: SystemRandomGenerator(),
      ),
    );
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  File createTempFile(String name, String content) {
    final file = File('${tempDir.path}/$name');
    file.writeAsStringSync(content);
    return file;
  }

  Future<int> runCli(List<String> args) {
    return runner.run(args, stdoutSink: stdoutBuffer, stderrSink: stderrBuffer);
  }

  group('CLI Acceptance Scenarios', () {
    test('Scenario 1: Successfully select and print a random line', () async {
      final file = createTempFile('quotes.txt', 'Line 1\nLine 2\nLine 3\n');

      final exitCode = await runCli([file.path]);

      expect(exitCode, equals(0));
      expect(
        stdoutBuffer.toString(),
        isIn(['Line 1\n', 'Line 2\n', 'Line 3\n']),
      );
      expect(stderrBuffer.toString(), isEmpty);
    });

    test('Scenario 2: Deterministic selection with --seed', () async {
      final file = createTempFile('items.txt', 'A\nB\nC\nD\nE\n');

      final exitCode1 = await runCli(['--seed', '42', file.path]);
      final output1 = stdoutBuffer.toString();
      stdoutBuffer.clear();

      final exitCode2 = await runCli(['--seed', '42', file.path]);
      final output2 = stdoutBuffer.toString();

      expect(exitCode1, equals(0));
      expect(exitCode2, equals(0));
      expect(output1, equals(output2));
      expect(output1, isNotEmpty);
    });

    test('Scenario 3: Missing file path argument', () async {
      final exitCode = await runCli([]);

      expect(exitCode, equals(1));
      expect(
        stderrBuffer.toString(),
        contains('Error: Missing required file path'),
      );
      expect(stderrBuffer.toString(), contains('Usage:'));
    });

    test('Scenario 4: File does not exist', () async {
      final nonExistentPath = '${tempDir.path}/non_existent.txt';

      final exitCode = await runCli([nonExistentPath]);

      expect(exitCode, equals(1));
      expect(
        stderrBuffer.toString(),
        contains('Error: File not found: $nonExistentPath'),
      );
    });

    test('Scenario 5: Empty file (0 bytes)', () async {
      final file = createTempFile('empty.txt', '');

      final exitCode = await runCli([file.path]);

      expect(exitCode, equals(1));
      expect(stderrBuffer.toString(), contains('Error: File is empty'));
    });

    test('Scenario 6: File contains only newlines', () async {
      final file = createTempFile('blanks.txt', '\n\n\n');

      final exitCode = await runCli([file.path]);

      expect(exitCode, equals(1));
      expect(stderrBuffer.toString(), contains('Error: File is empty'));
    });

    test('Scenario 7: UTF-8 encoding support', () async {
      final file = createTempFile('unicode.txt', 'Привет, мир! 🚀\n你好，世界！\n');

      final exitCode = await runCli([file.path]);

      expect(exitCode, equals(0));
      expect(stdoutBuffer.toString(), isIn(['Привет, мир! 🚀\n', '你好，世界！\n']));
    });

    test('Scenario 8: Help and Version options', () async {
      final helpExit = await runCli(['--help']);
      expect(helpExit, equals(0));
      expect(stdoutBuffer.toString(), contains('Usage:'));
      stdoutBuffer.clear();

      final versionExit = await runCli(['--version']);
      expect(versionExit, equals(0));
      expect(stdoutBuffer.toString(), isNotEmpty);
    });

    test('Scenario 9: Line truncation with -t / --truncate', () async {
      final file = createTempFile(
        'long.txt',
        'The quick brown fox jumps over the lazy dog\n',
      );

      final exitCode = await runCli(['-t', '15', file.path]);

      expect(exitCode, equals(0));
      expect(stdoutBuffer.toString(), equals('The quick brown…\n'));
    });

    test('Scenario 10: Line wrapping with -w / --wrap', () async {
      final file = createTempFile('wrap.txt', 'ABCDEFGHIJ\n');

      final exitCode = await runCli(['-w', '4', file.path]);

      expect(exitCode, equals(0));
      expect(stdoutBuffer.toString(), equals('ABCD\nEFGH\nIJ\n'));
    });

    test(
      'Scenario 11: Combined wrapping and truncation (width < truncate)',
      () async {
        final file = createTempFile('combined.txt', 'ABCDEFGHIJKLMN\n');

        final exitCode = await runCli(['-w', '4', '-t', '10', file.path]);

        expect(exitCode, equals(0));
        expect(stdoutBuffer.toString(), equals('ABCD\nEFGH\nIJ…\n'));
      },
    );

    test(
      'Scenario 12: Combined wrapping and truncation (width >= truncate)',
      () async {
        final file = createTempFile('combined.txt', 'ABCDEFGHIJKLMN\n');

        final exitCode = await runCli(['-w', '10', '-t', '5', file.path]);

        expect(exitCode, equals(0));
        expect(stdoutBuffer.toString(), equals('ABCDE…\n'));
      },
    );
  });
}
