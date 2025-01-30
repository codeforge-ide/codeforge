import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/code_editor.dart';
import '../widgets/ai_pane.dart';
import '../widgets/source_control_pane.dart';
import '../models/editor_state.dart';
import '../services/ai_service.dart';
import '../services/source_control_service.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => EditorState()),
        Provider(create: (_) => AIService()),
        Provider(create: (_) => SourceControlService()),
      ],
      child: const CodeforgeApp(),
    ),
  );
}

class CodeforgeApp extends StatelessWidget {
  const CodeforgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Codeforge',
      theme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Codeforge'),
            const SizedBox(width: 16),
            Consumer<EditorState>(
              builder: (context, state, _) => Text(
                state.filename + (state.isDirty ? '*' : ''),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
      body: const AdaptiveLayout(),
    );
  }
}

class AdaptiveLayout extends StatelessWidget {
  const AdaptiveLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 1200) {
          return const WideLayout();
        } else if (constraints.maxWidth > 800) {
          return const MediumLayout();
        } else {
          return const NarrowLayout();
        }
      },
    );
  }
}

class WideLayout extends StatelessWidget {
  const WideLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(flex: 3, child: CodeEditor()),
        VerticalDivider(),
        Expanded(flex: 1, child: AIPane()),
        VerticalDivider(),
        Expanded(flex: 1, child: SourceControlPane()),
      ],
    );
  }
}

class MediumLayout extends StatelessWidget {
  const MediumLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          flex: 2,
          child: CodeEditor(),
        ),
        VerticalDivider(),
        Expanded(
          child: Column(
            children: [
              Expanded(child: AIPane()),
              Divider(),
              Expanded(child: SourceControlPane()),
            ],
          ),
        ),
      ],
    );
  }
}

class NarrowLayout extends StatelessWidget {
  const NarrowLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Expanded(child: CodeEditor()),
        Divider(),
        Expanded(child: AIPane()),
        Divider(),
        Expanded(child: SourceControlPane()),
      ],
    );
  }
}
