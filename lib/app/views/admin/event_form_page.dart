import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/event_controller.dart';
import '../../models/event_model.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';

// ======================================================
// EVENT FORM PAGE — UI terpisah dari logic di Controller
// ======================================================
class EventFormPage extends StatefulWidget {
  const EventFormPage({super.key});

  @override
  State<EventFormPage> createState() => _EventFormPageState();
}

class _EventFormPageState extends State<EventFormPage> {
  // — Controller & argument
  final _controller = Get.find<EventController>();
  final EventModel? _editEvent = Get.arguments as EventModel?;

  // — Text controllers
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();

  // — State form
  DateTime? _startTime;
  DateTime? _endTime;
  bool _isPublic = true;
  final List<String> _selectedDivisions = [];

  // — Error per-field
  String? _titleError;
  String? _timeError;
  String? _divisionError;

  bool get _isEdit => _editEvent != null;

  // ======================================================
  // LIFECYCLE
  // ======================================================

  @override
  void initState() {
    super.initState();
    _controller.errorMessage.value = '';
    _controller.clearPickedImages();

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

  // ======================================================
  // VALIDASI — delegasi ke controller (per-fungsi)
  // ======================================================

  void _onTitleChanged(String v) {
    setState(() => _titleError = _controller.validateTitle(v));
    if (_controller.errorMessage.value.isNotEmpty) {
      _controller.errorMessage.value = '';
    }
  }

  // ======================================================
  // HANDLER AKSI
  // ======================================================

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
      _timeError = null;
    });
  }

  void _handleSave() {
    bool hasError = false;

    final titleErr = _controller.validateTitle(_titleController.text);
    final timeErr = _controller.validateTime(_startTime, _endTime,
        isEdit: _isEdit);
    final divErr = _controller.validateDivisions(_selectedDivisions);

    setState(() {
      _titleError = titleErr;
      _timeError = timeErr;
      _divisionError = divErr;
    });

    if (titleErr != null || timeErr != null || divErr != null) hasError = true;
    if (hasError) return;

    _controller.errorMessage.value = '';
    final title = _titleController.text.trim();
    final location = _locationController.text.trim();
    final description = _descriptionController.text.trim();

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

  // ======================================================
  // BUILD
  // ======================================================

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
                  // ── Informasi Dasar ─────────────────────────────
                  _SectionHeader(title: 'Informasi Dasar'),
                  const SizedBox(height: 16),

                  TextField(
                    controller: _titleController,
                    autocorrect: false,
                    onChanged: _onTitleChanged,
                    decoration: InputDecoration(
                      labelText: 'Nama Kegiatan',
                      hintText: 'Contoh: Rapat Koordinasi Musik',
                      errorText: _titleError,
                      prefixIcon: const Icon(Icons.event_note_rounded),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: _DateTimeTile(
                          label: 'Waktu Mulai',
                          value: _startTime,
                          hasError: _timeError != null,
                          onTap: () =>
                              _pickDateTime(context, isStart: true),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _DateTimeTile(
                          label: 'Waktu Selesai',
                          value: _endTime,
                          hasError: _timeError != null,
                          onTap: () =>
                              _pickDateTime(context, isStart: false),
                        ),
                      ),
                    ],
                  ),
                  if (_timeError != null)
                    _InlineError(
                        message: _timeError!, colorScheme: colorScheme),
                  const SizedBox(height: 16),

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

                  // ── Foto Kegiatan ────────────────────────────────
                  _SectionHeader(title: 'Foto Kegiatan'),
                  const SizedBox(height: 8),
                  Text(
                    'Tambahkan foto dokumentasi kegiatan (opsional)',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  _EventImagesSection(controller: _controller),
                  const SizedBox(height: 32),

                  // ── Visibilitas ──────────────────────────────────
                  _SectionHeader(title: 'Visibilitas & Akses'),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _VisibilityButton(
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
                        child: _VisibilityButton(
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

                  // ── Divisi Terkait ───────────────────────────────
                  _SectionHeader(title: 'Divisi Terkait'),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: AppConstants.divisions.map((division) {
                      final isSelected =
                          _selectedDivisions.contains(division);
                      final color = AppColors.getDivisionColor(division);
                      return GestureDetector(
                        onTap: () => setState(() {
                          if (isSelected) {
                            _selectedDivisions.remove(division);
                          } else {
                            _selectedDivisions.add(division);
                          }
                          if (_selectedDivisions.isNotEmpty) {
                            _divisionError = null;
                          }
                        }),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? color
                                : color.withOpacity(0.06),
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
                              color:
                                  isSelected ? Colors.white : color,
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
                  if (_divisionError != null)
                    _InlineError(
                        message: _divisionError!, colorScheme: colorScheme),

                  Obx(() {
                    if (_controller.errorMessage.value.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: _InlineError(
                          message: _controller.errorMessage.value,
                          colorScheme: colorScheme),
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
              onPressed:
                  _controller.isLoading.value ? null : _handleSave,
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
}

// ======================================================
// SECTION FOTO KEGIATAN — Widget terpisah
// ======================================================
class _EventImagesSection extends StatelessWidget {
  final EventController controller;
  const _EventImagesSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Obx(() {
      final picked = controller.pickedEventImages;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (picked.isNotEmpty)
            SizedBox(
              height: 110,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: picked.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, i) => _PickedImageThumbnail(
                  file: picked[i],
                  onRemove: () => controller.removePickedImage(i),
                ),
              ),
            ),
          if (picked.isNotEmpty) const SizedBox(height: 12),
          GestureDetector(
            onTap: controller.pickEventImages,
            child: Container(
              height: 80,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.surfaceTeal.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: colorScheme.primary.withOpacity(0.2),
                    width: 1.5,
                    style: BorderStyle.solid),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_photo_alternate_rounded,
                      color: colorScheme.primary, size: 24),
                  const SizedBox(width: 10),
                  Text(
                    picked.isEmpty
                        ? 'Tambah Foto Kegiatan'
                        : 'Tambah Foto Lagi',
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }
}

class _PickedImageThumbnail extends StatelessWidget {
  final dynamic file;
  final VoidCallback onRemove;
  const _PickedImageThumbnail({required this.file, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: FutureBuilder<Uint8List>(
            future: file.readAsBytes(),
            builder: (_, snap) {
              if (snap.hasData) {
                return Image.memory(snap.data!,
                    width: 100, height: 110, fit: BoxFit.cover);
              }
              return Container(
                width: 100,
                height: 110,
                color: Colors.grey.shade100,
                child: const Center(child: CircularProgressIndicator()),
              );
            },
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle),
              padding: const EdgeInsets.all(4),
              child: const Icon(Icons.close_rounded,
                  color: Colors.white, size: 14),
            ),
          ),
        ),
      ],
    );
  }
}

// ======================================================
// HELPER WIDGETS — Kecil & reusable dalam file ini
// ======================================================

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: AppColors.textSecondary,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  final String message;
  final ColorScheme colorScheme;
  const _InlineError({required this.message, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, left: 4),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded,
              size: 14, color: colorScheme.error),
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
}

class _VisibilityButton extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final bool isActive;
  final Color color;
  final VoidCallback onTap;

  const _VisibilityButton({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.isActive,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isActive ? color.withOpacity(0.1) : Theme.of(context).cardColor,
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
                    : Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.4),
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
}

class _DateTimeTile extends StatelessWidget {
  final String label;
  final DateTime? value;
  final VoidCallback onTap;
  final bool hasError;

  const _DateTimeTile({
    required this.label,
    required this.value,
    required this.onTap,
    this.hasError = false,
  });

  @override
  Widget build(BuildContext context) {
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
                        ? '${value!.day.toString().padLeft(2, '0')}/'
                            '${value!.month.toString().padLeft(2, '0')}/'
                            '${value!.year} '
                            '${value!.hour.toString().padLeft(2, '0')}:'
                            '${value!.minute.toString().padLeft(2, '0')}'
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
}
