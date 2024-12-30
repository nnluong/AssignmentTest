// Events
import 'package:flutter/material.dart';

abstract class SortableGridEvent {}

class DragStartEvent extends SortableGridEvent {
  final int index;

  DragStartEvent(this.index);
}

class DragUpdateEvent extends SortableGridEvent {
  final Offset details;

  DragUpdateEvent(this.details);
}

class DragEndEvent extends SortableGridEvent {}
