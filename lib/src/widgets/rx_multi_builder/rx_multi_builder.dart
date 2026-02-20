import 'package:get/get.dart';
import 'package:flutter/widgets.dart';
import 'package:getx_exten/src/types/types.dart';
import 'package:getx_exten/src/state/rx_bloc_cubit/rx_cubit.dart';
import 'package:getx_exten/src/state/rx_bloc_cubit/rx_bloc.dart';

/// Multi-source reactive builder
/// Rebuilds when ANY of the provided Rx values change
class RxMultiBuilder extends StatefulWidget {
  const RxMultiBuilder({
    required this.sources,
    required this.builder,
    super.key,
  });

  final List<Rx> sources;
  final Widget Function(BuildContext context) builder;

  @override
  State<RxMultiBuilder> createState() => _RxMultiBuilderState();
}

class _RxMultiBuilderState extends State<RxMultiBuilder> {
  final List<Worker> _workers = [];

  @override
  void initState() {
    super.initState();

    for (final source in widget.sources) {
      _workers.add(
        ever(source, (_) {
          if (mounted) {
            setState(() {});
          }
        }),
      );
    }
  }

  @override
  void dispose() {
    for (final worker in _workers) {
      worker.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context);
  }
}
