import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:getx_exten/get_selector/get_selector.dart';

import 'rx_cubit_test.dart';

void main() {
  group('GetSelector', () {
    testWidgets('only rebuilds when selected value changes', (tester) async {
      final cubit = ComplexCubit();
      Get.put(cubit);
      int buildCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: GetSelector<TestState, String>(
            controller: cubit,
            selector: (state) => state.name,
            builder: (context, name) {
              buildCount++;
              return Text(name);
            },
          ),
        ),
      );

      expect(buildCount, 1);
      expect(find.text(''), findsOneWidget);

      // Change age - should NOT rebuild
      cubit.updateAge(25);
      await tester.pump();
      expect(buildCount, 1); // Still 1
      expect(find.text(''), findsOneWidget);

      // Change name - should rebuild
      cubit.updateName('John');
      await tester.pump();
      expect(buildCount, 2);
      expect(find.text('John'), findsOneWidget);

      // Change age again - should NOT rebuild
      cubit.updateAge(30);
      await tester.pump();
      expect(buildCount, 2); // Still 2
      expect(find.text('John'), findsOneWidget);

      Get.delete<ComplexCubit>();
    });

    testWidgets('works with rx directly', (tester) async {
      final state = TestState('Alice', 20).obs;
      int buildCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: GetSelector<TestState, int>(
            rx: state,
            selector: (s) => s.age,
            builder: (context, age) {
              buildCount++;
              return Text('$age');
            },
          ),
        ),
      );

      expect(buildCount, 1);
      expect(find.text('20'), findsOneWidget);

      // Change name - should NOT rebuild
      state.value = TestState('Bob', 20);
      await tester.pump();
      expect(buildCount, 1);
      expect(find.text('20'), findsOneWidget);

      // Change age - should rebuild
      state.value = TestState('Bob', 25);
      await tester.pump();
      expect(buildCount, 2);
      expect(find.text('25'), findsOneWidget);
    });

    testWidgets('works with primitive selectors', (tester) async {
      final rx = 5.obs;
      int buildCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: GetSelector<int, bool>(
            rx: rx,
            selector: (value) => value > 10,
            builder: (context, isHigh) {
              buildCount++;
              return Text(isHigh ? 'High' : 'Low');
            },
          ),
        ),
      );

      expect(buildCount, 1);
      expect(find.text('Low'), findsOneWidget);

      // Change value but selector result same
      rx.value = 7;
      await tester.pump();
      expect(buildCount, 1); // No rebuild
      expect(find.text('Low'), findsOneWidget);

      // Change value and selector result changes
      rx.value = 15;
      await tester.pump();
      expect(buildCount, 2);
      expect(find.text('High'), findsOneWidget);
    });
  });
}


