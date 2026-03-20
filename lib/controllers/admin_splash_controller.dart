import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:grasp_app/utils/localstorage.dart';
import '../infrastructure/routes/admin_routes.dart';

class AdminSplashController extends GetxController {
  final box = GetStorage();

  @override
  void onInit() {
    super.onInit();
    Future.delayed(const Duration(seconds: 3), () async{
      bool isLoggedIn = await PrefManager().readValue(key: 'isLoggedIn') == "yes";
      if (isLoggedIn) {
        Get.offAllNamed(AdminRoutes.LOADING_SCREEN);
      } else {
        Get.offAllNamed(AdminRoutes.loginscreen);
      }
    }
    );
  }
}
