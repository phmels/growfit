// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_group.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExerciseGroupAdapter extends TypeAdapter<ExerciseGroup> {
  @override
  final int typeId = 1;

  @override
  ExerciseGroup read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExerciseGroup(
      id: fields[0] as String,
      name: fields[1] as String,
      exercises: (fields[2] as List).cast<Exercise>(),
    );
  }

  @override
  void write(BinaryWriter writer, ExerciseGroup obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.exercises);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseGroupAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
