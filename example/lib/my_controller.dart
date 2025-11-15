
import 'package:equatable/equatable.dart';
import 'package:example/app_state.dart';
import 'package:getx_exten/rx_bloc_cubit/rx_cubit.dart';

abstract class CounterState extends Equatable {
  final int value;
  const CounterState(this.value);
}

class CounterInitial extends CounterState {
  const CounterInitial() : super(0);

  @override
  List<Object?> get props => [value];
}

class CounterValue extends CounterState {
  const CounterValue(super.value);

  @override
  List<Object?> get props => [value];
}


class MyController extends RxCubit<CounterState> {
  MyController() : super(const CounterInitial());

  void increment() => emit(CounterValue(state.value + 1));

  void reset() => emit(const CounterInitial());
}


class ApiController extends RxCubit<ApiState> {
  ApiController() : super(const ApiInitial());

  @override
  void onInit(){
    super.onInit();
    fetchItems();
  }

  Future<void> fetchItems() async {
    emit(const ApiLoading());
    await Future.delayed(const Duration(seconds: 2));
    try {
      final items = ["Apple", "Banana", "Mango"];
      emit(ApiSuccess(items));
    } catch (e) {
      emit(const ApiError("Failed to fetch data"));
    }
  }
}