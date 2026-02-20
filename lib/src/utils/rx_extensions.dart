import 'package:get/get.dart';
import 'package:flutter/widgets.dart';
import 'package:getx_exten/src/types/types.dart';
import 'package:getx_exten/src/state/rx_bloc_cubit/rx_cubit.dart';
import 'package:getx_exten/src/state/rx_bloc_cubit/rx_bloc.dart';
import 'package:getx_exten/src/widgets/rx_selector/rx_selector.dart';

extension RxBlocExtensions<E, S> on RxBloc<E, S> {
  /// Create a selector that derives a value from state
  RxSelector<S, T> select<T>(
    T Function(S state) selector,
    Widget Function(BuildContext context, T value) builder,
  ) {
    return RxSelector<S, T>(
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
  RxSelector<S, T> select<T>(
    T Function(S state) selector,
    Widget Function(BuildContext context, T value) builder,
  ) {
    return RxSelector<S, T>(
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
