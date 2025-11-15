import 'package:getx_exten/getx_exten.dart';


/// Base Cubit that works with any state type
abstract class RxCubit<S> extends GetxController {
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