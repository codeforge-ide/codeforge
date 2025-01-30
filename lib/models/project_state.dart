import 'package:flutter/foundation.dart';

class ProjectState extends ChangeNotifier {
  String _projectPath = '';
  final List<String> _openFiles = [];
  String? _activeFile;
  final Map<String, bool> _fileChangeStatus = {};

  String get projectPath => _projectPath;
  List<String> get openFiles => List.unmodifiable(_openFiles);
  String? get activeFile => _activeFile;
  Map<String, bool> get fileChangeStatus => Map.unmodifiable(_fileChangeStatus);

  void setProjectPath(String path) {
    _projectPath = path;
    notifyListeners();
  }

  void addOpenFile(String filePath) {
    if (!_openFiles.contains(filePath)) {
      _openFiles.add(filePath);
      _fileChangeStatus[filePath] = false;
      notifyListeners();
    }
    setActiveFile(filePath);
  }

  void removeOpenFile(String filePath) {
    _openFiles.remove(filePath);
    _fileChangeStatus.remove(filePath);
    if (_activeFile == filePath) {
      _activeFile = _openFiles.isEmpty ? null : _openFiles.last;
    }
    notifyListeners();
  }

  void setActiveFile(String filePath) {
    if (_activeFile != filePath && _openFiles.contains(filePath)) {
      _activeFile = filePath;
      notifyListeners();
    }
  }

  void markFileChanged(String filePath, bool changed) {
    if (_fileChangeStatus[filePath] != changed) {
      _fileChangeStatus[filePath] = changed;
      notifyListeners();
    }
  }

  void closeAllFiles() {
    _openFiles.clear();
    _fileChangeStatus.clear();
    _activeFile = null;
    notifyListeners();
  }
}
