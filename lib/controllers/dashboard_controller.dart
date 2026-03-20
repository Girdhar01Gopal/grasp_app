import 'dart:convert';
import 'package:get/get.dart';
import 'package:grasp_app/Model/librarymodel.dart';
import 'package:grasp_app/Model/loginviewmodel.dart' hide Data;
import 'package:http/http.dart' as http;
import '../../utils/localstorage.dart';
import '../../utils/prefconst.dart';

class HomeController extends GetxController {
  /// ---------------- STATE ----------------
  final isLoading = true.obs;
  final selectedTabIndex = 0.obs;

  /// Subjects from API
  final subjects = <String>[].obs;

  /// Subject → Library list
  final subjectLibraries = <String, List<Data>>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchLibrary();
  }

  /// ---------------- HELPERS ----------------
  String buildUrl(String path) {
    final p = path.trim();
    if (p.isEmpty) return "";
    // prevent double slashes
    final clean = p.startsWith("/") ? p.substring(1) : p;
    return Uri.encodeFull("https://student.maharishiglobal.org/$clean");
  }

  bool isImage(String? url) {
    if (url == null || url.isEmpty) return false;
    final lower = url.toLowerCase();
    return lower.endsWith(".png") ||
        lower.endsWith(".jpg") ||
        lower.endsWith(".jpeg") ||
        lower.endsWith(".webp");
  }

  bool isPdf(String? url) {
    if (url == null || url.isEmpty) return false;
    return url.toLowerCase().endsWith(".pdf");
  }

  /// ---------------- API CALL ----------------
  Future<void> fetchLibrary() async {
    try {
      isLoading.value = true;

      final schoolId =
          await PrefManager().readValue(key: PrefConst.SchoolId) ?? "0";
      final studentId =
          await PrefManager().readValue(key: PrefConst.StudentId) ?? "0";
      final courseId =
          await PrefManager().readValue(key: PrefConst.CourseId) ?? "0";
final batchid =
          await PrefManager().readValue(key: PrefConst.batchid) ?? "0";

      final url =
          "https://student.maharishiglobal.org/api/MobApp/AppMobLibrary/$schoolId/$studentId/$courseId/$batchid";
print(url);
      final res = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'MobAppStdLabrary': 'MG656-00GGR5-@FGG46-#HH#00-HJFE11',
        },
      );

      if (res.statusCode != 200) {
        Get.snackbar("Error", "API failed (${res.statusCode})");
        return;
      }

      final body = utf8.decode(res.bodyBytes);
      final model = librarymodel.fromJson(jsonDecode(body));
      final data = model.data ?? [];

      /// ---------- GROUP BY SUBJECT ----------
      final Map<String, List<Data>> grouped = {};
      for (final item in data) {
        final subject = (item.subjectName ?? "General").trim();
        grouped.putIfAbsent(subject, () => []);
        grouped[subject]!.add(item);
      }

      /// update reactive maps/lists
      subjectLibraries.value = grouped;
      subjects.value = grouped.keys.toList();

      /// ✅ FIX: keep selected index valid after refresh / API change
      if (subjects.isEmpty) {
        selectedTabIndex.value = 0;
      } else if (selectedTabIndex.value >= subjects.length) {
        selectedTabIndex.value = 0;
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to load library");
    } finally {
      isLoading.value = false;
    }
  }

  /// ---------------- TAB CHANGE ----------------
  void changeTab(int index) {
    if (index < 0 || index >= subjects.length) return;
    selectedTabIndex.value = index;
  }

  /// ---------------- CURRENT LIST ----------------
  List<Data> get currentLibraries {
    if (subjects.isEmpty) return const [];
    final key = subjects[selectedTabIndex.value];
    return subjectLibraries[key] ?? const [];
  }
}
