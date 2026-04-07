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

  bool get _isEdit => _editEvent != null;

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Kegiatan' : 'Tambah Kegiatan'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Nama Kegiatan',
                hintText: 'Masukkan nama kegiatan',
                prefixIcon: Icon(Icons.event_outlined),
              ),
            ),
            const SizedBox(height: 16),

            // Date & Time pickers
            Row(
              children: [
                Expanded(
                  child: _dateTimeTile(
                    context,
                    label: 'Waktu Mulai',
                    value: _startTime,
                    onTap: () => _pickDateTime(context, isStart: true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _dateTimeTile(
                    context,
                    label: 'Waktu Selesai',
                    value: _endTime,
                    onTap: () => _pickDateTime(context, isStart: false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Lokasi',
                hintText: 'Masukkan lokasi kegiatan',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Deskripsi',
                hintText: 'Masukkan deskripsi kegiatan',
                prefixIcon: Icon(Icons.description_outlined),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 20),

            // Toggle publik / internal
            Text(
              'Visibilitas',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _visibilityButton(
                    context,
                    label: 'Publik',
                    subtitle: 'Semua orang bisa lihat',
                    icon: Icons.public_outlined,
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
                    subtitle: 'Hanya anggota & admin',
                    icon: Icons.lock_outline,
                    isActive: !_isPublic,
                    color: AppColors.primary,
                    onTap: () => setState(() => _isPublic = false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Division selector
            Text(
              'Divisi Terkait',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
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
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                  : Text(_isEdit ? 'Simpan Perubahan' : 'Tambah Kegiatan'),
            )),
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
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color:
              isActive ? color.withOpacity(0.1) : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? color : Theme.of(context).dividerColor,
            width: isActive ? 1.5 : 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon,
                color: isActive
                    ? color
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                size: 20),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: isActive ? color : null,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall,
            ),
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
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 4),
            Text(
              value != null
                  ? '${value.day.toString().padLeft(2, '0')}-'
                      '${value.month.toString().padLeft(2, '0')}-'
                      '${value.year} '
                      '${value.hour.toString().padLeft(2, '0')}:'
                      '${value.minute.toString().padLeft(2, '0')}'
                  : 'Pilih tanggal',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDateTime(BuildContext context,
      {required bool isStart}) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
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
    });
  }

  void _handleSave() {
    if (_titleController.text.trim().isEmpty) {
      _controller.errorMessage.value = 'Nama kegiatan wajib diisi';
      return;
    }
    if (_startTime == null || _endTime == null) {
      _controller.errorMessage.value = 'Waktu mulai dan selesai wajib diisi';
      return;
    }

    if (_isEdit) {
      _controller.updateEvent(
        id: _editEvent!.id,
        title: _titleController.text.trim(),
        location: _locationController.text.trim(),
        description: _descriptionController.text.trim(),
        startTime: _startTime!,
        endTime: _endTime!,
        isPublic: _isPublic,
        divisions: _selectedDivisions,
      );
    } else {
      _controller.createEvent(
        title: _titleController.text.trim(),
        location: _locationController.text.trim(),
        description: _descriptionController.text.trim(),
        startTime: _startTime!,
        endTime: _endTime!,
        isPublic: _isPublic,
        divisions: _selectedDivisions,
      );
    }
  }
}
