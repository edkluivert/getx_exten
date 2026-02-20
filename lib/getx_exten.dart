library getx_exten;

// Re-export common dependencies that users might need
export 'package:flutter/material.dart';
export 'package:get/get.dart';

// Export Shared Types
export 'src/types/types.dart';

// Export Widgets
export 'src/widgets/rx_builder/rx_builder.dart';
export 'src/widgets/rx_consumer/rx_consumer.dart';
export 'src/widgets/rx_listener/rx_listener.dart';
export 'src/widgets/rx_multi_builder/rx_multi_builder.dart';
export 'src/widgets/rx_selector/rx_selector.dart';

// Export State (RxBloc & RxCubit)
export 'src/state/rx_bloc_cubit/rx_bloc.dart';
export 'src/state/rx_bloc_cubit/rx_cubit.dart';

// Export Utils
export 'src/utils/rx_extensions.dart';
