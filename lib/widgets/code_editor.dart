import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:highlight/languages/dart.dart';
import 'package:highlight/languages/python.dart';
import 'package:highlight/languages/javascript.dart';
import '../services/tab_manager_service.dart';
import 'markdown_preview.dart';
import 'main_screen.dart';

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

  void _showEditorContextMenu(
      BuildContext context, Offset position, CodeController controller) async {
    final result = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
          position.dx, position.dy, position.dx, position.dy),
      items: [
        const PopupMenuItem(value: 'split_right', child: Text('Split Right')),
        const PopupMenuItem(value: 'split_left', child: Text('Split Left')),
        const PopupMenuItem(value: 'split_bottom', child: Text('Split Bottom')),
        const PopupMenuItem(value: 'split_top', child: Text('Split Top')),
        const PopupMenuDivider(),
        const PopupMenuItem(value: 'select_all', child: Text('Select All')),
        const PopupMenuItem(value: 'cut', child: Text('Cut')),
        const PopupMenuItem(value: 'copy', child: Text('Copy')),
        const PopupMenuItem(value: 'paste', child: Text('Paste')),
        const PopupMenuDivider(),
        const PopupMenuItem(
            value: 'command_palette', child: Text('Command Palette')),
      ],
    );
    if (result != null) {
      switch (result) {
        case 'select_all':
          controller.selection = TextSelection(
              baseOffset: 0, extentOffset: controller.text.length);
          break;
        case 'cut':
          final selection = controller.selection;
          if (!selection.isCollapsed) {
            final selectedText =
                controller.text.substring(selection.start, selection.end);
            Clipboard.setData(ClipboardData(text: selectedText));
            controller.text = controller.text
                .replaceRange(selection.start, selection.end, '');
          }
          break;
        case 'copy':
          final selection = controller.selection;
          if (!selection.isCollapsed) {
            final selectedText =
                controller.text.substring(selection.start, selection.end);
            Clipboard.setData(ClipboardData(text: selectedText));
          }
          break;
        case 'paste':
          final data = await Clipboard.getData('text/plain');
          if (data?.text != null) {
            final selection = controller.selection;
            final newText = controller.text
                .replaceRange(selection.start, selection.end, data!.text!);
            controller.text = newText;
          }
          break;
        case 'command_palette':
          // You can trigger the command palette here, e.g. via a callback
          if (context
                  .findAncestorStateOfType<MainScreenState>()
                  ?.toggleCommandPalette !=
              null) {
            context
                .findAncestorStateOfType<MainScreenState>()!
                .toggleCommandPalette();
          }
          break;
        // TODO: Implement split actions
        case 'split_right':
        case 'split_left':
        case 'split_bottom':
        case 'split_top':
          // Call your split logic here
          break;
      }
    }
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

    // Use flutter_code_editor's CodeController with folding and named section parsing
    final codeController = CodeController(
      text: content,
      language: _languageMap[language],
      namedSectionParser: const BracketsStartEndNamedSectionParser(),
    );
    // Autocompletion and folding are enabled by default in flutter_code_editor

    // Use a gutter with line numbers, errors, and folding handles
    final gutterStyle = GutterStyle(
      showErrors: true,
      showFoldingHandles: true,
      showLineNumbers: true,
    );

    // Use CodeTheme for highlighting
    final codeField = CodeTheme(
      data: CodeThemeData(styles: monokaiSublimeTheme),
      child: Listener(
        onPointerDown: (event) {
          if (event.kind == PointerDeviceKind.mouse &&
              event.buttons == kSecondaryMouseButton) {
            _showEditorContextMenu(context, event.position, codeController);
          }
        },
        child: CodeField(
          controller: codeController,
          expands: true,
          maxLines: null,
          minLines: null,
          textStyle: const TextStyle(fontFamily: 'monospace'),
          onChanged: (text) => editorState.updateContent(text),
          gutterStyle: gutterStyle,
        ),
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
