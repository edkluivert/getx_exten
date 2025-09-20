import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:getx_exten/utils/base_state.dart';
import '../utils/emit.dart';

typedef GetWidgetBuilder<S extends RxState> = Widget Function(
    BuildContext context,
    S state,
    );

typedef GetListener<S extends RxState> = void Function(
    BuildContext context,
    S state,
    );

typedef GetCondition<S extends RxState> = bool Function(
    S previous,
    S current,
    );

class GetConsumer<S extends RxState> extends StatefulWidget {
  const GetConsumer({
    required this.builder,
    required this.listener,
    required this.controller,
    this.listenWhen,
    this.buildWhen,
    super.key,
  });

  final GetWidgetBuilder<S> builder;
  final GetListener<S> listener;
  final dynamic controller;

  /// Optional filter: should [listener] be called?
  final GetCondition<S>? listenWhen;

  /// Optional filter: should [builder] rebuild?
  final GetCondition<S>? buildWhen;

  @override
  State<GetConsumer<S>> createState() => _GetConsumerState<S>();
}

class _GetConsumerState<S extends RxState> extends State<GetConsumer<S>> {
  late final Rx<S> _rx;
  late S _lastState;
  bool _isFirstBuild = true;

  @override
  void initState() {
    super.initState();
    if (widget.controller is RxCubit<S>) {
      _rx = (widget.controller as RxCubit<S>).rx;
    } else if (widget.controller is RxBloc<dynamic, S>) {
      _rx = (widget.controller as RxBloc<dynamic, S>).rx;
    } else {
      throw Exception('GetConsumer requires RxCubit<$S> or RxBloc<Event, $S>');
    }
    _lastState = _rx.value;
    // Call listener for the initial state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.listener(context, _lastState);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final state = _rx.value;
      // Update _lastState before any checks
      final shouldListen = widget.listenWhen?.call(_lastState, state) ?? true;
      final shouldBuild = widget.buildWhen?.call(_lastState, state) ?? true;

      if (shouldListen && !_isFirstBuild) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) widget.listener(context, state);
        });
      }

      if (shouldBuild) {
        _lastState = state;
        if (_isFirstBuild) _isFirstBuild = false;
        return widget.builder(context, state);
      } else {
        return widget.builder(context, _lastState);
      }
    });
  }
}


