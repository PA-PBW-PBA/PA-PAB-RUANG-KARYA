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

  @override
  void dispose() {
    _nominalController.dispose();
    _keteranganController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Transaksi')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Jenis toggle
            Text('Jenis Transaksi',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _jenisButton(
                    context,
                    label: 'Pemasukan',
                    value: 'pemasukan',
                    color: AppColors.accentGreen,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _jenisButton(
                    context,
                    label: 'Pengeluaran',
                    value: 'pengeluaran',
                    color: AppColors.accentRed,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _nominalController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Nominal',
                hintText: 'Masukkan jumlah',
                prefixIcon: Icon(Icons.attach_money),
                prefixText: 'Rp ',
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _keteranganController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Keterangan',
                hintText: 'Keterangan transaksi...',
                prefixIcon: Icon(Icons.description_outlined),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),

            // Date picker
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        color: Theme.of(context).colorScheme.primary, size: 18),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tanggal',
                            style: Theme.of(context).textTheme.bodySmall),
                        Text(
                          '${_selectedDate.day.toString().padLeft(2, '0')}-'
                          '${_selectedDate.month.toString().padLeft(2, '0')}-'
                          '${_selectedDate.year}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Division selector
            Text('Divisi', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AppConstants.divisions.map((division) {
                final isSelected = _selectedDivision == division;
                final color = AppColors.getDivisionColor(division);
                return GestureDetector(
                  onTap: () => setState(() => _selectedDivision = division),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: isSelected ? color : color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: color,
                        width: isSelected ? 0 : 0.5,
                      ),
                    ),
                    child: Text(
                      division,
                      style: TextStyle(
                        color: isSelected ? Colors.white : color,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            // Error
            Obx(() {
              if (_controller.errorMessage.value.isEmpty) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  _controller.errorMessage.value,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 13,
                  ),
                ),
              );
            }),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Obx(() => ElevatedButton(
              onPressed: _controller.isLoading.value ? null : _handleSave,
              child: _controller.isLoading.value
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Simpan Transaksi'),
            )),
      ),
    );
  }

  Widget _jenisButton(
    BuildContext context, {
    required String label,
    required String value,
    required Color color,
  }) {
    final isActive = _jenis == value;
    return GestureDetector(
      onTap: () => setState(() => _jenis = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? color : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color,
            width: isActive ? 0 : 0.5,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : color,
              fontWeight: FontWeight.w600,
            ),
          ),
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
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  void _handleSave() {
    if (_nominalController.text.trim().isEmpty) {
      _controller.errorMessage.value = 'Nominal wajib diisi';
      return;
    }
    final nominal = double.tryParse(_nominalController.text.trim());
    if (nominal == null || nominal <= 0) {
      _controller.errorMessage.value = 'Nominal tidak valid';
      return;
    }

    _controller.createKas(
      type: _jenis,
      amount: nominal,
      description: _keteranganController.text.trim(),
      divisionName: _selectedDivision,
      transactionDate: _selectedDate,
    );
  }
}
