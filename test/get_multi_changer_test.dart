import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:getx_exten/get_multi_changer/get_multi_changer.dart';

import 'rx_cubit_test.dart';

void main() {
  group('GetMultiChanger', () {
    testWidgets('rebuilds when any source changes', (tester) async {
      final rx1 = 0.obs;
      final rx2 = 'A'.obs;
      int buildCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: GetMultiChanger(
            sources: [rx1, rx2],
            builder: (context) {
              buildCount++;
              return Text('${rx1.value}-${rx2.value}');
            },
          ),
        ),
      );

      expect(buildCount, 1);
      expect(find.text('0-A'), findsOneWidget);

      // Change first source
      rx1.value = 1;
      await tester.pump();
      expect(buildCount, 2);
      expect(find.text('1-A'), findsOneWidget);

      // Change second source
      rx2.value = 'B';
      await tester.pump();
      expect(buildCount, 3);
      expect(find.text('1-B'), findsOneWidget);

      // Change both - they trigger separately but may be batched by the framework
      rx1.value = 2;
      rx2.value = 'C';
      await tester.pump();
      // When changing two values before pump, GetX batches them into one rebuild
      expect(buildCount >= 4, true); // At least 4 builds (initial + 3 changes)
      expect(find.text('2-C'), findsOneWidget);
    });

    testWidgets('works with multiple cubits', (tester) async {
      final cubit1 = TestCubit();
      final cubit2 = TestCubit();
      Get.put(cubit1, tag: 'cubit1');
      Get.put(cubit2, tag: 'cubit2');
      int buildCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: GetMultiChanger(
            sources: [cubit1.rx, cubit2.rx],
            builder: (context) {
              buildCount++;
              return Text('${cubit1.state}+${cubit2.state}');
            },
          ),
        ),
      );

      expect(buildCount, 1);
      expect(find.text('0+0'), findsOneWidget);

      cubit1.increment();
      await tester.pump();
      expect(buildCount, 2);
      expect(find.text('1+0'), findsOneWidget);

      cubit2.increment();
      await tester.pump();
      expect(buildCount, 3);
      expect(find.text('1+1'), findsOneWidget);

      Get.delete<TestCubit>(tag: 'cubit1');
      Get.delete<TestCubit>(tag: 'cubit2');
    });

    testWidgets('handles empty sources list', (tester) async {
      int buildCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: GetMultiChanger(
            sources: [],
            builder: (context) {
              buildCount++;
              return const Text('Empty');
            },
          ),
        ),
      );

      expect(buildCount, 1);
      expect(find.text('Empty'), findsOneWidget);
    });
  });
}