import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../widgets/code_editor.dart';
import '../widgets/ai_pane.dart';
import '../widgets/source_control_pane.dart';
import '../widgets/side_menu.dart';
import '../widgets/bottom_panel.dart';
import '../widgets/command_palette.dart';
import '../widgets/resizable_split_view.dart';
import '../widgets/workspace_drop_area.dart';
import '../models/editor_state.dart';
import '../services/ai_service.dart';
import '../services/source_control_service.dart';
import '../services/workspace_service.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => EditorState()),
        ChangeNotifierProvider(create: (_) => WorkspaceService()),
        Provider(create: (_) => AIService()),
        Provider(create: (_) => SourceControlService()),
      ],
      child: const CodeforgeApp(),
    ),
  );
}

class CodeforgeApp extends StatelessWidget {
  const CodeforgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Codeforge',
      theme: ThemeData.dark().copyWith(
        textTheme: ThemeData.dark()
            .textTheme
            .apply(fontSizeDelta: -2.0), // using fontSizeDelta instead
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool _showCommandPalette = false;

  void _toggleCommandPalette() {
    setState(() {
      _showCommandPalette = !_showCommandPalette;
    });
  }

  void _handleFileDrop(List<String> paths) {
    // In a real app, you may use more robust detection and load workspaces accordingly.
    Provider.of<WorkspaceService>(context, listen: false)
        .addWorkspace(paths.first);
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode()..requestFocus(),
      onKey: (RawKeyEvent event) {
        // Check for ctrl+shift+p key combination.
        if (event is RawKeyDownEvent &&
            event.isControlPressed &&
            event.isShiftPressed &&
            event.logicalKey == LogicalKeyboardKey.keyP) {
          _toggleCommandPalette();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              const Text('Codeforge'),
              const SizedBox(width: 16),
              Consumer<EditorState>(
                builder: (context, state, _) => Text(
                  state.filename + (state.isDirty ? '*' : ''),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
        drawer: const SideMenu(),
        body: WorkspaceDropArea(
          onDrop: _handleFileDrop,
          child: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth > 1200) {
                          // Wide layout: nest two resizable split views.
                          return ResizableSplitView(
                            orientation: SplitViewOrientation.horizontal,
                            initialRatio: 0.6,
                            first: const CodeEditor(),
                            second: ResizableSplitView(
                              orientation: SplitViewOrientation.horizontal,
                              initialRatio: 0.5,
                              first: const AIPane(),
                              second: const SourceControlPane(),
                            ),
                          );
                        } else if (constraints.maxWidth > 800) {
                          // Medium layout: two panels stacked horizontally.
                          return ResizableSplitView(
                            orientation: SplitViewOrientation.horizontal,
                            initialRatio: 0.5,
                            first: const CodeEditor(),
                            second: ResizableSplitView(
                              orientation: SplitViewOrientation.vertical,
                              initialRatio: 0.5,
                              first: const AIPane(),
                              second: const SourceControlPane(),
                            ),
                          );
                        } else {
                          // Narrow layout: stacked vertically.
                          return Column(
                            children: const [
                              Expanded(child: CodeEditor()),
                              Divider(height: 1),
                              Expanded(child: AIPane()),
                              Divider(height: 1),
                              Expanded(child: SourceControlPane()),
                            ],
                          );
                        }
                      },
                    ),
                  ),
                  BottomPanel(onCommandPalette: _toggleCommandPalette),
                ],
              ),
              if (_showCommandPalette)
                CommandPalette(
                  onClose: _toggleCommandPalette,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
