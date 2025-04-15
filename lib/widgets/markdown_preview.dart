import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class MarkdownPreview extends StatelessWidget {
  final String content;
  const MarkdownPreview({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return Markdown(
      data: content,
      styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)),
      physics: const BouncingScrollPhysics(),
    );
  }
}
