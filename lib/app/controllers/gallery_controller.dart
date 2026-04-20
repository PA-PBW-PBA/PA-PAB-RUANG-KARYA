import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/gallery_model.dart';
import '../../core/constants/app_constants.dart';

class GalleryController extends GetxController {
  final _supabase = Supabase.instance.client;
  final _picker = ImagePicker();

  final isLoading = false.obs;
  final gallery = <GalleryModel>[].obs;
  final filteredGallery = <GalleryModel>[].obs;
  final selectedDivision = 'Semua'.obs;
  final pickedGalleryFile = Rxn<XFile>();

  @override
  void onInit() {
    super.onInit();
    fetchGallery();
    ever(selectedDivision, (_) => _applyFilter());
  }

  Future<void> fetchGallery() async {
    isLoading.value = true;
    try {
      final response = await _supabase
          .from('gallery')
          .select('*, divisions(name)')
          .order('created_at', ascending: false);

      gallery.value = response
          .map<GalleryModel>((json) => GalleryModel.fromJson(json))
          .toList();

      _applyFilter();
    } catch (e) {
      // Handle error
    } finally {
      isLoading.value = false;
    }
  }

  void _applyFilter() {
    if (selectedDivision.value == 'Semua') {
      filteredGallery.value = gallery.toList();
    } else {
      filteredGallery.value = gallery
          .where((g) => g.divisionName == selectedDivision.value)
          .toList();
    }
  }

  void filterByDivision(String division) {
    selectedDivision.value = division;
  }

  Future<void> pickGalleryImage() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file != null) pickedGalleryFile.value = file;
  }

  Future<void> uploadGallery({
    required String caption,
    required String divisionName,
  }) async {
    if (pickedGalleryFile.value == null) {
      Get.snackbar('Peringatan', 'Pilih foto terlebih dahulu');
      return;
    }

    isLoading.value = true;
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User tidak ditemukan');

      final divisionResponse = await _supabase
          .from('divisions')
          .select('id')
          .eq('name', divisionName)
          .single();
      final divisionId = divisionResponse['id'];

      final file = pickedGalleryFile.value!;
      final bytes = await file.readAsBytes();
      final ext = file.path.split('.').last;
      final path =
          '$divisionName/${DateTime.now().millisecondsSinceEpoch}.$ext';

      await _supabase.storage
          .from(AppConstants.bucketGallery)
          .uploadBinary(path, bytes);

      final imageUrl =
          _supabase.storage.from(AppConstants.bucketGallery).getPublicUrl(path);

      await _supabase.from('gallery').insert({
        'division_id': divisionId,
        'image_url': imageUrl,
        'caption': caption.isEmpty ? null : caption,
        'uploaded_by': userId,
      });

      pickedGalleryFile.value = null;
      await fetchGallery();
      Get.snackbar('Berhasil', 'Foto berhasil diupload');
    } catch (e) {
      Get.snackbar('Gagal', 'Gagal mengupload foto');
    } finally {
      isLoading.value = false;
    }
  }

  // BUG FIX #6: Method updateGallery — sebelumnya tidak ada sama sekali,
  // sehingga tombol edit di GalleryCard tidak melakukan apa-apa.
  Future<void> updateGallery({
    required String id,
    required String caption,
    required String divisionName,
  }) async {
    isLoading.value = true;
    try {
      // Ambil division id
      final divisionResponse = await _supabase
          .from('divisions')
          .select('id')
          .eq('name', divisionName)
          .single();
      final divisionId = divisionResponse['id'];

      final updateData = <String, dynamic>{
        'division_id': divisionId,
        'caption': caption.isEmpty ? null : caption,
      };

      // Upload gambar baru jika ada
      if (pickedGalleryFile.value != null) {
        final file = pickedGalleryFile.value!;
        final bytes = await file.readAsBytes();
        final ext = file.path.split('.').last;
        final path =
            '$divisionName/${DateTime.now().millisecondsSinceEpoch}.$ext';

        await _supabase.storage
            .from(AppConstants.bucketGallery)
            .uploadBinary(path, bytes);

        final imageUrl = _supabase.storage
            .from(AppConstants.bucketGallery)
            .getPublicUrl(path);

        updateData['image_url'] = imageUrl;
        pickedGalleryFile.value = null;
      }

      await _supabase.from('gallery').update(updateData).eq('id', id);

      await fetchGallery();
      Get.snackbar('Berhasil', 'Karya berhasil diperbarui');
    } catch (e) {
      Get.snackbar('Gagal', 'Gagal memperbarui karya');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteGallery(String id) async {
    try {
      await _supabase.from('gallery').delete().eq('id', id);
      await fetchGallery();
      Get.snackbar('Berhasil', 'Foto berhasil dihapus');
    } catch (e) {
      Get.snackbar('Gagal', 'Gagal menghapus foto');
    }
  }
}
