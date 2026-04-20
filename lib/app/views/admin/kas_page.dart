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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            pinned: true,
            elevation: 0,
            backgroundColor: theme.scaffoldBackgroundColor.withOpacity(0.9),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Laporan Kas',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // total saldo di card
                  Obx(() {
                    final total = kasController.totalSaldo;
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [colorScheme.primary, AppColors.primaryDark],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            right: -20,
                            top: -20,
                            child: Icon(Icons.account_balance_wallet_rounded,
                                size: 100, color: Colors.white.withOpacity(0.1)),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'TOTAL SALDO AKTIF',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Rp ${_formatAmount(total)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -1,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text(
                                  'Terakhir diperbarui hari ini',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 20),

                  // pemasukan & pengeluaran 
                  Obx(() {
                    final pemasukan = kasController.totalPemasukan;
                    final pengeluaran = kasController.totalPengeluaran;
                    return Row(
                      children: [
                        Expanded(
                          child: _amountCard(
                            context,
                            'Pemasukan',
                            pemasukan,
                            AppColors.accentGreen,
                            Icons.arrow_downward_rounded,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _amountCard(
                            context,
                            'Pengeluaran',
                            pengeluaran,
                            AppColors.accentRed,
                            Icons.arrow_upward_rounded,
                          ),
                        ),
                      ],
                    );
                  }),
                  const SizedBox(height: 32),

                  Obx(() {
                    final pemasukan = kasController.totalPemasukan;
                    final pengeluaran = kasController.totalPengeluaran;
                    if (pemasukan == 0 && pengeluaran == 0) {
                      return const SizedBox.shrink();
                    }
                    return Column(
                      children: [
                        _buildSectionHeader(context, title: 'Analisis Arus Kas'),
                        const SizedBox(height: 24),
                        Container(
                          height: 240,
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                                color: theme.dividerColor.withOpacity(0.5)),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              PieChart(
                                PieChartData(
                                  sections: [
                                    PieChartSectionData(
                                      value: pemasukan,
                                      color: AppColors.accentGreen,
                                      title: '',
                                      radius: 25,
                                      showTitle: false,
                                    ),
                                    PieChartSectionData(
                                      value: pengeluaran > 0 ? pengeluaran : 0.001,
                                      color: AppColors.accentRed,
                                      title: '',
                                      radius: 25,
                                      showTitle: false,
                                    ),
                                  ],
                                  sectionsSpace: 4,
                                  centerSpaceRadius: 60,
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${(pemasukan + pengeluaran) > 0 ? ((pemasukan / (pemasukan + pengeluaran)) * 100).toStringAsFixed(0) : '0'}%',
                                    style: theme.textTheme.headlineMedium?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.accentGreen,
                                    ),
                                  ),
                                  Text(
                                    'Rasio Masuk',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }),
                  
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
      // FAB only for bendahara
      floatingActionButton: Obx(() {
        final user = authController.currentUser.value;
        if (user == null || !user.canManageKas) return const SizedBox.shrink();
        return FloatingActionButton.extended(
          onPressed: () => Get.toNamed(AppRoutes.kasForm),
          backgroundColor: colorScheme.primary,
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          icon: const Icon(Icons.add_card_rounded, color: Colors.white),
          label: const Text(
            'Transaksi Baru',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
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
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.15), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 16),
          Text(
            'Rp ${_formatAmount(amount)}',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, {required String title}) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      ],
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
