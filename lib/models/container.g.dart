// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'container.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ContainerDataAdapter extends TypeAdapter<ContainerData> {
  @override
  final int typeId = 0;

  @override
  ContainerData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ContainerData(
      key1: fields[0] as String,
      value1: fields[1] as String,
      key2: fields[2] as String,
      value2: fields[3] as String,
      key3: fields[4] as String,
      value3: fields[5] as String,
      date: fields[6] as DateTime,
      formattedDate: fields[7] as String,
      agenda: fields[8] as String,
      minutes: (fields[9] as List?)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, ContainerData obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.key1)
      ..writeByte(1)
      ..write(obj.value1)
      ..writeByte(2)
      ..write(obj.key2)
      ..writeByte(3)
      ..write(obj.value2)
      ..writeByte(4)
      ..write(obj.key3)
      ..writeByte(5)
      ..write(obj.value3)
      ..writeByte(6)
      ..write(obj.date)
      ..writeByte(7)
      ..write(obj.formattedDate)
      ..writeByte(8)
      ..write(obj.agenda)
      ..writeByte(9)
      ..write(obj.minutes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContainerDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
