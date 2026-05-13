import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ============================================================
// BACKGROUND HANDLER — harus top-level function (di luar class)
// ============================================================
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('[FCM Background] ${message.notification?.title}');
}

// ============================================================
// NOTIFICATION SERVICE
// ============================================================
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _fcm = FirebaseMessaging.instance;
  final _supabase = Supabase.instance.client;
  final _localNotif = FlutterLocalNotificationsPlugin();

  static const _androidChannel = AndroidNotificationChannel(
    'ruangkarya_channel',
    'Ruang Karya Notifikasi',
    description: 'Notifikasi kegiatan dan pengumuman Ruang Karya',
    importance: Importance.max,
    playSound: true,
  );

  // ============================================================
  // INIT — dipanggil sekali di main.dart
  // ============================================================
  Future<void> initialize() async {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _localNotif.initialize(
      settings: const InitializationSettings(
        android: androidInit,
        iOS: iosInit,
      ),
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle tap notifikasi saat app foreground
        final payload = response.payload;
        if (payload == 'new_event') {
          Get.toNamed('/event-list');
        }
      },
    );

    await _localNotif
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_androidChannel);

    await _requestPermission();

    // Foreground: tampilkan pakai local notifications
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Background → foreground (tap notif)
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Terminated → dibuka via notif
    final initial = await _fcm.getInitialMessage();
    if (initial != null) _handleNotificationTap(initial);

    debugPrint('[FCM] NotificationService initialized');
  }

  Future<void> _requestPermission() async {
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint('[FCM] Permission: ${settings.authorizationStatus}');
  }

  // ============================================================
  // SIMPAN TOKEN — panggil setelah login berhasil
  // ============================================================
  Future<void> saveTokenToSupabase(String userId) async {
    try {
      final token = await _fcm.getToken();
      if (token == null) return;

      await _supabase
          .from('profiles')
          .update({'fcm_token': token}).eq('id', userId);

      // Auto-refresh token jika FCM generate yang baru
      _fcm.onTokenRefresh.listen((newToken) async {
        await _supabase
            .from('profiles')
            .update({'fcm_token': newToken}).eq('id', userId);
        debugPrint('[FCM] Token refreshed');
      });

      debugPrint('[FCM] Token saved');
    } catch (e) {
      debugPrint('[FCM] Failed to save token: $e');
    }
  }

  // ============================================================
  // HAPUS TOKEN — panggil saat logout
  // ============================================================
  Future<void> clearToken(String userId) async {
    try {
      await _supabase
          .from('profiles')
          .update({'fcm_token': null}).eq('id', userId);
      await _fcm.deleteToken();
      debugPrint('[FCM] Token cleared');
    } catch (e) {
      debugPrint('[FCM] Failed to clear token: $e');
    }
  }

  // ============================================================
  // FOREGROUND NOTIFICATION
  // ============================================================
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final notif = message.notification;
    if (notif == null) return;

    final type = message.data['type'] ?? '';

    await _localNotif.show(
      id: notif.hashCode,
      title: notif.title,
      body: notif.body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: type,
    );
  }

  // ============================================================
  // TAP NOTIFIKASI → NAVIGASI
  // ============================================================
  void _handleNotificationTap(RemoteMessage message) {
    final type = message.data['type'];
    if (type == 'new_event') {
      Get.toNamed('/event-list');
    }
  }

  // ============================================================
  // KIRIM NOTIF VIA SUPABASE EDGE FUNCTION
  // ============================================================
  Future<bool> sendEventNotification({
    required String eventTitle,
    required String location,
    required String eventId,
  }) async {
    try {
      await _supabase.functions.invoke(
        'send-notification',
        body: {
          'title': 'Kegiatan Baru 📅',
          'body': '$eventTitle · $location',
          'data': {
            'type': 'new_event',
            'event_id': eventId,
          },
        },
      );
      return true;
    } catch (e) {
      debugPrint('[FCM] Failed to send notification: $e');
      return false;
    }
  }
}
