import 'package:get/get.dart';
import 'package:flutter/widgets.dart';
import 'package:getx_exten/src/types/types.dart';
import 'package:getx_exten/src/state/rx_bloc_cubit/rx_cubit.dart';
import 'package:getx_exten/src/state/rx_bloc_cubit/rx_bloc.dart';

/// Consumer widget that both listens and rebuilds
/// Can work with RxCubit, RxBloc, or any `Rx<T>`
class RxConsumer<S> extends StatefulWidget {
  const RxConsumer({
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

  final RxWidgetBuilder<S> builder;
  final RxWidgetListener<S> listener;
  final Rx<S>? rx;
  final dynamic controller;
  final RxCondition<S>? listenWhen;
  final RxCondition<S>? buildWhen;

  @override
  State<RxConsumer<S>> createState() => _RxConsumerState<S>();
}

class _RxConsumerState<S> extends State<RxConsumer<S>> {
  late final Rx<S> _rx;
  late S _lastBuiltState;
  late S _lastListenedState;
  bool _isFirstBuild = true;
  Widget? _cachedWidget;
  Worker? _worker;

  Rx<S> _getRx() {
    if (widget.rx != null) return widget.rx!;

    if (widget.controller is RxCubit<S>) {
      return (widget.controller as RxCubit<S>).rx;
    } else if (widget.controller is RxBloc<dynamic, S>) {
      return (widget.controller as RxBloc<dynamic, S>).rx;
    } else {
      throw Exception(
          'RxConsumer requires Rx<$S>, RxCubit<$S> or RxBloc<Event, $S>');
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

    // explicitly listen and trigger renders
    _worker = ever<S>(_rx, (state) {
      if (!mounted) return;

      final shouldListen =
          widget.listenWhen?.call(_lastListenedState, state) ?? true;
      final shouldBuild =
          widget.buildWhen?.call(_lastBuiltState, state) ?? true;

      // Handle listen behavior first independently of build
      if (shouldListen) {
        widget.listener(context, state);
        _lastListenedState = state;
      }

      if (shouldBuild) {
        setState(() {
          _lastBuiltState = state;
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
    if (_isFirstBuild) _isFirstBuild = false;
    _cachedWidget = widget.builder(context, _lastBuiltState);
    return _cachedWidget!;
  }
}
