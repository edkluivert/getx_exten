import 'package:get/get.dart';
import 'package:getx_exten/state_manager/state_manager.dart';

class MyController extends GetxController with StateMixin{

  final StateManager<String> stateManager = StateManager<String>();
  var counter = 0.obs;


  @override
  void onInit() {
    // TODO: implement onInit
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