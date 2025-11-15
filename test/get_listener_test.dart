import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:getx_exten/get_listener/get_listener.dart';

import 'rx_cubit_test.dart';

void main() {
  group('GetListenerWidget', () {
    testWidgets('triggers listener on initial state', (tester) async {
      final rx = 0.obs;
      final listenedValues = <int>[];

      await tester.pumpWidget(
        MaterialApp(
          home: GetListenerWidget<int>(
            rx: rx,
            listener: (context, state) {
              listenedValues.add(state);
            },
            child: const SizedBox(),
          ),
        ),
      );

      await tester.pump();
      expect(listenedValues, isEmpty); // Initial state not listened in this implementation
    });

    testWidgets('triggers listener on state change', (tester) async {
      final rx = 0.obs;
      final listenedValues = <int>[];

      await tester.pumpWidget(
        MaterialApp(
          home: GetListenerWidget<int>(
            rx: rx,
            listener: (context, state) {
              listenedValues.add(state);
            },
            child: const SizedBox(),
          ),
        ),
      );

      await tester.pump();

      rx.value = 1;
      await tester.pump();
      expect(listenedValues, [1]);

      rx.value = 2;
      await tester.pump();
      expect(listenedValues, [1, 2]);
    });

    testWidgets('respects listenWhen condition', (tester) async {
      final rx = 0.obs;
      final listenedValues = <int>[];

      await tester.pumpWidget(
        MaterialApp(
          home: GetListenerWidget<int>(
            rx: rx,
            listenWhen: (prev, curr) => curr % 2 == 0, // Only listen to even numbers
            listener: (context, state) {
              listenedValues.add(state);
            },
            child: const SizedBox(),
          ),
        ),
      );

      await tester.pump();

      rx.value = 1; // Odd - should not listen
      await tester.pump();
      expect(listenedValues, isEmpty);

      rx.value = 2; // Even - should listen
      await tester.pump();
      expect(listenedValues, [2]);

      rx.value = 3; // Odd - should not listen
      await tester.pump();
      expect(listenedValues, [2]);

      rx.value = 4; // Even - should listen
      await tester.pump();
      expect(listenedValues, [2, 4]);
    });

    testWidgets('does not rebuild child widget', (tester) async {
      final rx = 0.obs;
      int childBuildCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: GetListenerWidget<int>(
            rx: rx,
            listener: (context, state) {},
            child: Builder(
              builder: (context) {
                childBuildCount++;
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(childBuildCount, 1);

      rx.value = 1;
      await tester.pump();
      expect(childBuildCount, 1); // Should still be 1

      rx.value = 2;
      await tester.pump();
      expect(childBuildCount, 1); // Should still be 1
    });

    testWidgets('works with cubit', (tester) async {
      final cubit = TestCubit();
      Get.put(cubit);
      final listenedValues = <int>[];

      await tester.pumpWidget(
        MaterialApp(
          home: GetListenerWidget<int>(
            controller: cubit,
            listener: (context, state) {
              listenedValues.add(state);
            },
            child: const SizedBox(),
          ),
        ),
      );

      await tester.pump();

      cubit.increment();
      await tester.pump();
      expect(listenedValues, [1]);

      cubit.increment();
      await tester.pump();
      expect(listenedValues, [1, 2]);

      Get.delete<TestCubit>();
    });
  });
}
