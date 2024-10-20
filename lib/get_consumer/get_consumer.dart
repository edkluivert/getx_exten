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
    Key? key,
  }) : super(key: key);

  final GetxController controller;
  final Rx<T> valueRx;
  final GetWidgetListener<T> listener;
  final GetWidgetBuilder<T> builder;

  @override
  Widget build(BuildContext context) {
    ever<T>(valueRx, (value) => listener.call(context, value));
    return GetX<GetxController>(
      init: controller,
      builder: (_) {
        final currentValue = valueRx.value;
        return builder(context, currentValue);
      },
    );
  }
}
