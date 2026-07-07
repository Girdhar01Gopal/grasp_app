import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:grasp_app/Model/librarymodel.dart';
import 'package:grasp_app/infrastructure/routes/admin_routes.dart';
import 'package:grasp_app/screens/image_preview_screen.dart';
import '../controllers/dashboard_controller.dart';
import 'pdf_viewer_screen.dart';

// ── Brand colours ────────────────────────────────────────────────────────────
const _kPrimary     = Color(0xFFC49B3B);
const _kPrimaryDark = Color(0xFFAD8528);
const _kBg          = Color(0xFFF5F6FA);
const _kText        = Color(0xFF1A1D26);
const _kTextSub     = Color(0xFF6B7280);

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: _kBg,
      appBar: _AppBar(),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const _LoadingView();
        }
        return Column(
          children: [
            const _SubjectTabs(),
            Expanded(
              child: RefreshIndicator(
                color: _kPrimary,
                onRefresh: controller.fetchLibrary,
                child: Obx(() {
                  final list = controller.currentLibraries;
                  if (list.isEmpty) return const _EmptyView();

                  final crossAxisCount = isLandscape ? 4 : 2;
                  final aspect       = isLandscape ? 0.82 : 0.72;

                  return GridView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 28.h),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 16.h,
                      crossAxisSpacing: 12.w,
                      childAspectRatio: aspect,
                    ),
                    itemCount: list.length,
                    itemBuilder: (_, i) => _LibraryCard(list[i]),
                  );
                }),
              ),
            ),
          ],
        );
      }),
    );
  }
}

// ── App Bar ──────────────────────────────────────────────────────────────────
class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [_kPrimary, _kPrimaryDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x50C49B3B),
              blurRadius: 14,
              offset: Offset(0, 5),
            ),
          ],
        ),
      ),
      centerTitle: true,
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Text(
            'Libravia',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 18,
              letterSpacing: 0.8,
              color: Colors.white,
            ),
          ),
          // Text(
          //   'Digital Library',
          //   style: TextStyle(
          //     fontSize: 11,
          //     fontWeight: FontWeight.w400,
          //     color: Color(0xFFFFE0A0),
          //     letterSpacing: 0.5,
          //   ),
          // ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () => Get.offAllNamed(AdminRoutes.loginscreen),
          icon: const Icon(Icons.lock_outline_rounded, color: Colors.white),
          tooltip: 'Admin',
        ),
      ],
    );
  }
}

// ── Subject Tabs ─────────────────────────────────────────────────────────────
class _SubjectTabs extends GetView<HomeController> {
  const _SubjectTabs();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final subjects = controller.subjects;
      if (subjects.isEmpty) return const SizedBox.shrink();

      return Container(
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 56.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding:
                    EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                itemCount: subjects.length,
                itemBuilder: (_, i) {
                  final selected = controller.selectedTabIndex.value == i;
                  return GestureDetector(
                    onTap: () => controller.changeTab(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      margin: EdgeInsets.only(right: 10.w),
                      padding: EdgeInsets.symmetric(
                          horizontal: 18.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        gradient: selected
                            ? const LinearGradient(
                                colors: [_kPrimary, _kPrimaryDark],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        color:
                            selected ? null : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: selected
                            ? [
                                BoxShadow(
                                  color: _kPrimary.withValues(alpha: 0.38),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ]
                            : null,
                      ),
                      child: Text(
                        subjects[i],
                        style: TextStyle(
                          color: selected ? Colors.white : _kTextSub,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          fontSize: 6.sp,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const Divider(height: 1, thickness: 1, color: Color(0xFFEEEFF1)),
          ],
        ),
      );
    });
  }
}

// ── Library Card ─────────────────────────────────────────────────────────────
class _LibraryCard extends StatelessWidget {
  final Data item;
  const _LibraryCard(this.item);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    final fileUrl   = controller.buildUrl(item.libraryimg ?? '');
    final isImg     = controller.isImage(fileUrl);
    final isPdf     = controller.isPdf(fileUrl);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          if (isPdf) {
            Get.to(() => PdfViewerScreen(
                  pdfTitle: item.librarytext ?? 'PDF',
                  pdfUrl: fileUrl,
                ));
          } else if (isImg) {
            Get.to(() => ImagePreviewScreen(
                  title: item.librarytext ?? 'Image',
                  imageUrl: fileUrl,
                ));
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.07),
                blurRadius: 18,
                offset: const Offset(0, 5),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Preview ─────────────────────────────────────────────────
              Expanded(
                flex: 6,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16)),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _buildPreview(isImg, isPdf, fileUrl),

                      // Gradient overlay at image bottom
                      Positioned(
                        left: 0, right: 0, bottom: 0,
                        height: 38,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.22),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ),

                      // Type badge
                      Positioned(
                        top: 8, right: 8,
                        child: _TypeBadge(isPdf: isPdf),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Info ─────────────────────────────────────────────────────
              Expanded(
                flex: 4,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(10.w, 8.h, 10.w, 8.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.librarytext ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 6.sp,
                          color: _kText,
                          height: 1.3,
                        ),
                      ),
                      if ((item.subjectName ?? '').isNotEmpty)
                        Row(
                          children: [
                            const Icon(
                              Icons.bookmark_rounded,
                              size: 10,
                              color: _kPrimary,
                            ),
                            SizedBox(width: 4.w),
                            Expanded(
                              child: Text(
                                item.subjectName!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 5.sp,
                                  color: _kTextSub,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
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

  Widget _buildPreview(bool isImg, bool isPdf, String fileUrl) {
    if (isImg) {
      return Image.network(
        fileUrl,
        fit: BoxFit.cover,
        cacheWidth: 600,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            color: const Color(0xFFF3F4F6),
            child: Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: _kPrimary,
                  value: progress.expectedTotalBytes != null
                      ? progress.cumulativeBytesLoaded /
                          progress.expectedTotalBytes!
                      : null,
                ),
              ),
            ),
          );
        },
        errorBuilder: (_, __, ___) => Container(
          color: const Color(0xFFF3F4F6),
          child: const Center(
            child: Icon(
              Icons.broken_image_outlined,
              size: 36,
              color: Color(0xFFBCC1CA),
            ),
          ),
        ),
      );
    }

    // PDF — gradient background
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFF7272), Color(0xFFD32F2F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.picture_as_pdf_rounded,
              size: 40,
              color: Colors.white,
            ),
            SizedBox(height: 6.h),
            Text(
              'PDF Document',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 8.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Type Badge ───────────────────────────────────────────────────────────────
class _TypeBadge extends StatelessWidget {
  final bool isPdf;
  const _TypeBadge({required this.isPdf});

  @override
  Widget build(BuildContext context) {
    final color = isPdf ? const Color(0xFFD32F2F) : const Color(0xFF1E88E5);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.35),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        isPdf ? 'PDF' : 'IMG',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ── Loading ──────────────────────────────────────────────────────────────────
class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: _kPrimary),
          SizedBox(height: 16.h),
          Text(
            'Loading library…',
            style: TextStyle(color: _kTextSub, fontSize: 13.sp),
          ),
        ],
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────
class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: 90.h),
        Icon(
          Icons.library_books_outlined,
          size: 72,
          color: _kPrimary.withValues(alpha: 0.45),
        ),
        SizedBox(height: 20.h),
        Center(
          child: Text(
            'No Files Available',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: _kText,
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Center(
          child: Text(
            'Pull down to refresh',
            style: TextStyle(fontSize: 12.sp, color: _kTextSub),
          ),
        ),
      ],
    );
  }
}
