import '../core/app_error.dart';
import '../core/result.dart';

/// Port for reading lines from a source path.
abstract interface class LineReader {
  Result<List<String>, AppError> readLines(String path);
}
