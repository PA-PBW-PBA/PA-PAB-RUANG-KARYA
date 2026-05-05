import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/event_model.dart';
import '../../core/constants/app_constants.dart';

class EventController extends GetxController {
  final _supabase = Supabase.instance.client;
  final _picker = ImagePicker();

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

  // === FOTO KEGIATAN ===
  final pickedEventImages = <XFile>[].obs;

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

  // =========================================================
  // VALIDASI — tiap validasi dalam fungsi tersendiri
  // =========================================================

  /// Validasi judul tidak boleh kosong dan minimal 3 karakter
  String? validateTitle(String value) {
    final v = value.trim();
    if (v.isEmpty) return 'Judul kegiatan tidak boleh kosong';
    if (v.length < 3) return 'Judul kegiatan terlalu pendek (min. 3 karakter)';
    return null;
  }

  /// Validasi waktu: keduanya harus diisi, start < end
  String? validateTime(DateTime? startTime, DateTime? endTime,
      {bool isEdit = false}) {
    if (startTime == null || endTime == null) {
      return 'Waktu mulai dan selesai wajib dipilih';
    }
    if (!isEdit && startTime.isBefore(DateTime.now())) {
      return 'Waktu mulai tidak boleh di masa lampau';
    }
    if (endTime.isBefore(startTime)) {
      return 'Waktu selesai tidak boleh sebelum waktu mulai';
    }
    return null;
  }

  /// Validasi minimal satu divisi terkait dipilih
  String? validateDivisions(List<String> selected) {
    if (selected.isEmpty) return 'Pilih minimal satu divisi terkait';
    return null;
  }

  // =========================================================
  // FOTO KEGIATAN
  // =========================================================

  Future<void> pickEventImages() async {
    final files = await _picker.pickMultiImage(imageQuality: 85);
    if (files.isNotEmpty) {
      pickedEventImages.addAll(files);
    }
  }

  void removePickedImage(int index) {
    pickedEventImages.removeAt(index);
  }

  void clearPickedImages() {
    pickedEventImages.clear();
  }

  Future<List<String>> _uploadEventImages(String eventId) async {
    final urls = <String>[];
    for (final file in pickedEventImages) {
      final bytes = await file.readAsBytes();
      final ext = file.path.split('.').last;
      final path = 'events/$eventId/${DateTime.now().millisecondsSinceEpoch}.$ext';

      await _supabase.storage
          .from(AppConstants.bucketGallery)
          .uploadBinary(path, bytes);

      final url = _supabase.storage
          .from(AppConstants.bucketGallery)
          .getPublicUrl(path);

      urls.add(url);
    }
    return urls;
  }

  Future<void> addEventImages(String eventId) async {
    if (pickedEventImages.isEmpty) return;

    isLoading.value = true;
    try {
      final urls = await _uploadEventImages(eventId);

      // Ambil imageUrls yang sudah ada
      final event = events.firstWhere((e) => e.id == eventId);
      final updatedUrls = [...event.imageUrls, ...urls];

      await _supabase
          .from('events')
          .update({'image_urls': updatedUrls}).eq('id', eventId);

      final index = events.indexWhere((e) => e.id == eventId);
      if (index != -1) {
        events[index] = events[index].copyWith(imageUrls: updatedUrls);
        events.refresh();
        _applyFilter();
      }

      clearPickedImages();
      Get.snackbar('Berhasil', 'Foto kegiatan berhasil ditambahkan');
    } catch (e) {
      Get.snackbar('Gagal', 'Gagal upload foto kegiatan');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteEventImage(String eventId, String imageUrl) async {
    try {
      final event = events.firstWhere((e) => e.id == eventId);
      final updatedUrls = event.imageUrls.where((u) => u != imageUrl).toList();

      await _supabase
          .from('events')
          .update({'image_urls': updatedUrls}).eq('id', eventId);

      final index = events.indexWhere((e) => e.id == eventId);
      if (index != -1) {
        events[index] = events[index].copyWith(imageUrls: updatedUrls);
        events.refresh();
        _applyFilter();
      }
    } catch (e) {
      Get.snackbar('Gagal', 'Gagal menghapus foto');
    }
  }

  // =========================================================
  // DATA FETCHING
  // =========================================================

  Future<void> fetchDivisions() async {
    try {
      final response =
          await _supabase.from('divisions').select('name').order('name');
      final List<String> names =
          (response as List).map((e) => e['name'] as String).toList();
      divisions.value = ['Semua', ...names];
    } catch (e) {
      debugPrint('Gagal memuat list divisi: $e');
    }
  }

  void _setupRealtimeListener() {
    _supabase.from('events').stream(primaryKey: ['id']).listen((data) {
      events.value = data.map<EventModel>((json) {
        final divList = (json['event_divisions'] as List?)
                ?.map((e) => e['divisions']?['name'] as String?)
                .whereType<String>()
                .toList() ??
            [];
        final eventData = Map<String, dynamic>.from(json);
        eventData['divisions'] = divList;
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
        final divList = (json['event_divisions'] as List)
            .map((e) => e['divisions']?['name'] as String?)
            .whereType<String>()
            .toList();
        final data = Map<String, dynamic>.from(json);
        data['divisions'] = divList;
        return EventModel.fromJson(data);
      }).toList();
      _applyFilter();
    } catch (e) {
      errorMessage.value = 'Gagal memuat data kegiatan';
    } finally {
      isLoading.value = false;
    }
  }

  // =========================================================
  // FILTER
  // =========================================================

  void _applyFilter() {
    var result = events.toList();
    result = _filterByDay(result);
    result = _filterByDivision(result);
    result = _filterBySearch(result);
    filteredEvents.value = result;
  }

  List<EventModel> _filterByDay(List<EventModel> source) {
    if (selectedDay.value == null) return source;
    final day = selectedDay.value!;
    return source
        .where((e) =>
            e.startTime.year == day.year &&
            e.startTime.month == day.month &&
            e.startTime.day == day.day)
        .toList();
  }

  List<EventModel> _filterByDivision(List<EventModel> source) {
    if (selectedDivision.value == 'Semua') return source;
    return source
        .where((e) => e.divisions.contains(selectedDivision.value))
        .toList();
  }

  List<EventModel> _filterBySearch(List<EventModel> source) {
    if (searchQuery.value.isEmpty) return source;
    final query = searchQuery.value.toLowerCase();
    return source.where((e) => e.title.toLowerCase().contains(query)).toList();
  }

  void filterByDivision(String division) {
    selectedDay.value = null;
    selectedDivision.value = division;
  }

  void resetFilters() {
    selectedDay.value = null;
    selectedDivision.value = 'Semua';
    searchQuery.value = '';
    _applyFilter();
  }

  List<EventModel> getEventsForDay(DateTime day) {
    return events
        .where((e) =>
            e.startTime.year == day.year &&
            e.startTime.month == day.month &&
            e.startTime.day == day.day)
        .toList();
  }

  // =========================================================
  // CRUD
  // =========================================================

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
            'image_urls': [],
          })
          .select()
          .single();

      final eventId = response['id'];

      // Upload foto jika ada
      if (pickedEventImages.isNotEmpty) {
        final urls = await _uploadEventImages(eventId);
        await _supabase
            .from('events')
            .update({'image_urls': urls}).eq('id', eventId);
        clearPickedImages();
      }

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
    final index = events.indexWhere((e) => e.id == id);
    if (index == -1) return;
    final oldItem = events[index];

    // Optimistic update
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

      // Upload foto baru jika ada
      if (pickedEventImages.isNotEmpty) {
        final urls = await _uploadEventImages(id);
        final existing = events[index].imageUrls;
        final merged = [...existing, ...urls];
        await _supabase
            .from('events')
            .update({'image_urls': merged}).eq('id', id);
        clearPickedImages();
      }

      await fetchEvents();
      Get.back();
      Get.snackbar('Berhasil', 'Kegiatan berhasil diperbarui');
    } catch (e) {
      // Rollback
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
      String eventId, List<String> divisionNames) async {
    if (divisionNames.isEmpty) return;

    final divisionResponse = await _supabase
        .from('divisions')
        .select('id, name')
        .inFilter('name', divisionNames);

    final rows = divisionResponse
        .map((d) => {
              'event_id': eventId,
              'division_id': d['id'],
            })
        .toList();

    await _supabase.from('event_divisions').insert(rows);
  }
}
