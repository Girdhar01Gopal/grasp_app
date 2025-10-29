import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../infrastructure/routes/admin_routes.dart';
import '../../utils/constants/color_constants.dart';

class AdminDrawer2 extends StatefulWidget {
  @override
  _AdminDrawer2State createState() => _AdminDrawer2State();
}

class _AdminDrawer2State extends State<AdminDrawer2> {
  String? hoveredRoute;

  @override
  Widget build(BuildContext context) {
    final currentRoute = Get.currentRoute;

    // Optional: clamp text scale to prevent huge accessibility text breaking layout
    final media = MediaQuery.of(context);
    final clampedTextScale = media.textScaleFactor.clamp(1.0, 1.2);

    return MediaQuery(
      data: media.copyWith(textScaleFactor: clampedTextScale),
      child: SafeArea(
        child: Drawer(
          backgroundColor: Colors.white,
          child: Column(
            children: [
              /// ===== Custom Header (Minimal & Overflow-Safe) =====
              SizedBox(
                height: 150.h,
                width: double.infinity,
                child: Container(
                  clipBehavior: Clip.antiAlias, // <- prevent painted overflow
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF0D1B2A), Color(0xFF1B263B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    image: DecorationImage(
                      image: AssetImage('assets/images/drawer_bg_pattern.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: LayoutBuilder(
                    builder: (ctx, constraints) {
                      final headerW = constraints.maxWidth;
                      final headerH = constraints.maxHeight;

                      // Size the diagonal band relative to header size so it never overflows its clip
                      final bandW = headerW * 0.75;
                      final bandH = headerH * 1.6;

                      return Stack(
                        children: [
                          Align(
                            alignment: Alignment.topRight,
                            child: Transform.rotate(
                              angle: -0.4,
                              child: SizedBox(
                                width: bandW,
                                height: bandH,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Minimal Center Text (kept empty as per your latest)
                          // You can uncomment if needed:
                          // Center(
                          //   child: Text(
                          //     'MENU',
                          //     style: TextStyle(
                          //       color: Colors.white,
                          //       fontSize: 22.sp,
                          //       fontWeight: FontWeight.bold,
                          //       letterSpacing: 1.2,
                          //     ),
                          //   ),
                          // ),
                        ],
                      );
                    },
                  ),
                ),
              ),

              /// ===== Drawer Items =====
              Expanded(
                child: Container(
                  color: Colors.white,
                  child: ListView(
                    padding: EdgeInsets.symmetric(vertical: 6.h), // small breathing room
                    children: [
                      _buildDrawerItem(
                        "Reset",
                        Icons.refresh,
                        AdminRoutes.LOADING_SCREEN,
                        currentRoute,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ===== Drawer Item Widget =====
  Widget _buildDrawerItem(
      String title,
      IconData icon,
      String route,
      String currentRoute, {
        bool isLogout = false,
      }) {
    final isSelected = currentRoute == route;
    final isHovered = hoveredRoute == route;

    return MouseRegion(
      onEnter: (_) => setState(() => hoveredRoute = route),
      onExit: (_) => setState(() => hoveredRoute = null),
      child: Container(
        color: isSelected
            ? AppColor.grey_200
            : isHovered
            ? AppColor.grey_100
            : null,
        child: ListTile(
          dense: true, // <- reduces tile height; helps on small screens
          minLeadingWidth: 20, // <- avoids large gaps that may push text
          horizontalTitleGap: 12,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
          leading: Icon(
            icon,
            size: 22, // slightly smaller, safer on compact widths
            color: isLogout
                ? Colors.red
                : isSelected
                ? AppColor.APP_Color_Indigo
                : isHovered
                ? AppColor.APP_Color_Pink
                : Colors.grey.shade800,
          ),
          title: Text(
            title,
            maxLines: 1, // <- prevent multi-line overflow
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14.sp, // responsive text
              color: isLogout
                  ? Colors.red
                  : isSelected
                  ? AppColor.APP_Color_Indigo
                  : isHovered
                  ? AppColor.APP_Color_Pink
                  : Colors.black,
              fontWeight: isLogout || isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
          onTap: () {
            if (isLogout) {
              GetStorage().erase();
              Get.offAllNamed(AdminRoutes.LOADING_SCREEN);
            } else if (!isSelected) {
              Get.toNamed(route);
            } else {
              Get.back();
            }
          },
        ),
      ),
    );
  }
}
