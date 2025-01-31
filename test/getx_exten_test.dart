
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get/state_manager.dart';
import 'package:getx_exten/getx_exten.dart';

class TestController extends GetxController {
  // Sample state variable
  var state = 0.obs;

  void increment() {
    state.value++;
  }
}

void main() {
  testWidgets('GetListener calls listener on value change', (WidgetTester tester) async {
    // Create a reactive variable
    final valueRx = 0.obs;

    // Variable to track listener calls
    int listenerCallCount = 0;

    // Build the GetListener widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GetListener<int>(
            valueRx: valueRx,
            listener: (context, state) {
              listenerCallCount++;
            },
            child: Container(),
          ),
        ),
      ),
    );

    // Ensure listener is not called initially
    expect(listenerCallCount, 0);

    // Change the value of the reactive variable
    valueRx.value = 1;
    await tester.pump(); // Rebuild the widget tree

    // Ensure listener is called once when value changes
    expect(listenerCallCount, 1);

    // Change the value again
    valueRx.value = 2;
    await tester.pump(); // Rebuild the widget tree

    // Ensure listener is called again when value changes
    expect(listenerCallCount, 2);
  });

  testWidgets('GetConsumer calls listener and builder on value change', (WidgetTester tester) async {
    // Create an instance of the controller
    final controller = TestController();
    final valueRx = controller.state;

    // Variable to track listener calls
    int listenerCallCount = 0;

    // Build the GetConsumer widget
    await tester.pumpWidget(
      GetMaterialApp(
        home: Scaffold(
          body: GetConsumer<int>(
            controller: controller,
            valueRx: valueRx,
            listener: (context, state) {
              listenerCallCount++;
            },
            builder: (context, state) {
              return Text('Current State: $state');
            },
          ),
        ),
      ),
    );

    // Ensure listener is not called initially
    expect(listenerCallCount, 0);

    // Trigger a state change
    controller.increment();
    await tester.pump(); // Rebuild the widget tree

    // Ensure listener is called once when value changes
    expect(listenerCallCount, 1);

    // Ensure builder is called with the updated value
    expect(find.text('Current State: 1'), findsOneWidget);

    // Trigger another state change
    controller.increment();
    await tester.pump(); // Rebuild the widget tree

    // Ensure listener is called again when value changes
    expect(listenerCallCount, 2);

    // Ensure builder is called with the updated value
    expect(find.text('Current State: 2'), findsOneWidget);
  });
}
