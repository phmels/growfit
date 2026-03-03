// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'training_plan.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TrainingPlanAdapter extends TypeAdapter<TrainingPlan> {
  @override
  final int typeId = 7;

  @override
  TrainingPlan read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TrainingPlan(
      days: (fields[0] as List).cast<TrainingDay>(),
    );
  }

  @override
  void write(BinaryWriter writer, TrainingPlan obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.days);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrainingPlanAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
