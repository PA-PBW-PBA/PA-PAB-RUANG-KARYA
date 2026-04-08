import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/event_model.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../routes/app_routes.dart';

class EventController extends GetxController {
  final _supabase = Supabase.instance.client;

  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final events = <EventModel>[].obs;
  final filteredEvents = <EventModel>[].obs;
  final searchQuery = ''.obs;
  final selectedDivision = 'Semua'.obs;
  final selectedDay = Rxn<DateTime>();
  final focusedDay = DateTime.now().obs;
  final activeTab = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchEvents();
    _setupRealtimeListener();
    selectedDay.value = DateTime.now();
    ever(searchQuery, (_) => _applyFilter());
    ever(selectedDivision, (_) => _applyFilter());
    ever(selectedDay, (_) => _applyFilter());
  }

  void _setupRealtimeListener() {
    _supabase
        .from('events')
        .stream(primaryKey: ['id'])
        .listen((data) {
          // buat notifikasi kalau ada data baru yang masuk (INSERT)
          if (events.isNotEmpty && data.length > events.length) {
            final newEvent = data.last;

            if (newEvent['created_by'] != _supabase.auth.currentUser?.id) {
              _showSystemNotification(newEvent['title']);
            }
          }
          fetchEvents();
        });
  }

  void _showSystemNotification(String title) {
    Get.snackbar(
      'Kegiatan Baru! 🔔',
      'Baru saja diterbitkan: $title. Cek jadwal sekarang!',
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.primary.withOpacity(0.9),
      colorText: Colors.white,
      icon: const Icon(Icons.notifications_active, color: Colors.white),
      duration: const Duration(seconds: 5),
      mainButton: TextButton(
        onPressed: () {
          if (_supabase.auth.currentSession != null) {
            Get.toNamed(AppRoutes.eventMember);
          } else {
            Get.toNamed(AppRoutes.eventVisitor);
          }
        },
        child: const Text('LIHAT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Future<void> fetchEvents() async {
    isLoading.value = true;
    try {
      // cek apakah user sudah login
      final session = _supabase.auth.currentSession;

      late List response;

      if (session != null) {
        // anggota dan admin bisa lihat semua event
        response = await _supabase
            .from('events')
            .select('*, event_divisions(divisions(name))')
            .order('start_time');
      } else {
        // Pengunjung cuma bisa lihat event publik
        response = await _supabase
            .from('events')
            .select('*, event_divisions(divisions(name))')
            .eq('is_public', true)
            .order('start_time');
      }

      events.value = response.map<EventModel>((json) {
        final divisions = (json['event_divisions'] as List)
            .map((e) => e['divisions']?['name'] as String?)
            .whereType<String>()
            .toList();
        final data = Map<String, dynamic>.from(json);
        data['divisions'] = divisions;
        return EventModel.fromJson(data);
      }).toList();

      _applyFilter();
    } catch (e) {
      errorMessage.value = 'Gagal memuat data kegiatan';
    } finally {
      isLoading.value = false;
    }
  }

  void _applyFilter() {
    var result = events.toList();

    if (selectedDay.value != null) {
      final day = selectedDay.value!;
      result = result
          .where((e) =>
              e.startTime.year == day.year &&
              e.startTime.month == day.month &&
              e.startTime.day == day.day)
          .toList();
    }

    if (selectedDivision.value != 'Semua') {
      result = result
          .where((e) => e.divisions.contains(selectedDivision.value))
          .toList();
    }

    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      result =
          result.where((e) => e.title.toLowerCase().contains(query)).toList();
    }

    filteredEvents.value = result;
  }

  void filterByDivision(String division) {
    selectedDivision.value = division;
  }

  List<EventModel> getEventsForDay(DateTime day) {
    return events
        .where((e) =>
            e.startTime.year == day.year &&
            e.startTime.month == day.month &&
            e.startTime.day == day.day)
        .toList();
  }

  Future<void> createEvent({
    required String title,
    required String location,
    required String description,
    required DateTime startTime,
    required DateTime endTime,
    required bool isPublic,
    required List<String> divisions,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User tidak ditemukan');

      final response = await _supabase
          .from('events')
          .insert({
            'title': title,
            'location': location,
            'description': description,
            'start_time': startTime.toIso8601String(),
            'end_time': endTime.toIso8601String(),
            'is_public': isPublic,
            'created_by': userId,
          })
          .select()
          .single();

      final eventId = response['id'];
      await _insertEventDivisions(eventId, divisions);

      await fetchEvents();
      Get.back();
      Get.snackbar('Berhasil', 'Kegiatan berhasil ditambahkan');
    } catch (e) {
      errorMessage.value = 'Gagal menambah kegiatan. Coba lagi.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateEvent({
    required String id,
    required String title,
    required String location,
    required String description,
    required DateTime startTime,
    required DateTime endTime,
    required bool isPublic,
    required List<String> divisions,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      await _supabase.from('events').update({
        'title': title,
        'location': location,
        'description': description,
        'start_time': startTime.toIso8601String(),
        'end_time': endTime.toIso8601String(),
        'is_public': isPublic,
      }).eq('id', id);

      await _supabase.from('event_divisions').delete().eq('event_id', id);
      await _insertEventDivisions(id, divisions);

      await fetchEvents();
      Get.back();
      Get.snackbar('Berhasil', 'Kegiatan berhasil diperbarui');
    } catch (e) {
      errorMessage.value = 'Gagal memperbarui kegiatan. Coba lagi.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteEvent(String id) async {
    try {
      await _supabase.from('events').delete().eq('id', id);
      await fetchEvents();
      Get.snackbar('Berhasil', 'Kegiatan berhasil dihapus');
    } catch (e) {
      Get.snackbar('Gagal', 'Gagal menghapus kegiatan');
    }
  }

  Future<void> _insertEventDivisions(
      String eventId, List<String> divisions) async {
    if (divisions.isEmpty) return;

    final divisionResponse = await _supabase
        .from('divisions')
        .select('id, name')
        .inFilter('name', divisions);

    final rows = divisionResponse
        .map((d) => {
              'event_id': eventId,
              'division_id': d['id'],
            })
        .toList();

    await _supabase.from('event_divisions').insert(rows);
  }
}
