import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/member_controller.dart';
import '../../models/user_model.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';

class MemberFormPage extends StatefulWidget {
  const MemberFormPage({super.key});

  @override
  State<MemberFormPage> createState() => _MemberFormPageState();
}

class _MemberFormPageState extends State<MemberFormPage> {
  final _controller = Get.find<MemberController>();
  final UserModel? _editMember = Get.arguments as UserModel?;

  final _nameController = TextEditingController();
  final _nimController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _angkatanController = TextEditingController();
  final _passwordController = TextEditingController();

  final List<String> _selectedDivisions = [];
  bool _showPassword = false;
  bool get _isEdit => _editMember != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      _nameController.text = _editMember!.fullName;
      _nimController.text = _editMember!.nim;
      _emailController.text = _editMember!.email;
      _phoneController.text = _editMember!.phone ?? '';
      _angkatanController.text = _editMember!.angkatan ?? '';
      _selectedDivisions.addAll(_editMember!.divisions);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nimController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _angkatanController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Anggota' : 'Tambah Anggota'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar upload
            Center(
              child: GestureDetector(
                onTap: _controller.pickAvatar,
                child: Obx(() => CircleAvatar(
                      radius: 48,
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.1),
                      backgroundImage:
                          _controller.pickedAvatarFile.value != null
                              ? null
                              : null,
                      child: _controller.pickedAvatarFile.value == null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.camera_alt_outlined,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 24,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Foto',
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            )
                          : null,
                    )),
              ),
            ),
            const SizedBox(height: 24),

            // Form fields
            _buildField('Nama Lengkap', _nameController,
                hint: 'Masukkan nama lengkap', icon: Icons.person_outline),
            const SizedBox(height: 16),
            _buildField('NIM', _nimController,
                hint: 'Masukkan NIM',
                icon: Icons.badge_outlined,
                keyboardType: TextInputType.number,
                enabled: !_isEdit),
            const SizedBox(height: 16),
            _buildField('Email', _emailController,
                hint: 'Masukkan email',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 16),
            _buildField('Nomor HP', _phoneController,
                hint: 'Masukkan nomor HP',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone),
            const SizedBox(height: 16),
            _buildField('Angkatan', _angkatanController,
                hint: 'Contoh: 2024',
                icon: Icons.school_outlined,
                keyboardType: TextInputType.number),

            // Password — hanya untuk tambah baru
            if (!_isEdit) ...[
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: !_showPassword,
                decoration: InputDecoration(
                  labelText: 'Password Default',
                  hintText: 'Kosongkan untuk pakai NIM sebagai password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: GestureDetector(
                    onTap: () => setState(() => _showPassword = !_showPassword),
                    child: Icon(
                      _showPassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Division selector
            Text(
              'Divisi',
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

      // Save button sticky
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
                  : Text(_isEdit ? 'Simpan Perubahan' : 'Tambah Anggota'),
            )),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller, {
    String? hint,
    IconData? icon,
    TextInputType? keyboardType,
    bool enabled = true,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: icon != null ? Icon(icon) : null,
      ),
    );
  }

  void _handleSave() {
    if (_nameController.text.trim().isEmpty ||
        _nimController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty) {
      _controller.errorMessage.value = 'Nama, NIM, dan Email wajib diisi';
      return;
    }
    if (_selectedDivisions.isEmpty) {
      _controller.errorMessage.value = 'Pilih minimal satu divisi';
      return;
    }

    if (_isEdit) {
      _controller.updateMember(
        id: _editMember!.id,
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        angkatan: _angkatanController.text.trim(),
        divisions: _selectedDivisions,
      );
    } else {
      final password = _passwordController.text.trim().isEmpty
          ? _nimController.text.trim()
          : _passwordController.text.trim();

      _controller.createMember(
        nim: _nimController.text.trim(),
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        angkatan: _angkatanController.text.trim(),
        password: password,
        divisions: _selectedDivisions,
      );
    }
  }
}
