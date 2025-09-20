import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:getx_exten/utils/base_state.dart';
import 'package:getx_exten/utils/emit.dart';
import 'package:getx_exten/get_consumer/get_consumer.dart';

class CounterState extends RxState {
  final int value;
  const CounterState(this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is CounterState &&
              runtimeType == other.runtimeType &&
              value == other.value;

  @override
  int get hashCode => value.hashCode;
}

class CounterCubit extends RxCubit<CounterState> {
  CounterCubit() : super(const CounterState(0));
  void increment() => emit(CounterState(state.value + 1));
}

void main() {
  testWidgets('GetConsumer rebuilds UI and calls listener', (tester) async {
    // Initialize Flutter binding
    TestWidgetsFlutterBinding.ensureInitialized();
    // Enable test mode for GetX
    Get.testMode = true;
    // Register the cubit
    final cubit = CounterCubit();
    Get.put<CounterCubit>(cubit);

    int? listenedValue;

    await tester.pumpWidget(
      GetMaterialApp(
        home: Scaffold(
          body: GetConsumer<CounterState>(
            controller: cubit,
            listenWhen: (prev, curr) => curr.value % 2 == 0,
            buildWhen: (prev, curr) => curr.value % 2 == 0,
            listener: (context, state) {
              listenedValue = state.value;
            },
            builder: (context, state) {
              return Text(
                'Count: ${state.value}',
                key: const ValueKey('counter-text'),
              );
            },
          ),
        ),
      ),
    );

    // Pump and settle to ensure all frames are rendered
    await tester.pumpAndSettle();

    // Verify initial render (value = 0, which is even)
    expect(find.byKey(const ValueKey('counter-text')), findsOneWidget);
    expect(find.text('Count: 0'), findsOneWidget);
    expect(listenedValue, 0); // Listener should be called for initial state

    // Increment once (value = 1) → blocked by conditions
    cubit.increment();
    await tester.pumpAndSettle();
    expect(find.text('Count: 0'), findsOneWidget); // UI should not update
    expect(listenedValue, 0); // Listener should not be called again

    // Increment again (value = 2) → allowed
    cubit.increment();
    await tester.pumpAndSettle();
    expect(find.text('Count: 2'), findsOneWidget); // UI should update
    expect(listenedValue, 2); // Listener should be called
  });
}
