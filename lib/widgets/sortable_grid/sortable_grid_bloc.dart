import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:assignmenttest/widgets/sortable_grid/sortable_grid_event.dart';
import 'package:assignmenttest/widgets/sortable_grid/sortable_grid_state.dart';

class SortableGridBloc extends Bloc<SortableGridEvent, SortableGridState> {
  final int dragActivationThreshold;
  final Function(List<int> itemOrder) onDragRelease;

  int? _draggedItemIndex;
  double? _draggedItemX;
  double? _draggedItemY;
  bool _hasActivatedDrag = false;

  SortableGridBloc({
    required List<int> initialItemOrder,
    required this.dragActivationThreshold,
    required this.onDragRelease,
  }) : super(SortableGridInitial(initialItemOrder)) {
    on<DragStartEvent>(_onDragStart);
    on<DragUpdateEvent>(_onDragUpdate);
    on<DragEndEvent>(_onDragEnd);
  }

  // Handler for DragStartEvent
  void _onDragStart(DragStartEvent event, Emitter<SortableGridState> emit) {
    _draggedItemIndex = event.index;
    _hasActivatedDrag = false;

    // Only transition to `SortableGridDragging` state if the current state is `SortableGridInitial`
    if (state is SortableGridInitial || state is SortableGridFinishedDragging) {
      emit(SortableGridDragging(
        itemOrder: List.from((state is SortableGridInitial)
            ? (state as SortableGridInitial).itemOrder
            : (state as SortableGridFinishedDragging).itemOrder),
        draggedItemIndex: _draggedItemIndex!,
        draggedItemX: 0.0,
        draggedItemY: 0.0,
      ));
    }
  }

  // Handler for DragUpdateEvent
  void _onDragUpdate(DragUpdateEvent event, Emitter<SortableGridState> emit) {
    final details = event.details;

    if (!_hasActivatedDrag && details.distance > dragActivationThreshold) {
      _hasActivatedDrag = true;
    }

    _draggedItemX = details.dx;
    _draggedItemY = details.dy;

    // Only update if the current state is `SortableGridDragging`
    if (state is SortableGridDragging) {
      emit(SortableGridDragging(
        itemOrder: List.from((state as SortableGridDragging).itemOrder),
        draggedItemIndex: _draggedItemIndex!,
        draggedItemX: _draggedItemX!,
        draggedItemY: _draggedItemY!,
      ));
    }
  }

  // Handler for DragEndEvent
  void _onDragEnd(DragEndEvent event, Emitter<SortableGridState> emit) {
    final currentState = state;
    if (currentState is SortableGridDragging) {
      final targetIndex = _getTargetIndex(currentState);

      if (targetIndex != _draggedItemIndex) {
        // Swap items
        final newOrder = List<int>.from(currentState.itemOrder);
        final temp = newOrder[_draggedItemIndex!];
        newOrder[_draggedItemIndex!] = newOrder[targetIndex];
        newOrder[targetIndex] = temp;

        // Call the onDragRelease callback with the new order
        onDragRelease(newOrder);

        // Emit the state as finished dragging with the new order
        emit(SortableGridFinishedDragging(newOrder));
      } else {
        // If no movement, just finalize the drag with the same order
        emit(SortableGridFinishedDragging(currentState.itemOrder));
      }
    }
  }

  // Helper method to calculate the target index based on drag position
  int _getTargetIndex(SortableGridDragging state) {
    double minDistance = double.infinity;
    int targetIndex = state.draggedItemIndex;

    for (int i = 0; i < state.itemOrder.length; i++) {
      if (i != state.draggedItemIndex) {
        final position = _getItemPosition(i);
        final distance =
            (Offset(state.draggedItemX, state.draggedItemY) - position)
                .distance;
        if (distance < minDistance) {
          minDistance = distance;
          targetIndex = i;
        }
      }
    }

    return targetIndex;
  }

  // Helper method to calculate the position of an item based on its index
  Offset _getItemPosition(int index) {
    final row = index ~/ 2;
    final col = index % 2;
    return Offset(col * 90.0, row * 90.0);
  }
}
