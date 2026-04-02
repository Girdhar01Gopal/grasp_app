import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:grasp_app/Model/librarymodel.dart';
import 'package:grasp_app/infrastructure/routes/admin_routes.dart';
import 'package:grasp_app/screens/image_preview_screen.dart';
import '../controllers/dashboard_controller.dart';
import 'pdf_viewer_screen.dart';
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),

      /// ---------------- APP BAR ----------------
      appBar: AppBar(
        backgroundColor: const Color(0xFFC49B3B),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Libravia",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            letterSpacing: .5,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: (){
               Get.offAllNamed(AdminRoutes.loginscreen);
            },
            icon: const Icon(Icons.lock, color: Colors.white),
          ),
        ],
      ),

      body: Stack(
        children: [
          /// ---------------- BACKGROUND IMAGE ----------------
          Positioned.fill(
            child: Opacity(
              opacity: 0.08,
              child: Image.asset(
                "assets/images/FIITJEE_Logo.png",
                fit: BoxFit.cover,
              ),
            ),
          ),

          /// ---------------- MAIN CONTENT ----------------
          Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            return Column(
              children: [
                /// SUBJECT TABS
                const _SubjectTabs(),

                /// GRID + REFRESH
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: controller.fetchLibrary,
                    child: Obx(() {
                      final list = controller.currentLibraries;

                      if (list.isEmpty) {
                        return ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: const [
                            SizedBox(height: 250),
                            Center(
                              child: Text(
                                "No Library Files Found",
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        );
                      }

                      final crossAxisCount = isLandscape ? 5 : 2;
                      final aspect = isLandscape ? 1.15 : 0.82;

                      return GridView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.all(16.w),
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: aspect,
                        ),
                        itemCount: list.length,
                        itemBuilder: (_, i) => _ProfessionalLibraryCard(list[i]),
                      );
                    }),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _SubjectTabs extends GetView<HomeController> {
  const _SubjectTabs();

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Obx(() {
      final subjects = controller.subjects;

      if (subjects.isEmpty) {
        return SizedBox(height: isLandscape ? 56.h : 70.h);
      }

      return SizedBox(
        height: isLandscape ? 76.h : 70.h,
        child: ListView.builder(
          key: ValueKey('${subjects.length}_${controller.selectedTabIndex.value}'),
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          itemCount: subjects.length,
          itemBuilder: (_, i) {
            final selected = controller.selectedTabIndex.value == i;
            return GestureDetector(
              onTap: () => controller.changeTab(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                margin: EdgeInsets.only(right: 12.w),
                padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: selected ? const Color(0xFFC49B3B) : Colors.white,
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(color: const Color(0xFFC49B3B)),
                  boxShadow: [
                    if (selected)
                      BoxShadow(
                        color: const Color(0xFFC49B3B).withOpacity(.35),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                  ],
                ),
                child: Center(
                  child: Text(
                    subjects[i],
                    style: TextStyle(
                      color: selected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w700,
                      fontSize: 6.sp,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }
}

class _ProfessionalLibraryCard extends StatelessWidget {
  final Data item;
  const _ProfessionalLibraryCard(this.item);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    final fileUrl = controller.buildUrl(item.libraryimg ?? "");
    final isImg = controller.isImage(fileUrl);
    final isPdf = controller.isPdf(fileUrl);

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        if (isPdf) {
          Get.to(() => PdfViewerScreen(
                pdfTitle: item.librarytext ?? "PDF",
                pdfUrl: fileUrl,
              ));
        } else if (isImg) {
          Get.to(() => ImagePreviewScreen(
                title: item.librarytext ?? "Image",
                imageUrl: fileUrl,
              ));
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ---------- PREVIEW ----------
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(18)),
                    child: isImg
                        ? Image.network(
                            fileUrl,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            cacheWidth: 700,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: const Color(0xFFF1F3F6),
                                child: const Center(
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              );
                            },
                            errorBuilder: (_, __, ___) => Container(
                              color: const Color(0xFFF1F3F6),
                              child: const Center(
                                child: Icon(Icons.broken_image,
                                    size: 30, color: Colors.grey),
                              ),
                            ),
                          )
                        : Container(
                            color: const Color(0xFFF1F3F6),
                            child: const Center(
                              child: Icon(
                                Icons.picture_as_pdf,
                                size: 44,
                                color: Colors.red,
                              ),
                            ),
                          ),
                  ),

                  /// File type badge
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isPdf ? Colors.red : Colors.blue,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isPdf ? "PDF" : "IMG",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 7,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            /// ---------- TITLE ----------
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Text(
                item.librarytext ?? "",
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 7.sp,
                  height: 1.3,
                ),
              ),
            ),

            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }
}