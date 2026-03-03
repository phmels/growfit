// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'training_day.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TrainingDayAdapter extends TypeAdapter<TrainingDay> {
  @override
  final int typeId = 6;

  @override
  TrainingDay read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TrainingDay(
      id: fields[0] as String,
      name: fields[1] as String,
      groups: (fields[2] as List).cast<ExerciseGroup>(),
    );
  }

  @override
  void write(BinaryWriter writer, TrainingDay obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.groups);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrainingDayAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
