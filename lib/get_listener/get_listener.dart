import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

typedef RxListener<T> = void Function(BuildContext context, T state);

class GetListener<T> extends StatefulWidget {
  const GetListener({
    required this.rx,
    required this.listener,
    required this.child,
    super.key,
  });

  final Rx<T> rx;
  final RxListener<T> listener;
  final Widget child;

  @override
  State<GetListener<T>> createState() => _GetListenerState<T>();
}

class _GetListenerState<T> extends State<GetListener<T>> {
  late T _lastValue;
  Worker? _worker;

  @override
  void initState() {
    super.initState();
    _lastValue = widget.rx.value;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.listener(context, _lastValue);
      }
    });
    // Listen for future changes
    _worker = ever<T>(widget.rx, (newValue) {
      if (newValue != _lastValue) {
        if (mounted) {
          widget.listener(context, newValue);
        }
        _lastValue = newValue;
      }
    });
  }


  @override
  void dispose() {
    _worker?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
