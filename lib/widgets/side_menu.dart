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
          const ExpansionTile(
            title: Text("File"),
            children: [
              ListTile(title: Text("New File")),
              ListTile(title: Text("Open File")),
            ],
          ),
          const ExpansionTile(
            title: Text("Edit"),
            children: [
              ListTile(title: Text("Undo")),
              ListTile(title: Text("Redo")),
            ],
          ),
          const ExpansionTile(
            title: Text("View"),
            children: [
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
