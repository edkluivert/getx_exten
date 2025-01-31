import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';

typedef GetxWidgetListener<S> = void Function(BuildContext context, S state);

class GetListener<T> extends StatefulWidget {
  const GetListener({
    required this.valueRx,
    required this.listener,
    required this.child,
    super.key,
  });

  final Rx<T> valueRx;
  final GetxWidgetListener<T> listener;
  final Widget child;

  @override
  State<GetListener<T>> createState() => _GetListenerState<T>();
}

class _GetListenerState<T> extends State<GetListener<T>> {

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
    return widget.child;
  }
}

