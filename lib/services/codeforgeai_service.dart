import 'dart:async';
import 'dart:convert';
import 'dart:io';

class CodeforgeAIService {
  /// Runs a codeforgeai CLI command and returns the output as a string.
  /// [args] is a list of arguments, e.g. ['analyze'], ['prompt', 'Hello']
  Future<CodeforgeAIResult> runCommand(List<String> args,
      {String? workingDirectory, String? input}) async {
    final process = await Process.start(
      'codeforgeai',
      args,
      workingDirectory: workingDirectory,
      runInShell: true,
    );
    if (input != null) {
      process.stdin.write(input);
      await process.stdin.close();
    }
    final stdoutFuture = process.stdout.transform(utf8.decoder).join();
    final stderrFuture = process.stderr.transform(utf8.decoder).join();
    final exitCode = await process.exitCode;
    final stdoutStr = await stdoutFuture;
    final stderrStr = await stderrFuture;
    return CodeforgeAIResult(
      exitCode: exitCode,
      stdout: stdoutStr,
      stderr: stderrStr,
    );
  }

  Map<String, dynamic>? _config;

  /// Loads the .codeforgeai.json config from the user's home directory.
  Future<void> loadConfig() async {
    final home =
        Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];
    if (home == null) return;
    final configFile = File('$home/.codeforgeai.json');
    if (await configFile.exists()) {
      final contents = await configFile.readAsString();
      try {
        _config = jsonDecode(contents) as Map<String, dynamic>;
      } catch (e) {
        _config = null;
      }
    }
  }

  /// Saves the given config map to the .codeforgeai.json file in the user's home directory.
  Future<void> saveConfig(Map<String, dynamic> config) async {
    final home =
        Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];
    if (home == null) return;
    final configFile = File('$home/.codeforgeai.json');
    await configFile.writeAsString(jsonEncode(config), flush: true);
    _config = config;
  }

  /// Returns the File object for the .codeforgeai.json config file, or null if not found.
  Future<File?> getConfigFile() async {
    final home =
        Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];
    if (home == null) return null;
    final configFile = File('$home/.codeforgeai.json');
    if (await configFile.exists()) {
      return configFile;
    }
    return null;
  }

  /// Returns the loaded config, or null if not loaded.
  Map<String, dynamic>? get config => _config;

  /// Example: Analyze the current project
  Future<CodeforgeAIResult> analyzeProject({String? workingDirectory}) {
    return runCommand(['analyze'], workingDirectory: workingDirectory);
  }

  /// Example: Prompt the AI
  Future<CodeforgeAIResult> promptAI(String prompt,
      {String? workingDirectory}) {
    return runCommand(['prompt', prompt], workingDirectory: workingDirectory);
  }

  /// Example: Explain a file
  Future<CodeforgeAIResult> explainFile(String filePath,
      {String? workingDirectory}) {
    return runCommand(['explain', filePath],
        workingDirectory: workingDirectory);
  }

  /// Add more methods for other CLI commands as needed...
}

class CodeforgeAIResult {
  final int exitCode;
  final String stdout;
  final String stderr;
  CodeforgeAIResult(
      {required this.exitCode, required this.stdout, required this.stderr});
  bool get success => exitCode == 0;
}
