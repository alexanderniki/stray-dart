import 'dart:io';

import 'package:stray_dart/stray_dart.dart';

Future<void> main(List<String> arguments) async {
  final runner = CliRunner(
    stringPicker: StringPicker(
      lineReader: const FileLineReader(),
      randomGenerator: SystemRandomGenerator(),
    ),
  );

  final exitCode = await runner.run(arguments);
  exit(exitCode);
}
