import 'package:example/my_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getx_exten/get_consumer/get_consumer.dart';
import 'package:getx_exten/state_manager/state_manager.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
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
        child: GetConsumer<String>(
          stateManager: controller.stateManager,
          listener: (context, state) {
            if (controller.stateManager.status.value == RxState.error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Error: ${controller.stateManager.status}")),
              );
            }else if(controller.stateManager.status.value == RxState.success){
              print('hi');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Success: ${controller.stateManager.status}")),
              );
            }
          },
          onLoading: const Center(child: CircularProgressIndicator()),
          successWidget: (data) => Center(child: Text(data ?? "Success")),
          onError: (error) => Center(child: Text("Error: $error")),
          onEmpty: const Center(child: Text("No data available")),

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
