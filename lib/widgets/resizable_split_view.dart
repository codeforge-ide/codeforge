import 'package:flutter/material.dart';

enum SplitViewOrientation { horizontal, vertical }

class ResizableSplitView extends StatefulWidget {
  final Widget first;
  final Widget second;
  final double initialRatio;
  final SplitViewOrientation orientation;

  const ResizableSplitView({
    super.key,
    required this.first,
    required this.second,
    this.initialRatio = 0.7,
    this.orientation = SplitViewOrientation.horizontal,
  });

  @override
  State<ResizableSplitView> createState() => _ResizableSplitViewState();
}

class _ResizableSplitViewState extends State<ResizableSplitView> {
  late double splitRatio;

  @override
  void initState() {
    super.initState();
    splitRatio = widget.initialRatio;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxSize = widget.orientation == SplitViewOrientation.horizontal
            ? constraints.maxWidth
            : constraints.maxHeight;
        final firstSize = splitRatio * maxSize;
        final secondSize = (1 - splitRatio) * maxSize;

        return widget.orientation == SplitViewOrientation.horizontal
            ? Row(
                children: [
                  SizedBox(width: firstSize, child: widget.first),
MouseRegion(
  cursor: SystemMouseCursors.resizeColumn,
  child: GestureDetector(
    behavior: HitTestBehavior.translucent,
    onHorizontalDragUpdate: (details) {
      setState(() {
        splitRatio += details.delta.dx / maxSize;
        splitRatio = splitRatio.clamp(0.1, 0.9);
      });
    },
    child: Container(
      width: 12,
      color: Colors.transparent,
      child: Center(
        child: Container(
          width: 4,
          height: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[700],
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    ),
  ),
),                  SizedBox(width: secondSize, child: widget.second),
                ],
              )
            : Column(
                children: [
                  SizedBox(height: firstSize, child: widget.first),
MouseRegion(
  cursor: SystemMouseCursors.resizeRow,
  child: GestureDetector(
    behavior: HitTestBehavior.translucent,
    onVerticalDragUpdate: (details) {
      setState(() {
        splitRatio += details.delta.dy / maxSize;
        splitRatio = splitRatio.clamp(0.1, 0.9);
      });
    },
    child: Container(
      height: 12,
      color: Colors.transparent,
      child: Center(
        child: Container(
          height: 4,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[700],
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    ),
  ),
),                  SizedBox(height: secondSize, child: widget.second),
                ],
              );
      },
    );
  }
}
