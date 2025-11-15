
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:getx_exten/get_consumer/get_consumer.dart';

import 'rx_cubit_test.dart';

void main() {
  group('GetConsumer', () {
    testWidgets('triggers listener and rebuilds on state change', (tester) async {
      final rx = 0.obs;
      final listenedValues = <int>[];

      await tester.pumpWidget(
        MaterialApp(
          home: GetConsumer<int>(
            rx: rx,
            listener: (context, state) {
              listenedValues.add(state);
            },
            builder: (context, state) => Text('$state'),
          ),
        ),
      );

      // Initial listener call
      await tester.pump();
      expect(listenedValues, [0]);
      expect(find.text('0'), findsOneWidget);

      rx.value = 1;
      await tester.pump();
      expect(listenedValues, [0, 1]);
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('respects buildWhen condition', (tester) async {
      final rx = 0.obs;
      final listenedValues = <int>[];
      int buildCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: GetConsumer<int>(
            rx: rx,
            buildWhen: (prev, curr) => curr % 2 == 0,
            listener: (context, state) {
              listenedValues.add(state);
            },
            builder: (context, state) {
              buildCount++;
              return Text('$state');
            },
          ),
        ),
      );

      await tester.pump();
      expect(buildCount, 1);
      expect(listenedValues, [0]);

      rx.value = 1; // Odd - should not rebuild but should listen
      await tester.pump();
      expect(buildCount, 1); // No rebuild
      expect(listenedValues, [0, 1]); // But listened
      expect(find.text('0'), findsOneWidget); // Shows old value

      rx.value = 2; // Even - should rebuild and listen
      await tester.pump();
      expect(buildCount, 2);
      expect(listenedValues, [0, 1, 2]);
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('respects listenWhen condition', (tester) async {
      final rx = 0.obs;
      final listenedValues = <int>[];

      await tester.pumpWidget(
        MaterialApp(
          home: GetConsumer<int>(
            rx: rx,
            listenWhen: (prev, curr) => curr % 2 == 0,
            listener: (context, state) {
              listenedValues.add(state);
            },
            builder: (context, state) => Text('$state'),
          ),
        ),
      );

      await tester.pump();
      expect(listenedValues, [0]); // Initial

      rx.value = 1; // Odd - should not listen
      await tester.pump();
      expect(listenedValues, [0]); // No new value
      expect(find.text('1'), findsOneWidget); // But still rebuilds

      rx.value = 2; // Even - should listen
      await tester.pump();
      expect(listenedValues, [0, 2]);
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('works with cubit', (tester) async {
      final cubit = TestCubit();
      Get.put(cubit);
      final listenedValues = <int>[];

      await tester.pumpWidget(
        MaterialApp(
          home: GetConsumer<int>(
            controller: cubit,
            listener: (context, state) {
              listenedValues.add(state);
            },
            builder: (context, state) => Text('$state'),
          ),
        ),
      );

      await tester.pump();
      expect(listenedValues, [0]);
      expect(find.text('0'), findsOneWidget);

      cubit.increment();
      await tester.pump();
      expect(listenedValues, [0, 1]);
      expect(find.text('1'), findsOneWidget);

      Get.delete<TestCubit>();
    });
  });
}


