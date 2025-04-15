import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:code_text_field/code_text_field.dart';
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
  CodeController? _codeController;
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

    // Always show file content, regardless of language type
    final language = _languageMap.containsKey(editorState.language)
        ? editorState.language
        : 'plaintext';
    final content = editorState.content;
    final filePath = activeTab?.filePath ?? '';

    final isMarkdown =
        language == 'markdown' || filePath.toLowerCase().endsWith('.md');

    // Force rebuild of the editor/preview split when switching files by using a Key
    return isMarkdown
        ? Row(
            key: ValueKey('md-$filePath'),
            children: [
              Expanded(
                child: Column(
                  children: [
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
                              textStyle:
                                  const TextStyle(fontFamily: 'monospace'),
                              expands: true,
                              maxLines: null,
                              minLines: null,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              VerticalDivider(width: 1),
              Expanded(
                child: MarkdownPreview(
                    key: ValueKey('md-preview-$filePath'), content: content),
              ),
            ],
          )
        : Column(
            key: ValueKey('not-md-$filePath'),
            children: [
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
                        expands: true,
                        maxLines: null,
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
