import 'package:stray_dart/stray_dart.dart';
import 'package:test/test.dart';

class FakeLineReader implements LineReader {
  final Result<List<String>, AppError> result;

  FakeLineReader(this.result);

  @override
  Result<List<String>, AppError> readLines(String path) => result;
}

class FakeRandomGenerator implements RandomGenerator {
  final int fixedValue;

  FakeRandomGenerator(this.fixedValue);

  @override
  int nextInt(int max) => fixedValue % max;
}

void main() {
  group('StringPicker', () {
    test('returns selected line using random index', () {
      final reader = FakeLineReader(
        const Success(['Line 1', 'Line 2', 'Line 3']),
      );
      final random = FakeRandomGenerator(1);
      final picker = StringPicker(lineReader: reader, randomGenerator: random);

      final result = picker.pickLine('dummy.txt');

      expect(result, isA<Success<String, AppError>>());
      expect(result.valueOrNull, equals('Line 2'));
    });

    test('always selects the single line in a single-line file', () {
      final reader = FakeLineReader(const Success(['Only Line']));
      final random = FakeRandomGenerator(999);
      final picker = StringPicker(lineReader: reader, randomGenerator: random);

      final result = picker.pickLine('dummy.txt');

      expect(result.valueOrNull, equals('Only Line'));
    });

    test('returns EmptyFile error when file has 0 lines', () {
      final reader = FakeLineReader(const Success([]));
      final random = FakeRandomGenerator(0);
      final picker = StringPicker(lineReader: reader, randomGenerator: random);

      final result = picker.pickLine('dummy.txt');

      expect(result, isA<Failure<String, AppError>>());
      expect(result.errorOrNull, isA<EmptyFile>());
    });

    test('returns EmptyFile error when all lines are empty or whitespace', () {
      final reader = FakeLineReader(const Success(['', '   ', '\t']));
      final random = FakeRandomGenerator(0);
      final picker = StringPicker(lineReader: reader, randomGenerator: random);

      final result = picker.pickLine('dummy.txt');

      expect(result, isA<Failure<String, AppError>>());
      expect(result.errorOrNull, isA<EmptyFile>());
    });

    test('strips trailing CRLF and LF from candidate lines', () {
      final reader = FakeLineReader(
        const Success(['Hello World\r\n', 'Second Line\n']),
      );
      final random = FakeRandomGenerator(0);
      final picker = StringPicker(lineReader: reader, randomGenerator: random);

      final result = picker.pickLine('dummy.txt');

      expect(result.valueOrNull, equals('Hello World'));
    });

    test('preserves UTF-8 and emojis intact', () {
      final reader = FakeLineReader(
        const Success(['Привет, мир! 🚀', '你好，世界！']),
      );
      final random = FakeRandomGenerator(0);
      final picker = StringPicker(lineReader: reader, randomGenerator: random);

      final result = picker.pickLine('dummy.txt');

      expect(result.valueOrNull, equals('Привет, мир! 🚀'));
    });

    test('propagates reader failure unchanged', () {
      final reader = FakeLineReader(const Failure(FileNotFound('missing.txt')));
      final random = FakeRandomGenerator(0);
      final picker = StringPicker(lineReader: reader, randomGenerator: random);

      final result = picker.pickLine('missing.txt');

      expect(result, isA<Failure<String, AppError>>());
      expect(result.errorOrNull, equals(const FileNotFound('missing.txt')));
    });
  });
}
