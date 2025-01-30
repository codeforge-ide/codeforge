import 'dart:io';

class SourceControlService {
  Future<String> getStatus() async {
    try {
      final result = await Process.run('git', ['status']);
      return result.stdout.toString();
    } catch (e) {
      return 'Error getting git status: $e';
    }
  }

  Future<String> getChangedFiles() async {
    try {
      final result = await Process.run('git', ['diff', '--name-only']);
      return result.stdout.toString();
    } catch (e) {
      return 'Error getting changed files: $e';
    }
  }

  Future<String> stageFile(String filePath) async {
    try {
      final result = await Process.run('git', ['add', filePath]);
      return result.stdout.toString();
    } catch (e) {
      return 'Error staging file: $e';
    }
  }

  Future<String> commit(String message) async {
    try {
      final result = await Process.run('git', ['commit', '-m', message]);
      return result.stdout.toString();
    } catch (e) {
      return 'Error committing: $e';
    }
  }
}
