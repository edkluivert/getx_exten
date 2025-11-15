import 'package:getx_exten/getx_exten.dart';

/// Builder widget that rebuilds on state changes
/// Can work with RxCubit, RxBloc, or any Rx<T>
typedef GetWidgetBuilder<S> = Widget Function(
    BuildContext context,
    S state,
    );

typedef GetCondition<S> = bool Function(
    S previous,
    S current,
    );

/// Builder widget that rebuilds on state changes
/// Can work with RxCubit, RxBloc, or any Rx<T>
class GetChanger<S> extends StatefulWidget {
  const GetChanger({
    required this.builder,
    this.rx,
    this.controller,
    this.buildWhen,
    super.key,
  }) : assert(
  (rx != null) ^ (controller != null),
  'Provide either rx or controller, but not both',
  );

  final GetWidgetBuilder<S> builder;
  final Rx<S>? rx;
  final dynamic controller;
  final GetCondition<S>? buildWhen;

  @override
  State<GetChanger<S>> createState() => _GetChangerState<S>();
}

class _GetChangerState<S> extends State<GetChanger<S>> {
  late final Rx<S> _rx;
  late S _lastBuiltState;
  Widget? _cachedWidget;

  Rx<S> _getRx() {
    if (widget.rx != null) return widget.rx!;

    if (widget.controller is RxCubit<S>) {
      return (widget.controller as RxCubit<S>).rx;
    } else if (widget.controller is RxBloc<dynamic, S>) {
      return (widget.controller as RxBloc<dynamic, S>).rx;
    } else {
      throw Exception('GetChanger requires Rx<$S>, RxCubit<$S> or RxBloc<Event, $S>');
    }
  }

  @override
  void initState() {
    super.initState();
    _rx = _getRx();
    _lastBuiltState = _rx.value;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final state = _rx.value;

      if (widget.buildWhen != null) {
        final shouldBuild = widget.buildWhen!(_lastBuiltState, state);
        if (!shouldBuild) {
          // Return cached widget to avoid calling builder
          return _cachedWidget ?? widget.builder(context, _lastBuiltState);
        }
      }

      _lastBuiltState = state;
      _cachedWidget = widget.builder(context, state);
      return _cachedWidget!;
    });
  }
}
