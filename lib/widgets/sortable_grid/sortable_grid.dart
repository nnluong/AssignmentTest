import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:assignmenttest/widgets/sortable_grid/sortable_grid_bloc.dart';
import 'package:assignmenttest/widgets/sortable_grid/sortable_grid_event.dart';
import 'package:assignmenttest/widgets/sortable_grid/sortable_grid_state.dart';
// The BLoC and events you've defined

class SortableGrid extends StatelessWidget {
  final List<Widget> children;
  final int itemsPerRow;
  final int dragActivationThreshold;
  final Duration blockTransitionDuration;
  final Duration activeBlockCenteringDuration;
  final Function(List<int> itemOrder) onDragRelease;
  final Function() onDragStart;

  SortableGrid({
    required this.children,
    required this.itemsPerRow,
    required this.dragActivationThreshold,
    required this.blockTransitionDuration,
    required this.activeBlockCenteringDuration,
    required this.onDragRelease,
    required this.onDragStart,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SortableGridBloc(
        initialItemOrder: List.generate(children.length, (index) => index),
        dragActivationThreshold: dragActivationThreshold,
        onDragRelease: onDragRelease,
      ),
      child: BlocBuilder<SortableGridBloc, SortableGridState>(
        builder: (context, state) {
          if (state is SortableGridInitial ||
              state is SortableGridDragging ||
              state is SortableGridFinishedDragging) {
            return GestureDetector(
              onPanUpdate: (details) {
                if (state is SortableGridDragging) {
                  context
                      .read<SortableGridBloc>()
                      .add(DragUpdateEvent(details.localPosition));
                }
              },
              onPanEnd: (_) {
                context.read<SortableGridBloc>().add(DragEndEvent());
              },
              child: Stack(
                children: List.generate(children.length, (index) {
                  final child = children[state.itemOrder[index]];
                  final isBeingDragged = state is SortableGridDragging &&
                      state.draggedItemIndex == index;
                  final position = _getItemPosition(state, index);

                  return AnimatedPositioned(
                    duration: isBeingDragged
                        ? activeBlockCenteringDuration
                        : blockTransitionDuration,
                    left: position.dx,
                    top: position.dy,
                    child: GestureDetector(
                      onPanStart: (_) {
                        context
                            .read<SortableGridBloc>()
                            .add(DragStartEvent(index));
                        onDragStart();
                      },
                      onPanUpdate: (details) {
                        if (state is SortableGridDragging &&
                            state.draggedItemIndex == index) {
                          context
                              .read<SortableGridBloc>()
                              .add(DragUpdateEvent(details.localPosition));
                        }
                      },
                      onPanEnd: (_) {
                        context.read<SortableGridBloc>().add(DragEndEvent());
                      },
                      child: Container(
                        width: isBeingDragged ? 65 : 80,
                        height: isBeingDragged ? 65 : 80,
                        child: child,
                      ),
                    ),
                  );
                }),
              ),
            );
          }
          return Container(); // Default fallback if state is unknown
        },
      ),
    );
  }

  // Get position for each item based on index and layout
  Offset _getItemPosition(SortableGridState state, int index) {
    final row = index ~/ itemsPerRow;
    final col = index % itemsPerRow;
    double x = col * 90.0; // Adjust width and height to match your grid size
    double y = row * 90.0;

    // If dragging an item, move it with the drag position
    if (state is SortableGridDragging &&
        state.draggedItemIndex == index &&
        state.draggedItemX != null &&
        state.draggedItemY != null) {
      return Offset(state.draggedItemX, state.draggedItemY);
    }

    return Offset(x, y);
  }
}
