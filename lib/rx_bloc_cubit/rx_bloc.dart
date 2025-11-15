import 'package:getx_exten/getx_exten.dart';

typedef Emitter<S> = void Function(S state);
typedef EventHandler<E, S> = Future<void> Function(E event, Emitter<S> emit);

/// Base Bloc that works with any state type
abstract class RxBloc<E, S> extends GetxController {
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