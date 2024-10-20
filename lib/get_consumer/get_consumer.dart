import 'package:flutter/material.dart';
import 'package:get/get.dart';

typedef GetWidgetListener<S> = void Function(BuildContext context, S state);
typedef GetWidgetBuilder<S> = Widget Function(BuildContext context, S state);

class GetConsumer<T> extends StatelessWidget {
  const GetConsumer({
    required this.controller,
    required this.valueRx,
    required this.listener,
    required this.builder,
    super.key,
  });

  final GetxController controller;
  final Rx<T> valueRx;
  final GetWidgetListener<T> listener;
  final GetWidgetBuilder<T> builder;

  // Static variable to keep track of listener registration
  // still needs tests
  static final Set<Rx> _registeredListeners = {};

  @override
  Widget build(BuildContext context) {
    //ever<T>(valueRx, (value) => listener.call(context, value));
    if (!_registeredListeners.contains(valueRx)) {
      ever<T>(valueRx, (value) {
        listener.call(context, value);
      });
      // Mark as having a registered listener
      _registeredListeners.add(valueRx);
    }



    return GetX<GetxController>(
      init: controller,
      builder: (_) {
        return builder(context, valueRx.value);
      },
    );
  }
}
