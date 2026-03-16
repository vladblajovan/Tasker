import 'package:freezed_annotation/freezed_annotation.dart';

part 'recurrence.freezed.dart';

enum RecurrenceType {
  daily,
  weekly,
  monthly,
  custom,
}

@freezed
abstract class Recurrence with _$Recurrence {
  const factory Recurrence({
    required RecurrenceType type,
    required int interval,
    List<int>? weekdays,
    DateTime? endDate,
  }) = _Recurrence;
}
