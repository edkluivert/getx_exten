import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:getx_exten/rx_bloc_cubit/rx_cubit.dart';

class TestCubit extends RxCubit<int> {
  TestCubit() : super(0);

  void increment() => emit(state + 1);
  void decrement() => emit(state - 1);
}
class TestCubitWithOnChange extends RxCubit<int> {
  TestCubitWithOnChange(this.onChangeCallback) : super(0);

  final void Function(int state) onChangeCallback;

  void increment() => emit(state + 1);
  void decrement() => emit(state - 1);

  @override
  void onChange(int state) {
    super.onChange(state);
    onChangeCallback(state);
  }
}
class TestState {
  final String name;
  final int age;

  TestState(this.name, this.age);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is TestState && name == other.name && age == other.age;

  @override
  int get hashCode => name.hashCode ^ age.hashCode;
}

class ComplexCubit extends RxCubit<TestState> {
  ComplexCubit() : super(TestState('', 0));

  void updateName(String name) => emit(TestState(name, state.age));
  void updateAge(int age) => emit(TestState(state.name, age));
}

void main() {
  group('RxCubit', () {
    test('initializes with correct state', () {
      final cubit = TestCubit();
      expect(cubit.state, 0);
    });

    test('emits new state correctly', () {
      final cubit = TestCubit();
      cubit.increment();
      expect(cubit.state, 1);
      cubit.increment();
      expect(cubit.state, 2);
    });

    test('rx observable updates with state', () {
      final cubit = TestCubit();
      expect(cubit.rx.value, 0);

      cubit.increment();
      expect(cubit.rx.value, 1);
    });

    test('onChange is called on state change', () {
      int? changedValue;

      // Create a cubit that overrides onChange
      final cubit = TestCubitWithOnChange((state) {
        changedValue = state;
      });

      cubit.increment();
      expect(changedValue, 1);

      cubit.increment();
      expect(changedValue, 2);
    });

    test('works with custom state classes', () {
      final cubit = ComplexCubit();
      expect(cubit.state.name, '');
      expect(cubit.state.age, 0);

      cubit.updateName('John');
      expect(cubit.state.name, 'John');
      expect(cubit.state.age, 0);

      cubit.updateAge(25);
      expect(cubit.state.name, 'John');
      expect(cubit.state.age, 25);
    });
  });
}