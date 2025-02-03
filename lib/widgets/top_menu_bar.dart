import 'package:flutter/material.dart';

class TopMenuBar extends StatelessWidget {
  final VoidCallback onClose;

  const TopMenuBar({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              TextButton(
                  onPressed: () {},
                  child: const Text('File',
                      style: TextStyle(color: Colors.white))),
              TextButton(
                  onPressed: () {},
                  child: const Text('Edit',
                      style: TextStyle(color: Colors.white))),
              TextButton(
                  onPressed: () {},
                  child: const Text('View',
                      style: TextStyle(color: Colors.white))),
              // ...add more menu items as needed...
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: onClose,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
