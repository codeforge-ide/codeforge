import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;

class CodeforgeStorageService {
  static final String homeDir = Platform.environment['HOME'] ??
      Platform.environment['USERPROFILE'] ??
      '.';
  static final String configDir = p.join(homeDir, '.codeforge');
  static final String recentFile = p.join(configDir, 'recent_workspaces.json');

  static Future<void> ensureConfigDir() async {
    final dir = Directory(configDir);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
  }

  static Future<List<String>> getRecentWorkspaces() async {
    await ensureConfigDir();
    final file = File(recentFile);
    if (!await file.exists()) return [];
    final content = await file.readAsString();
    return content.isNotEmpty ? List<String>.from(jsonDecode(content)) : [];
  }

  static Future<void> addRecentWorkspace(String path) async {
    await ensureConfigDir();
    final recents = await getRecentWorkspaces();
    recents.remove(path);
    recents.insert(0, path);
    if (recents.length > 10) recents.length = 10;
    final file = File(recentFile);
    await file.writeAsString(jsonEncode(recents));
  }
}
