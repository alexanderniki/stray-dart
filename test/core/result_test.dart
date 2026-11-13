import 'package:stray_dart/stray_dart.dart';
import 'package:test/test.dart';

void main() {
  group('Result', () {
    test('Success holds value and reports isSuccess', () {
      const result = Success<int, String>(42);

      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      expect(result.value, equals(42));
      expect(result.valueOrNull, equals(42));
      expect(result.errorOrNull, isNull);
    });

    test('Failure holds error and reports isFailure', () {
      const result = Failure<int, String>('something went wrong');

      expect(result.isSuccess, isFalse);
      expect(result.isFailure, isTrue);
      expect(result.error, equals('something went wrong'));
      expect(result.valueOrNull, isNull);
      expect(result.errorOrNull, equals('something went wrong'));
    });

    test('when maps Success correctly', () {
      const result = Success<int, String>(10);
      final mapped = result.when(
        onSuccess: (val) => 'val: $val',
        onFailure: (err) => 'err: $err',
      );

      expect(mapped, equals('val: 10'));
    });

    test('when maps Failure correctly', () {
      const result = Failure<int, String>('boom');
      final mapped = result.when(
        onSuccess: (val) => 'val: $val',
        onFailure: (err) => 'err: $err',
      );

      expect(mapped, equals('err: boom'));
    });
  });
}
