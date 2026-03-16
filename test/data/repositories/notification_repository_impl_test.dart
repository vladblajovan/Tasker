import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tasker/data/datasources/notification_local_datasource.dart';
import 'package:tasker/data/models/task_model.dart';
import 'package:tasker/data/repositories/notification_repository_impl.dart';
import 'package:tasker/domain/entities/priority.dart';
import 'package:tasker/domain/entities/task.dart';

class MockNotificationLocalDatasource extends Mock
    implements NotificationLocalDatasource {}

class FakeTaskModel extends Fake implements TaskModel {}

void main() {
  late NotificationRepositoryImpl repository;
  late MockNotificationLocalDatasource mockDatasource;

  setUpAll(() {
    registerFallbackValue(FakeTaskModel());
  });

  setUp(() {
    mockDatasource = MockNotificationLocalDatasource();
    repository = NotificationRepositoryImpl(mockDatasource);
  });

  final tTask = Task(
    id: '1',
    title: 'Test Task',
    isCompleted: false,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
    dueDate: DateTime(2026, 3, 15, 9, 0),
    priority: Priority.medium,
  );

  group('scheduleNotification', () {
    test(
      'should schedule notification via datasource using fromEntity mapping',
      () async {
        when(
          () => mockDatasource.scheduleNotification(any()),
        ).thenAnswer((_) async {});

        await repository.scheduleNotification(tTask);

        final captured = verify(
          () => mockDatasource.scheduleNotification(captureAny()),
        ).captured;
        final model = captured.first as TaskModel;
        expect(model.id, tTask.id);
        expect(model.title, tTask.title);
        expect(model.dueDate, tTask.dueDate);
      },
    );
  });

  group('cancelNotification', () {
    test('should cancel notification via datasource', () async {
      when(
        () => mockDatasource.cancelNotification('1'),
      ).thenAnswer((_) async {});

      await repository.cancelNotification('1');

      verify(() => mockDatasource.cancelNotification('1')).called(1);
    });
  });

  group('cancelAllNotifications', () {
    test('should cancel all notifications via datasource', () async {
      when(
        () => mockDatasource.cancelAllNotifications(),
      ).thenAnswer((_) async {});

      await repository.cancelAllNotifications();

      verify(() => mockDatasource.cancelAllNotifications()).called(1);
    });
  });
}
