import 'package:flutter/material.dart';
import '../models/editor_state.dart';

class TabInfo {
  final String filePath;
  final EditorState editorState;
  final DateTime lastAccessed;

  TabInfo({
    required this.filePath,
    required this.editorState,
    DateTime? lastAccessed,
  }) : lastAccessed = lastAccessed ?? DateTime.now();
}

class TabManagerService extends ChangeNotifier {
  final List<TabInfo> _tabs = [];
  int _activeTabIndex = -1;
  static const int maxTabs = 10;

  List<TabInfo> get tabs => List.unmodifiable(_tabs);
  int get activeTabIndex => _activeTabIndex;
  TabInfo? get activeTab =>
      _activeTabIndex >= 0 && _activeTabIndex < _tabs.length
          ? _tabs[_activeTabIndex]
          : null;

  void openTab(String filePath, EditorState editorState) {
    final existingIndex = _tabs.indexWhere((tab) => tab.filePath == filePath);

    if (existingIndex != -1) {
      _activeTabIndex = existingIndex;
      notifyListeners();
      return;
    }

    if (_tabs.length >= maxTabs) {
      // Remove least recently used tab that isn't dirty
      final cleanTabs = _tabs.where((tab) => !tab.editorState.isDirty).toList()
        ..sort((a, b) => a.lastAccessed.compareTo(b.lastAccessed));

      if (cleanTabs.isNotEmpty) {
        _tabs.remove(cleanTabs.first);
      }
    }

    _tabs.add(TabInfo(
      filePath: filePath,
      editorState: editorState,
    ));
    _activeTabIndex = _tabs.length - 1;
    notifyListeners();
  }

  void closeTab(int index) {
    if (index < 0 || index >= _tabs.length) return;

    _tabs.removeAt(index);
    if (_activeTabIndex >= _tabs.length) {
      _activeTabIndex = _tabs.isEmpty ? -1 : _tabs.length - 1;
    }
    notifyListeners();
  }

  void setActiveTab(int index) {
    if (index >= 0 && index < _tabs.length && _activeTabIndex != index) {
      _activeTabIndex = index;
      notifyListeners();
    }
  }

  bool hasUnsavedChanges() {
    return _tabs.any((tab) => tab.editorState.isDirty);
  }

  List<String> getUnsavedFiles() {
    return _tabs
        .where((tab) => tab.editorState.isDirty)
        .map((tab) => tab.filePath)
        .toList();
  }
}
