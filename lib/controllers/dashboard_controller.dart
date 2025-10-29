import 'package:get/get.dart';

class HomeController extends GetxController {
  var selectedTabIndex = 0.obs;
  final subjects = ["Chemistry", "Physics", "Mathematics"];

  void changeTab(int index) {
    selectedTabIndex.value = index;
  }
}
