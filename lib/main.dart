import 'package:flutter/material.dart';
import 'package:macos_dock_example/dock.dart';
import 'package:macos_dock_example/docktile.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  final Map<String, IconData> items = const {
    "Contacts": Icons.person,
    "Messages": Icons.message,
    "Calls": Icons.call,
    "Camera": Icons.camera,
    "Gallery": Icons.photo,
  };

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Dock(
            tiles: items.entries
                .map((v) => DockTileModal(icon: v.value, title: v.key))
                .toList(),
          ),
        ),
      ),
    );
  }
}
