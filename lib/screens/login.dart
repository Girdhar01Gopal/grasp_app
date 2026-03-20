import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:grasp_app/controllers/logincontroller.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';


class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginController());
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;

    Widget logoAndText() => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 50.h,
              backgroundColor: Colors.white,
              child: Image.asset(
                'assets/images/FIITJEE_Logo.png',
                fit: BoxFit.contain,
                height: 90.h,
                width: 70.h,
              ),
            ),
            SizedBox(height: 60.h),
            Text(
              "Welcome to Libravia",
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : const Color(0xFFC49B3B),
              ),
            ),
            Text(
              "Login with your Enrollment Number",
              style: TextStyle(
                color: isDarkMode ? Colors.white70 : Colors.grey[600],
                fontSize: 14.sp,
              ),
            ),
          ],
        );

    Widget loginForm() => Padding(
      padding:  EdgeInsets.only(top: 0.sp),
      child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextField(
                controller: controller.passwordController,
                decoration: InputDecoration(
                  labelText: "Enrollment Number",
                  labelStyle: TextStyle(
                    color: isDarkMode ? Colors.white70 : const Color.fromARGB(255, 15, 2, 2),
                    fontSize: 4.sp,
                  ),
                  prefixIcon: const Icon(CupertinoIcons.number, color: Colors.black54),
                  filled: true,
                  fillColor: isDarkMode ? Colors.grey[700] : Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(
                      color: isDarkMode ? Colors.white : const Color(0xFFC49B3B),
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(
                      color: isDarkMode ? Colors.white : const Color(0xFFC49B3B),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30.h),
              Obx(() => ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : () => controller.login(enrollmentNo: controller.passwordController.text.toString()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDarkMode ? Colors.grey[700] : const Color(0xFFC49B3B),
                      minimumSize: Size(double.infinity, 48.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: controller.isLoading.value
                        ? LoadingAnimationWidget.newtonCradle(
                            color: Colors.white,
                            size: 80.h,
                          )
                        : Text(
                            "Continue",
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  )),
              SizedBox(height: 50.h),
              Column(
                children: [
                  Text(
                    "Libravia",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : const Color(0xFFC49B3B),
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    "– Knowledge Sharing Platform –",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isDarkMode ? Colors.white70 : const Color(0xFFC49B3B),
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    "by MGEPL",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isDarkMode ? Colors.white54 : Colors.grey.shade700,
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
    );

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[800] : Colors.white,
      body: Stack(
        children: [
          // ---------- Gradient Curve Background ----------
          CustomPaint(
            size: Size(MediaQuery.of(context).size.width, 300.h),
            painter: GradientCurvePainter(isDarkMode),
          ),
          SafeArea(
            child: isLandscape
                ? Center(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 20.h),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: logoAndText()),
                            SizedBox(width: 40.w),
                            Expanded(child: loginForm()),
                          ],
                        ),
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    padding: EdgeInsets.only(top: 0, left: 28.w, right: 28.w),
                    child: Column(
                      children: [
                        SizedBox(height: 80.h),
                        logoAndText(),
                        SizedBox(height: 60.h),
                        loginForm(),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

/// ---------- Gradient Painter ----------
class GradientCurvePainter extends CustomPainter {
  final bool isDarkMode;

  GradientCurvePainter(this.isDarkMode);

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();

    path.lineTo(0, size.height * 0.65);
    path.quadraticBezierTo(
      size.width * 0.25, size.height * 0.85,
      size.width * 0.5, size.height * 0.7,
    );
    path.quadraticBezierTo(
      size.width * 0.75, size.height * 0.55,
      size.width, size.height * 0.75,
    );
    path.lineTo(size.width, 0);
    path.close();

    // Define gradient colors based on dark or light mode
    final gradient = LinearGradient(
      colors: isDarkMode
          ? [Colors.black, Colors.grey!, Colors.black]
          : [Color(0xFFF5D487), Color(0xFFb94a42), Color.fromARGB(255, 102, 22, 16)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    final paint = Paint()
      ..shader = gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}