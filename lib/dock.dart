import 'dart:async';
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
  bool isInsideDock = true;
  Offset? start;

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

  void onDragTimer() {
    Timer(const Duration(milliseconds: 800), () {
      if (dragIndex != null && hoverIndex != null && dragIndex != hoverIndex) {
        setState(() {
          tiles.insert(hoverIndex!, tiles.removeAt(dragIndex!));
          dragIndex = hoverIndex;
          start = null;
        });
      }
      if (dragIndex != null) onDragTimer();
    });
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
              cursor: SystemMouseCursors.click,
              onEnter: ((event) {
                hoverIndex = index;
                if (dragIndex == null) {
                  setState(() {
                    hoverIndex = index;
                  });
                }
              }),
              onExit: (event) {
                hoverIndex = null;
                if (dragIndex == null) {
                  setState(() {
                    hoverIndex = null;
                  });
                }
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
                    delay: animationDuration,
                    maxSimultaneousDrags: 1,
                    onDragStarted: () {
                      onDragTimer();
                      setState(() {
                        dragIndex = index;
                      });
                    },
                    onDragEnd: (details) {
                      start = null;
                      setState(() {
                        dragIndex = null;
                      });
                    },
                    onDragUpdate: (details) {
                      start ??= details.globalPosition;
                      if (isInsideDock !=
                          (start! - details.globalPosition).distance < 50) {
                        setState(() {
                          isInsideDock = !isInsideDock;
                        });
                      }
                    },
                    feedback:
                        DockTile(tile: tiles[index], toDisplayTitle: false),
                    child: dragIndex == index
                        ? AnimatedSize(
                            duration: animationDuration,
                            child: SizedBox(width: isInsideDock ? 60 : 0))
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
