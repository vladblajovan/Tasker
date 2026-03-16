import 'package:hive_ce/hive.dart';
import 'package:tasker/domain/entities/recurrence.dart';

class RecurrenceTypeAdapter extends TypeAdapter<RecurrenceType> {
  @override
  final int typeId = 5;

  @override
  RecurrenceType read(BinaryReader reader) {
    final index = reader.readInt();
    return RecurrenceType.values[index];
  }

  @override
  void write(BinaryWriter writer, RecurrenceType obj) {
    writer.writeInt(obj.index);
  }
}
