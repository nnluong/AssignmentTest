abstract class SortableGridState {
  final List<int> itemOrder;

  SortableGridState(this.itemOrder);
}

class SortableGridInitial extends SortableGridState {
  SortableGridInitial(List<int> itemOrder) : super(itemOrder);
}

class SortableGridDragging extends SortableGridState {
  final int draggedItemIndex;
  final double draggedItemX;
  final double draggedItemY;

  SortableGridDragging({
    required List<int> itemOrder,
    required this.draggedItemIndex,
    required this.draggedItemX,
    required this.draggedItemY,
  }) : super(itemOrder);
}

class SortableGridFinishedDragging extends SortableGridState {
  SortableGridFinishedDragging(List<int> itemOrder) : super(itemOrder);
}
