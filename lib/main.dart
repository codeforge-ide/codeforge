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
import 'widgets/status_bar.dart';
import 'widgets/search_panel.dart';
// import 'widgets/tab_bar.dart'; // Assuming this is not used if EditorTabBar is removed
import 'widgets/bottom_tab_panel.dart';
import 'services/codeforge_storage_service.dart';
import 'widgets/top_menu_bar.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_resizable_container/flutter_resizable_container.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'widgets/buttons/buttonColors.dart';
// import 'widgets/editor_tab_bar.dart'; // Removed missing import

// Accept command-line arguments
void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  final settingsService = await SettingsService.create();
  final workspaceService = WorkspaceService(); // Create instance early

  // If a path argument is provided, try to open it as a workspace
  if (args.isNotEmpty) {
    final path = args.first;
    // You might want to add error handling or validation here
    // to ensure the path is valid before adding it.
    workspaceService.addWorkspace(path); // Use the service to add the workspace
    // Optionally, store it as a recent workspace
    await CodeforgeStorageService.addRecentWorkspace(path);
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => EditorState()),
        // Use the pre-created instance
        ChangeNotifierProvider.value(value: workspaceService),
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

  doWhenWindowReady(() {
    final win = appWindow;
    const initialSize = Size(600, 450);
    win.minSize = initialSize;
    win.size = initialSize;
    win.alignment = Alignment.center;
    // win.title = ""; // Remove window title
    // win.titleBarStyle = TitleBarStyle.hidden; // Add this line

    win.show();
  });
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
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
        },
        physics: const ClampingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  bool _showCommandPalette = false;
  bool _showSearchPanel = false;
  int _selectedLeftSidebarIndex = 0;
  int _selectedBottomPanelIndex = 0;
  bool _showLeftSidebar = true;
  bool _showBottomPanel = true;
  bool _showRightSidebar = false;
  bool _isHighContrast = false;
  bool _isUltraDark = false;

  final List<Widget> _leftSidebarViews = [];
  final List<Widget> _rightSidebarViews = [];

  late final ResizableController _mainController;
  late final ResizableController _editorController;

  FocusNode _keyboardFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    _mainController = ResizableController();
    _editorController = ResizableController();

    // Initialize the sidebar views
    _leftSidebarViews.addAll([
      const FileExplorer(),
      const SourceControlPane(),
      const SearchPanel(mode: SearchMode.files),
    ]);

    // Initialize the right sidebar views
    _rightSidebarViews.addAll([
      const AIPane(),
    ]);
  }

  @override
  void dispose() {
    _mainController.dispose();
    _editorController.dispose();
    _keyboardFocusNode.dispose(); // Dispose focus node
    super.dispose();
  }

  Future<void> _handleOpenWorkspace(String path) async {
    Provider.of<WorkspaceService>(context, listen: false).addWorkspace(path);
    await CodeforgeStorageService.addRecentWorkspace(path);
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

  void _toggleLightDarkMode() {
    final themeService = context.read<ThemeService>();
    themeService.setThemeMode(
      themeService.themeMode == ThemeMode.dark
          ? ThemeMode.light
          : ThemeMode.dark,
    );
  }

  void _toggleHighContrast() {
    setState(() {
      _isHighContrast = !_isHighContrast;
    });
    // You can expand this to actually change the theme colors for high contrast
  }

  void _toggleUltraDark() {
    setState(() {
      _isUltraDark = !_isUltraDark;
    });
    final themeService = context.read<ThemeService>();
    if (_isUltraDark) {
      themeService.setThemeMode(ThemeMode.dark);
      // You can expand this to set a custom ultra-dark theme
    }
  }

  void _handleFileDrop(List<String> paths) {
    _handleOpenWorkspace(paths.first);
  }

  @override
  Widget build(BuildContext context) {
    // Get workspace name safely
    final workspaceService = context.watch<WorkspaceService>();
    final workspaceName =
        workspaceService.activeWorkspace?.split('/').last ?? 'No Workspace';

    return RawKeyboardListener(
      focusNode: _keyboardFocusNode,
      autofocus: true,
      onKey: (RawKeyEvent event) {
        // Handle keyboard shortcuts
        if (event is RawKeyDownEvent) {
          // Support both Ctrl+Shift+P and Cmd+Shift+P (for Mac)
          final isCtrlOrCmd = event.isControlPressed || event.isMetaPressed;
          if (isCtrlOrCmd &&
              event.isShiftPressed &&
              (event.logicalKey == LogicalKeyboardKey.keyP ||
                  event.logicalKey.keyLabel.toLowerCase() == 'p')) {
            _toggleCommandPalette();
          }
          // Cmd/Ctrl + B: Toggle sidebar
          else if (isCtrlOrCmd && event.logicalKey == LogicalKeyboardKey.keyB) {
            _toggleLeftSidebar();
          }
          // Cmd/Ctrl + J: Toggle bottom panel
          else if (isCtrlOrCmd && event.logicalKey == LogicalKeyboardKey.keyJ) {
            _toggleBottomPanel();
          }
          // Cmd/Ctrl + Shift + F: Search
          else if (isCtrlOrCmd &&
              event.isShiftPressed &&
              event.logicalKey == LogicalKeyboardKey.keyF) {
            _toggleSearchPanel();
          }
        }
      },
      child: Scaffold(
        // Ensure no AppBar is present here
        body: WindowBorder(
          // Wrap body with WindowBorder
          color: Theme.of(context).dividerColor, // Use theme color for border
          width: 1,
          child: Column(
            // Main content column
            children: [
              // Top bar area combining TopMenuBar and WindowButtons
              SizedBox(
                // Constrain the height of the top bar
                height: 30, // Adjust height as needed (e.g., kToolbarHeight)
                child: Row(
                  children: [
                    Expanded(
                      child: MoveWindow(
                        // Make the TopMenuBar area draggable
                        child: TopMenuBar(
                          // Pass necessary callbacks and data
                          // Example properties (ensure these match your TopMenuBar constructor):
                          onMenuSelected: (menu) {/* TODO */},
                          onCommandPalette: _toggleCommandPalette,
                          workspaceName: workspaceName,
                          onToggleSidebar: _toggleLeftSidebar,
                          onToggleSecondarySidebar: _toggleRightSidebar,
                          onToggleBottomBar: _toggleBottomPanel,
                          onCustomizeLayout: () {/* TODO */},
                          // Add other required parameters for TopMenuBar
                        ),
                      ),
                    ),
                    // WindowButtons(
                    //   // Add the standard window buttons
                    //   buttonColors: buttonColors,
                    //   closeButtonColors: closeButtonColors,
                    // ),

                    // Row(
                    //   children: [
                    //     MinimizeWindowButton(colors: buttonColors),
                    //     MaximizeWindowButton(colors: buttonColors),
                    //     CloseWindowButton(colors: closeButtonColors),
                    //   ],
                    // )
                  ],
                ),
              ),
              // The rest of the application content
              Expanded(
                child: WorkspaceDropArea(
                  // Your existing main content area
                  onDrop: _handleFileDrop, // Ensure this callback is correct
                  child: ResizableContainer(
                    // The main resizable layout
                    controller: _mainController,
                    direction: Axis.horizontal,
                    children: [
                      // Primary sidebar (Activity Bar)
                      if (_showLeftSidebar)
                        ResizableChild(
                          size: const ResizableSize.pixels(48),
                          child: Material(
                            // Use Material for background color
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceVariant, // Example color
                            child: Column(
                              children: [
                                const SizedBox(
                                    height:
                                        8), // Spacing from top (under MoveWindow area)
                                _buildSidebarIconButton(
                                    0,
                                    Icons.description_outlined,
                                    'Explorer'), // Example icons
                                _buildSidebarIconButton(
                                    1, Icons.merge_type, 'Source Control'),
                                _buildSidebarIconButton(
                                    2, Icons.search, 'Search'),
                                const Spacer(),
                                IconButton(
                                  icon: const Icon(Icons.settings_outlined),
                                  onPressed: () {/* TODO: Open settings */},
                                  tooltip: 'Manage',
                                ),
                                const SizedBox(height: 8),
                              ],
                            ),
                          ),
                        ),

                      // Sidebar content (File Explorer, Search, etc.)
                      if (_showLeftSidebar)
                        ResizableChild(
                          size: const ResizableSize.ratio(0.2, min: 150),
                          child: Container(
                            // Use Container for background
                            color: Theme.of(context)
                                .colorScheme
                                .surface, // Example color
                            child: IndexedStack(
                              // Use IndexedStack to switch views
                              index: _selectedLeftSidebarIndex,
                              children: _leftSidebarViews,
                            ),
                          ),
                        ),

                      // Main editor area + Right Sidebar
                      ResizableChild(
                        size: const ResizableSize.expand(),
                        child: ResizableContainer(
                          controller: _editorController,
                          direction:
                              Axis.horizontal, // Split editor and right sidebar
                          children: [
                            // Editor + Bottom Panel Column
                            ResizableChild(
                              size: const ResizableSize.expand(),
                              child: Column(
                                children: [
                                  // const EditorTabBar(), // Removed missing widget
                                  const Expanded(
                                    child:
                                        CodeEditor(), // Ensure CodeEditor is imported/defined
                                  ),
                                  // Bottom Panel (Conditional and Vertically Resizable)
                                  if (_showBottomPanel)
                                    const Flexible(
                                      // Wrap ResizableContainer with Flexible
                                      child: ResizableContainer(
                                        direction: Axis.vertical,
                                        // controller: _bottomPanelController, // Add if you need to control this specific resize
                                        children: [
                                          ResizableChild(
                                            size: ResizableSize.ratio(0.25,
                                                min: 100),
                                            // Remove invalid parameters from BottomTabPanel
                                            child:
                                                BottomTabPanel(), // Ensure BottomTabPanel is imported
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),

                            // Right Sidebar (e.g., AI Pane)
                            if (_showRightSidebar)
                              ResizableChild(
                                size: const ResizableSize.ratio(0.2, min: 150),
                                child: IndexedStack(
                                  // Use IndexedStack if multiple right panels possible
                                  index:
                                      0, // Assuming only one right sidebar view for now
                                  children: _rightSidebarViews,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Status bar at the bottom
              const StatusBar(), // Ensure StatusBar is imported/defined
            ],
          ),
        ),
        // Remove floatingActionButton and endDrawer if they are no longer needed
        // or integrate their toggling logic differently (e.g., via TopMenuBar)
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
}
