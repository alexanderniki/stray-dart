import 'dart:io' as io;

import 'package:args/args.dart';

import '../domain/random_generator.dart';
import '../domain/string_formatter.dart';
import '../domain/string_picker.dart';

const String appVersion = '0.0.1';

/// Runner for CLI commands and argument processing.
class CliRunner {
  final StringPicker stringPicker;

  CliRunner({required this.stringPicker});

  ArgParser _buildParser() {
    return ArgParser()
      ..addFlag(
        'help',
        abbr: 'h',
        negatable: false,
        help: 'Print this usage information.',
      )
      ..addFlag(
        'version',
        abbr: 'v',
        negatable: false,
        help: 'Print the tool version.',
      )
      ..addOption('seed', help: 'Random seed for deterministic line selection.')
      ..addOption(
        'truncate',
        abbr: 't',
        help: 'Truncate line after specified number of characters.',
      )
      ..addOption(
        'wrap',
        abbr: 'w',
        help: 'Wrap line after specified number of characters.',
      );
  }

  void _printUsage(StringSink sink, ArgParser parser) {
    sink.writeln('Usage: stray [flags] <file-path>');
    sink.writeln(parser.usage);
  }

  Future<int> run(
    List<String> arguments, {
    StringSink? stdoutSink,
    StringSink? stderrSink,
  }) async {
    final stdout = stdoutSink ?? io.stdout;
    final stderr = stderrSink ?? io.stderr;
    final parser = _buildParser();

    final ArgResults results;
    try {
      results = parser.parse(arguments);
    } on FormatException catch (e) {
      stderr.writeln('Error: ${e.message}');
      _printUsage(stderr, parser);
      return 1;
    }

    if (results.flag('help')) {
      _printUsage(stdout, parser);
      return 0;
    }

    if (results.flag('version')) {
      stdout.writeln('stray version: $appVersion');
      return 0;
    }

    if (results.rest.isEmpty) {
      stderr.writeln('Error: Missing required file path');
      _printUsage(stderr, parser);
      return 1;
    }

    if (results.rest.length > 1) {
      stderr.writeln('Error: Exactly one file path argument is required');
      _printUsage(stderr, parser);
      return 1;
    }

    final filePath = results.rest.first;

    int? seed;
    if (results.wasParsed('seed')) {
      final seedStr = results.option('seed');
      seed = int.tryParse(seedStr ?? '');
      if (seed == null) {
        stderr.writeln('Error: Invalid value for --seed: must be an integer');
        return 1;
      }
    }

    int? truncate;
    if (results.wasParsed('truncate')) {
      final truncateStr = results.option('truncate');
      truncate = int.tryParse(truncateStr ?? '');
      if (truncate == null || truncate <= 0) {
        stderr.writeln(
          'Error: Invalid value for --truncate: must be a positive integer',
        );
        return 1;
      }
    }

    int? wrap;
    if (results.wasParsed('wrap')) {
      final wrapStr = results.option('wrap');
      wrap = int.tryParse(wrapStr ?? '');
      if (wrap == null || wrap <= 0) {
        stderr.writeln(
          'Error: Invalid value for --wrap: must be a positive integer',
        );
        return 1;
      }
    }

    final picker = (seed != null)
        ? StringPicker(
            lineReader: stringPicker.lineReader,
            randomGenerator: SystemRandomGenerator(seed),
          )
        : stringPicker;

    final pickResult = picker.pickLine(filePath);

    return pickResult.when(
      onSuccess: (line) {
        final formatted = StringFormatter.format(
          line,
          truncate: truncate,
          wrap: wrap,
        );
        stdout.writeln(formatted);
        return 0;
      },
      onFailure: (error) {
        stderr.writeln('Error: ${error.message}');
        return 1;
      },
    );
  }
}
