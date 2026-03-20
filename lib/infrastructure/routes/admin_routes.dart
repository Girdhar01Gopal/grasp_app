import 'package:get/get.dart';
import 'package:grasp_app/bindings/loginbinding.dart';
import 'package:grasp_app/screens/login.dart';
import '../../bindings/Loading_Binding.dart';
import '../../bindings/bindings.dart';
import '../../bindings/dashboard_binding.dart';
import '../../screens/Loading_Screen.dart';
import '../../screens/admin_splash_screen.dart';
import '../../screens/dashboard_screen.dart';

class AdminRoutes {
  // ==================
  // Route Names
  // ==================
  static const ADMIN_SPLASH = '/admin/splash';
  static const LOADING_SCREEN = '/loading';
  static const homeScreen = '/home';
  static const MAIN_SCREEN = '/mainScreen';
  static const CONTINUE_SCREEN = '/continue';
  static const usageScreen = '/usageScreen';
    static const loginscreen = '/loginscreen';


  // ========
  // Route Definitions
  // ========
  static final List<GetPage> routes = [
    // Splash Screen
    GetPage(
      name: ADMIN_SPLASH,
      page: () => AdminSplashScreen(),
      transition: Transition.fadeIn,
      transitionDuration: Duration(milliseconds: 400),
    ),

    // Loading Screen
    GetPage(
      name: LOADING_SCREEN,
      page: () => LoadingScreen(),
      binding: LoadingBinding(),
    ),
 GetPage(
      name: loginscreen,
      page: () => LoginScreen(),
      binding: Loginbinding(),
    ),
    // Home Screen
    GetPage(
      name: homeScreen,
      page: () => HomeScreen(),
      binding: HomeBinding(),
    ),

  
  ];
}
