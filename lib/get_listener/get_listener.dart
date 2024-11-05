// import 'package:flutter/material.dart';
// import 'package:get/state_manager.dart';
//
// typedef GetxWidgetListener<S> = void Function(BuildContext context, S state);
//
// class GetListener<T> extends StatelessWidget {
//   const GetListener({
//     required this.valueRx,
//     required this.listener,
//     required this.child,
//     super.key,
//   });
//
//   final RxInterface<T> valueRx;
//   final GetxWidgetListener<T> listener;
//   final Widget child;
//
//   @override
//   Widget build(BuildContext context) {
//     ever<T>(valueRx, (value) => listener.call(context, value));
//     return child;
//   }
// }
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getx_exten/state_manager/state_manager.dart';

typedef GetxListenerCallback = void Function(BuildContext context, RxState state);

class GetListener extends StatelessWidget {
  const GetListener({
    required this.stateManager,
    required this.listener,
    required this.child,
    super.key,
  });

  final StateManager stateManager;
  final GetxListenerCallback listener;
  final Widget child;


  static final Set<Rx> _registeredListeners = {};

  @override
  Widget build(BuildContext context) {


    if (!_registeredListeners.contains(stateManager.status)) {
      ever<RxState>(stateManager.status, (state) {
        listener.call(context, state);
      });
      // Mark as having a registered listener
      _registeredListeners.add(stateManager.status);
    }

    return child;
  }
}