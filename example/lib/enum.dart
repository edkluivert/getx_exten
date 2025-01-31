
/// A sealed class to represent the state of a request, carrying optional data or error information.
abstract class RequestState<T> {
  const RequestState();

  /// Factory for the `initial` state.
  factory RequestState.initial() = Initial<T>;

  /// Factory for the `loading` state.
  factory RequestState.loading() = Loading<T>;

  /// Factory for the `success` state with data.
  factory RequestState.success(T data) = Success<T>;

  /// Factory for the `error` state with an error message.
  factory RequestState.error(String errorMessage) = Error<T>;
}

/// Represents the `initial` state.
class Initial<T> extends RequestState<T> {}

/// Represents the `loading` state.
class Loading<T> extends RequestState<T> {}

/// Represents the `success` state with attached data.
class Success<T> extends RequestState<T> {
  final T data;

  Success(this.data);
}

/// Represents the `error` state with an error message.
class Error<T> extends RequestState<T> {
  final String errorMessage;

  Error(this.errorMessage);
}
