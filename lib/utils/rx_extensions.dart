
import 'package:getx_exten/getx_exten.dart';

extension RxBlocExtensions<E, S> on RxBloc<E, S> {
  /// Create a selector that derives a value from state
  GetSelector<S, T> select<T>(
      T Function(S state) selector,
      Widget Function(BuildContext context, T value) builder,
      ) {
    return GetSelector<S, T>(
      controller: this,
      selector: selector,
      builder: builder,
    );
  }

  /// Watch state changes (for imperative usage outside widgets)
  Worker watch(void Function(S state) callback) {
    return ever(rx, callback);
  }
}

extension RxCubitExtensions<S> on RxCubit<S> {
  /// Create a selector that derives a value from state
  GetSelector<S, T> select<T>(
      T Function(S state) selector,
      Widget Function(BuildContext context, T value) builder,
      ) {
    return GetSelector<S, T>(
      controller: this,
      selector: selector,
      builder: builder,
    );
  }

  /// Watch state changes (for imperative usage outside widgets)
  Worker watch(void Function(S state) callback) {
    return ever(rx, callback);
  }
}