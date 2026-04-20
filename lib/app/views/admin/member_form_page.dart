import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/member_controller.dart';
import '../../controllers/auth_controller.dart';
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
  final _phoneController = TextEditingController();
  final _angkatanController = TextEditingController();
  final _passwordController = TextEditingController();

  final List<String> _selectedDivisions = [];
  bool _showPassword = false;
  bool _isBph = false; // status BPH, hanya bisa diubah oleh admin
  bool get _isEdit => _editMember != null;

  String? _nameError;
  String? _nimError;
  String? _phoneError;

  static final _validNameChars = RegExp(r"^[a-zA-Z\s'\-\.]+$");
  static final _validNimChars = RegExp(r'^[0-9]+$');
  static final _validPhoneChars = RegExp(r'^[0-9+\-\s\(\)]+$');

  @override
  void initState() {
    super.initState();
    _controller.errorMessage.value = '';
    if (_isEdit) {
      _nameController.text = _editMember!.fullName;
      _nimController.text = _editMember!.nim;
      _phoneController.text = _editMember!.phone ?? '';
      _angkatanController.text = _editMember!.angkatan ?? '';
      _selectedDivisions.addAll(_editMember!.divisions);
      _isBph = _editMember!.isBph;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nimController.dispose();
    _phoneController.dispose();
    _angkatanController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateName(String value) {
    final v = value.trim();
    if (v.isEmpty) return 'Nama lengkap tidak boleh kosong';
    if (!_validNameChars.hasMatch(v)) return 'Nama hanya boleh huruf dan spasi';
    return null;
  }

  String? _validateNim(String value) {
    final v = value.trim();
    if (v.isEmpty) return 'NIM tidak boleh kosong';
    if (!_validNimChars.hasMatch(v)) return 'NIM hanya boleh angka';
    if (v.length < 5) return 'NIM terlalu pendek (min. 5 digit)';
    return null;
  }

  String? _validatePhone(String value) {
    final v = value.trim();
    if (v.isEmpty) return null; // opsional
    if (!_validPhoneChars.hasMatch(v)) {
      return 'Nomor HP mengandung karakter tidak valid';
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
                _isEdit ? 'Edit Anggota' : 'Tambah Anggota',
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
                  // Avatar picker
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
                                  child:
                                      _controller.pickedAvatarFile.value == null
                                          ? Icon(Icons.person_rounded,
                                              color: colorScheme.primary
                                                  .withOpacity(0.5),
                                              size: 50)
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
                              child: const Icon(Icons.camera_alt_rounded,
                                  color: Colors.white, size: 18),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  _buildFormHeader('Informasi Pribadi'),
                  const SizedBox(height: 16),

                  // Nama
                  _buildField(context, 'Nama Lengkap', _nameController,
                      hint: 'Masukkan nama lengkap',
                      icon: Icons.person_outline_rounded,
                      errorText: _nameError,
                      onChanged: (v) =>
                          setState(() => _nameError = _validateName(v))),
                  const SizedBox(height: 16),

                  // NIM — nonaktif saat edit
                  _buildField(context, 'NIM', _nimController,
                      hint: 'Masukkan NIM (hanya angka)',
                      icon: Icons.badge_outlined,
                      errorText: _nimError, onChanged: (v) {
                    setState(() => _nimError = _validateNim(v));
                  }, keyboardType: TextInputType.number, enabled: !_isEdit),
                  const SizedBox(height: 8),

                  // Info email otomatis — update realtime saat NIM diketik
                  if (!_isEdit)
                    ValueListenableBuilder<TextEditingValue>(
                      valueListenable: _nimController,
                      builder: (_, value, __) {
                        final nim = value.text.trim();
                        final autoEmail = nim.isEmpty
                            ? 'NIM${AppConstants.supabaseEmailDomain}'
                            : '$nim${AppConstants.supabaseEmailDomain}';
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: colorScheme.primary.withOpacity(0.15)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.email_outlined,
                                  size: 16, color: colorScheme.primary),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Email login (otomatis)',
                                        style: TextStyle(
                                            color: colorScheme.primary,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 2),
                                    Text(autoEmail,
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                                fontWeight: FontWeight.w700)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: 16),

                  // Nomor HP
                  _buildField(context, 'Nomor HP', _phoneController,
                      hint: 'Opsional',
                      icon: Icons.phone_outlined,
                      errorText: _phoneError,
                      onChanged: (v) =>
                          setState(() => _phoneError = _validatePhone(v)),
                      keyboardType: TextInputType.phone),
                  const SizedBox(height: 16),

                  // Angkatan
                  _buildField(context, 'Angkatan', _angkatanController,
                      hint: 'Contoh: 2024',
                      icon: Icons.school_outlined,
                      keyboardType: TextInputType.number),

                  // Password — hanya saat tambah baru
                  if (!_isEdit) ...[
                    const SizedBox(height: 24),
                    _buildFormHeader('Keamanan'),
                    const SizedBox(height: 8),
                    // Info password default
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.warning.withOpacity(0.2)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline_rounded,
                              size: 16, color: AppColors.warning),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Kosongkan agar password default = NIM anggota. '
                              'Anggota wajib ganti password saat pertama login.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.warning,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _passwordController,
                      obscureText: !_showPassword,
                      autocorrect: false,
                      enableSuggestions: false,
                      decoration: InputDecoration(
                        labelText: 'Password Default',
                        hintText: 'Kosongkan = pakai NIM',
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        suffixIcon: IconButton(
                          onPressed: () =>
                              setState(() => _showPassword = !_showPassword),
                          icon: Icon(_showPassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),

                  // ── Toggle BPH — hanya tampil saat edit & pemanggil admin ──
                  Builder(builder: (context) {
                    final authController = Get.find<AuthController>();
                    final caller = authController.currentUser.value;
                    final callerIsAdmin = caller?.isAdmin ?? false;

                    if (!_isEdit || !callerIsAdmin) {
                      return const SizedBox.shrink();
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFormHeader('Hak Akses'),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withOpacity(0.04),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: colorScheme.primary.withOpacity(0.15)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.admin_panel_settings_rounded,
                                  color: _isBph
                                      ? colorScheme.primary
                                      : AppColors.textSecondary,
                                  size: 22),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Jadikan BPH',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: _isBph
                                            ? colorScheme.primary
                                            : AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'BPH bisa akses halaman admin kecuali keuangan',
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color: AppColors.textSecondary,
                                        height: 1.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: _isBph,
                                onChanged: (val) =>
                                    setState(() => _isBph = val),
                                activeThumbColor: colorScheme.primary,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    );
                  }),

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
                              color:
                                  isSelected ? color : color.withOpacity(0.15),
                              width: 1.5,
                            ),
                          ),
                          child: Text(division,
                              style: TextStyle(
                                  color: isSelected ? Colors.white : color,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w600,
                                  fontSize: 13)),
                        ),
                      );
                    }).toList(),
                  ),

                  // Error dari controller
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
                          border: Border.all(
                              color: colorScheme.error.withOpacity(0.3)),
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
                                    fontWeight: FontWeight.w600),
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
                          strokeWidth: 2, color: Colors.white))
                  : Text(_isEdit ? 'Simpan Perubahan' : 'Tambah Anggota Baru',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700)),
            )),
      ),
    );
  }

  Widget _buildFormHeader(String title) {
    return Text(title,
        style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppColors.textSecondary,
            letterSpacing: 0.5));
  }

  Widget _buildField(
    BuildContext context,
    String label,
    TextEditingController controller, {
    String? hint,
    IconData? icon,
    String? errorText,
    ValueChanged<String>? onChanged,
    TextInputType? keyboardType,
    bool enabled = true,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      enabled: enabled,
      autocorrect: false,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        errorText: errorText,
        prefixIcon: icon != null ? Icon(icon) : null,
        filled: !enabled,
        fillColor:
            enabled ? null : Theme.of(context).dividerColor.withOpacity(0.1),
      ),
    );
  }

  Future<void> _handleSave() async {
    _controller.errorMessage.value = '';

    final nameErr = _validateName(_nameController.text);
    final nimErr = _isEdit ? null : _validateNim(_nimController.text);
    final phoneErr = _validatePhone(_phoneController.text);

    setState(() {
      _nameError = nameErr;
      _nimError = nimErr;
      _phoneError = phoneErr;
    });

    if (nameErr != null || nimErr != null || phoneErr != null) return;

    if (_selectedDivisions.isEmpty) {
      _controller.errorMessage.value = 'Pilih minimal satu divisi';
      return;
    }

    if (_isEdit) {
      // Jika status BPH berubah, panggil setBph dulu via Edge Function
      final authController = Get.find<AuthController>();
      final callerIsAdmin = authController.currentUser.value?.isAdmin ?? false;
      if (callerIsAdmin && _isBph != _editMember!.isBph) {
        await _controller.setBph(_editMember!.id, _isBph);
      }

      _controller.updateMember(
        id: _editMember!.id,
        fullName: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        angkatan: _angkatanController.text.trim(),
        divisions: _selectedDivisions,
      );
    } else {
      _controller.createMember(
        nim: _nimController.text.trim(),
        fullName: _nameController.text.trim(),
        password: _passwordController.text.trim(),
        phone: _phoneController.text.trim(),
        angkatan: _angkatanController.text.trim(),
        divisions: _selectedDivisions,
      );
    }
  }
}
