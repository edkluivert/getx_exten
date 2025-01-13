# GetX Listener and Consumer Library

This library extends the functionality of the [GetX](https://pub.dev/packages/get) package in Flutter, allowing for efficient state management with `GetListener` and `GetConsumer`. These widgets make it easy to reactively update the UI based on changes in state.

## Features

- **GetListener**: A widget that listens to a specific controller or variable and rebuilds whenever the observed state changes.
- **GetConsumer**: A widget that allows you to consume and react to changes in a specified controller, making it easier to manage dependencies and state updates.

- Contribution
This implementation was inspired by [Jean Roldan](https://stackoverflow.com/users/14933165/jean-roldan), who provided valuable insights and code suggestions on Stack Overflow. Their contributions helped streamline the integration of reactive programming principles in Flutter applications.


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
import 'package:get/get.dart';
import 'package:getx_exten/state_manager/state_manager.dart';

class MyController extends GetxController {

  final StateManager<String> stateManager = StateManager<String>();
  var counter = 0.obs;


  @override
  void onInit() {
    super.onInit();
    fetchData();

  }

  void increment(){
    counter++;

    //update();
  }

  void decrement(){
    counter--;
  }



  Future<void> fetchData() async {
    stateManager.setLoading();
    await Future.delayed(Duration(seconds: 2)).then((_){
      stateManager.setSuccess("Fetched Data");
    });

  }

  Future<void> fetchDataWithError() async {
    stateManager.setLoading();
    await Future.delayed(Duration(seconds: 2));
    stateManager.setError("Error occurred");
  }

}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final MyController controller = Get.put(MyController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: GetListener(
          stateManager: controller.stateManager,
          listener: (context, state) {
            if (controller.stateManager.status.value == RxState.error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Error: ${controller.stateManager.status}")),
              );
            }else if(controller.stateManager.status.value == RxState.success){
              print('hi');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Success: ${controller.stateManager.data}")),
              );
            }
          },
          child: GetConsumer<String>(
            stateManager: controller.stateManager,
            listener: (context, state) {
              // if (controller.stateManager.status.value == RxState.error) {
              //   ScaffoldMessenger.of(context).showSnackBar(
              //     SnackBar(content: Text("Error: ${controller.stateManager.status}")),
              //   );
              // }else if(controller.stateManager.status.value == RxState.success){
              //   print('hi');
              //   ScaffoldMessenger.of(context).showSnackBar(
              //     SnackBar(content: Text("Success: ${controller.stateManager.status}")),
              //   );
              //}
            },
            onLoading: const Center(child: CircularProgressIndicator()),
            successWidget: (data) => Center(child: Text(data ?? "Success")),
            onError: (error) => Center(child: Text("Error: $error")),
            onEmpty: const Center(child: Text("No data available")),

          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.increment,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

License
This project is licensed under the MIT License. See the LICENSE file for more details.
