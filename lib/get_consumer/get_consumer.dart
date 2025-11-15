import 'package:getx_exten/getx_exten.dart';

/// Consumer widget that both listens and rebuilds
/// Can work with RxCubit, RxBloc, or any Rx<T>
class GetConsumer<S> extends StatefulWidget {
  const GetConsumer({
    required this.builder,
    required this.listener,
    this.rx,
    this.controller,
    this.listenWhen,
    this.buildWhen,
    super.key,
  }) : assert(
  (rx != null) ^ (controller != null),
  'Provide either rx or controller, but not both',
  );

  final GetWidgetBuilder<S> builder;
  final GetListener<S> listener;
  final Rx<S>? rx;
  final dynamic controller;
  final GetCondition<S>? listenWhen;
  final GetCondition<S>? buildWhen;

  @override
  State<GetConsumer<S>> createState() => _GetConsumerState<S>();
}

class _GetConsumerState<S> extends State<GetConsumer<S>> {
  late final Rx<S> _rx;
  late S _lastBuiltState;
  late S _lastListenedState;
  bool _isFirstBuild = true;
  Widget? _cachedWidget;

  Rx<S> _getRx() {
    if (widget.rx != null) return widget.rx!;

    if (widget.controller is RxCubit<S>) {
      return (widget.controller as RxCubit<S>).rx;
    } else if (widget.controller is RxBloc<dynamic, S>) {
      return (widget.controller as RxBloc<dynamic, S>).rx;
    } else {
      throw Exception('GetConsumer requires Rx<$S>, RxCubit<$S> or RxBloc<Event, $S>');
    }
  }

  @override
  void initState() {
    super.initState();
    _rx = _getRx();
    _lastBuiltState = _rx.value;
    _lastListenedState = _rx.value;

    // Call listener for the initial state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.listener(context, _lastListenedState);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final state = _rx.value;
      final shouldListen = widget.listenWhen?.call(_lastListenedState, state) ?? true;
      final shouldBuild = widget.buildWhen?.call(_lastBuiltState, state) ?? true;

      if (shouldListen && !_isFirstBuild) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) widget.listener(context, state);
        });
        _lastListenedState = state;
      }

      if (shouldBuild) {
        _lastBuiltState = state;
        if (_isFirstBuild) _isFirstBuild = false;
        _cachedWidget = widget.builder(context, state);
        return _cachedWidget!;
      } else {
        if (_isFirstBuild) _isFirstBuild = false;
        return _cachedWidget ?? widget.builder(context, _lastBuiltState);
      }
    });
  }
}