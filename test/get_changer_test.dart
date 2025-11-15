import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:getx_exten/get_changer/get_changer.dart';
import 'package:getx_exten/rx_bloc_cubit/rx_bloc.dart';
import 'package:getx_exten/rx_bloc_cubit/rx_cubit.dart';

import 'rx_cubit_test.dart';

void main() {
  group('GetChanger', () {
    testWidgets('rebuilds on state change with rx', (tester) async {
      final rx = 0.obs;

      await tester.pumpWidget(
        MaterialApp(
          home: GetChanger<int>(
            rx: rx,
            builder: (context, state) => Text('$state'),
          ),
        ),
      );

      expect(find.text('0'), findsOneWidget);

      rx.value = 1;
      await tester.pump();

      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('rebuilds on state change with cubit', (tester) async {
      final cubit = TestCubit();
      Get.put(cubit);

      await tester.pumpWidget(
        MaterialApp(
          home: GetChanger<int>(
            controller: cubit,
            builder: (context, state) => Text('$state'),
          ),
        ),
      );

      expect(find.text('0'), findsOneWidget);

      cubit.increment();
      await tester.pump();

      expect(find.text('1'), findsOneWidget);

      Get.delete<TestCubit>();
    });

    testWidgets('respects buildWhen condition', (tester) async {
      final rx = 0.obs;
      int buildCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: GetChanger<int>(
            rx: rx,
            buildWhen: (prev, curr) => curr % 2 == 0, // Only rebuild on even numbers
            builder: (context, state) {
              buildCount++;
              return Text('$state');
            },
          ),
        ),
      );

      expect(buildCount, 1);
      expect(find.text('0'), findsOneWidget);

      rx.value = 1; // Odd - should not rebuild
      await tester.pump();
      expect(buildCount, 1); // Still 1
      expect(find.text('0'), findsOneWidget); // Shows old value

      rx.value = 2; // Even - should rebuild
      await tester.pump();
      expect(buildCount, 2);
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('throws error when both rx and controller provided', (tester) async {
      final rx = 0.obs;
      final cubit = TestCubit();

      expect(
            () => GetChanger<int>(
          rx: rx,
          controller: cubit,
          builder: (context, state) => Text('$state'),
        ),
        throwsAssertionError,
      );
    });

    testWidgets('throws error when neither rx nor controller provided', (tester) async {
      expect(
            () => GetChanger<int>(
          builder: (context, state) => Text('$state'),
        ),
        throwsAssertionError,
      );
    });
  });
}