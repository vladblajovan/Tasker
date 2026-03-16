// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurrence_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RecurrenceModelAdapter extends TypeAdapter<RecurrenceModel> {
  @override
  final typeId = 1;

  @override
  RecurrenceModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RecurrenceModel(
      type: fields[0] as RecurrenceType,
      interval: (fields[1] as num).toInt(),
      weekdays: (fields[2] as List?)?.cast<int>(),
      endDate: fields[3] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, RecurrenceModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.type)
      ..writeByte(1)
      ..write(obj.interval)
      ..writeByte(2)
      ..write(obj.weekdays)
      ..writeByte(3)
      ..write(obj.endDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecurrenceModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
