import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:macos_dock_example/docktile.dart';

class Dock extends StatefulWidget {
  const Dock({
    super.key,
    this.tiles = const [],
  });

  final List<DockTileModal> tiles;

  @override
  State<Dock> createState() => _DockState();
}

class _DockState extends State<Dock> {
  final animationDuration = const Duration(milliseconds: 300);
  late final List<DockTileModal> tiles;
  int? hoverIndex;
  int? dragIndex;
  bool isOutsideDock = false;

  @override
  void initState() {
    super.initState();
    tiles = List.from(widget.tiles);
  }

  double getTranslationY(int index) {
    return getPropertyValue(
      index: index,
      baseValue: 0,
      maxValue: -22,
      nonHoveredMaxValue: -14,
    );
  }

  double getPropertyValue({
    required int index,
    required double baseValue,
    required double maxValue,
    required double nonHoveredMaxValue,
  }) {
    late final double propertyValue;

    if (hoverIndex == null) {
      return baseValue;
    }

    final difference = (hoverIndex! - index).abs();

    int itemsAffected = tiles.length;

    if (difference == 0) {
      propertyValue = maxValue;
    } else if (difference <= itemsAffected) {
      final ratio = (itemsAffected - difference) / itemsAffected;

      propertyValue = lerpDouble(baseValue, nonHoveredMaxValue, ratio)!;
    } else {
      propertyValue = baseValue;
    }
    return propertyValue;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.bottomCenter,
      children: [
        Positioned(
          height: 70,
          left: 0,
          right: 0,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.black12,
            ),
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(tiles.length, (index) {
            return MouseRegion(
              opaque: false,
              cursor: SystemMouseCursors.click,
              onEnter: ((event) {
                setState(() {
                  hoverIndex = index;
                  isOutsideDock = false;
                  if (dragIndex != null) {
                    tiles.insert(hoverIndex!, tiles.removeAt(dragIndex!));
                    dragIndex = hoverIndex;
                  }
                });
              }),
              onExit: (event) {
                setState(() {
                  hoverIndex = null;
                  Future.delayed(const Duration(milliseconds: 500), () {
                    if (hoverIndex == null) {
                      setState(() => isOutsideDock = true);
                    }
                  });
                });
              },
              child: AnimatedContainer(
                duration: animationDuration,
                transform: Matrix4.identity()
                  ..translate(
                    0.0,
                    getTranslationY(index),
                    0.0,
                  ),
                child: LongPressDraggable(
                    maxSimultaneousDrags: 1,
                    onDragStarted: () {
                      setState(() {
                        dragIndex = index;
                      });
                    },
                    onDragEnd: (details) {
                      setState(() {
                        dragIndex = null;
                      });
                    },
                    feedback:
                        DockTile(tile: tiles[index], toDisplayTitle: false),
                    child: dragIndex == index
                        ? AnimatedSize(
                            duration: animationDuration,
                            child: SizedBox(width: isOutsideDock ? 0 : 48))
                        : DockTile(
                            tile: tiles[index],
                            toDisplayTitle:
                                index == hoverIndex && dragIndex == null)),
              ),
            );
          }),
        )
      ],
    );
  }
}
