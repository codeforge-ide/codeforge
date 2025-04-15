import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import 'package:highlight/languages/dart.dart';
import 'package:highlight/languages/python.dart';
import 'package:highlight/languages/javascript.dart';
import '../services/tab_manager_service.dart';
import 'markdown_preview.dart';

class CodeEditor extends StatefulWidget {
  const CodeEditor({super.key});

  @override
  CodeEditorState createState() => CodeEditorState();
}

class CodeEditorState extends State<CodeEditor> {
  final Map<String, dynamic> _languageMap = {
    'dart': dart,
    'python': python,
    'javascript': javascript,
    'plaintext': null, // For plain text and unknown types
    'markdown': null, // For .md files (optional, can add a highlighter)
  };

  List<String> get _dropdownLanguages => _languageMap.keys.toList();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final tabManager = context.watch<TabManagerService>();
    final activeTab = tabManager.activeTab;
    final editorState = activeTab?.editorState;

    if (editorState == null) {
      return const Center(child: Text('No file open'));
    }

    final language = _languageMap.containsKey(editorState.language)
        ? editorState.language
        : 'plaintext';
    final content = editorState.content;
    final filePath = activeTab?.filePath ?? '';
    final isMarkdown =
        language == 'markdown' || filePath.toLowerCase().endsWith('.md');

    // Use flutter_code_editor's CodeController
    final codeController = CodeController(
      text: content,
      language: _languageMap[language],
    );

    // Use CodeTheme for highlighting
    final codeField = CodeTheme(
      data: CodeThemeData(styles: monokaiSublimeTheme),
      child: CodeField(
        controller: codeController,
        expands: true,
        maxLines: null,
        minLines: null,
        textStyle: const TextStyle(fontFamily: 'monospace'),
        onChanged: (text) => editorState.updateContent(text),
        // You can add more options here (gutterStyle, autocompletion, etc.)
      ),
    );

    return isMarkdown
        ? Row(
            key: ValueKey('md-$filePath'),
            children: [
              Expanded(child: codeField),
              VerticalDivider(width: 1),
              Expanded(
                child: MarkdownPreview(
                    key: ValueKey('md-preview-$filePath'), content: content),
              ),
            ],
          )
        : codeField;
  }
}
