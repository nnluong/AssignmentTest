import 'dart:math';
import 'package:assignmenttest/widgets/sortable_grid/sortable_grid.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Sortable Grid Example'),
        ),
        body: SortableGridExample(),
      ),
    );
  }
}

class SortableGridExample extends StatelessWidget {
  final List<String> alphabets = ['+', 'B', 'C', 'D', 'E', 'F'];

  String getRandomColor() {
    final random = Random();
    int r = 160 + random.nextInt(85); // Red range
    int g = 160 + random.nextInt(85); // Green range
    int b = 160 + random.nextInt(85); // Blue range
    return 'rgb($r, $g, $b)';
  }

  @override
  Widget build(BuildContext context) {
    return SortableGrid(
      itemsPerRow: 2,
      dragActivationThreshold: 200,
      blockTransitionDuration: Duration(milliseconds: 400),
      activeBlockCenteringDuration: Duration(milliseconds: 200),
      onDragStart: () {
        print("A block is being dragged now!");
      },
      onDragRelease: (itemOrder) {
        print(
            "Drag was released, the blocks are in the following order: $itemOrder");
      },
      children: List.generate(alphabets.length, (index) {
        final letter =
            index == 1 || index == alphabets.length - 1 ? '' : alphabets[index];
        final colorItemNormal = index == 1 || index == alphabets.length - 1
            ? Colors.transparent
            : Color(0xFF000000);
        final color = (index == 0)
            ? Colors.blue
            : colorItemNormal; // Default color, modify as needed

        return Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              letter,
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
              ),
            ),
          ),
        );
      }),
    );
  }
}
