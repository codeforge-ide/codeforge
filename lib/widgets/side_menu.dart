import 'package:flutter/material.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
              child: Text("Main Menu",
                  style: Theme.of(context).textTheme.titleLarge)),
          ExpansionTile(
            title: const Text("File"),
            children: const [
              ListTile(title: Text("New File")),
              ListTile(title: Text("Open File")),
            ],
          ),
          ExpansionTile(
            title: const Text("Edit"),
            children: const [
              ListTile(title: Text("Undo")),
              ListTile(title: Text("Redo")),
            ],
          ),
          ExpansionTile(
            title: const Text("View"),
            children: const [
              ListTile(title: Text("Toggle Sidebar")),
              ListTile(title: Text("Zoom In")),
              ListTile(title: Text("Zoom Out")),
            ],
          ),
          // ...add more menu items as needed...
        ],
      ),
    );
  }
}
