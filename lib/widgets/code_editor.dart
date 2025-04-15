import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:code_text_field/code_text_field.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import 'package:highlight/languages/dart.dart';
import 'package:highlight/languages/python.dart';
import 'package:highlight/languages/javascript.dart';
import '../services/tab_manager_service.dart';

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
    final tabManager = context.read<TabManagerService>();
    final activeTab = tabManager.activeTab;
    final editorState = activeTab?.editorState;

    if (editorState != null) {
      _codeController = CodeController(
        text: editorState.content,
        language: _languageMap[editorState.language] ?? dart,
        patternMap: monokaiSublimeTheme,
      );
    }
  }

  @override
  void dispose() {
    _codeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tabManager = context.watch<TabManagerService>();
    final activeTab = tabManager.activeTab;
    final editorState = activeTab?.editorState;

    if (editorState == null) {
      return const Center(child: Text('No file open'));
    }

    final language = editorState.language;
    final content = editorState.content;

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
                onChanged: (newLanguage) {
                  if (newLanguage != null) {
                    editorState.setLanguage(newLanguage);
                    setState(() {
                      _codeController?.language =
                          _languageMap[newLanguage] ?? dart;
                    });
                  }
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SizedBox(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                child: CodeField(
                  controller: _codeController!,
                  onChanged: (content) {
                    editorState.updateContent(content);
                  },
                  textStyle: const TextStyle(fontFamily: 'monospace'),
                  expands:
                      true, // This makes CodeField fill and scroll within its area
                  maxLines: null, // Allow unlimited lines
                  minLines: null,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
