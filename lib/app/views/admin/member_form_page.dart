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
                _isEdit ? 'Edit Anggota' : 'Tambah Anggota',
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
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: _controller.pickAvatar,
                      child: Stack(
                        children: [
                          Obx(() => Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: colorScheme.primary.withOpacity(0.2),
                                    width: 2,
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: 50,
                                  backgroundColor:
                                      colorScheme.primary.withOpacity(0.08),
                                  backgroundImage:
                                      _controller.pickedAvatarFile.value != null
                                          ? null
                                          : null,
                                  child: _controller.pickedAvatarFile.value ==
                                          null
                                      ? Icon(
                                          Icons.person_rounded,
                                          color: colorScheme.primary
                                              .withOpacity(0.5),
                                          size: 50,
                                        )
                                      : null,
                                ),
                              )),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: colorScheme.primary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: theme.scaffoldBackgroundColor,
                                    width: 3),
                              ),
                              child: const Icon(
                                Icons.camera_alt_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  _buildFormHeader('Informasi Pribadi'),
                  const SizedBox(height: 16),

                  _buildField(context, 'Nama Lengkap', _nameController,
                      hint: 'Masukkan nama lengkap',
                      icon: Icons.person_outline_rounded),
                  const SizedBox(height: 16),
                  _buildField(context, 'NIM', _nimController,
                      hint: 'Masukkan NIM',
                      icon: Icons.badge_outlined,
                      keyboardType: TextInputType.number,
                      enabled: !_isEdit),
                  const SizedBox(height: 16),
                  _buildField(context, 'Email', _emailController,
                      hint: 'Masukkan email',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      enabled: !_isEdit),
                  const SizedBox(height: 16),
                  _buildField(context, 'Nomor HP', _phoneController,
                      hint: 'Masukkan nomor HP',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone),
                  const SizedBox(height: 16),
                  _buildField(context, 'Angkatan', _angkatanController,
                      hint: 'Contoh: 2024',
                      icon: Icons.school_outlined,
                      keyboardType: TextInputType.number),

                  if (!_isEdit) ...[
                    const SizedBox(height: 24),
                    _buildFormHeader('Keamanan'),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      obscureText: !_showPassword,
                      decoration: InputDecoration(
                        labelText: 'Password Default',
                        hintText: 'Kosongkan untuk pakai NIM',
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        suffixIcon: IconButton(
                          onPressed: () =>
                              setState(() => _showPassword = !_showPassword),
                          icon: Icon(
                            _showPassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),
                  _buildFormHeader('Divisi Organisasi'),
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
                        }),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? color : color.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected ? color : color.withOpacity(0.15),
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            division,
                            style: TextStyle(
                              color: isSelected ? Colors.white : color,
                              fontWeight:
                                  isSelected ? FontWeight.w700 : FontWeight.w600,
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
                  : Text(
                      _isEdit ? 'Simpan Perubahan' : 'Tambah Anggota Baru',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700),
                    ),
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

  Widget _buildField(
    BuildContext context,
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
        filled: !enabled,
        fillColor: enabled ? null : Theme.of(context).dividerColor.withOpacity(0.1),
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
