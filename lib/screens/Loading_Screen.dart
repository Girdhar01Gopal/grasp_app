import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../controllers/Loading_Controller.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(LoadingController());
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
      body: Stack(
        children: [
          // ---------- Background Curves ----------
          CustomPaint(
            size: Size(MediaQuery.of(context).size.width,
                MediaQuery.of(context).size.height),
            painter: LoadingCurvePainter(isDarkMode),
          ),
          

          // ---------- Main Content ----------
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                   SizedBox(height: 50.h),
                // Logo in the center with soft shadow
                Container(
                  height: 150.h,
                  width: 120.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDarkMode ? Colors.grey[800] : Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: isDarkMode ? Colors.black45 : Colors.black26,
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(10.h),
                    child: Image.asset(
                      'assets/images/FIITJEE_Logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                SizedBox(height: 30.h),

                // Loading Text
                Text(
                  "Loading, please wait...",
                  style: TextStyle(
                    fontSize: 18.sp,
                    color: isDarkMode ? Colors.grey[300] : const Color(0xFFC49B3B),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 20.h),

                // Animated Circular Loader
                 SizedBox(
                  height: 50,
                  width: 50,
                  child: LoadingAnimationWidget.newtonCradle(
                    color: isDarkMode ? Colors.grey[400]! : const Color(0xFFC49B3B),
                      size: 80.h
                    
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ---------- Custom Painter for Background Curves ----------
class LoadingCurvePainter extends CustomPainter {
  final bool isDarkMode;

  LoadingCurvePainter(this.isDarkMode);

  @override
  void paint(Canvas canvas, Size size) {
    // Top gradient curve
    final topPath = Path();
    topPath.lineTo(0, size.height * 0.35);
    topPath.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.40,
      size.width,
      size.height * 0.25,
    );
    topPath.lineTo(size.width, 0);
    topPath.close();

    final topGradient = LinearGradient(
      colors: isDarkMode
          ? [
              Colors.grey[800]!,
              Colors.grey[700]!,
            ]
          : [
              const Color(0xFFC49B3B),
              const Color(0xFFC49B3B),
            ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    final topPaint = Paint()
      ..shader =
          topGradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;
    canvas.drawPath(topPath, topPaint);

    // Bottom gradient curve
    final bottomPath = Path();
    bottomPath.moveTo(0, size.height);
    bottomPath.lineTo(0, size.height * 0.75);
    bottomPath.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.85,
      size.width,
      size.height * 0.7,
    );
    bottomPath.lineTo(size.width, size.height);
    bottomPath.close();

    final bottomGradient = LinearGradient(
      colors: isDarkMode
          ? [
              Colors.grey[700]!.withOpacity(0.9),
              Colors.grey[800]!,
            ]
          : [
              const Color(0xFFC49B3B).withOpacity(0.9),
              const Color(0xFFC49B3B),
            ],
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
    );
    final bottomPaint = Paint()
      ..shader = bottomGradient
          .createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;
    canvas.drawPath(bottomPath, bottomPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
