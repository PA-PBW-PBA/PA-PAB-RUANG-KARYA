import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../controllers/kas_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/admin_bottom_nav.dart';

class KasPage extends StatelessWidget {
  const KasPage({super.key});

  @override
  Widget build(BuildContext context) {
    final kasController = Get.find<KasController>();
    final authController = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Kas')),
      body: Obx(() {
        final total = kasController.totalSaldo;
        final pemasukan = kasController.totalPemasukan;
        final pengeluaran = kasController.totalPengeluaran;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Total saldo card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      'Total Saldo',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Rp ${_formatAmount(total)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Pemasukan & pengeluaran
              Row(
                children: [
                  Expanded(
                    child: _amountCard(
                      context,
                      'Total Pemasukan',
                      pemasukan,
                      AppColors.accentGreen,
                      Icons.arrow_downward,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _amountCard(
                      context,
                      'Total Pengeluaran',
                      pengeluaran,
                      AppColors.accentRed,
                      Icons.arrow_upward,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Chart — hanya tampil kalau ada data
              if (pemasukan > 0 || pengeluaran > 0) ...[
                Text(
                  'Perbandingan Kas',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sections: [
                        PieChartSectionData(
                          value: pemasukan,
                          color: AppColors.accentGreen,
                          title: 'Masuk',
                          radius: 80,
                          titleStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        PieChartSectionData(
                          value: pengeluaran > 0 ? pengeluaran : 0.001,
                          color: AppColors.accentRed,
                          title: pengeluaran > 0 ? 'Keluar' : '',
                          radius: 80,
                          titleStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                      sectionsSpace: 4,
                      centerSpaceRadius: 40,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ],
          ),
        );
      }),
      // FAB hanya muncul untuk bendahara
      floatingActionButton: Obx(() {
        final user = authController.currentUser.value;
        if (user == null || !user.canManageKas) return const SizedBox.shrink();
        return FloatingActionButton(
          onPressed: () => Get.toNamed(AppRoutes.kasForm),
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: const Icon(Icons.add, color: Colors.white),
        );
      }),
      bottomNavigationBar: AdminBottomNav(currentIndex: 4),
    );
  }

  Widget _amountCard(
    BuildContext context,
    String label,
    double amount,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            'Rp ${_formatAmount(amount)}',
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }

  String _formatAmount(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}jt';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}rb';
    }
    return amount.toStringAsFixed(0);
  }
}
