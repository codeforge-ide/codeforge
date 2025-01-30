import 'package:flutter/material.dart';

class EditorState extends ChangeNotifier {
  String _content = '';
  String _language = 'dart';
  String _filename = 'untitled';
  bool _isDirty = false;

  String get content => _content;
  String get language => _language;
  String get filename => _filename;
  bool get isDirty => _isDirty;

  void updateContent(String newContent) {
    if (_content != newContent) {
      _content = newContent;
      _isDirty = true;
      notifyListeners();
    }
  }

  void setLanguage(String lang) {
    if (_language != lang) {
      _language = lang;
      notifyListeners();
    }
  }

  void setFilename(String name) {
    if (_filename != name) {
      _filename = name;
      notifyListeners();
    }
  }

  void markSaved() {
    if (_isDirty) {
      _isDirty = false;
      notifyListeners();
    }
  }
}
