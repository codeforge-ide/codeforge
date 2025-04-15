import 'package:flutter/material.dart';
import 'terminal_pane.dart';
import 'output_pane.dart';
import 'problems_panel.dart';
import 'ai_pane.dart';

class BottomTabPanel extends StatefulWidget {
  const BottomTabPanel({super.key});

  @override
  State<BottomTabPanel> createState() => _BottomTabPanelState();
}

class _BottomTabPanelState extends State<BottomTabPanel> {
  int _selectedIndex = 0;
  final List<Widget> _views = const [
    TerminalPane(),
    OutputPane(),
    ProblemsPanel(),
    AIPane(),
  ];
  final List<String> _titles = const [
    'Terminal',
    'Output',
    'Problems',
    'AI Assistant',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 36,
          color: Theme.of(context).colorScheme.background.withOpacity(0.9),
          child: Row(
            children: List.generate(_titles.length, (i) => _buildTab(i)),
          ),
        ),
        Expanded(child: _views[_selectedIndex]),
      ],
    );
  }

  Widget _buildTab(int index) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
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
          _titles[index],
          style: TextStyle(
            color: isSelected ? Theme.of(context).colorScheme.primary : null,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
