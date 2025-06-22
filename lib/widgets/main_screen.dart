import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/file_explorer.dart';
import '../widgets/source_control_pane.dart';
import '../widgets/search_panel.dart';
import '../widgets/ai_pane.dart';
import 'tab_bar.dart';
import 'code_editor.dart';
import 'bottom_tab_panel.dart';
import 'status_bar.dart';
import 'workspace_drop_area.dart';
import 'package:flutter_resizable_container/flutter_resizable_container.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  bool _showCommandPalette = false;
  bool _showSearchPanel = false;
  int _selectedLeftSidebarIndex = 0;
  final int _selectedBottomPanelIndex = 0;
  bool _showLeftSidebar = true;
  bool _showBottomPanel = true;
  bool _showRightSidebar = false;
  final bool _isHighContrast = false;
  final bool _isUltraDark = false;

  final List<Widget> _leftSidebarViews = [];
  final List<Widget> _rightSidebarViews = [];

  late final ResizableController _mainController;
  late final ResizableController _editorController;

  final FocusNode _keyboardFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _mainController = ResizableController();
    _editorController = ResizableController();
    _leftSidebarViews.addAll([
      const FileExplorer(),
      const SourceControlPane(),
      const SearchPanel(mode: SearchMode.files),
    ]);
    _rightSidebarViews.addAll([
      const AIPane(),
    ]);
  }

  @override
  void dispose() {
    _mainController.dispose();
    _editorController.dispose();
    super.dispose();
  }

  void toggleCommandPalette() {
    setState(() {
      _showCommandPalette = !_showCommandPalette;
    });
  }

  void _toggleLeftSidebar() {
    setState(() {
      _showLeftSidebar = !_showLeftSidebar;
    });
  }

  void _toggleRightSidebar() {
    setState(() {
      _showRightSidebar = !_showRightSidebar;
    });
  }

  void _toggleBottomPanel() {
    setState(() {
      _showBottomPanel = !_showBottomPanel;
    });
  }

  void _toggleSearchPanel() {
    setState(() {
      _showSearchPanel = !_showSearchPanel;
    });
  }

  void _handleFileDrop(List<String> paths) {
    // You may want to implement workspace opening logic here
    // For now, just a placeholder
  }

  @override
  Widget build(BuildContext context) {
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
            toggleCommandPalette();
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
        body: WorkspaceDropArea(
          onDrop: _handleFileDrop,
          child: Column(
            children: [
              // Main content (no titlebar)
              Expanded(
                child: ResizableContainer(
                  controller: _mainController,
                  direction: Axis.horizontal,
                  children: [
                    // Primary sidebar
                    if (_showLeftSidebar)
                      ResizableChild(
                        size: const ResizableSize.pixels(48, min: 40, max: 80),
                        divider: ResizableDivider(
                            thickness: 3, color: Colors.grey[700]),
                        child: Material(
                          color: Theme.of(context)
                              .colorScheme
                              .surface
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

                    // Sidebar content
                    if (_showLeftSidebar)
                      ResizableChild(
                        size:
                            const ResizableSize.ratio(0.2, min: 100, max: 400),
                        divider: ResizableDivider(
                            thickness: 3, color: Colors.grey[700]),
                        child: Container(
                          color: Theme.of(context).colorScheme.surface,
                          child: _leftSidebarViews[_selectedLeftSidebarIndex],
                        ),
                      ),

                    // Main editor + right sidebar
                    ResizableChild(
                      size: const ResizableSize.expand(),
                      child: ResizableContainer(
                        controller: _editorController,
                        direction: Axis.horizontal,
                        children: [
                          // Editor area (with tab bar and bottom panel)
                          ResizableChild(
                            size: const ResizableSize.expand(),
                            divider: ResizableDivider(
                                thickness: 3, color: Colors.grey[700]),
                            child: Column(
                              children: [
                                const EditorTabBar(),
                                const Expanded(
                                  child: CodeEditor(),
                                ),
                                if (_showBottomPanel)
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.25,
                                    child: const BottomTabPanel(),
                                  ),
                              ],
                            ),
                          ),
                          // Right sidebar
                          if (_showRightSidebar)
                            ResizableChild(
                              size: const ResizableSize.pixels(300,
                                  min: 150, max: 500),
                              child: _rightSidebarViews[0],
                            ),
                        ],
                      ),
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
                onPressed: _toggleRightSidebar,
                child: const Icon(Icons.code),
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
}
