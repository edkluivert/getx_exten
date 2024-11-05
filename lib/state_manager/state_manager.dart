// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// enum RxState {
//   loading,
//   success,
//   error,
//   empty,
//   isLoadingMore,
// }
//
// class StateManager<T> {
//   final Rx<RxState> _status = Rx<RxState>(RxState.empty);
//   RxState get status => _status.value;
//
//   final Rx<T?> _data = Rx<T?>(null);
//   T? get data => _data.value;
//
//   void setLoading() {
//     _status.value = RxState.loading;
//   }
//
//   void setSuccess(T value) {
//     _data.value = value;
//     _status.value = RxState.success;
//   }
//
//   void setError(String message) {
//     _status.value = RxState.error;
//   }
//
//   void setEmpty() {
//     _status.value = RxState.empty;
//   }
//
//   Widget obx(
//       NotifierBuilder<T?> widget, {
//         Widget Function(String? error)? onError,
//         Widget? onLoading,
//         Widget? onEmpty,
//       }) {
//     return SimpleBuilder(builder: (_) {
//       switch (_status.value) {
//         case RxStatus.loading:
//           return onLoading ?? const Center(child: CircularProgressIndicator());
//         case RxStatus.error:
//           return onError != null
//               ? onError("An error occurred.")
//               : Center(child: Text('An error occurred.'));
//         case RxStatus.empty:
//           return onEmpty ?? const Center(child: Text("No data available"));
//         case RxStatus.success:
//         default:
//           return widget(_data.value);
//       }
//     });
//   }
// }
import 'package:flutter/material.dart';
import 'package:get/get.dart';
enum RxState {
  loading,
  success,
  error,
  empty,
}

class StateManager<T> {
  final Rx<RxState> _status = Rx<RxState>(RxState.empty);
  Rx<RxState> get status => _status;

  final Rx<T?> _data = Rx<T?>(null);
  T? get data => _data.value;

  void setLoading() {
    _status.value = RxState.loading;
  }

  void setSuccess(T value) {
    _data.value = value;
    _status.value = RxState.success;
  }

  void setError(String message) {
    _status.value = RxState.error;
  }

  void setEmpty() {
    _status.value = RxState.empty;
  }

  Widget obx(
      NotifierBuilder<T?> widget, {
        Widget Function(String? error)? onError,
        Widget? onLoading,
        Widget? onEmpty,
      }) {
    return Obx(() { // Use Obx to reactively listen to changes
      switch (_status.value) {
        case RxState.loading:
          return onLoading ?? const Center(child: CircularProgressIndicator());
        case RxState.error:
          return onError != null
              ? onError("An error occurred.")
              : Center(child: Text('An error occurred.'));
        case RxState.empty:
          return onEmpty ?? const Center(child: Text("No data available"));
        case RxState.success:
        default:
          return widget(_data.value);
      }
    });
  }

  // Method to listen to the status changes without rebuilding the UI
  void listenToStatus(
      {required Function onLoading,
        required Function onSuccess,
        required Function onError,
        required Function onEmpty}) {
    ever<RxState>(_status, (state) {
      switch (state) {
        case RxState.loading:
          onLoading();
          break;
        case RxState.success:
          onSuccess();
          break;
        case RxState.error:
          onError();
          break;
        case RxState.empty:
          onEmpty();
          break;
      }
    });
  }
}

