import 'package:flutter/material.dart';
import 'package:get/get.dart';

typedef GetWidgetListener<S> = void Function(BuildContext context, S state);
typedef GetWidgetBuilder<S> = Widget Function(BuildContext context, S state);

class GetConsumer<T> extends StatefulWidget {
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

  @override
  State<GetConsumer<T>> createState() => _GetConsumerState<T>();
}

class _GetConsumerState<T> extends State<GetConsumer<T>> {
  Worker? _worker;

  @override
  void initState() {
    super.initState();
    _worker = ever<T>(widget.valueRx, (value) {
      if (mounted) {
        widget.listener.call(context, value);
      }
    });
  }

  @override
  void dispose() {
    _worker?.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return GetX<GetxController>(
      init: widget.controller,
      builder: (_) {
        final currentValue = widget.valueRx.value;
        return widget.builder(context, currentValue);
      },
    );
  }
}