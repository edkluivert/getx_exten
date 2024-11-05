import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:getx_exten/getx_exten.dart';
import 'package:getx_exten/state_manager/state_manager.dart';

class TestController extends GetxController {
  final StateManager<int> stateManager = StateManager<int>();

  TestController() {
    stateManager.setSuccess(0); // Start with initial value
  }

  void increment() {
    stateManager.setSuccess(stateManager.data! + 1);
  }
}

void main() {
  // testWidgets('GetListener calls listener on value change', (WidgetTester tester) async {
  //   // Create a reactive variable
  //   final valueRx = 0.obs;
  //
  //   // Variable to track listener calls
  //   int listenerCallCount = 0;
  //
  //   // Build the GetListener widget
  //   await tester.pumpWidget(
  //     MaterialApp(
  //       home: Scaffold(
  //         body: GetListener<int>(
  //           valueRx: valueRx,
  //           listener: (context, state) {
  //             listenerCallCount++;
  //           },
  //           child: Container(),
  //         ),
  //       ),
  //     ),
  //   );
  //
  //   // Ensure listener is not called initially
  //   expect(listenerCallCount, 0);
  //
  //   // Change the value of the reactive variable
  //   valueRx.value = 1;
  //   await tester.pump(); // Rebuild the widget tree
  //
  //   // Ensure listener is called once when value changes
  //   expect(listenerCallCount, 1);
  //
  //   // Change the value again
  //   valueRx.value = 2;
  //   await tester.pump(); // Rebuild the widget tree
  //
  //   // Ensure listener is called again when value changes
  //   expect(listenerCallCount, 2);
  // });

  group('StateManager Tests', () {
    late StateManager<int> stateManager;

    setUp(() {
      stateManager = StateManager<int>();
    });

    test('Initial state should be empty', () {
      expect(stateManager.status.value, RxState.empty);
      expect(stateManager.data, isNull);
    });

    test('setLoading should update status to loading', () {
      stateManager.setLoading();
      expect(stateManager.status.value, RxState.loading);
    });

    test('setSuccess should update status to success and set data', () {
      stateManager.setSuccess(42);
      expect(stateManager.status.value, RxState.success);
      expect(stateManager.data, 42);
    });

    test('setError should update status to error', () {
      stateManager.setError("Error");
      expect(stateManager.status.value, RxState.error);
    });

    test('setEmpty should update status to empty', () {
      stateManager.setEmpty();
      expect(stateManager.status.value, RxState.empty);
    });

    testWidgets('obx should show loading widget', (WidgetTester tester) async {
      stateManager.setLoading();

      await tester.pumpWidget(
        MaterialApp(
          home: stateManager.obx(
                (data) => Text('Data: $data'),
            onLoading: CircularProgressIndicator(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('obx should show success widget', (WidgetTester tester) async {
      stateManager.setSuccess(42);

      await tester.pumpWidget(
        MaterialApp(
          home: stateManager.obx(
                (data) => Text('Data: $data'),
          ),
        ),
      );

      expect(find.text('Data: 42'), findsOneWidget);
    });

    // Define your test as before
    testWidgets('obx should show error widget', (WidgetTester tester) async {
      stateManager.setError("Custom error");

      await tester.pumpWidget(
        MaterialApp(
          home: stateManager.obx(
                (data) => Text('Data: $data'),
            onError: (error) => Text(error ?? 'Default error'),
          ),
        ),
      );

      await tester.pump(); // Ensure the widget tree is rebuilt

      expect(find.text('Custom error'), findsOneWidget); // The test expects this text to appear
    });


    testWidgets('obx should show empty widget', (WidgetTester tester) async {
      stateManager.setEmpty();

      await tester.pumpWidget(
        MaterialApp(
          home: stateManager.obx(
                (data) => Text('Data: $data'),
            onEmpty: Text('Empty data'),
          ),
        ),
      );

      expect(find.text('Empty data'), findsOneWidget);
    });
  });
}
