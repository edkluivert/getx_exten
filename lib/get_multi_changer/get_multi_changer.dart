
import 'package:getx_exten/getx_exten.dart';


/// Multi-source reactive builder
/// Rebuilds when ANY of the provided Rx values change
class GetMultiChanger extends StatelessWidget {
  const GetMultiChanger({
    required this.sources,
    required this.builder,
    super.key,
  });

  final List<Rx> sources;
  final Widget Function(BuildContext context) builder;

  @override
  Widget build(BuildContext context) {
    // If no sources, just build without reactivity
    if (sources.isEmpty) {
      return builder(context);
    }

    return Obx(() {
      // Access all sources to register dependencies
      for (var source in sources) {
        source.value; // This registers the dependency
      }
      return builder(context);
    });
  }
}