import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/kas_model.dart';

class KasController extends GetxController {
  final _supabase = Supabase.instance.client;

  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final kasList = <KasModel>[].obs;

  double get totalPemasukan =>
      kasList.where((k) => k.isPemasukan).fold(0, (sum, k) => sum + k.amount);

  double get totalPengeluaran =>
      kasList.where((k) => k.isPengeluaran).fold(0, (sum, k) => sum + k.amount);

  double get totalSaldo => totalPemasukan - totalPengeluaran;

  @override
  void onInit() {
    super.onInit();
    fetchKas();
  }

  Future<void> fetchKas() async {
    isLoading.value = true;
    try {
      final response = await _supabase
          .from('kas')
          .select('*, divisions(name)')
          .order('transaction_date', ascending: false);

      kasList.value =
          response.map<KasModel>((json) => KasModel.fromJson(json)).toList();
    } catch (e) {
      errorMessage.value = 'Gagal memuat data kas';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createKas({
    required String type,
    required double amount,
    required String description,
    required String divisionName,
    required DateTime transactionDate,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User tidak ditemukan');

      final divisionResponse = await _supabase
          .from('divisions')
          .select('id')
          .eq('name', divisionName)
          .single();
      final divisionId = divisionResponse['id'];

      await _supabase.from('kas').insert({
        'division_id': divisionId,
        'type': type,
        'amount': amount,
        'description': description.isEmpty ? null : description,
        'transaction_date': transactionDate.toIso8601String(),
        'created_by': userId,
      });

      await fetchKas();
      Get.back();
      Get.snackbar('Berhasil', 'Transaksi berhasil disimpan');
    } catch (e) {
      errorMessage.value = 'Gagal menyimpan transaksi. Coba lagi.';
    } finally {
      isLoading.value = false;
    }
  }
}
