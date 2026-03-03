// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_group.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WorkoutGroupAdapter extends TypeAdapter<WorkoutGroup> {
  @override
  final int typeId = 3;

  @override
  WorkoutGroup read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WorkoutGroup(
      name: fields[0] as String,
      exercises: (fields[1] as List).cast<WorkoutExercise>(),
    );
  }

  @override
  void write(BinaryWriter writer, WorkoutGroup obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.exercises);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutGroupAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
