import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../controllers/auth_controller.dart';
import '../routes/app_routes.dart';

class AuthMiddleware extends GetMiddleware {
  /// null  → cukup harus login
  /// 'admin' → harus admin ATAU bph
  /// 'admin_only' → harus admin penuh (untuk halaman keuangan)
  final String? requiredRole;

  AuthMiddleware({this.requiredRole});

  @override
  RouteSettings? redirect(String? route) {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) return const RouteSettings(name: AppRoutes.login);
    if (requiredRole == null) return null;

    final authController = Get.find<AuthController>();
    final user = authController.currentUser.value;
    if (user == null) return null;

    if (!user.isActive) return const RouteSettings(name: AppRoutes.login);

    switch (requiredRole) {
      case 'admin':
        // Izinkan admin dan bph
        if (!user.canAccessAdmin) {
          return const RouteSettings(name: AppRoutes.homeMember);
        }
        break;
      case 'admin_only':
        // Hanya admin penuh (untuk keuangan)
        if (!user.isAdmin) {
          return const RouteSettings(name: AppRoutes.dashboardAdmin);
        }
        break;
    }

    return null;
  }
}
