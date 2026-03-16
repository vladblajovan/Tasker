import 'package:hive_ce/hive.dart';
import 'package:tasker/domain/entities/priority.dart';

class PriorityAdapter extends TypeAdapter<Priority> {
  @override
  final int typeId = 4;

  @override
  Priority read(BinaryReader reader) {
    final index = reader.readInt();
    return Priority.values[index];
  }

  @override
  void write(BinaryWriter writer, Priority obj) {
    writer.writeInt(obj.index);
  }
}
