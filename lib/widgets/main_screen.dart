import 'package:flutter/material.dart';
import '../widgets/file_explorer.dart';
import '../widgets/source_control_pane.dart';
import '../widgets/search_panel.dart';
import '../widgets/ai_pane.dart';
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

  // ...other methods and build function from main.dart...
}
