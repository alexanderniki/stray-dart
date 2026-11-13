import 'dart:convert';
import 'dart:io';

import '../core/app_error.dart';
import '../core/result.dart';
import '../domain/line_reader.dart';

/// Reads lines from the local file system using UTF-8 encoding.
class FileLineReader implements LineReader {
  const FileLineReader();

  @override
  Result<List<String>, AppError> readLines(String path) {
    final type = FileSystemEntity.typeSync(path);
    if (type == FileSystemEntityType.notFound) {
      return Failure(FileNotFound(path));
    }
    if (type == FileSystemEntityType.directory) {
      return Failure(PathIsDirectory(path));
    }

    try {
      final file = File(path);
      final content = file.readAsStringSync(encoding: utf8);
      if (content.isEmpty) {
        return Failure(EmptyFile(path));
      }
      final lines = const LineSplitter().convert(content);
      return Success(lines);
    } on FileSystemException catch (e) {
      return Failure(UnexpectedError(e.message));
    } catch (e) {
      return Failure(UnexpectedError(e.toString()));
    }
  }
}
