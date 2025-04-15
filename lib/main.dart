import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'widgets/code_editor.dart';
import 'widgets/ai_pane.dart';
import 'widgets/source_control_pane.dart';
import 'widgets/workspace_drop_area.dart';
import 'models/editor_state.dart';
import 'services/ai_service.dart';
import 'services/source_control_service.dart';
import 'services/workspace_service.dart';
import 'theme/dense_text_theme.dart';
import 'services/tab_manager_service.dart';
import 'services/file_system_service.dart';
import 'services/settings_service.dart';
import 'services/theme_service.dart';
import 'widgets/file_explorer.dart';
import 'widgets/terminal_pane.dart';
import 'widgets/output_pane.dart';
import 'widgets/status_bar.dart';
import 'widgets/search_panel.dart';
import 'widgets/tab_bar.dart';
import 'widgets/problems_panel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final settingsService = await SettingsService.create();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => EditorState()),
        ChangeNotifierProvider(create: (_) => WorkspaceService()),
        ChangeNotifierProvider(create: (_) => TabManagerService()),
        ChangeNotifierProvider(create: (_) => ThemeService()),
        ChangeNotifierProvider.value(value: settingsService),
        Provider(create: (_) => AIService()),
        Provider(create: (_) => SourceControlService()),
        Provider(create: (_) => FileSystemService()),
      ],
      child: const CodeforgeApp(),
    ),
  );
}

class CodeforgeApp extends StatelessWidget {
  const CodeforgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = context.watch<ThemeService>();

    return MaterialApp(
      title: 'Codeforge IDE',
      debugShowCheckedModeBanner: false,
      themeMode: themeService.themeMode,
      darkTheme: ThemeData.dark().copyWith(
        textTheme: getDenseTextTheme(ThemeData.dark().textTheme, delta: 2.0),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
          surface: const Color(0xFF1E1E1E),
          background: const Color(0xFF1E1E1E),
        ),
        scaffoldBackgroundColor: const Color(0xFF1E1E1E),
      ),
      theme: ThemeData.light().copyWith(
        textTheme: getDenseTextTheme(ThemeData.light().textTheme, delta: 2.0),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
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
  bool _showSearchPanel = false;
  int _selectedLeftSidebarIndex = 0;
  int _selectedBottomPanelIndex = 0;
  bool _showLeftSidebar = true;
  bool _showBottomPanel = true;
  bool _showRightSidebar = false;

  final List<Widget> _leftSidebarViews = [];
  final List<Widget> _bottomPanelViews = [];
  final List<Widget> _rightSidebarViews = [];

  // Main layout split ratio
  double _mainHorizontalSplitRatio = 0.2; // Left sidebar width
  double _mainVerticalSplitRatio = 0.7; // Editor height
  double _rightSplitRatio = 0.7; // Right top pane height

  @override
  void initState() {
    super.initState();

    // Initialize the sidebar views
    _leftSidebarViews.addAll([
      const FileExplorer(),
      const SourceControlPane(),
      const SearchPanel(mode: SearchMode.files),
    ]);

    // Initialize the bottom panel views
    _bottomPanelViews.addAll([
      const TerminalPane(),
      const OutputPane(),
      const ProblemsPanel(),
      const AIPane(),
    ]);

    // Initialize the right sidebar views
    _rightSidebarViews.addAll([
      const AIPane(),
    ]);
  }

  void _toggleCommandPalette() {
    setState(() {
      _showCommandPalette = !_showCommandPalette;
    });
  }

  void _toggleSearchPanel() {
    setState(() {
      _showSearchPanel = !_showSearchPanel;
    });
  }

  void _toggleLeftSidebar() {
    setState(() {
      _showLeftSidebar = !_showLeftSidebar;
    });
  }

  void _toggleBottomPanel() {
    setState(() {
      _showBottomPanel = !_showBottomPanel;
    });
  }

  void _toggleRightSidebar() {
    setState(() {
      _showRightSidebar = !_showRightSidebar;
    });
  }

  void _handleFileDrop(List<String> paths) {
    Provider.of<WorkspaceService>(context, listen: false)
        .addWorkspace(paths.first);
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode()..requestFocus(),
      onKey: (RawKeyEvent event) {
        // Handle keyboard shortcuts
        if (event is RawKeyDownEvent) {
          // Cmd/Ctrl + Shift + P: Command palette
          if (event.isMetaPressed &&
              event.isShiftPressed &&
              event.logicalKey == LogicalKeyboardKey.keyP) {
            _toggleCommandPalette();
          }
          // Cmd/Ctrl + B: Toggle sidebar
          else if (event.isMetaPressed &&
              event.logicalKey == LogicalKeyboardKey.keyB) {
            _toggleLeftSidebar();
          }
          // Cmd/Ctrl + J: Toggle bottom panel
          else if (event.isMetaPressed &&
              event.logicalKey == LogicalKeyboardKey.keyJ) {
            _toggleBottomPanel();
          }
          // Cmd/Ctrl + Shift + F: Search
          else if (event.isMetaPressed &&
              event.isShiftPressed &&
              event.logicalKey == LogicalKeyboardKey.keyF) {
            _toggleSearchPanel();
          }
        }
      },
      child: Scaffold(
        body: WorkspaceDropArea(
          onDrop: _handleFileDrop,
          child: Column(
            children: [
              // Top menu and tabs
              Column(
                children: [
                  AppBar(
                    title: const Text('Codeforge IDE'),
                    automaticallyImplyLeading: false,
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.settings),
                        onPressed: () {
                          // Show settings dialog
                        },
                      ),
                    ],
                  ),
                  const EditorTabBar(),
                ],
              ),

              // Main content
              Expanded(
                child: Row(
                  children: [
                    // Left sidebar
                    if (_showLeftSidebar)
                      SizedBox(
                        width: 48,
                        child: Material(
                          color: Theme.of(context)
                              .colorScheme
                              .background
                              .withOpacity(0.9),
                          child: Column(
                            children: [
                              const SizedBox(height: 8),
                              _buildSidebarIconButton(
                                0,
                                Icons.folder,
                                'Explorer',
                                tooltip: 'Explorer (Ctrl+Shift+E)',
                              ),
                              _buildSidebarIconButton(
                                1,
                                Icons.source,
                                'Source Control',
                                tooltip: 'Source Control (Ctrl+Shift+G)',
                              ),
                              _buildSidebarIconButton(
                                2,
                                Icons.search,
                                'Search',
                                tooltip: 'Search (Ctrl+Shift+F)',
                              ),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.settings),
                                onPressed: () {
                                  // Open settings
                                },
                                tooltip: 'Settings',
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ),

                    // Left sidebar content
                    if (_showLeftSidebar)
                      SizedBox(
                        width: MediaQuery.of(context).size.width *
                                _mainHorizontalSplitRatio -
                            48,
                        child: Container(
                          color: Theme.of(context).colorScheme.background,
                          child: _leftSidebarViews[_selectedLeftSidebarIndex],
                        ),
                      ),

                    // Resizer for left sidebar
                    if (_showLeftSidebar)
                      GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onHorizontalDragUpdate: (details) {
                          setState(() {
                            _mainHorizontalSplitRatio += details.delta.dx /
                                MediaQuery.of(context).size.width;
                            _mainHorizontalSplitRatio =
                                _mainHorizontalSplitRatio.clamp(0.1, 0.6);
                          });
                        },
                        child: Container(
                          width: 4,
                          color: Colors.grey[700],
                        ),
                      ),

                    // Main editor area
                    Expanded(
                      child: Column(
                        children: [
                          // Editor area
                          SizedBox(
                            height: _showBottomPanel
                                ? MediaQuery.of(context).size.height *
                                        _mainVerticalSplitRatio -
                                    120
                                : MediaQuery.of(context).size.height - 120,
                            child: const CodeEditor(),
                          ),

                          // Resizer for bottom panel
                          if (_showBottomPanel)
                            GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onVerticalDragUpdate: (details) {
                                setState(() {
                                  _mainVerticalSplitRatio -= details.delta.dy /
                                      MediaQuery.of(context).size.height;
                                  _mainVerticalSplitRatio =
                                      _mainVerticalSplitRatio.clamp(0.2, 0.9);
                                });
                              },
                              child: Container(
                                height: 4,
                                color: Colors.grey[700],
                              ),
                            ),

                          // Bottom panel with tabs
                          if (_showBottomPanel)
                            Expanded(
                              child: Column(
                                children: [
                                  // Bottom panel tabs
                                  Container(
                                    height: 36,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .background
                                        .withOpacity(0.9),
                                    child: Row(
                                      children: [
                                        _buildBottomPanelTab(0, 'Terminal'),
                                        _buildBottomPanelTab(1, 'Output'),
                                        _buildBottomPanelTab(2, 'Problems'),
                                        _buildBottomPanelTab(3, 'AI Assistant'),
                                        const Spacer(),
                                        IconButton(
                                          icon:
                                              const Icon(Icons.close, size: 16),
                                          onPressed: _toggleBottomPanel,
                                          tooltip: 'Close Panel',
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Bottom panel content
                                  Expanded(
                                    child: _bottomPanelViews[
                                        _selectedBottomPanelIndex],
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Right sidebar resizer
                    if (_showRightSidebar)
                      GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onHorizontalDragUpdate: (details) {
                          setState(() {
                            // Update right sidebar width
                          });
                        },
                        child: Container(
                          width: 4,
                          color: Colors.grey[700],
                        ),
                      ),

                    // Right sidebar
                    if (_showRightSidebar)
                      SizedBox(
                        width: 300,
                        child: _rightSidebarViews[0],
                      ),
                  ],
                ),
              ),

              // Status bar
              const StatusBar(),
            ],
          ),
        ),

        // Floating overlays
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: _showCommandPalette || _showSearchPanel
            ? null
            : FloatingActionButton(
                mini: true,
                child: const Icon(Icons.code),
                onPressed: _toggleRightSidebar,
              ),

        // Overlays
        endDrawer: _showRightSidebar ? null : const AIPane(),
      ),
    );
  }

  Widget _buildSidebarIconButton(int index, IconData icon, String label,
      {String? tooltip}) {
    final isSelected = _selectedLeftSidebarIndex == index;

    return Tooltip(
      message: tooltip ?? label,
      preferBelow: false,
      child: InkWell(
        onTap: () => setState(() => _selectedLeftSidebarIndex = index),
        child: Container(
          width: double.infinity,
          height: 48,
          decoration: BoxDecoration(
            border: isSelected
                ? Border(
                    left: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 3,
                    ),
                  )
                : null,
            color: isSelected
                ? Theme.of(context)
                    .colorScheme
                    .primaryContainer
                    .withOpacity(0.3)
                : Colors.transparent,
          ),
          child: Icon(
            icon,
            color: isSelected ? Theme.of(context).colorScheme.primary : null,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomPanelTab(int index, String title) {
    final isSelected = _selectedBottomPanelIndex == index;

    return InkWell(
      onTap: () => setState(() => _selectedBottomPanelIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.transparent,
              width: 2,
            ),
          ),
          color: isSelected
              ? Theme.of(context).colorScheme.surface
              : Colors.transparent,
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Theme.of(context).colorScheme.primary : null,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
