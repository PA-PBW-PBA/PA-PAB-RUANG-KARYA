import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/event_model.dart';

class EventController extends GetxController {
  final _supabase = Supabase.instance.client;

  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final events = <EventModel>[].obs;
  final filteredEvents = <EventModel>[].obs;

  // --- BARU: Variabel untuk menyimpan list divisi dari DB ---
  var divisions = <String>['Semua'].obs;

  final searchQuery = ''.obs;
  final selectedDivision = 'Semua'.obs;
  final selectedDay = Rxn<DateTime>();
  final focusedDay = DateTime.now().obs;
  final activeTab = 0.obs;

  @override
  void onInit() {
    super.onInit();
    selectedDay.value = DateTime.now();

    fetchEvents();
    fetchDivisions(); // Panggil fungsi untuk mengambil list divisi
    _setupRealtimeListener();

    ever(searchQuery, (_) => _applyFilter());
    ever(selectedDivision, (_) => _applyFilter());
    ever(selectedDay, (_) => _applyFilter());
  }

  // --- BARU: Fungsi Fetch Divisi dari Supabase ---
  Future<void> fetchDivisions() async {
    try {
      // Mengambil data dari tabel 'divisions'
      final response =
          await _supabase.from('divisions').select('name').order('name');

      // Mengubah response menjadi List<String>
      final List<String> names =
          (response as List).map((e) => e['name'] as String).toList();

      // Update data divisi, tambahkan 'Semua' di awal
      divisions.value = ['Semua', ...names];
    } catch (e) {
      debugPrint("Gagal memuat list divisi: $e");
    }
  }

  // --- FUNGSI RESET ---
  void resetFilters() {
    selectedDay.value = null;
    selectedDivision.value = 'Semua';
    searchQuery.value = '';
    _applyFilter();
  }

  // --- REALTIME LISTENER ---
  void _setupRealtimeListener() {
    _supabase.from('events').stream(primaryKey: ['id']).listen((data) {
      events.value = data.map<EventModel>((json) {
        final divisions = (json['event_divisions'] as List?)
                ?.map((e) => e['divisions']?['name'] as String?)
                .whereType<String>()
                .toList() ??
            [];
        final eventData = Map<String, dynamic>.from(json);
        eventData['divisions'] = divisions;
        return EventModel.fromJson(eventData);
      }).toList();

      _applyFilter();
    });
  }

  // --- FETCH DATA EVENT ---
  Future<void> fetchEvents() async {
    isLoading.value = true;
    try {
      final session = _supabase.auth.currentSession;
      var query = _supabase
          .from('events')
          .select('*, event_divisions(divisions(name))');

      if (session == null) {
        query = query.eq('is_public', true);
      }

      final response = await query.order('start_time');

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

  // --- LOGIKA FILTER UTAMA ---
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

  // --- FUNGSI AKSI ---
  void filterByDivision(String division) {
    selectedDay.value =
        null; // Reset tanggal agar user melihat semua event di divisi tsb
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

  // --- CRUD OPERATIONS ---
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
      errorMessage.value = 'Gagal menambah kegiatan';
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
      errorMessage.value = 'Gagal memperbarui kegiatan';
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
