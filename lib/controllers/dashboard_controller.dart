import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart' hide Data;
import 'package:grasp_app/Model/librarymodel.dart';
import 'package:grasp_app/Model/loginviewmodel.dart' hide Data;
import 'package:http/http.dart' as http;
import '../../utils/localstorage.dart';
import '../../utils/prefconst.dart';

class HomeController extends GetxController {
  static const String _libraryCachePrefix = 'cached_library_response';

  /// ---------------- STATE ----------------
  final isLoading = true.obs;
  final selectedTabIndex = 0.obs;

  /// Subjects from API
  final subjects = <String>[].obs;

  /// Subject → Library list
  final subjectLibraries = <String, List<Data>>{}.obs;

  final GetStorage _storage = GetStorage();

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
    return Uri.encodeFull("https://student.maharishiglobal.in/$clean");
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

  String _libraryCacheKey(
    String schoolId,
    String studentId,
    String courseId,
    String batchId,
  ) {
    return '${_libraryCachePrefix}_s${schoolId}_st${studentId}_c${courseId}_b${batchId}';
  }

  bool _hasConnection(dynamic connectivityResult) {
    if (connectivityResult is List<ConnectivityResult>) {
      return connectivityResult.any(
        (result) => result != ConnectivityResult.none,
      );
    }

    return connectivityResult != ConnectivityResult.none;
  }

  void _applyLibraryData(String body) {
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

    /// keep selected index valid after refresh / API change
    if (subjects.isEmpty) {
      selectedTabIndex.value = 0;
    } else if (selectedTabIndex.value >= subjects.length) {
      selectedTabIndex.value = 0;
    }
  }

  bool _loadCachedLibrary(String cacheKey) {
    final cachedBody = _storage.read(cacheKey);
    if (cachedBody is! String || cachedBody.isEmpty) {
      return false;
    }

    _applyLibraryData(cachedBody);
    return true;
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

      final cacheKey = _libraryCacheKey(
        schoolId.toString(),
        studentId.toString(),
        courseId.toString(),
        batchid.toString(),
      );

      final connectivityResult = await Connectivity().checkConnectivity();
      final hasConnection = _hasConnection(connectivityResult);

      if (!hasConnection) {
        if (_loadCachedLibrary(cacheKey)) {
          return;
        }

        Get.snackbar("Offline", "No saved files are available yet.");
        return;
      }

      final url =
          "https://student.maharishiglobal.in/api/MobApp/AppMobLibrary/$schoolId/$studentId/$courseId/$batchid";
      print(url);
      final res = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'MobAppStdLabrary': 'MG656-00GGR5-@FGG46-#HH#00-HJFE11',
        },
      );

      if (res.statusCode != 200) {
        if (_loadCachedLibrary(cacheKey)) {
          return;
        }

        Get.snackbar("Error", "API failed (${res.statusCode})");
        return;
      }

      final body = utf8.decode(res.bodyBytes);
      await _storage.write(cacheKey, body);
      _applyLibraryData(body);
    } catch (e) {
      final schoolId =
          await PrefManager().readValue(key: PrefConst.SchoolId) ?? "0";
      final studentId =
          await PrefManager().readValue(key: PrefConst.StudentId) ?? "0";
      final courseId =
          await PrefManager().readValue(key: PrefConst.CourseId) ?? "0";
      final batchid =
          await PrefManager().readValue(key: PrefConst.batchid) ?? "0";

      final cacheKey = _libraryCacheKey(
        schoolId.toString(),
        studentId.toString(),
        courseId.toString(),
        batchid.toString(),
      );

      if (_loadCachedLibrary(cacheKey)) {
        return;
      }

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
