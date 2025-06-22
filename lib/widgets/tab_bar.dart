import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/tab_manager_service.dart';
import '../utils/language_utils.dart';

class EditorTabBar extends StatelessWidget {
  const EditorTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    final tabManager = context.watch<TabManagerService>();
    final tabs = tabManager.tabs;
    final activeTabIndex = tabManager.activeTabIndex;

    if (tabs.isEmpty) {
      return Container(
        height: 40,
        color: Theme.of(context).colorScheme.surface.withOpacity(0.7),
        child: const Center(
          child: Text('No files open',
              style: TextStyle(fontStyle: FontStyle.italic)),
        ),
      );
    }

    return Container(
      height: 40,
      color: Theme.of(context).colorScheme.surface.withOpacity(0.7),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        itemBuilder: (context, index) {
          final tab = tabs[index];
          final filename = tab.filePath.split('/').last;
          final isActive = index == activeTabIndex;
          final isDirty = tab.editorState.isDirty;

          return InkWell(
            onTap: () => tabManager.setActiveTab(index),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 200),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isActive
                        ? Theme.of(context).colorScheme.primary
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                color: isActive
                    ? Theme.of(context).colorScheme.surface
                    : Theme.of(context).colorScheme.surface.withOpacity(0.3),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    LanguageUtils.getFileIcon(filename),
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      filename,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight:
                            isActive ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  if (isDirty)
                    const Text('•',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        )),
                  InkWell(
                    onTap: () => tabManager.closeTab(index),
                    child: const Icon(Icons.close, size: 16),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
