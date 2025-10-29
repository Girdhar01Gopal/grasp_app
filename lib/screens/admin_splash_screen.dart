import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/admin_splash_controller.dart';

class AdminSplashScreen extends StatelessWidget {
  const AdminSplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AdminSplashController controller = Get.put(AdminSplashController());

    return Scaffold(
      backgroundColor: Colors.white, // Pure white background
      body: SafeArea(
        child: Center(
          child: Image.asset(
            'assets/images/grasp_1.png',
            width: 200, // You can increase/decrease this value
            height: 200, // You can also adjust this
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
