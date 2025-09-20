import 'package:get/get.dart';

import 'package:get/get.dart';
import 'package:getx_exten/utils/base_state.dart';

abstract class RxCubit<S extends RxState> extends GetxController {
  RxCubit(S initialState) {
    _state = initialState.obs;
  }

  late final Rx<S> _state;

  /// Current state
  S get state => _state.value;

  /// Exposed observable for widgets to listen to
  Rx<S> get rx => _state;

  /// Emit a new state
  void emit(S newState) {
    _state.value = newState;
    onChange(newState);
  }

  /// Optional lifecycle hook
  void onChange(S state) {}
}



typedef Emitter<S> = void Function(S state);

typedef EventHandler<E, S> = Future<void> Function(E event, Emitter<S> emit);

abstract class RxBloc<E, S extends RxState> extends GetxController {
  RxBloc(S initialState) {
    _state = initialState.obs;
  }

  late final Rx<S> _state;
  final _handlers = <Type, EventHandler<E, S>>{};

  S get state => _state.value;
  Rx<S> get rx => _state;

  void emit(S newState) {
    _state.value = newState;
  }

  void on<EE extends E>(EventHandler<EE, S> handler) {
    _handlers[EE] = (event, emit) async {
      await handler(event as EE, emit);
    };
  }

  void add(E event) {
    final handler = _handlers[event.runtimeType];
    if (handler != null) {
      handler(event, emit);
    }
  }
}


