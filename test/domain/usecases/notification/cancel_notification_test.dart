import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test_app/domain/repositories/notification_repository.dart';
import 'package:test_app/domain/usecases/notification/cancel_notification.dart';

class MockNotificationRepository extends Mock
    implements NotificationRepository {}

void main() {
  late CancelNotification useCase;
  late MockNotificationRepository mockNotificationRepository;

  setUp(() {
    mockNotificationRepository = MockNotificationRepository();
    useCase = CancelNotification(mockNotificationRepository);
  });

  group('CancelNotification', () {
    test('should cancel a notification for a given task id', () async {
      when(() => mockNotificationRepository.cancelNotification('1'))
          .thenAnswer((_) async {});

      await useCase.call('1');

      verify(() => mockNotificationRepository.cancelNotification('1'))
          .called(1);
      verifyNoMoreInteractions(mockNotificationRepository);
    });
  });
}
