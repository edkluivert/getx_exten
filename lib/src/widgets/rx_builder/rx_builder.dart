import 'package:get/get.dart';
import 'package:flutter/widgets.dart';
import 'package:getx_exten/src/types/types.dart';
import 'package:getx_exten/src/state/rx_bloc_cubit/rx_cubit.dart';
import 'package:getx_exten/src/state/rx_bloc_cubit/rx_bloc.dart';

/// Builder widget that rebuilds on state changes
/// Can work with RxCubit, RxBloc, or any `Rx<T>`
/// Builder widget that rebuilds on state changes
/// Can work with RxCubit, RxBloc, or any Rx<T>
class RxBuilder<S> extends StatefulWidget {
  const RxBuilder({
    required this.builder,
    this.rx,
    this.controller,
    this.buildWhen,
    super.key,
  }) : assert(
          (rx != null) ^ (controller != null),
          'Provide either rx or controller, but not both',
        );

  final RxWidgetBuilder<S> builder;
  final Rx<S>? rx;
  final dynamic controller;
  final RxCondition<S>? buildWhen;

  @override
  State<RxBuilder<S>> createState() => _RxBuilderState<S>();
}

class _RxBuilderState<S> extends State<RxBuilder<S>> {
  late final Rx<S> _rx;
  late S _lastBuiltState;
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
          'RxBuilder requires Rx<$S>, RxCubit<$S> or RxBloc<Event, $S>');
    }
  }

  @override
  void initState() {
    super.initState();
    _rx = _getRx();
    _lastBuiltState = _rx.value;

    _worker = ever<S>(_rx, (state) {
      if (!mounted) return;

      if (widget.buildWhen != null) {
        final shouldBuild = widget.buildWhen!(_lastBuiltState, state);
        if (!shouldBuild) return;
      }

      setState(() {
        _lastBuiltState = state;
      });
    });
  }

  @override
  void dispose() {
    _worker?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _cachedWidget = widget.builder(context, _lastBuiltState);
    return _cachedWidget!;
  }
}
