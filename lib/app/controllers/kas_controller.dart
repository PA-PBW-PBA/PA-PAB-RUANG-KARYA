import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../models/kas_model.dart';

class KasController extends GetxController {
  final _supabase = Supabase.instance.client;

  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final kasList = <KasModel>[].obs;

  // --- GETTERS ---
  double get totalPemasukan =>
      kasList.where((k) => k.isPemasukan).fold(0, (sum, k) => sum + k.amount);

  double get totalPengeluaran =>
      kasList.where((k) => k.isPengeluaran).fold(0, (sum, k) => sum + k.amount);

  double get totalSaldo => totalPemasukan - totalPengeluaran;

  // --- FORMATTER ---
  String formatCurrency(double amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  @override
  void onInit() {
    super.onInit();
    fetchKas();
  }

  // --- VALIDASI ---
  String? _validateInput({
    required double amount,
    required String description,
    required String divisionName,
  }) {
    if (amount <= 0) return 'Nominal transaksi tidak boleh nol atau negatif.';
    if (description.trim().isEmpty) return 'Keterangan wajib diisi.';
    if (description.trim().length < 3) return 'Keterangan terlalu pendek.';
    if (divisionName == 'Pilih Divisi' || divisionName.isEmpty) {
      return 'Mohon pilih divisi.';
    }
    return null;
  }

  // --- FUNGSI FETCH ---
  Future<void> fetchKas() async {
    isLoading.value = true;
    try {
      final response = await _supabase
          .from('kas')
          .select('*, divisions(name)')
          .order('transaction_date', ascending: false);

      kasList.value =
          (response as List).map((json) => KasModel.fromJson(json)).toList();
    } catch (e) {
      errorMessage.value = 'Gagal memuat data kas: $e';
      Get.snackbar('Error', 'Gagal memuat data kas');
    } finally {
      isLoading.value = false;
    }
  }

  // --- FUNGSI CREATE ---
  Future<void> createKas({
    required String type,
    required double amount,
    required String description,
    required String divisionName,
    required DateTime transactionDate,
  }) async {
    // 1. Validasi lokal
    final error = _validateInput(
      amount: amount,
      description: description,
      divisionName: divisionName,
    );

    if (error != null) {
      Get.snackbar('Data Tidak Valid', error, backgroundColor: Colors.red[100]);
      return;
    }

    isLoading.value = true;

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User tidak terautentikasi');

      // 2. Cari ID Divisi
      final divisionResponse = await _supabase
          .from('divisions')
          .select('id')
          .eq('name', divisionName)
          .maybeSingle();

      if (divisionResponse == null) {
        throw Exception('Divisi tidak ditemukan di database.');
      }

      final divisionId = divisionResponse['id'];

      // 3. Insert Data
      await _supabase.from('kas').insert({
        'division_id': divisionId,
        'type': type,
        'amount': amount,
        'description': description.trim(),
        'transaction_date': transactionDate.toIso8601String(),
        'created_by': userId,
      });

      // 4. Refresh data & feedback
      await fetchKas();
      Get.back();
      Get.snackbar('Berhasil', 'Transaksi $type berhasil disimpan',
          backgroundColor: Colors.green[100]);
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('Gagal', 'Terjadi kesalahan: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
}
