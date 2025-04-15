import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

class TopMenuBar extends StatelessWidget {
  final void Function(String) onMenuSelected;
  final VoidCallback onCommandPalette;
  final String? workspaceName;
  final VoidCallback onToggleSidebar;
  final VoidCallback onToggleSecondarySidebar;
  final VoidCallback onToggleBottomBar;
  final VoidCallback onCustomizeLayout;

  const TopMenuBar({
    super.key,
    required this.onMenuSelected,
    required this.onCommandPalette,
    this.workspaceName,
    required this.onToggleSidebar,
    required this.onToggleSecondarySidebar,
    required this.onToggleBottomBar,
    required this.onCustomizeLayout,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      elevation: 2,
      child: Container(
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            _buildMenu('File'),
            _buildMenu('Edit'),
            _buildMenu('Selection'),
            _buildMenu('View'),
            _buildMenu('Go'),
            _buildMenu('Run'),
            _buildMenu('Terminal'),
            _buildMenu('Help'),
            const SizedBox(width: 16),
            // Command palette region
            Expanded(
              child: GestureDetector(
                onTap: onCommandPalette,
                child: Container(
                  height: 28,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primaryContainer
                        .withOpacity(0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      const Icon(Icons.search, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        workspaceName ?? 'No Folder',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const Spacer(),
                      Text('Ctrl+Shift+P',
                          style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Quick actions
            Tooltip(
              message: 'Customize Layout',
              child: IconButton(
                icon: const Icon(Icons.dashboard_customize),
                onPressed: onCustomizeLayout,
              ),
            ),
            Tooltip(
              message: 'Toggle Primary Sidebar',
              child: IconButton(
                icon: const Icon(Icons.view_sidebar),
                onPressed: onToggleSidebar,
              ),
            ),
            Tooltip(
              message: 'Toggle Secondary Sidebar',
              child: IconButton(
                icon: const Icon(Icons.vertical_split),
                onPressed: onToggleSecondarySidebar,
              ),
            ),
            Tooltip(
              message: 'Toggle Bottom Bar',
              child: IconButton(
                icon: const Icon(Icons.space_bar),
                onPressed: onToggleBottomBar,
              ),
            ),
            // --- Custom Window Buttons ---
            const SizedBox(width: 8),
            WindowTitleBarBox(
              child: Row(
                children: [
                  MinimizeWindowButton(),
                  MaximizeWindowButton(),
                  CloseWindowButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenu(String label) {
    return PopupMenuButton<String>(
      onSelected: onMenuSelected,
      itemBuilder: (context) => [
        PopupMenuItem(value: '$label:dummy', child: Text('Coming soon...')),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
      ),
    );
  }
}
