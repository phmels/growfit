import 'package:equatable/equatable.dart';

abstract class CycleEvent extends Equatable {
  const CycleEvent();

  @override
  List<Object?> get props => [];
}

class LoadCycle extends CycleEvent {}

class AdvanceCycle extends CycleEvent {}
