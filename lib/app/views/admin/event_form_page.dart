import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/event_controller.dart';
import '../../models/event_model.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';

class EventFormPage extends StatefulWidget {
  const EventFormPage({super.key});

  @override
  State<EventFormPage> createState() => _EventFormPageState();
}

class _EventFormPageState extends State<EventFormPage> {
  final _controller = Get.find<EventController>();
  final EventModel? _editEvent = Get.arguments as EventModel?;

  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime? _startTime;
  DateTime? _endTime;
  bool _isPublic = true;
  final List<String> _selectedDivisions = [];

  // Error per-field — tampil langsung di bawah field masing-masing
  String? _titleError;
  String? _timeError; // error untuk pasangan waktu mulai & selesai
  String? _divisionError; // error untuk pilihan divisi

  bool get _isEdit => _editEvent != null;

  @override
  void initState() {
    super.initState();
    _controller.errorMessage.value = '';
    if (_isEdit) {
      _titleController.text = _editEvent!.title;
      _locationController.text = _editEvent!.location ?? '';
      _descriptionController.text = _editEvent!.description ?? '';
      _startTime = _editEvent!.startTime;
      _endTime = _editEvent!.endTime;
      _isPublic = _editEvent!.isPublic;
      _selectedDivisions.addAll(_editEvent!.divisions);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String? _validateTitle(String value) {
    final v = value.trim();
    if (v.isEmpty) return 'Nama kegiatan tidak boleh kosong';
    if (v.length < 3) return 'Nama kegiatan terlalu pendek (min. 3 karakter)';
    final forbidden = RegExp(r'[<>"\\`]');
    if (forbidden.hasMatch(v)) {
      return 'Nama mengandung karakter yang tidak diizinkan';
    }
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
                _isEdit ? 'Edit Kegiatan' : 'Buat Kegiatan',
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
                  // ── Informasi Dasar ───────────────────────────────────
                  _buildFormHeader('Informasi Dasar'),
                  const SizedBox(height: 16),

                  // Nama Kegiatan — error langsung di bawah field
                  TextField(
                    controller: _titleController,
                    autocorrect: false,
                    onChanged: (v) =>
                        setState(() => _titleError = _validateTitle(v)),
                    decoration: InputDecoration(
                      labelText: 'Nama Kegiatan',
                      hintText: 'Contoh: Rapat Koordinasi Musik',
                      errorText: _titleError,
                      prefixIcon: const Icon(Icons.event_note_rounded),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Waktu Mulai & Selesai
                  Row(
                    children: [
                      Expanded(
                        child: _dateTimeTile(
                          context,
                          label: 'Waktu Mulai',
                          value: _startTime,
                          hasError: _timeError != null,
                          onTap: () => _pickDateTime(context, isStart: true),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _dateTimeTile(
                          context,
                          label: 'Waktu Selesai',
                          value: _endTime,
                          hasError: _timeError != null,
                          onTap: () => _pickDateTime(context, isStart: false),
                        ),
                      ),
                    ],
                  ),
                  // Error waktu — tepat di bawah tile waktu
                  if (_timeError != null)
                    _inlineError(_timeError!, colorScheme),
                  const SizedBox(height: 16),

                  // Lokasi
                  TextField(
                    controller: _locationController,
                    autocorrect: false,
                    decoration: const InputDecoration(
                      labelText: 'Lokasi',
                      hintText: 'Contoh: Studio Ruang Karya',
                      prefixIcon: Icon(Icons.location_on_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Deskripsi
                  TextField(
                    controller: _descriptionController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Deskripsi',
                      hintText: 'Tulis detail kegiatan...',
                      prefixIcon: Icon(Icons.description_outlined),
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── Visibilitas ───────────────────────────────────────
                  _buildFormHeader('Visibilitas & Akses'),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _visibilityButton(
                          context,
                          label: 'Publik',
                          subtitle: 'Semua pengunjung',
                          icon: Icons.public_rounded,
                          isActive: _isPublic,
                          color: AppColors.accentGreen,
                          onTap: () => setState(() => _isPublic = true),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _visibilityButton(
                          context,
                          label: 'Internal',
                          subtitle: 'Anggota & Admin',
                          icon: Icons.lock_person_rounded,
                          isActive: !_isPublic,
                          color: colorScheme.primary,
                          onTap: () => setState(() => _isPublic = false),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // ── Divisi Terkait ────────────────────────────────────
                  _buildFormHeader('Divisi Terkait'),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: AppConstants.divisions.map((division) {
                      final isSelected = _selectedDivisions.contains(division);
                      final color = AppColors.getDivisionColor(division);
                      return GestureDetector(
                        onTap: () => setState(() {
                          if (isSelected) {
                            _selectedDivisions.remove(division);
                          } else {
                            _selectedDivisions.add(division);
                          }
                          // hapus error divisi saat user mulai memilih
                          if (_selectedDivisions.isNotEmpty) {
                            _divisionError = null;
                          }
                        }),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? color : color.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected
                                  ? color
                                  : (_divisionError != null
                                      ? colorScheme.error.withOpacity(0.5)
                                      : color.withOpacity(0.15)),
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
                  // Error divisi — tepat di bawah chip divisi
                  if (_divisionError != null)
                    _inlineError(_divisionError!, colorScheme),

                  // Error dari server (gagal simpan ke Supabase)
                  Obx(() {
                    if (_controller.errorMessage.value.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: _inlineError(
                          _controller.errorMessage.value, colorScheme),
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
                  : Text(
                      _isEdit ? 'Simpan Perubahan' : 'Terbitkan Kegiatan',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700),
                    ),
            )),
      ),
    );
  }

  // Widget error inline kecil — dipakai di bawah tiap field
  Widget _inlineError(String message, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, left: 4),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, size: 14, color: colorScheme.error),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: colorScheme.error,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
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

  Widget _visibilityButton(
    BuildContext context, {
    required String label,
    required String subtitle,
    required IconData icon,
    required bool isActive,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              isActive ? color.withOpacity(0.1) : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? color : Theme.of(context).dividerColor,
            width: isActive ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon,
                color: isActive
                    ? color
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                size: 24),
            const SizedBox(height: 10),
            Text(label,
                style: TextStyle(
                    color: isActive ? color : null,
                    fontWeight: FontWeight.w800,
                    fontSize: 14)),
            const SizedBox(height: 2),
            Text(subtitle,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _dateTimeTile(
    BuildContext context, {
    required String label,
    DateTime? value,
    required VoidCallback onTap,
    bool hasError = false,
  }) {
    final primary = Theme.of(context).colorScheme.primary;
    final error = Theme.of(context).colorScheme.error;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            // border merah jika ada error
            color: hasError
                ? error.withOpacity(0.6)
                : Theme.of(context).dividerColor,
            width: hasError ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: hasError ? error : null)),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.calendar_month_rounded,
                    size: 16, color: hasError ? error : primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    value != null
                        ? '${value.day.toString().padLeft(2, '0')}/'
                            '${value.month.toString().padLeft(2, '0')}/'
                            '${value.year} '
                            '${value.hour.toString().padLeft(2, '0')}:'
                            '${value.minute.toString().padLeft(2, '0')}'
                        : 'Pilih Jadwal',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: value == null && hasError ? error : null),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDateTime(BuildContext context,
      {required bool isStart}) async {
    final now = DateTime.now();
    final firstDate = _isEdit ? DateTime(now.year - 5, 1, 1) : now;

    DateTime initialDate;
    if (isStart && _startTime != null) {
      initialDate = _startTime!.isBefore(firstDate) ? firstDate : _startTime!;
    } else if (!isStart && _endTime != null) {
      initialDate = _endTime!.isBefore(firstDate) ? firstDate : _endTime!;
    } else {
      initialDate = now;
    }

    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime(2030),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
          isStart ? (_startTime ?? now) : (_endTime ?? now)),
    );
    if (time == null) return;

    final dt =
        DateTime(date.year, date.month, date.day, time.hour, time.minute);

    setState(() {
      if (isStart) {
        _startTime = dt;
      } else {
        _endTime = dt;
      }
      // Hapus error waktu saat user sudah memilih
      _timeError = null;
    });
  }

  void _handleSave() {
    final title = _titleController.text.trim();
    final location = _locationController.text.trim();
    final description = _descriptionController.text.trim();
    final now = DateTime.now();
    bool hasError = false;

    // Validasi judul
    final titleErr = _validateTitle(title);
    setState(() => _titleError = titleErr);
    if (titleErr != null) hasError = true;

    // Validasi waktu — error di bawah tile waktu
    String? timeErr;
    if (_startTime == null || _endTime == null) {
      timeErr = 'Waktu mulai dan selesai wajib dipilih';
    } else if (!_isEdit && _startTime!.isBefore(now)) {
      timeErr = 'Waktu mulai tidak boleh di masa lampau';
    } else if (_endTime!.isBefore(_startTime!)) {
      timeErr = 'Waktu selesai tidak boleh sebelum waktu mulai';
    }
    setState(() => _timeError = timeErr);
    if (timeErr != null) hasError = true;

    // Validasi divisi — error di bawah chip divisi
    final String? divErr =
        _selectedDivisions.isEmpty ? 'Pilih minimal satu divisi terkait' : null;
    setState(() => _divisionError = divErr);
    if (divErr != null) hasError = true;

    if (hasError) return;

    _controller.errorMessage.value = '';

    if (!_isEdit) {
      _showNotificationDialog(title, location, description);
    } else {
      _performSave(title, location, description);
    }
  }

  void _showNotificationDialog(
      String title, String location, String description) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.notifications_active_rounded,
                color: AppColors.accentGreen),
            SizedBox(width: 12),
            Text('Kirim Notifikasi?'),
          ],
        ),
        content:
            Text('Kegiatan "$title" akan diterbitkan. Beritahu semua anggota?'),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              _performSave(title, location, description);
            },
            child: const Text('Simpan Saja'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'Notifikasi Terkirim',
                'Anggota akan segera menerima pemberitahuan.',
                snackPosition: SnackPosition.TOP,
                backgroundColor: AppColors.accentGreen.withOpacity(0.9),
                colorText: Colors.white,
                duration: const Duration(seconds: 3),
              );
              _performSave(title, location, description);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentGreen),
            child: const Text('Ya, Kirim'),
          ),
        ],
      ),
    );
  }

  void _performSave(String title, String location, String description) {
    if (_isEdit) {
      _controller.updateEvent(
        id: _editEvent!.id,
        title: title,
        location: location,
        description: description,
        startTime: _startTime!,
        endTime: _endTime!,
        isPublic: _isPublic,
        divisions: _selectedDivisions,
      );
    } else {
      _controller.createEvent(
        title: title,
        location: location,
        description: description,
        startTime: _startTime!,
        endTime: _endTime!,
        isPublic: _isPublic,
        divisions: _selectedDivisions,
      );
    }
  }
}
