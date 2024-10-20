import 'package:get/get.dart';

class MyController extends GetxController{

  var counter = 0.obs;

  void increment(){
    counter++;

    //update();
  }

  void decrement(){
    counter--;
  }

}