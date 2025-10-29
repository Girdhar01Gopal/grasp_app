import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';
import '../../infrastructure/app_drawer/admin_drawer2.dart';
import '../screens/pdf_viewer_screen.dart'; // ✅ import the new PDF screen

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.put(HomeController());
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

    ScreenUtil.init(context, designSize: const Size(375, 812), minTextAdapt: true);

    return Scaffold(
      key: _scaffoldKey,
      drawer: AdminDrawer2(),
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFE53935),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.notes, color: Colors.white, size: 28),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: const Text(
          'DIGIPACK',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.5,
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: RichText(
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: 'e',
                    style: TextStyle(
                      color: Colors.indigo,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      letterSpacing: 1.2,
                    ),
                  ),
                  TextSpan(
                    text: 'CM',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background_image_grasp.png',
              fit: BoxFit.cover,
            ),
          ),

          Column(
            children: [
              SizedBox(height: 12.h),

              /// 🔹 Subject Tabs
              Obx(() {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  child: Row(
                    children: List.generate(controller.subjects.length, (index) {
                      final isSelected = controller.selectedTabIndex.value == index;
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        child: GestureDetector(
                          onTap: () => controller.changeTab(index),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 10.h),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.red : Colors.white,
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(color: Colors.red, width: 1.5),
                            ),
                            child: Text(
                              controller.subjects[index],
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black87,
                                fontWeight: FontWeight.bold,
                                fontSize: 15.sp,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                );
              }),

              SizedBox(height: 20.h),

              /// 🔹 Tab Content
              Expanded(
                child: Obx(() {
                  final selected = controller.selectedTabIndex.value;

                  if (selected == 0) {
                    return _subjectSection(
                      color: Colors.blue.shade700,
                      shortCode: "CHEM",
                      cards: [
                        {"title": "ARCHIVES-2023-24-ADVANCE-CHEMISTRY", "date": "2023-08-13"},
                        {"title": "ARCHIVE-JEE-MAIN-2023-24-CHEMISTRY", "date": "2023-07-25"},
                      ],
                    );
                  } else if (selected == 1) {
                    return _subjectSection(
                      color: Colors.deepPurple,
                      shortCode: "PHY",
                      cards: [
                        {"title": "ARCHIVES-2023-24-ADVANCE-PHYSICS", "date": "2023-08-13"},
                        {"title": "ARCHIVE-JEE-MAIN-2023-24-PHYSICS", "date": "2023-07-25"},
                      ],
                    );
                  } else {
                    return _subjectSection(
                      color: Colors.amber.shade800,
                      shortCode: "MATHS",
                      cards: [
                        {"title": "ARCHIVE-JEE-MAIN-2023-24-MATHEMATICS", "date": "2023-07-25"},
                        {"title": "ARCHIVES-2023-24-ADVANCE-MATHEMATICS", "date": "2023-08-19"},
                      ],
                    );
                  }
                }),
              ),

              /// 🔹 Footer
              Container(height: 25.h, color: Colors.white),
              Container(
                height: 80.h,
                width: double.infinity,
                color: Colors.blue.shade700,
                padding: EdgeInsets.symmetric(horizontal: 18.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text("eCM",
                        style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w500)),
                    Text("FIITJEE",
                        style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 🔹 Subject Section
  Widget _subjectSection({
    required Color color,
    required String shortCode,
    required List<Map<String, String>> cards,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: SingleChildScrollView(
        child: Wrap(
          spacing: 20.w,
          runSpacing: 20.h,
          alignment: WrapAlignment.center,
          children: cards.map((data) {
            return SizedBox(
              width: 0.38.sw,
              height: 0.25.sh,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: color.withOpacity(0.95),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 6,
                  shadowColor: Colors.black26,
                  padding: EdgeInsets.all(12.w),
                ),
                onPressed: () => _openPdf(data["title"]!, data["date"]!),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Text(shortCode,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 22.sp,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2)),
                        SizedBox(height: 8.h),
                        Text(data["title"]!,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontSize: 13.sp, height: 1.3)),
                      ],
                    ),
                    Text(data["date"]!,
                        style: TextStyle(color: Colors.white70, fontSize: 13.sp, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  /// 🔹 Opens the PDF viewer screen
  void _openPdf(String title, String date) {
    Get.to(() => PdfViewerScreen(
      pdfTitle: title,
      pdfUrl: "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf",
    ));
  }
}
