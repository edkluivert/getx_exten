import 'package:example/enum.dart';
import 'package:get/get.dart';

class MyController extends GetxController{

  var counter = 0.obs;
  final Rx<RequestState<List<String>>> feedsRequestState =
      RequestState<List<String>>.initial().obs;

  @override
  void onInit() {
    super.onInit();
    fetchFeeds();
  }

  void increment(){
    counter++;

    //update();
  }

  void decrement(){
    counter--;
  }



  /// Fetch data and update the state
  Future<void> fetchFeeds() async {
    try {
      // Update state to loading
      feedsRequestState.value = RequestState.loading();

      // Simulate a network request
      await Future.delayed(const Duration(seconds: 2));

      // Example response data
      List<String> response = ['Feed 1', 'Feed 2', 'Feed 3'];

      // Update state to success and pass the data
      feedsRequestState.value = RequestState.success(response);
    } catch (error) {
      // Update state to error with a message
      feedsRequestState.value =
          RequestState.error('Failed to fetch feeds');
    }
    update();
  }

}