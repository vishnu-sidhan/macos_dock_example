import 'package:flutter/material.dart';

class DockTileModal {
  final IconData icon;
  final String title;
  const DockTileModal({
    required this.icon,
    required this.title,
  });
}

class DockTile<DocTileModal> extends StatelessWidget {
  const DockTile({super.key, required this.tile, required this.toDisplayTitle});

  final bool toDisplayTitle;

  final DockTileModal tile;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedOpacity(
            opacity: toDisplayTitle ? 1 : 0,
            duration: const Duration(milliseconds: 300),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(3.0),
                child: Text(
                  tile.title,
                  textScaler: const TextScaler.linear(0.6),
                ),
              ),
            )),
        FittedBox(
          fit: BoxFit.contain,
          child: Container(
            constraints: const BoxConstraints(minWidth: 48),
            height: 48,
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors
                  .primaries[tile.icon.hashCode % Colors.primaries.length],
            ),
            child: Center(child: Icon(tile.icon, color: Colors.white)),
          ),
        ),
      ],
    );
  }
}
