/// Core Result pattern representing either Success or Failure.
sealed class Result<S, F> {
  const Result();

  bool get isSuccess => this is Success<S, F>;
  bool get isFailure => this is Failure<S, F>;

  S? get valueOrNull => switch (this) {
    Success(:final value) => value,
    Failure() => null,
  };

  F? get errorOrNull => switch (this) {
    Success() => null,
    Failure(:final error) => error,
  };

  R when<R>({
    required R Function(S value) onSuccess,
    required R Function(F error) onFailure,
  }) {
    return switch (this) {
      Success(:final value) => onSuccess(value),
      Failure(:final error) => onFailure(error),
    };
  }
}

final class Success<S, F> extends Result<S, F> {
  final S value;
  const Success(this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Success<S, F> &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Success($value)';
}

final class Failure<S, F> extends Result<S, F> {
  final F error;
  const Failure(this.error);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure<S, F> &&
          runtimeType == other.runtimeType &&
          error == other.error;

  @override
  int get hashCode => error.hashCode;

  @override
  String toString() => 'Failure($error)';
}
