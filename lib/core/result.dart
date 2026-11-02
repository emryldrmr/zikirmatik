/// The one blessed error pattern (docs/conventions.md, Error handling):
/// domain and data layers return a [Result] instead of throwing across layers.
sealed class Result<T> {
  const Result();
}

final class Ok<T> extends Result<T> {
  const Ok(this.value);

  final T value;
}

final class Err<T> extends Result<T> {
  const Err(this.failure);

  final Failure failure;
}

/// Why an operation failed. The UI maps each case to a Turkish message;
/// [cause] is for logs and tests only and is never shown to the user.
sealed class Failure {
  const Failure(this.cause);

  final Object? cause;
}

/// Reading from or writing to on-device storage failed.
final class StorageFailure extends Failure {
  const StorageFailure([super.cause]);
}

/// User input broke a business rule (e.g. BR-2's target range).
final class ValidationFailure extends Failure {
  const ValidationFailure([super.cause]);
}
