import 'package:example/enum.dart';
import 'package:example/my_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getx_exten/get_consumer/get_consumer.dart';
import 'package:getx_exten/get_listener/get_listener.dart';

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
        child: GetListener<RequestState>(
          valueRx: controller.feedsRequestState,
          listener: (context, state){

            if (state is Error ) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage), // Show the error message
                  duration: const Duration(seconds: 3), // Optional duration
                  backgroundColor: Colors.red, // Show red for errors
                ),
              );
            }

            if (state is Success<List<String>>) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Fetched ${state.data.length} items successfully!'),
                  duration: const Duration(seconds: 2),
                  backgroundColor: Colors.green, // Green for success
                ),
              );
            }

            // You can optionally handle other states as well:
            if (state is Loading) {
              // Example (usually unnecessary)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Loading...'),
                  duration: Duration(seconds: 1), // Short duration
                ),
              );
            }
          },
          child: GetConsumer(
            controller: controller,
            valueRx: controller.counter,
            listener: (context, state){
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
            builder: (context, state){
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
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}