
import 'package:getx_exten/utils/base_state.dart';
import 'package:getx_exten/utils/emit.dart';


/// Base counter state
abstract class CounterState extends RxState {
  final int value;
  const CounterState(this.value);
}

/// Initial state (count = 0)
class CounterInitial extends CounterState {
  const CounterInitial() : super(0);
}

/// Updated state with a value
class CounterValue extends CounterState {
  const CounterValue(int value) : super(value);
}

class MyController extends RxCubit<CounterState> {
  MyController() : super(const CounterInitial());

  void increment() => emit(CounterValue(state.value + 1));

  void reset() => emit(const CounterInitial());
}
