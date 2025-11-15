import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:getx_exten/get_changer/get_changer.dart';
import 'package:getx_exten/get_listener/get_listener.dart';
import 'package:getx_exten/get_multi_changer/get_multi_changer.dart';
import 'package:getx_exten/get_selector/get_selector.dart';

import 'rx_cubit_test.dart';

void main() {
  group('Integration Tests', () {
    testWidgets('complex app with multiple widgets', (tester) async {
      final cubit = ComplexCubit();
      Get.put(cubit);
      final listenedValues = <String>[];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                // Selector for name only
                GetSelector<TestState, String>(
                  controller: cubit,
                  selector: (state) => state.name,
                  builder: (context, name) => Text('Name: $name'),
                ),
                // Selector for age only
                GetSelector<TestState, int>(
                  controller: cubit,
                  selector: (state) => state.age,
                  builder: (context, age) => Text('Age: $age'),
                ),
                // Listener for name changes
                GetListenerWidget<TestState>(
                  controller: cubit,
                  listenWhen: (prev, curr) => prev.name != curr.name,
                  listener: (context, state) {
                    listenedValues.add(state.name);
                  },
                  child: const SizedBox(),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Name: '), findsOneWidget);
      expect(find.text('Age: 0'), findsOneWidget);

      // Update name
      cubit.updateName('Alice');
      await tester.pump();
      expect(find.text('Name: Alice'), findsOneWidget);
      expect(find.text('Age: 0'), findsOneWidget);
      expect(listenedValues, ['Alice']);

      // Update age
      cubit.updateAge(30);
      await tester.pump();
      expect(find.text('Name: Alice'), findsOneWidget);
      expect(find.text('Age: 30'), findsOneWidget);
      expect(listenedValues, ['Alice']); // No new listen

      // Update name again
      cubit.updateName('Bob');
      await tester.pump();
      expect(find.text('Name: Bob'), findsOneWidget);
      expect(find.text('Age: 30'), findsOneWidget);
      expect(listenedValues, ['Alice', 'Bob']);

      Get.delete<ComplexCubit>();
    });

    testWidgets('mixing GetX rx with cubit', (tester) async {
      final cubit = TestCubit();
      final rx = 'Hello'.obs;
      Get.put(cubit);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                GetChanger<int>(
                  controller: cubit,
                  builder: (context, count) => Text('Count: $count'),
                ),
                GetChanger<String>(
                  rx: rx,
                  builder: (context, text) => Text('Text: $text'),
                ),
                GetMultiChanger(
                  sources: [cubit.rx, rx],
                  builder: (context) => Text('${cubit.state}-${rx.value}'),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Count: 0'), findsOneWidget);
      expect(find.text('Text: Hello'), findsOneWidget);
      expect(find.text('0-Hello'), findsOneWidget);

      cubit.increment();
      await tester.pump();
      expect(find.text('Count: 1'), findsOneWidget);
      expect(find.text('1-Hello'), findsOneWidget);

      rx.value = 'World';
      await tester.pump();
      expect(find.text('Text: World'), findsOneWidget);
      expect(find.text('1-World'), findsOneWidget);

      Get.delete<TestCubit>();
    });
  });
}