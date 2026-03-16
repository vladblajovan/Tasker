class Failure {
  const Failure(this.message);
  final String message;

  @override
  String toString() => 'Failure(message: $message)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}

class StorageFailure extends Failure {
  const StorageFailure(super.message);
}
