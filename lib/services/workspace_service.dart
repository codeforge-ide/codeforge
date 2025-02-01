import 'package:flutter/material.dart';

class WorkspaceService extends ChangeNotifier {
  final List<String> workspaces = [];
  String? _activeWorkspace;

  String? get activeWorkspace => _activeWorkspace;

  void addWorkspace(String path) {
    if (!workspaces.contains(path)) {
      workspaces.add(path);
      _activeWorkspace = path;
      notifyListeners();
    }
  }

  void switchWorkspace(String path) {
    if (workspaces.contains(path)) {
      _activeWorkspace = path;
      notifyListeners();
    }
  }
}
