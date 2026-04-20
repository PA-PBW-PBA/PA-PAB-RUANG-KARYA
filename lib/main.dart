import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/controllers/auth_controller.dart';
import 'app/controllers/app_config_controller.dart';
import 'app/routes/app_pages.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  }

  try {
    await dotenv.load(fileName: '.env');
    debugPrint('dotenv loaded');
  } catch (e) {
    debugPrint('dotenv gagal dimuat: $e');
  }

  try {
    await GetStorage.init();
    debugPrint('get_storage loaded');
  } catch (e) {
    debugPrint('get_storage gagal: $e');
  }

  final supabaseUrl =
      dotenv.env['SUPABASE_URL'] ?? 'https://placeholder.supabase.co';
  final supabaseKey =
      dotenv.env['SUPABASE_ANON_KEY'] ?? 'placeholder-key';

  try {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseKey,
    );
    debugPrint('supabase initialized');
  } catch (e) {
    debugPrint('supabase gagal init: $e');
  }

  Get.put(AppConfigController(), permanent: true);
  Get.put(AuthController(), permanent: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      themeMode: ThemeMode.light,
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
    );
  }
}