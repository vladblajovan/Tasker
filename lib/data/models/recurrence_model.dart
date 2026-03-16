import 'package:hive_ce/hive.dart';
import 'package:test_app/domain/entities/recurrence.dart';

part 'recurrence_model.g.dart';

@HiveType(typeId: 1)
class RecurrenceModel extends HiveObject {
  RecurrenceModel({
    required this.type,
    required this.interval,
    this.weekdays,
    this.endDate,
  });

  @HiveField(0)
  final RecurrenceType type;

  @HiveField(1)
  final int interval;

  @HiveField(2)
  final List<int>? weekdays;

  @HiveField(3)
  final DateTime? endDate;

  Recurrence toEntity() {
    return Recurrence(
      type: type,
      interval: interval,
      weekdays: weekdays,
      endDate: endDate,
    );
  }

  static RecurrenceModel fromEntity(Recurrence entity) {
    return RecurrenceModel(
      type: entity.type,
      interval: entity.interval,
      weekdays: entity.weekdays,
      endDate: entity.endDate,
    );
  }
}
