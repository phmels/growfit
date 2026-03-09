// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cycle_state_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CycleStateEntityAdapter extends TypeAdapter<CycleStateEntity> {
  @override
  final int typeId = 9;

  @override
  CycleStateEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CycleStateEntity(
      currentIndex: fields[0] as int,
      restEvery: fields[1] as int,
    );
  }

  @override
  void write(BinaryWriter writer, CycleStateEntity obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.currentIndex)
      ..writeByte(1)
      ..write(obj.restEvery);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CycleStateEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
