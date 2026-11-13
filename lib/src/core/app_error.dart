/// Base hierarchy for typed application errors.
sealed class AppError {
  final String message;
  const AppError(this.message);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppError &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;

  @override
  String toString() => '$runtimeType: $message';
}

final class FileNotFound extends AppError {
  const FileNotFound(String path) : super('File not found: $path');
}

final class PathIsDirectory extends AppError {
  const PathIsDirectory(String path) : super('Path is a directory: $path');
}

final class EmptyFile extends AppError {
  const EmptyFile([String? path])
    : super('File is empty${path != null ? ': $path' : ''}');
}

final class InvalidInput extends AppError {
  const InvalidInput(super.message);
}

final class UnexpectedError extends AppError {
  const UnexpectedError(super.message);
}
