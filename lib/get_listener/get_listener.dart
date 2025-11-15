import 'package:getx_exten/getx_exten.dart';


typedef GetWidgetBuilder<S> = Widget Function(
    BuildContext context,
    S state,
    );

typedef GetCondition<S> = bool Function(
    S previous,
    S current,
    );




typedef GetListener<S> = void Function(
    BuildContext context,
    S state,
    );

/// Listener widget that doesn't rebuild, only listens
/// Can work with RxCubit, RxBloc, or any Rx<T>
class GetListenerWidget<S> extends StatefulWidget {
  const GetListenerWidget({
    required this.listener,
    required this.child,
    this.rx,
    this.controller,
    this.listenWhen,
    super.key,
  }) : assert(
  (rx != null) ^ (controller != null),
  'Provide either rx or controller, but not both',
  );

  final GetListener<S> listener;
  final Rx<S>? rx;
  final dynamic controller;
  final Widget child;
  final GetCondition<S>? listenWhen;

  @override
  State<GetListenerWidget<S>> createState() => _GetListenerWidgetState<S>();
}

class _GetListenerWidgetState<S> extends State<GetListenerWidget<S>> {
  late final Rx<S> _rx;
  late S _lastState;
  Worker? _worker;

  Rx<S> _getRx() {
    if (widget.rx != null) return widget.rx!;

    if (widget.controller is RxCubit<S>) {
      return (widget.controller as RxCubit<S>).rx;
    } else if (widget.controller is RxBloc<dynamic, S>) {
      return (widget.controller as RxBloc<dynamic, S>).rx;
    } else {
      throw Exception('GetListenerWidget requires Rx<$S>, RxCubit<$S> or RxBloc<Event, $S>');
    }
  }

  @override
  void initState() {
    super.initState();
    _rx = _getRx();
    _lastState = _rx.value;

    // Listen for future changes
    _worker = ever<S>(_rx, (newState) {
      final shouldListen = widget.listenWhen?.call(_lastState, newState) ?? true;

      if (shouldListen && mounted) {
        widget.listener(context, newState);
      }

      _lastState = newState;
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











