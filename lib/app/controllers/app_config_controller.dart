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
      // Menggunakan maybeSingle agar tidak error jika data tidak ditemukan
      final response = await supabase
          .from('app_settings')
          .select('value')
          .eq('key', 'admin_whatsapp')
          .maybeSingle();

      if (response != null && response['value'] != null) {
        whatsappNumber.value = response['value'].toString();
        print("Sukses: Data berhasil diambil -> ${whatsappNumber.value}");
      } else {
        print("Warning: Key 'admin_whatsapp' tidak ditemukan di database.");
        whatsappNumber.value = '';
      }
    } catch (e) {
      print("Error fatal fetching config: $e");
      whatsappNumber.value = '';
    } finally {
      isLoading.value = false;
    }
  }
}
