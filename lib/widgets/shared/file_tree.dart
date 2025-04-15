import 'dart:io';
import 'package:flutter/material.dart';

class FileTree extends StatelessWidget {
  final List<FileSystemEntity> entities;
  final Map<String, bool> expandedFolders;
  final bool showHiddenFiles;
  final String basePath;
  final Function(String) onFileTap;
  final Function(String) onFolderTap;

  const FileTree({
    super.key,
    required this.entities,
    required this.expandedFolders,
    required this.showHiddenFiles,
    required this.basePath,
    required this.onFileTap,
    required this.onFolderTap,
  });

  @override
  Widget build(BuildContext context) {
    final widgets = <Widget>[];
    for (final entity in entities) {
      final fileName = entity.path.split('/').last;
      if (!showHiddenFiles && fileName.startsWith('.')) continue;
      if (entity is Directory) {
        final isExpanded = expandedFolders[entity.path] ?? false;
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
              onTap: () => onFolderTap(entity.path),
              trailing: const Icon(Icons.arrow_right, size: 16),
            ),
          ),
        );
        if (isExpanded) {
          final children = Directory(entity.path).listSync();
          widgets.add(FileTree(
            entities: children,
            expandedFolders: expandedFolders,
            showHiddenFiles: showHiddenFiles,
            basePath: entity.path,
            onFileTap: onFileTap,
            onFolderTap: onFolderTap,
          ));
        }
      } else {
        widgets.add(
          Padding(
            padding: EdgeInsets.only(left: basePath.isEmpty ? 0 : 16.0),
            child: ListTile(
              dense: true,
              visualDensity: VisualDensity.compact,
              leading: const Icon(Icons.insert_drive_file,
                  size: 16, color: Colors.blueGrey),
              title: Text(fileName, overflow: TextOverflow.ellipsis),
              onTap: () => onFileTap(entity.path),
            ),
          ),
        );
      }
    }
    return Column(children: widgets);
  }
}
