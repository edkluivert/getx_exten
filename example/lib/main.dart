import 'package:example/app_state.dart';
import 'package:example/enum.dart';
import 'package:example/my_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getx_exten/get_consumer/get_consumer.dart';
import 'package:getx_exten/getx_exten.dart';



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


  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final MyController controller = Get.put(MyController());

  final ApiController apiController = Get.put(ApiController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Counter Example')),
      body: GetConsumer<ApiState>(
        controller: apiController ,
        listener: (BuildContext context, state) {  },
        builder: (context, state) {
          if (state is ApiLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ApiSuccess<List<String>>) {
            return Column(
              children: state.data.map((e) => Text(e)).toList(),
            );
          } else if (state is ApiError) {
            return Center(child: Text("Error: ${state.message}"));
          }
          return const Text("Press fetch to load items");
        },
      ),
      // body: Center(
      //   child: GetConsumer<CounterState>(
      //     controller: controller,
      //     listenWhen: (previous, current) =>  current.value % 2 == 0,
      //     buildWhen: (previous, current) => current.value % 2 == 0,
      //     listener: (context, state) {
      //       if (state is CounterValue ) {
      //         ScaffoldMessenger.of(context).showSnackBar(
      //           SnackBar(content: Text("You reached ${state.value}! 🎉")),
      //         );
      //       }
      //     },
      //     builder: (context, state) {
      //       if (state is CounterInitial) {
      //         return const Text(
      //           "Press the + button to start",
      //           style: TextStyle(fontSize: 20),
      //         );
      //       } else if (state is CounterValue) {
      //         return Text(
      //           "Count: ${state.value}",
      //           style: const TextStyle(fontSize: 30),
      //         );
      //       }
      //       return const SizedBox();
      //     },
      //   ),
      // ),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.increment,
        child: const Icon(Icons.add),
      ),
    );

     }
  }
