import 'package:getx_exten/getx_exten.dart';

/// Selector widget that rebuilds only when selected value changes
/// Leverages GetX reactivity for fine-grained updates
class GetSelector<S, T> extends StatefulWidget {
  const GetSelector({
    required this.selector,
    required this.builder,
    this.rx,
    this.controller,
    super.key,
  }) : assert(
  (rx != null) ^ (controller != null),
  'Provide either rx or controller, but not both',
  );

  final T Function(S state) selector;
  final Widget Function(BuildContext context, T value) builder;
  final Rx<S>? rx;
  final dynamic controller;

  @override
  State<GetSelector<S, T>> createState() => _GetSelectorState<S, T>();
}

class _GetSelectorState<S, T> extends State<GetSelector<S, T>> {
  late final Rx<S> _rx;
  late T _currentValue;
  Worker? _worker;

  Rx<S> _getRx() {
    if (widget.rx != null) return widget.rx!;

    if (widget.controller is RxCubit<S>) {
      return (widget.controller as RxCubit<S>).rx;
    } else if (widget.controller is RxBloc<dynamic, S>) {
      return (widget.controller as RxBloc<dynamic, S>).rx;
    } else {
      throw Exception('GetSelector requires Rx<$S>, RxCubit<$S> or RxBloc<Event, $S>');
    }
  }

  @override
  void initState() {
    super.initState();
    _rx = _getRx();
    _currentValue = widget.selector(_rx.value);

    // Use ever worker to selectively rebuild
    // Note: ever fires immediately, but we check if value actually changed
    _worker = ever<S>(_rx, (newState) {
      final newValue = widget.selector(newState);

      // Only rebuild if selected value changed
      if (_currentValue != newValue && mounted) {
        setState(() {
          _currentValue = newValue;
        });
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
    return widget.builder(context, _currentValue);
  }
}
