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

  @override
  void initState() {
    super.initState();
    if (widget.controller is RxCubit<S>) {
      _rx = (widget.controller as RxCubit<S>).rx;
    } else if (widget.controller is RxBloc<dynamic, S>) {
      _rx = (widget.controller as RxBloc<dynamic, S>).rx;
    } else {
      throw Exception(
        'GetConsumer requires RxCubit<$S> or RxBloc<Event, $S>',
      );
    }
    _lastState = _rx.value;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final state = _rx.value;

      // Run listener if condition matches
      final shouldListen = widget.listenWhen?.call(_lastState, state) ?? true;
      if (shouldListen && state != _lastState) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) widget.listener(context, state);
        });
      }

      // Decide if we should rebuild UI
      final shouldBuild = widget.buildWhen?.call(_lastState, state) ?? true;
      _lastState = state;

      if (shouldBuild) {
        return widget.builder(context, state);
      } else {
        // Keep old UI
        return widget.builder(context, _lastState);
      }
    });
  }
}
