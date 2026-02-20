import 'package:flutter/material.dart';

/// Builder widget that rebuilds on state changes
typedef RxWidgetBuilder<S> = Widget Function(
  BuildContext context,
  S state,
);

/// Condition evaluating to true or false based on previous and current state
typedef RxCondition<S> = bool Function(
  S previous,
  S current,
);

/// Function mapped to execute a side-effect based on state
typedef RxWidgetListener<S> = void Function(
  BuildContext context,
  S state,
);
