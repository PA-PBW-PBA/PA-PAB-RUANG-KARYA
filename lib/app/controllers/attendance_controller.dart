import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/attendance_model.dart';

class AttendanceController extends GetxController {
  final _supabase = Supabase.instance.client;

  final isLoading = false.obs;
  final myAttendances = <AttendanceModel>[].obs;

  final attendanceMap = <String, String>{}.obs;

  int get totalEvents => myAttendances.length;

  int get totalHadir => myAttendances.where((a) => a.isHadir).length;

  int get attendancePercentage =>
      totalEvents == 0 ? 0 : ((totalHadir / totalEvents) * 100).round();

  int get hadirCount => attendanceMap.values.where((s) => s == 'hadir').length;

  @override
  void onInit() {
    super.onInit();
    fetchMyAttendances();
  }

  Future<void> fetchMyAttendances() async {
    isLoading.value = true;
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final response = await _supabase
          .from('attendances')
          .select('*, events(title)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      myAttendances.value = response
          .map<AttendanceModel>((json) => AttendanceModel.fromJson(json))
          .toList();
    } catch (e) {
      Get.snackbar('Gagal', 'Gagal memuat riwayat absensi');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchMemberAttendances(String userId) async {
    isLoading.value = true;
    try {
      final response = await _supabase
          .from('attendances')
          .select('*, events(title)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      myAttendances.value = response
          .map<AttendanceModel>((json) => AttendanceModel.fromJson(json))
          .toList();
    } catch (e) {
      Get.snackbar('Gagal', 'Gagal memuat riwayat absensi anggota.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadAttendanceForEvent(String eventId) async {
    isLoading.value = true;
    attendanceMap.clear();

    try {
      final response =
          await _supabase.from('attendances').select().eq('event_id', eventId);

      for (final item in response) {
        attendanceMap[item['user_id']] = item['status'];
      }
    } catch (e) {
      Get.snackbar('Gagal', 'Gagal memuat riwayat absensi');
    } finally {
      isLoading.value = false;
    }
  }

  String getStatus(String userId) {
    return attendanceMap[userId] ?? 'tidak_hadir';
  }

  void setStatus(String userId, String status) {
    attendanceMap[userId] = status;
  }

  Future<void> saveAttendance(String eventId) async {
    isLoading.value = true;
    try {
      final adminId = _supabase.auth.currentUser?.id;
      if (adminId == null) throw Exception('User tidak ditemukan');

      await _supabase.from('attendances').delete().eq('event_id', eventId);

      if (attendanceMap.isEmpty) return;

      final rows = attendanceMap.entries
          .map((entry) => {
                'event_id': eventId,
                'user_id': entry.key,
                'status': entry.value,
                'created_by': adminId,
              })
          .toList();

      await _supabase.from('attendances').insert(rows);

      Get.back();
      Get.snackbar('Berhasil', 'Absensi berhasil disimpan');
    } catch (e) {
      Get.snackbar('Gagal', 'Gagal menyimpan absensi');
    } finally {
      isLoading.value = false;
    }
  }
}
