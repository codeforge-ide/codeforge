import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// ignore: unused_import
import 'package:highlight/languages/plaintext.dart' as LanguageNames
    show plaintext;
import 'package:provider/provider.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
// ignore: unused_import
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

  // ignore: unused_field
  List<String> get _dropdownLanguages => _languageMap.keys.toList();
  // ignore: unused_field
  CodeController? _controller;

  // Scroll controller for linking editor scroll to minimap
  // Note: flutter_code_editor's CodeField manages its own internal scroll controller.
  // We need a way to listen to it or provide one if the API allows.
  // For now, this might not be directly usable with CodeField's internal scrolling.
  // Let's keep it for the Minimap's gesture handling for now.
  final ScrollController _codeScrollController = ScrollController();
  // We need a separate ScrollController for the Minimap's ListView
  // if we want to control its scroll position based on editor scroll.
  // However, the current Minimap implementation doesn't scroll its content;
  // it just displays a representation and a viewport rectangle.

  @override
  void initState() {
    super.initState();
    // If CodeField exposed its scroll controller or scroll notifications,
    // we could listen here.
    // _codeScrollController.addListener(_updateMinimap);
  }

  @override
  void dispose() {
    // _codeScrollController.removeListener(_updateMinimap);
    _codeScrollController.dispose();
    super.dispose();
  }

  // void _updateMinimap() {
  //   // This function would be called when the editor scrolls.
  //   // We might need to trigger a rebuild of the Minimap or update its state.
  //   // setState(() {}); // Might be inefficient, better to use a dedicated state management for minimap viewport
  // }

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
            // Replace the selection with empty string
            controller.value = controller.value.replaced(selection, '');
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
            // Replace the selection with pasted text
            controller.value =
                controller.value.replaced(selection, data!.text!);
            // Optionally move cursor to the end of pasted text
            controller.selection = TextSelection.collapsed(
                offset: selection.start + data.text!.length);
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

    // Create or update the CodeController based on the active tab's state
    // It's crucial to manage the controller's lifecycle correctly,
    // especially when switching tabs. Using a ValueKey on the CodeField
    // tied to the filePath might help Flutter recreate the state.
    final codeController = CodeController(
      // Removed: CodeController does not accept a key
      text: content,
      language: _languageMap[language],
      namedSectionParser: const BracketsStartEndNamedSectionParser(),
      // Removed: onChange parameter, use onChanged in CodeField instead
    );

    // Use a gutter with line numbers, errors, and folding handles
    const gutterStyle = GutterStyle(
      showErrors: true,
      showFoldingHandles: true,
      showLineNumbers: true,
      // Adjust padding/margin as needed
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
        child: ScrollConfiguration(
          behavior: const _ClampingScrollBehavior(),
          child: Align(
            alignment:
                Alignment.topLeft, // Ensure first line is always at the top
            child: CodeField(
              key: ValueKey('field-$filePath'),
              controller: codeController,
              maxLines: null,
              minLines: null,
              expands:
                  false, // Do not expand to fill parent, let content dictate height
              textStyle: const TextStyle(fontFamily: 'monospace', height: 1.3),
              onChanged: (text) => editorState.updateContent(text),
              gutterStyle: gutterStyle,
            ),
          ),
        ),
      ),
    );

    // Pass the external _codeScrollController to the Minimap
    // This controller will be updated via the NotificationListener above
    final minimap = Minimap(
      key: ValueKey('minimap-$filePath'), // Ensure Minimap updates with file
      code: content,
      scrollController: _codeScrollController, // Use the shared controller
      // lineCount is needed for layout calculation, recalculate if content changes
      lineCount: content.split('\n').length,
    );

    // The parent widget containing CodeEditor should handle the layout
    // (e.g., using Column and Expanded for vertical arrangement).
    // This widget now returns the editor/preview/minimap Row, respecting
    // the constraints given by its parent.
    return isMarkdown
        ? Row(
            key: ValueKey('md-row-$filePath'),
            children: [
              Expanded(child: codeField),
              const VerticalDivider(width: 1),
              Expanded(
                child: MarkdownPreview(
                    key: ValueKey('md-preview-$filePath'), content: content),
              ),
            ],
          )
        : Row(
            key: ValueKey('code-row-$filePath'),
            children: [
              Expanded(
                  child:
                      codeField), // CodeField takes available horizontal space
              const VerticalDivider(width: 1),
              SizedBox(
                width: 80, // Fixed width for the minimap
                child: minimap,
              ),
            ],
          );
  }
}

// Custom ScrollBehavior to remove Overscroll glow
class _ClampingScrollBehavior extends ScrollBehavior {
  const _ClampingScrollBehavior();
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      const ClampingScrollPhysics(); // Prevents overscroll effect
  @override
  Widget buildOverscrollIndicator(
          BuildContext context, Widget child, ScrollableDetails details) =>
      child; // Removes the glow
}

// Minimap widget implementation (Improved)
class Minimap extends StatefulWidget {
  final String code;
  final ScrollController scrollController; // Controller linked to editor scroll
  final int lineCount;
  const Minimap(
      {super.key,
      required this.code,
      required this.scrollController,
      required this.lineCount});

  @override
  State<Minimap> createState() => _MinimapState();
}

class _MinimapState extends State<Minimap> {
  double? _dragStartY;
  double? _initialScrollOffset;

  @override
  void initState() {
    super.initState();
    // Listen to the scroll controller to rebuild the viewport rectangle
    widget.scrollController.addListener(_onScrollChanged);
  }

  @override
  void didUpdateWidget(covariant Minimap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.scrollController != oldWidget.scrollController) {
      oldWidget.scrollController.removeListener(_onScrollChanged);
      widget.scrollController.addListener(_onScrollChanged);
    }
    // If line count changes significantly, might need to recalculate layout factors
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScrollChanged);
    super.dispose();
  }

  void _onScrollChanged() {
    // Trigger a rebuild to update the viewport rectangle position
    if (mounted) {
      setState(() {});
    }
  }

  void _onVerticalDragStart(DragStartDetails details) {
    if (!widget.scrollController.hasClients) return;
    _dragStartY = details.localPosition.dy;
    _initialScrollOffset = widget.scrollController.offset;
    // Optional: Add visual feedback on drag start
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    if (_dragStartY == null ||
        _initialScrollOffset == null ||
        !widget.scrollController.hasClients) {
      return;
    }

    final minimapHeight = context.size?.height;
    if (minimapHeight == null || minimapHeight <= 0) return;

    final scrollableHeight = widget.scrollController.position.maxScrollExtent;
    if (scrollableHeight <= 0) return; // Nothing to scroll

    final dy = details.localPosition.dy - _dragStartY!;

    // Calculate scroll delta based on drag distance relative to minimap height
    // This ratio determines how much the editor should scroll
    final scrollDeltaRatio = dy / minimapHeight;
    final scrollDelta = scrollDeltaRatio * scrollableHeight;

    // Calculate new offset, clamping it within valid scroll bounds
    final newScrollOffset =
        (_initialScrollOffset! + scrollDelta).clamp(0.0, scrollableHeight);

    widget.scrollController.jumpTo(newScrollOffset);
    // No need to call setState here, the listener _onScrollChanged will handle it
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    _dragStartY = null;
    _initialScrollOffset = null;
    // Optional: Add visual feedback on drag end
  }

  @override
  Widget build(BuildContext context) {
    // Use LayoutBuilder to get the actual available height for the minimap
    return LayoutBuilder(
      builder: (context, constraints) {
        final minimapHeight = constraints.maxHeight;
        if (!minimapHeight.isFinite ||
            minimapHeight <= 0 ||
            widget.lineCount <= 0) {
          // Handle cases where height is not properly constrained or no content
          return const SizedBox.shrink();
        }

        // Calculate line height based on available space and line count
        final double lineHeight = (minimapHeight / widget.lineCount)
            .clamp(0.5, 2.0); // Clamp for visibility

        // Calculate viewport rectangle position and size
        double viewportTop = 0;
        double viewportHeightRect =
            minimapHeight; // Default to full height if no scroll info

        if (widget.scrollController.hasClients &&
            widget.scrollController.position.hasContentDimensions) {
          final scrollExtent = widget.scrollController.position.maxScrollExtent;
          final viewportExtent =
              widget.scrollController.position.viewportDimension;
          final scrollOffset = widget.scrollController.offset;

          // Total virtual height represented by the scroll range
          final totalScrollableHeight = scrollExtent + viewportExtent;

          if (totalScrollableHeight > 1e-5) {
            // Avoid division by zero
            // Ratio of scroll offset to total scrollable height
            final scrollRatio =
                (scrollOffset / totalScrollableHeight).clamp(0.0, 1.0);
            // Ratio of viewport size to total scrollable height
            final viewportRatio =
                (viewportExtent / totalScrollableHeight).clamp(0.0, 1.0);

            viewportTop = scrollRatio * minimapHeight;
            viewportHeightRect = viewportRatio * minimapHeight;
          }
        }

        // Clamp viewport position and height to minimap bounds
        viewportHeightRect = viewportHeightRect.clamp(0.0, minimapHeight);
        viewportTop =
            viewportTop.clamp(0.0, minimapHeight - viewportHeightRect);

        return GestureDetector(
          onVerticalDragStart: _onVerticalDragStart,
          onVerticalDragUpdate: _onVerticalDragUpdate,
          onVerticalDragEnd: _onVerticalDragEnd, // Reset state on drag end
          child: ClipRect(
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: SizedBox(
                height: lineHeight * widget.lineCount,
                child: Stack(
                  children: [
                    // Minimap lines representation
                    Positioned.fill(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: List.generate(
                          widget.lineCount,
                          (i) => Container(
                            height: lineHeight,
                            color: i % 2 == 0
                                ? const Color(0xFF2A2A2A)
                                : const Color(0xFF2F2F2F),
                          ),
                          growable: false,
                        ),
                      ),
                    ),
                    // Viewport rectangle overlay
                    Positioned(
                      top: viewportTop,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: viewportHeightRect,
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Colors.blueGrey.shade700, width: 0.5),
                          color: Colors.white.withOpacity(0.08),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
