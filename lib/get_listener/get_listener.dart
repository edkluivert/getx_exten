import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';

typedef GetxWidgetListener<S> = void Function(BuildContext context, S state);

class GetListener<T> extends StatelessWidget {
  const GetListener({
    required this.valueRx,
    required this.listener,
    required this.child,
    super.key,
  });

  final RxInterface<T> valueRx;
  final GetxWidgetListener<T> listener;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    ever<T>(valueRx, (value) => listener.call(context, value));
    return child;
  }
}
