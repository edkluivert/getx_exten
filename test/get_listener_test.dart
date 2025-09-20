import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:getx_exten/get_listener/get_listener.dart';

void main() {
  testWidgets('GetListener triggers listener on state change', (tester) async {
    final rx = 0.obs;
    int? listenedValue;

    await tester.pumpWidget(
      MaterialApp(
        home: GetListener<int>(
          rx: rx,
          listener: (context, state) {
            listenedValue = state;
          },
          child: const SizedBox(),
        ),
      ),
    );

    // First frame runs the postFrameCallback
    await tester.pump();

    expect(listenedValue, 0);

    // Change the rx value
    rx.value = 1;
    await tester.pump();

    expect(listenedValue, 1);
  });
}
