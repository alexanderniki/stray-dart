import 'package:stray_dart/stray_dart.dart';
import 'package:test/test.dart';

void main() {
  group('StringFormatter', () {
    group('Truncation (-t, --truncate)', () {
      test('truncates line and appends ellipsis when length exceeds limit', () {
        const input = 'The quick brown fox jumps over the lazy dog';
        final result = StringFormatter.format(input, truncate: 15);

        expect(result, equals('The quick brown…'));
      });

      test(
        'leaves line unchanged when length is less than or equal to limit',
        () {
          const input = 'Hello';
          final result = StringFormatter.format(input, truncate: 10);

          expect(result, equals('Hello'));
        },
      );

      test('leaves line unchanged when length exactly equals limit', () {
        const input = 'ExactLength';
        final result = StringFormatter.format(input, truncate: input.length);

        expect(result, equals('ExactLength'));
      });
    });

    group('Wrapping (-w, --wrap)', () {
      test('wraps line into chunks of specified width', () {
        const input = 'ABCDEFGHIJ';
        final result = StringFormatter.format(input, wrap: 4);

        expect(result, equals('ABCD\nEFGH\nIJ'));
      });

      test(
        'leaves line unchanged when length is less than or equal to wrap',
        () {
          const input = 'ABC';
          final result = StringFormatter.format(input, wrap: 5);

          expect(result, equals('ABC'));
        },
      );
    });

    group('Combined Wrapping and Truncation', () {
      test('case 1 (width < truncate): wraps and truncates with ellipsis', () {
        const input = 'ABCDEFGHIJKLMN';
        final result = StringFormatter.format(input, wrap: 4, truncate: 10);

        expect(result, equals('ABCD\nEFGH\nIJ…'));
      });

      test('case 2 (width >= truncate): ignores width and truncates only', () {
        const input = 'ABCDEFGHIJKLMN';
        final result = StringFormatter.format(input, wrap: 10, truncate: 5);

        expect(result, equals('ABCDE…'));
      });
    });
  });
}
