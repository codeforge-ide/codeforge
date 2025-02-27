import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/file_system_service.dart';
import '../services/workspace_service.dart';
import '../services/tab_manager_service.dart';
import '../models/editor_state.dart';
import '../utils/language_utils.dart';
import 'shared/loading_overlay.dart';
import 'shared/error_dialog.dart';

class FileExplorer extends StatefulWidget {
  const FileExplorer({super.key});

  @override
  FileExplorerState createState() => FileExplorerState();
}

class FileExplorerState extends State<FileExplorer> {
  bool _isLoading = false;
  final Map<String, bool> _expandedFolders = {};
  List<FileSystemEntity> _entities = [];
  String? _error;
  bool _showHiddenFiles = false;

  @override
  void initState() {
    super.initState();
    _loadWorkspace();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload when workspace changes
    final workspace = context.watch<WorkspaceService>().activeWorkspace;
    if (workspace != null) {
      _loadEntities(workspace);
    }
  }

  Future<void> _loadWorkspace() async {
    final workspace = context.read<WorkspaceService>().activeWorkspace;
    if (workspace != null) {
      await _loadEntities(workspace);
    }
  }

  Future<void> _loadEntities(String path) async {
    if (path.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final dir = Directory(path);
      if (await dir.exists()) {
        final entities = await dir.list().toList();
        
        // Sort directories first, then files
        entities.sort((a, b) {
          final aIsDir = a is Directory;
          final bIsDir = b is Directory;
          if (aIsDir && !bIsDir) return -1;
          if (!aIsDir && bIsDir) return 1;
          return a.path.compareTo(b.path);
        });
        
        setState(() {
          _entities = entities;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Directory does not exist: $path';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load workspace: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshWorkspace() async {
    final workspace = context.read<WorkspaceService>().activeWorkspace;
    if (workspace != null) {
      await _loadEntities(workspace);
    }
  }

  Future<void> _openFile(String path) async {
    final fileSystemService = context.read<FileSystemService>();
    final tabManager = context.read<TabManagerService>();
    
    try {
      setState(() => _isLoading = true);
      
      final content = await fileSystemService.readFile(path);
      final language = LanguageUtils.detectLanguageFromFilename(path);
      
      final editorState = EditorState()
        ..updateContent(content)
        ..setLanguage(language)
        ..setFilename(fileSystemService.getFileName(path))
        ..markSaved();
      
      tabManager.openTab(path, editorState);
      
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _error = 'Failed to open file: $e';
        _isLoading = false;
      });
    }
  }

  void _toggleFolderExpand(String path) {
    setState(() {
      _expandedFolders[path] = !(_expandedFolders[path] ?? false);
    });
  }

  void _toggleShowHiddenFiles() {
    setState(() {
      _showHiddenFiles = !_showHiddenFiles;
      _refreshWorkspace();
    });
  }

  @override
  Widget build(BuildContext context) {
    final workspace = context.watch<WorkspaceService>().activeWorkspace;

    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Explorer header with actions
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Text('EXPLORER', 
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.refresh, size: 18),
                    tooltip: 'Refresh',
                    onPressed: _refreshWorkspace,
                  ),
                  IconButton(
                    icon: Icon(
                      _showHiddenFiles ? Icons.visibility : Icons.visibility_off, 
                      size: 18
                    ),
                    tooltip: _showHiddenFiles ? 'Hide hidden files' : 'Show hidden files',
                    onPressed: _toggleShowHiddenFiles,
                  ),
                  IconButton(
                    icon: const Icon(Icons.create_new_folder, size: 18),
                    tooltip: 'New Folder',
                    onPressed: () {
                      // Add new folder functionality
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, size: 18),
                    tooltip: 'New File',
                    onPressed: () {
                      // Add new file functionality
                    },
                  ),
                ],
              ),
            ),

            if (_error != null)
              Card(
                color: Theme.of(context).colorScheme.errorContainer,
                margin: const EdgeInsets.all(8),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Icon(Icons.error, color: Theme.of(context).colorScheme.error),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(_error!,
                          style: TextStyle(color: Theme.of(context).colorScheme.error)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => setState(() => _error = null),
                      ),
                    ],
                  ),
                ),
              ),

            if (workspace == null)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.folder_open, size: 48, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text('No workspace opened'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          // Open folder dialog
                        },
                        child: const Text('Open Folder'),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    ListTile(
                      dense: true,
                      visualDensity: VisualDensity.compact,
                      title: Row(
                        children: [
                          Icon(Icons.folder_open, 
                            size: 16, 
                            color: Theme.of(context).colorScheme.primary
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              workspace.split('/').last,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      onTap: _refreshWorkspace,
                    ),
                    ..._buildFileTree(_entities, ''),
                  ],
                ),
              ),
          ],
        ),
        if (_isLoading) const LoadingOverlay(),
      ],
    );
  }

  List<Widget> _buildFileTree(List<FileSystemEntity> entities, String basePath) {
    final widgets = <Widget>[];
    
    for (final entity in entities) {
      final relativePath = basePath.isEmpty ? 
          entity.path.split('/').last : 
          '$basePath/${entity.path.split('/').last}';
      
      final fileName = entity.path.split('/').last;
      
      // Skip hidden files if not showing them
      if (!_showHiddenFiles && fileName.startsWith('.')) {
        continue;
      }
      
      if (entity is Directory) {
        final isExpanded = _expandedFolders[entity.path] ?? false;
        
        widgets.add(
          Padding(
            padding: EdgeInsets.only(left: basePath.isEmpty ? 0 : 16.0),
            child: ListTile(
              dense: true,
              visualDensity: VisualDensity.compact,
              leading: Icon(
                isExpanded ? Icons.folder_open : Icons.folder,
                size: 16,
                color: Colors.amber,
              ),
              title: Text(fileName, overflow: TextOverflow.ellipsis),
              onTap: () => _toggleFolderExpand(entity.path),
              trailing: const Icon(Icons.arrow_right, size: 16),
            ),
          ),
        );
        
        if (isExpanded) {
          // Recursively load directory contents when expanded
          try {
            final childEntities = entity.listSync();
            childEntities.sort((a, b) {
              final aIsDir = a is Directory;
              final bIsDir = b is Directory;
              if (aIsDir && !bIsDir) return -1;
              if (!aIsDir && bIsDir) return 1;
              return a.path.compareTo(b.path);
            });
            
            widgets.addAll(_buildFileTree(childEntities, relativePath));
          } catch (e) {
            widgets.add(
              Padding(
                padding: EdgeInsets.only(left: basePath.isEmpty ? 16.0 : 32.0),
                child: ListTile(
                  title: Text('Error: $e', style: const TextStyle(color: Colors.red)),
                ),
              ),
            );
          }
        }
      } else if (entity is File) {
        widgets.add(
          Padding(
            padding: EdgeInsets.only(left: basePath.isEmpty ? 0 : 16.0),
            child: ListTile(
              dense: true,
              visualDensity: VisualDensity.compact,
              leading: Text(
                LanguageUtils.getFileIcon(fileName),
                style: const TextStyle(fontSize: 16),
              ),
              title: Text(fileName, overflow: TextOverflow.ellipsis),
              onTap: () => _openFile(entity.path),
            ),
          ),
        );
      }
    }
    
    return widgets;
  }
}

