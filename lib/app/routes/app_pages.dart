import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/member_controller.dart';
import '../controllers/event_controller.dart';
import '../controllers/gallery_controller.dart';
import '../controllers/kas_controller.dart';
import '../controllers/attendance_controller.dart';
import '../middlewares/auth_middleware.dart';
import '../views/splash/splash_page.dart';
import '../views/visitor/home_visitor_page.dart';
import '../views/visitor/event_visitor_page.dart';
import '../views/visitor/event_detail_page.dart';
import '../views/visitor/gallery_visitor_page.dart';
import '../views/visitor/division_info_page.dart';
import '../views/auth/login_page.dart';
import '../views/auth/change_password_page.dart';
import '../views/member/home_member_page.dart';
import '../views/member/event_member_page.dart';
import '../views/member/attendance_history_page.dart';
import '../views/member/gallery_member_page.dart';
import '../views/member/profile_member_page.dart';
import '../views/member/member_list_readonly_page.dart';
import '../views/admin/dashboard_admin_page.dart';
import '../views/admin/member_list_page.dart';
import '../views/admin/member_form_page.dart';
import '../views/admin/event_list_page.dart';
import '../views/admin/event_form_page.dart';
import '../views/admin/attendance_input_page.dart';
import '../views/admin/gallery_admin_page.dart';
import '../views/admin/kas_page.dart';
import '../views/admin/kas_form_page.dart';
import '../views/admin/profile_admin_page.dart';
import '../views/admin/member_detail_page.dart';
import 'app_routes.dart';

class AppPages {
  static const initial = AppRoutes.splash;

  static final routes = [
    // ── Splash ─────────────────────────────────────────────────
    GetPage(name: AppRoutes.splash, page: () => const SplashPage()),

    // ── Visitor ────────────────────────────────────────────────
    GetPage(
      name: AppRoutes.homeVisitor,
      page: () => const HomeVisitorPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => EventController());
        Get.lazyPut(() => GalleryController());
      }),
    ),
    GetPage(
      name: AppRoutes.eventVisitor,
      page: () => const EventVisitorPage(),
      binding: BindingsBuilder(() => Get.lazyPut(() => EventController())),
    ),
    GetPage(name: AppRoutes.eventDetail, page: () => const EventDetailPage()),
    GetPage(
      name: AppRoutes.galleryVisitor,
      page: () => const GalleryVisitorPage(),
      binding: BindingsBuilder(() => Get.lazyPut(() => GalleryController())),
    ),
    GetPage(name: AppRoutes.divisionInfo, page: () => const DivisionInfoPage()),

    // ── Auth ───────────────────────────────────────────────────
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginPage(),
      binding: BindingsBuilder(() => Get.lazyPut(() => AuthController())),
    ),
    GetPage(
      name: AppRoutes.changePassword,
      page: () => const ChangePasswordPage(),
      middlewares: [AuthMiddleware()],
      binding: BindingsBuilder(() => Get.lazyPut(() => AuthController())),
    ),

    // ── Member ─────────────────────────────────────────────────
    GetPage(
      name: AppRoutes.homeMember,
      page: () => const HomeMemberPage(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.eventMember,
      page: () => const EventMemberPage(),
      middlewares: [AuthMiddleware()],
      binding: BindingsBuilder(() => Get.lazyPut(() => EventController())),
    ),
    GetPage(
      name: AppRoutes.attendanceHistory,
      page: () => const AttendanceHistoryPage(),
      middlewares: [AuthMiddleware()],
      binding: BindingsBuilder(() => Get.lazyPut(() => AttendanceController())),
    ),
    GetPage(
      name: AppRoutes.galleryMember,
      page: () => const GalleryMemberPage(),
      middlewares: [AuthMiddleware()],
      binding: BindingsBuilder(() => Get.lazyPut(() => GalleryController())),
    ),
    GetPage(
      name: AppRoutes.profileMember,
      page: () => const ProfileMemberPage(),
      middlewares: [AuthMiddleware()],
      binding: BindingsBuilder(() => Get.lazyPut(() => AuthController())),
    ),
    GetPage(
      name: AppRoutes.memberListReadonly,
      page: () => const MemberListReadonlyPage(),
      middlewares: [AuthMiddleware()],
      binding: BindingsBuilder(() => Get.lazyPut(() => MemberController())),
    ),

    // ── Admin & BPH (requiredRole: 'admin') ────────────────────
    GetPage(
      name: AppRoutes.dashboardAdmin,
      page: () => const DashboardAdminPage(),
      middlewares: [AuthMiddleware(requiredRole: 'admin')],
      binding: BindingsBuilder(() {
        Get.lazyPut(() => MemberController());
        Get.lazyPut(() => EventController());
        Get.lazyPut(() => KasController());
      }),
    ),
    GetPage(
      name: AppRoutes.memberList,
      page: () => const MemberListPage(),
      middlewares: [AuthMiddleware(requiredRole: 'admin')],
      binding: BindingsBuilder(() => Get.lazyPut(() => MemberController())),
    ),
    GetPage(
      name: AppRoutes.memberForm,
      page: () => const MemberFormPage(),
      middlewares: [AuthMiddleware(requiredRole: 'admin')],
      binding: BindingsBuilder(() => Get.lazyPut(() => MemberController())),
    ),
    GetPage(
      name: AppRoutes.memberDetail,
      page: () => const MemberDetailPage(),
      middlewares: [AuthMiddleware(requiredRole: 'admin')],
      binding: BindingsBuilder(() {
        Get.lazyPut(() => MemberController());
        Get.lazyPut(() => AttendanceController());
      }),
    ),
    GetPage(
      name: AppRoutes.eventList,
      page: () => const EventListPage(),
      middlewares: [AuthMiddleware(requiredRole: 'admin')],
      binding: BindingsBuilder(() => Get.lazyPut(() => EventController())),
    ),
    GetPage(
      name: AppRoutes.eventForm,
      page: () => const EventFormPage(),
      middlewares: [AuthMiddleware(requiredRole: 'admin')],
      binding: BindingsBuilder(() => Get.lazyPut(() => EventController())),
    ),
    GetPage(
      name: AppRoutes.attendanceInput,
      page: () => const AttendanceInputPage(),
      middlewares: [AuthMiddleware(requiredRole: 'admin')],
      binding: BindingsBuilder(() {
        Get.lazyPut(() => AttendanceController());
        Get.lazyPut(() => MemberController());
      }),
    ),
    GetPage(
      name: AppRoutes.galleryAdmin,
      page: () => const GalleryAdminPage(),
      middlewares: [AuthMiddleware(requiredRole: 'admin')],
      binding: BindingsBuilder(() => Get.lazyPut(() => GalleryController())),
    ),
    GetPage(
      name: AppRoutes.profileAdmin,
      page: () => const ProfileAdminPage(),
      middlewares: [AuthMiddleware(requiredRole: 'admin')],
    ),

    // ── Keuangan — hanya admin penuh (requiredRole: 'admin_only') ──
    GetPage(
      name: AppRoutes.kasPage,
      page: () => const KasPage(),
      middlewares: [AuthMiddleware(requiredRole: 'admin_only')],
      binding: BindingsBuilder(() => Get.lazyPut(() => KasController())),
    ),
    GetPage(
      name: AppRoutes.kasForm,
      page: () => const KasFormPage(),
      middlewares: [AuthMiddleware(requiredRole: 'admin_only')],
      binding: BindingsBuilder(() => Get.lazyPut(() => KasController())),
    ),
  ];
}
