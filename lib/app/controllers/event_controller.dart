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
    fetchDivisions();
    _setupRealtimeListener();

    ever(searchQuery, (_) => _applyFilter());
    ever(selectedDivision, (_) => _applyFilter());
    ever(selectedDay, (_) => _applyFilter());
  }

  // --- VALIDASI INPUT ---
  String? _validateInput({
    required String title,
    required String description,
    required String location,
    required DateTime startTime,
    required DateTime endTime,
  }) {
    if (title.trim().isEmpty ||
        description.trim().isEmpty ||
        location.trim().isEmpty) {
      return 'Mohon lengkapi semua data kegiatan.';
    }
    if (title.trim().length < 3) return 'Judul kegiatan terlalu pendek.';
    if (description.trim().length < 5)
      return 'Deskripsi kegiatan terlalu pendek.';
    if (description.length > 1000) return 'Deskripsi terlalu panjang.';

    // Validasi Waktu
    if (startTime.isAfter(endTime)) {
      return 'Waktu mulai tidak boleh setelah waktu selesai.';
    }

    return null;
  }

  // --- FUNGSI ASLI ---
  Future<void> fetchDivisions() async {
    try {
      final response =
          await _supabase.from('divisions').select('name').order('name');
      final List<String> names =
          (response as List).map((e) => e['name'] as String).toList();
      divisions.value = ['Semua', ...names];
    } catch (e) {
      debugPrint("Gagal memuat list divisi: $e");
    }
  }

  void resetFilters() {
    selectedDay.value = null;
    selectedDivision.value = 'Semua';
    searchQuery.value = '';
    _applyFilter();
  }

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

  Future<void> fetchEvents() async {
    isLoading.value = true;
    try {
      final session = _supabase.auth.currentSession;
      var query = _supabase
          .from('events')
          .select('*, event_divisions(divisions(name))');
      if (session == null) query = query.eq('is_public', true);

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
    selectedDay.value = null;
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
    // 1. Validasi
    final error = _validateInput(
        title: title,
        description: description,
        location: location,
        startTime: startTime,
        endTime: endTime);
    if (error != null) {
      Get.snackbar('Data Tidak Valid', error, backgroundColor: Colors.red[100]);
      return;
    }

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
    // 1. Validasi
    final error = _validateInput(
        title: title,
        description: description,
        location: location,
        startTime: startTime,
        endTime: endTime);
    if (error != null) {
      Get.snackbar('Data Tidak Valid', error, backgroundColor: Colors.red[100]);
      return;
    }

    // Backup untuk Optimistic Update (Rollback)
    final index = events.indexWhere((e) => e.id == id);
    if (index == -1) return;
    final oldItem = events[index];

    // 2. Optimistic Update (Update UI instan)
    events[index] = oldItem.copyWith(
      title: title,
      description: description,
      location: location,
      startTime: startTime,
      endTime: endTime,
      isPublic: isPublic,
      divisions: divisions,
    );
    events.refresh();
    _applyFilter();

    isLoading.value = true;
    try {
      // 3. Update Supabase
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

      await fetchEvents(); // Sinkronisasi data final
      Get.back();
      Get.snackbar('Berhasil', 'Kegiatan berhasil diperbarui');
    } catch (e) {
      // 4. Rollback jika gagal
      events[index] = oldItem;
      events.refresh();
      _applyFilter();
      Get.snackbar('Gagal', 'Gagal update, data dikembalikan');
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
