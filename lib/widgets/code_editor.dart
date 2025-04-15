import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:code_text_field/code_text_field.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import 'package:highlight/languages/dart.dart';
import 'package:highlight/languages/python.dart';
import 'package:highlight/languages/javascript.dart';
import '../models/editor_state.dart';

class CodeEditor extends StatefulWidget {
  const CodeEditor({super.key});

  @override
  CodeEditorState createState() => CodeEditorState();
}

class CodeEditorState extends State<CodeEditor> {
  CodeController? _codeController;
  final Map<String, dynamic> _languageMap = {
    'dart': dart,
    'python': python,
    'javascript': javascript,
  };

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  void _initializeController() {
    final editorState = context.read<EditorState>();
    _codeController = CodeController(
      text: editorState.content,
      language: _languageMap[editorState.language] ?? dart,
      patternMap: monokaiSublimeTheme,
    );
  }

  @override
  void dispose() {
    _codeController?.dispose();
    super.dispose();
  }

  void _handleLanguageChange(String? newLanguage) {
    if (newLanguage != null) {
      final editorState = context.read<EditorState>();
      editorState.setLanguage(newLanguage);

      setState(() {
        final oldContent = _codeController?.text ?? '';
        _codeController?.dispose();
        _codeController = CodeController(
          text: oldContent,
          language: _languageMap[newLanguage] ?? dart,
          patternMap: monokaiSublimeTheme,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final editorState = context.watch<EditorState>();
    final language = editorState.language;
    final content = editorState.content;

    // Recreate controller if language or content changes
    _codeController ??= CodeController(
      text: content,
      language: _languageMap[language] ?? dart,
      patternMap: monokaiSublimeTheme,
    );
    if (_codeController!.text != content) {
      _codeController!.text = content;
    }
    if (_codeController!.language != (_languageMap[language] ?? dart)) {
      _codeController!.language = _languageMap[language] ?? dart;
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              DropdownButton<String>(
                value: language,
                items: _languageMap.keys.map((lang) {
                  return DropdownMenuItem(
                    value: lang,
                    child: Text(lang.toUpperCase()),
                  );
                }).toList(),
                onChanged: _handleLanguageChange,
              ),
            ],
          ),
        ),
        Expanded(
          child: _codeController == null
              ? const Center(child: CircularProgressIndicator())
              : CodeField(
                  controller: _codeController!,
                  onChanged: (content) {
                    context.read<EditorState>().updateContent(content);
                  },
                  textStyle: const TextStyle(fontFamily: 'monospace'),
                ),
        ),
      ],
    );
  }
}
