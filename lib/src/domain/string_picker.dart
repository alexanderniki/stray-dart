import '../core/app_error.dart';
import '../core/result.dart';
import 'line_reader.dart';
import 'random_generator.dart';

/// Domain service for selecting a random line from a source.
class StringPicker {
  final LineReader lineReader;
  final RandomGenerator randomGenerator;

  StringPicker({required this.lineReader, required this.randomGenerator});

  Result<String, AppError> pickLine(String path) {
    final readResult = lineReader.readLines(path);

    return readResult.when(
      onFailure: (error) => Failure(error),
      onSuccess: (lines) {
        // Strip trailing \r and \n from each line
        final normalizedLines = lines
            .map((line) => line.replaceAll(RegExp(r'[\r\n]+$'), ''))
            .where((line) => line.trim().isNotEmpty)
            .toList();

        if (normalizedLines.isEmpty) {
          return const Failure(EmptyFile());
        }

        if (normalizedLines.length == 1) {
          return Success(normalizedLines.first);
        }

        final index = randomGenerator.nextInt(normalizedLines.length);
        return Success(normalizedLines[index]);
      },
    );
  }
}
