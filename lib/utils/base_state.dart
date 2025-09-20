/// Base state class for RxCubit and RxBloc
abstract class RxState {
  const RxState();
}

/// Common generic states
class RxInitial extends RxState {
  const RxInitial();
}

class RxLoading extends RxState {
  const RxLoading();
}

class RxSuccess<T> extends RxState {
  final T data;
  const RxSuccess(this.data);
}

class RxError extends RxState {
  final String message;
  const RxError(this.message);
}
