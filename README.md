# GetX Listener and Consumer Library

This library extends the functionality of the [GetX](https://pub.dev/packages/get) package in Flutter, allowing for efficient state management with `GetListener` and `GetConsumer`. These widgets make it easy to reactively update the UI based on changes in state.

## Features

- **GetListener**: A widget that listens to a specific observable variable and triggers a callback when the state changes.
- **GetConsumer**: A widget that listens to state changes and also provides a builder function to rebuild part of the UI.

## Acknowledgments

This implementation was inspired by [Jean Roldan](https://stackoverflow.com/users/14933165/jean-roldan), whose contributions on Stack Overflow provided valuable insights into integrating reactive programming principles in Flutter applications.

## Installation

Add the following dependency to your `pubspec.yaml` file:

```yaml
dependencies:
  get: ^4.0.0  # or the latest version
```

## Usage

### GetListener

`GetListener` is useful when you need to react to changes in a specific variable from a controller without rebuilding the entire widget tree.

#### Example

```dart
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class MyController extends GetxController {
  final RxInt counter = 0.obs;
  final Rx<RequestState<List<String>>> feedsRequestState = RequestState<List<String>>.initial().obs;

  void increment() => counter++;
  void decrement() => counter--;

  /// Fetch data and update the state
  Future<void> fetchFeeds() async {
    try {
      feedsRequestState.value = RequestState.loading();
      await Future.delayed(const Duration(seconds: 2));
      feedsRequestState.value = RequestState.success(['Feed 1', 'Feed 2', 'Feed 3']);
    } catch (error) {
      feedsRequestState.value = RequestState.error('Failed to fetch feeds');
    }
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final MyController controller = Get.put(MyController());
    
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: GetListener<RequestState>(
          valueRx: controller.feedsRequestState,
          listener: (context, state) {
            if (state is Error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage),
                  duration: const Duration(seconds: 3),
                  backgroundColor: Colors.red,
                ),
              );
            }
            if (state is Success<List<String>>) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Fetched ${state.data.length} items successfully!'),
                  duration: const Duration(seconds: 2),
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
          child: GetConsumer(
            controller: controller,
            valueRx: controller.counter,
            listener: (context, state) {
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
                  const Text('You have pushed the button this many times:'),
                  Text(
                    state.toString(),
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ],
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.increment,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

## RequestState Class

This class represents different states of a request:

```dart
abstract class RequestState<T> {
  const RequestState();

  factory RequestState.initial() = Initial<T>;
  factory RequestState.loading() = Loading<T>;
  factory RequestState.success(T data) = Success<T>;
  factory RequestState.error(String errorMessage) = Error<T>;
}

class Initial<T> extends RequestState<T> {}
class Loading<T> extends RequestState<T> {}

class Success<T> extends RequestState<T> {
  final T data;
  Success(this.data);
}

class Error<T> extends RequestState<T> {
  final String errorMessage;
  Error(this.errorMessage);
}
```

## License

This project is licensed under the MIT License. See the LICENSE file for more details.

