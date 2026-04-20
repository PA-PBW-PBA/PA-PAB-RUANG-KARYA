import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/kas_controller.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';

class KasFormPage extends StatefulWidget {
  const KasFormPage({super.key});

  @override
  State<KasFormPage> createState() => _KasFormPageState();
}

class _KasFormPageState extends State<KasFormPage> {
  final _controller = Get.find<KasController>();
  final _nominalController = TextEditingController();
  final _keteranganController = TextEditingController();

  String _jenis = 'pemasukan';
  String _selectedDivision = AppConstants.divisions.first;
  DateTime _selectedDate = DateTime.now();

  String? _nominalError;

  @override
  void dispose() {
    _nominalController.dispose();
    _keteranganController.dispose();
    super.dispose();
  }

  String? _validateNominal(String value) {
    final v = value.trim();
    if (v.isEmpty) return 'Nominal wajib diisi';
    final nominal = double.tryParse(v);
    if (nominal == null) return 'Nominal harus berupa angka';
    if (nominal <= 0) return 'Nominal harus lebih dari 0';
    return null;
  }

  @override
  Widget build(BuildContext context) {
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
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => Get.back(),
            ),
            backgroundColor: theme.scaffoldBackgroundColor.withOpacity(0.9),
            flexibleSpace: FlexibleSpaceBar(
              expandedTitleScale: 1.2,
              title: Text(
                'Catat Transaksi',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFormHeader('Klasifikasi Keuangan'),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _jenisButton(
                          context,
                          label: 'Pemasukan',
                          value: 'pemasukan',
                          icon: Icons.add_chart_rounded,
                          color: AppColors.accentGreen,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _jenisButton(
                          context,
                          label: 'Pengeluaran',
                          value: 'pengeluaran',
                          icon: Icons.remove_moderator_rounded,
                          color: AppColors.accentRed,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  _buildFormHeader('Detail Transaksi'),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: TextField(
                      controller: _nominalController,
                      keyboardType: TextInputType.number,
                      autocorrect: false,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w800),
                      onChanged: (v) =>
                          setState(() => _nominalError = _validateNominal(v)),
                      decoration: InputDecoration(
                        labelText: 'Nominal Transaksi',
                        hintText: '0',
                        errorText: _nominalError,
                        prefixIcon: Container(
                          padding: const EdgeInsets.all(12),
                          child: Text('Rp',
                              style: TextStyle(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                              )),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _keteranganController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Keterangan',
                      hintText: 'Misal: Iuran bulanan divisi...',
                      prefixIcon: Icon(Icons.notes_rounded),
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: _pickDate,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: theme.dividerColor),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.calendar_today_rounded,
                                color: colorScheme.primary, size: 18),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Tanggal Transaksi',
                                  style: theme.textTheme.bodySmall
                                      ?.copyWith(fontWeight: FontWeight.bold)),
                              Text(
                                '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}',
                                style: theme.textTheme.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Icon(Icons.edit_calendar_rounded,
                              size: 20,
                              color: colorScheme.primary.withOpacity(0.5)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildFormHeader('Divisi Penanggung Jawab'),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: AppConstants.divisions.map((division) {
                      final isSelected = _selectedDivision == division;
                      final color = AppColors.getDivisionColor(division);
                      return GestureDetector(
                        onTap: () =>
                            setState(() => _selectedDivision = division),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? color : color.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color:
                                  isSelected ? color : color.withOpacity(0.15),
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            division,
                            style: TextStyle(
                              color: isSelected ? Colors.white : color,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  Obx(() {
                    if (_controller.errorMessage.value.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorScheme.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline_rounded,
                                color: colorScheme.error, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _controller.errorMessage.value,
                                style: TextStyle(
                                  color: colorScheme.error,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Obx(() => ElevatedButton(
              onPressed: _controller.isLoading.value ? null : _handleSave,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: _controller.isLoading.value
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Simpan Transaksi',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            )),
      ),
    );
  }

  Widget _buildFormHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w800,
        color: AppColors.textSecondary,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _jenisButton(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final isActive = _jenis == value;
    return GestureDetector(
      onTap: () => setState(() => _jenis = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isActive ? color : color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? color : color.withOpacity(0.15),
            width: 2,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(icon, color: isActive ? Colors.white : color, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : color,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: Theme.of(context).colorScheme.primary,
                ),
          ),
          child: child!,
        );
      },
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  void _handleSave() {
    final nominalErr = _validateNominal(_nominalController.text);
    setState(() => _nominalError = nominalErr);
    if (nominalErr != null) return;

    _controller.errorMessage.value = '';

    _controller.createKas(
      type: _jenis,
      amount: double.parse(_nominalController.text.trim()),
      description: _keteranganController.text.trim(),
      divisionName: _selectedDivision,
      transactionDate: _selectedDate,
    );
  }
}
