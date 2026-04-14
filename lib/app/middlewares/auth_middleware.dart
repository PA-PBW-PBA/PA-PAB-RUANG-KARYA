import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../controllers/auth_controller.dart';
import '../routes/app_routes.dart';

class AuthMiddleware extends GetMiddleware {
  final String? requiredRole;

  AuthMiddleware({this.requiredRole});

  @override
  RouteSettings? redirect(String? route) {
    final session = Supabase.instance.client.auth.currentSession;

    // belum login sama sekali
    if (session == null) {
      return const RouteSettings(name: AppRoutes.login);
    }

    // kalau tidak ada role yang disyaratkan, cukup cek login saja
    if (requiredRole == null) return null;

    // ambil role dari AuthController yang sudah load dari tabel profiles
    final authController = Get.find<AuthController>();
    final user = authController.currentUser.value;

    // kalau user belum terload, biarkan lewat dulu
    // auth_controller akan handle redirect yang benar
    if (user == null) return null;

    // user dinonaktifkan
    if (!user.isActive) {
      return const RouteSettings(name: AppRoutes.login);
    }

    // cek role
    if (user.role != requiredRole) {
      if (user.isAdmin) {
        return const RouteSettings(name: AppRoutes.dashboardAdmin);
      } else {
        return const RouteSettings(name: AppRoutes.homeMember);
      }
    }

    return null;
  }
}
