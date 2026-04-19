import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppConfigController extends GetxController {
  final supabase = Supabase.instance.client;

  var whatsappNumber = ''.obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchConfig();
  }

  Future<void> fetchConfig() async {
    isLoading.value = true;
    try {
      // Kita query berdasarkan 'key', lalu ambil kolom 'value'-nya
      final response = await supabase
          .from('app_settings')
          .select('value')
          .eq('key',
              'admin_whatsapp') // Filter baris yang kuncinya adalah admin_whatsapp
          .single();

      // Karena hanya mengambil satu kolom 'value', langsung akses datanya
      whatsappNumber.value = response['value']?.toString() ?? '';

      print("Sukses: Data berhasil diambil -> ${whatsappNumber.value}");
    } catch (e) {
      print("Error fetching config: $e");
      whatsappNumber.value = ''; // Reset jika gagal
    } finally {
      isLoading.value = false;
    }
  }
}
