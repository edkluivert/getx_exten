import 'package:flutter_test/flutter_test.dart';
import 'package:getx_exten/rx_bloc_cubit/rx_bloc.dart';

abstract class TestEvent {}
class IncrementEvent extends TestEvent {}
class DecrementEvent extends TestEvent {}
class AddEvent extends TestEvent {
  final int value;
  AddEvent(this.value);
}

class TestBloc extends RxBloc<TestEvent, int> {
  TestBloc() : super(0) {
    on<IncrementEvent>((event, emit) async {
      emit(state + 1);
    });

    on<DecrementEvent>((event, emit) async {
      emit(state - 1);
    });

    on<AddEvent>((event, emit) async {
      emit(state + event.value);
    });
  }
}

void main() {
  group('RxBloc', () {
    test('initializes with correct state', () {
      final bloc = TestBloc();
      expect(bloc.state, 0);
    });

    test('handles events correctly', () async {
      final bloc = TestBloc();

      bloc.add(IncrementEvent());
      await Future.delayed(Duration.zero); // Wait for async handler
      expect(bloc.state, 1);

      bloc.add(IncrementEvent());
      await Future.delayed(Duration.zero);
      expect(bloc.state, 2);
    });

    test('handles multiple event types', () async {
      final bloc = TestBloc();

      bloc.add(IncrementEvent());
      await Future.delayed(Duration.zero);
      expect(bloc.state, 1);

      bloc.add(DecrementEvent());
      await Future.delayed(Duration.zero);
      expect(bloc.state, 0);

      bloc.add(AddEvent(5));
      await Future.delayed(Duration.zero);
      expect(bloc.state, 5);
    });

    test('rx observable updates with state', () async {
      final bloc = TestBloc();
      expect(bloc.rx.value, 0);

      bloc.add(IncrementEvent());
      await Future.delayed(Duration.zero);
      expect(bloc.rx.value, 1);
    });
  });
}
