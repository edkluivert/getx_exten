# GetX Listener and Consumer Library

This library extends the functionality of the [GetX](https://pub.dev/packages/get) package in Flutter, allowing for efficient state management with `GetListener` and `GetConsumer`. These widgets make it easy to reactively update the UI based on changes in state.

## Features

- **GetListener**: A widget that listens to a specific controller or variable and rebuilds whenever the observed state changes.
- **GetConsumer**: A widget that allows you to consume and react to changes in a specified controller, making it easier to manage dependencies and state updates.

## Getting Started

### Installation

Add the following dependency to your `pubspec.yaml` file:

```yaml
dependencies:
  get: ^4.0.0  # or the latest version
## Usage

### GetListener

`GetListener` is useful when you need to react to changes in a specific variable from a controller without needing to rebuild the entire widget tree.

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyController extends GetxController {
  var count = 0.obs;

  void increment() {
    count++;
  }
}

class MyWidget extends StatelessWidget {
  final MyController controller = Get.put(MyController());

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GetListener<MyController>(
          listener: (controller) {
            // React to changes here
            print('Count updated: ${controller.count}');
          },
          child: Obx(() => Text('Count: ${controller.count}')),
        ),
        ElevatedButton(
          onPressed: controller.increment,
          child: Text('Increment'),
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyController extends GetxController {
  var counter = 0.obs;

  void increment() {
    counter++;
  }
}

class MyWidget extends StatelessWidget {
  final MyController controller = Get.put(MyController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GetConsumer Example'),
      ),
      body: Center(
        child: GetConsumer<MyController>(
          controller: controller,
          valueRx: controller.counter,
          listener: (context, state) {
            // Show SnackBar if the counter is even
            if (state % 2 == 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Hello! This is a SnackBar message.'),
                  duration: Duration(seconds: 2),
                  backgroundColor: Colors.blue,
                ),
              );
            }
          },
          builder: (context, state) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  'You have pushed the button this many times:',
                ),
                Text(
                  state.toString(),
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                ElevatedButton(
                  onPressed: controller.increment,
                  child: const Text('Increment'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
Contribution
This implementation was inspired by Jean Roldan, who provided valuable insights and code suggestions on Stack Overflow. Their contributions helped streamline the integration of reactive programming principles in Flutter applications.

License
This project is licensed under the MIT License. See the LICENSE file for more details.
