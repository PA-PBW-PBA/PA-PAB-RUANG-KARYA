import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/controllers/auth_controller.dart';
<<<<<<< HEAD
import 'app/controllers/app_config_controller.dart';
=======
import 'app/controllers/app_config_controller.dart'; // Tambahkan import ini
>>>>>>> 760f72503b73442f7fa98adaeac9561a97b81f1b
import 'app/routes/app_pages.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  }

<<<<<<< HEAD
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
=======
  await dotenv.load(fileName: '.env');
  await GetStorage.init();

  final supabaseUrl =
      dotenv.env['SUPABASE_URL'] ?? 'https://placeholder.supabase.co';
  final supabaseKey = dotenv.env['SUPABASE_ANON_KEY'] ?? 'placeholder-key';

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseKey,
  );

  // Inisialisasi Controller agar data config siap saat app terbuka
  Get.put(AppConfigController(), permanent: true);

  if (!kIsWeb) {
    FlutterNativeSplash.remove();
  }
>>>>>>> 760f72503b73442f7fa98adaeac9561a97b81f1b

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
=======
    // AuthController tetap diinisialisasi di sini atau di main sama saja
    Get.put(AuthController(), permanent: true);

>>>>>>> 760f72503b73442f7fa98adaeac9561a97b81f1b
    return GetMaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
<<<<<<< HEAD
      themeMode: ThemeMode.light,
=======
      themeMode: ThemeMode.light, // Selalu light mode
>>>>>>> 760f72503b73442f7fa98adaeac9561a97b81f1b
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
    );
  }
<<<<<<< HEAD
}
=======
}
>>>>>>> 760f72503b73442f7fa98adaeac9561a97b81f1b
