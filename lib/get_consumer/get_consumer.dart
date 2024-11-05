import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getx_exten/state_manager/state_manager.dart';

typedef NotifierBuilder<T> = Widget Function(T? state);

class GetConsumer<T> extends StatelessWidget {
  final StateManager<T> stateManager;
  final NotifierBuilder<T?> successWidget;
  final Widget Function(String? error)? onError;
  final Widget? onLoading;
  final Widget? onEmpty;
  final void Function(BuildContext context, T? state)? listener;

  const GetConsumer({
    super.key,
    required this.stateManager,
    required this.successWidget,
    this.onLoading,
    this.onError,
    this.onEmpty,
    this.listener,
  });

  static final Set<Rx> _registeredListeners = {};

  @override
  Widget build(BuildContext context) {
    // Using Obx to reactively listen to changes in the StateManager

    if (!_registeredListeners.contains(stateManager.status)) {
      ever(stateManager.status, (status) {
        if (listener != null) {
          // the listener is called only once for each state change
          listener!(context, stateManager.data);
        }
      });
      // Mark as having a registered listener
      _registeredListeners.add(stateManager.status);
    }

    return stateManager.obx(
      successWidget,
      onLoading: onLoading,
      onError: onError,
      onEmpty: onEmpty,
    );
  }
}
