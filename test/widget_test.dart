import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get_storage/get_storage.dart';

import 'package:grasp_app/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Avoid GetStorage init crash in tests
    await GetStorage.init();
  });

  testWidgets('AdminApp loads without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(AdminApp());

    // Let ScreenUtilInit + routing settle
    await tester.pumpAndSettle();

    // Basic sanity: app mounted
    expect(find.byType(GetMaterialApp), findsOneWidget);
  });
}
