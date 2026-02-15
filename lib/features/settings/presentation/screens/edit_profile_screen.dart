import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../widgets/avatar_picker_sheet.dart';

/// Edit Profile Screen
///
/// Allows users to edit their profile information including:
/// - Profile photo (camera/gallery/remove)
/// - Full name (required, validated)
/// - Phone number (optional, validated for Indian format)
/// - Email address (read-only)
///
/// Features:
/// - Form validation with proper error messages
/// - Photo upload with loading states
/// - Unsaved changes detection with confirmation dialog
/// - Material 3 design with dark mode support
/// - Proper error handling and user feedback
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _imagePicker = ImagePicker();

  String? _avatarUrl;
  File? _avatarFile;
  bool _isLoading = false;
  bool _isDirty = false;
  bool _isUploadingPhoto = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    final user = ref.read(currentUserProvider);
    if (user != null) {
      _nameController.text = user.name;
      _phoneController.text = user.phone ?? '';
      _avatarUrl = user.avatarUrl;
    }
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }

    final trimmed = value.trim();

    if (trimmed.length < 2) {
      return 'Name must be at least 2 characters';
    }

    if (trimmed.length > 50) {
      return 'Name must be less than 50 characters';
    }

    final namePattern = RegExp(r"^[a-zA-Z\s\-']+$");
    if (!namePattern.hasMatch(trimmed)) {
      return 'Name can only contain letters, spaces, hyphens, and apostrophes';
    }

    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final trimmed = value.trim();

    if (trimmed.startsWith('+91')) {
      return 'Please enter phone without country code';
    }

    final phonePattern = RegExp(r'^[0-9]{10}$');
    if (!phonePattern.hasMatch(trimmed)) {
      return 'Please enter a valid 10-digit phone number';
    }

    return null;
  }

  Future<void> _handleCameraPhoto() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        await _uploadPhoto(File(image.path));
      }
    } catch (e) {
      if (!mounted) {
        return;
      }
      _showErrorSnackBar('Failed to capture photo: $e');
    }
  }

  Future<void> _handleGalleryPhoto() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        await _uploadPhoto(File(image.path));
      }
    } catch (e) {
      if (!mounted) {
        return;
      }
      _showErrorSnackBar('Failed to select photo: $e');
    }
  }

  Future<void> _uploadPhoto(File file) async {
    setState(() {
      _isUploadingPhoto = true;
      _avatarFile = file;
      _isDirty = true;
    });

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      setState(() {
        _avatarUrl = file.path;
      });

      if (!mounted) {
        return;
      }
      _showSuccessSnackBar('Photo updated successfully');
    } catch (e) {
      if (!mounted) {
        return;
      }
      _showErrorSnackBar('Failed to upload photo: $e');

      setState(() {
        _avatarFile = null;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingPhoto = false;
        });
      }
    }
  }

  Future<void> _handleRemovePhoto() async {
    setState(() {
      _isUploadingPhoto = true;
      _isDirty = true;
    });

    try {
      await Future.delayed(const Duration(milliseconds: 300));

      setState(() {
        _avatarUrl = null;
        _avatarFile = null;
      });

      if (!mounted) {
        return;
      }
      _showSuccessSnackBar('Photo removed successfully');
    } catch (e) {
      if (!mounted) {
        return;
      }
      _showErrorSnackBar('Failed to remove photo: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingPhoto = false;
        });
      }
    }
  }

  void _showAvatarPicker() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => AvatarPickerSheet(
        showRemoveOption: _avatarUrl != null || _avatarFile != null,
        onCameraSelected: _handleCameraPhoto,
        onGallerySelected: _handleGalleryPhoto,
        onRemoveSelected: _handleRemovePhoto,
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final name = _nameController.text.trim();
      final phone = _phoneController.text.trim();

      final user = ref.read(currentUserProvider);
      if (user == null) {
        throw Exception('User not found');
      }

      final updatedUser = user.copyWith(
        name: name,
        phone: phone.isEmpty ? null : phone,
        avatarUrl: _avatarUrl,
      );

      ref.read(authStateProvider.notifier).updateUser(updatedUser);

      setState(() {
        _isDirty = false;
      });

      if (!mounted) {
        return;
      }

      _showSuccessSnackBar('Profile updated successfully');

      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) {
        return;
      }
      context.pop();
    } catch (e) {
      if (!mounted) {
        return;
      }
      _showErrorSnackBar('Failed to update profile: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<bool> _onWillPop() async {
    if (!_isDirty) {
      return true;
    }

    final shouldDiscard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard Changes?'),
        content: const Text('You have unsaved changes. Do you want to discard them?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: SpendexColors.expense,
            ),
            child: const Text('Discard'),
          ),
        ],
      ),
    );

    return shouldDiscard ?? false;
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: SpendexColors.income,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: SpendexColors.expense,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) {
      return '?';
    }
    if (parts.length == 1) {
      return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '?';
    }
    return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryTextColor =
        isDark ? SpendexColors.darkTextSecondary : SpendexColors.lightTextSecondary;
    final user = ref.watch(currentUserProvider);

    return PopScope(
      canPop: !_isDirty,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }

        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          context.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Profile'),
          centerTitle: true,
          actions: [
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else
              IconButton(
                icon: const Icon(Iconsax.tick_circle),
                onPressed: _saveProfile,
                tooltip: 'Save Profile',
              ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(SpendexTheme.spacing2xl),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Stack(
                    children: [
                      _buildAvatar(isDark),
                      if (_isUploadingPhoto)
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black.withValues(alpha: 0.5),
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            ),
                          ),
                        )
                      else
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: _buildEditButton(isDark),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: SpendexTheme.spacing3xl),
                TextFormField(
                  controller: _nameController,
                  enabled: !_isLoading,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    hintText: 'Enter your full name',
                    prefixIcon: const Icon(Iconsax.user),
                    helperText: 'This is how your name will appear in the app',
                    helperStyle: SpendexTheme.labelMedium.copyWith(
                      color: secondaryTextColor,
                      fontSize: 11,
                    ),
                  ),
                  textCapitalization: TextCapitalization.words,
                  keyboardType: TextInputType.name,
                  validator: _validateName,
                  onChanged: (value) {
                    setState(() {
                      _isDirty = true;
                    });
                  },
                ),
                const SizedBox(height: SpendexTheme.spacingLg),
                TextFormField(
                  controller: _phoneController,
                  enabled: !_isLoading,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    hintText: 'Enter your phone number',
                    prefixIcon: const Icon(Iconsax.mobile),
                    helperText: 'Optional - 10 digit Indian phone number',
                    helperStyle: SpendexTheme.labelMedium.copyWith(
                      color: secondaryTextColor,
                      fontSize: 11,
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  validator: _validatePhone,
                  onChanged: (value) {
                    setState(() {
                      _isDirty = true;
                    });
                  },
                ),
                const SizedBox(height: SpendexTheme.spacingLg),
                TextFormField(
                  initialValue: user?.email ?? '',
                  enabled: false,
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    hintText: 'your.email@example.com',
                    prefixIcon: const Icon(Iconsax.sms),
                    helperText: 'Email cannot be changed',
                    helperStyle: SpendexTheme.labelMedium.copyWith(
                      color: secondaryTextColor,
                      fontSize: 11,
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
                      borderSide: BorderSide(
                        color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: SpendexTheme.spacing3xl),
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Save Changes'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(bool isDark) {
    final user = ref.watch(currentUserProvider);
    final hasPhoto = (_avatarFile != null) || (_avatarUrl != null && _avatarUrl!.isNotEmpty);

    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: hasPhoto
            ? null
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  SpendexColors.primary,
                  SpendexColors.primaryDark,
                ],
              ),
        border: Border.all(
          color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: SpendexColors.primary.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: hasPhoto
          ? ClipOval(
              child: _avatarFile != null
                  ? Image.file(
                      _avatarFile!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildInitials(user?.name ?? '?');
                      },
                    )
                  : CachedNetworkImage(
                      imageUrl: _avatarUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      errorWidget: (context, url, error) =>
                          _buildInitials(user?.name ?? '?'),
                    ),
            )
          : _buildInitials(user?.name ?? '?'),
    );
  }

  Widget _buildInitials(String name) {
    final initials = _getInitials(name);
    return Center(
      child: Text(
        initials,
        style: SpendexTheme.displayLarge.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 48,
        ),
      ),
    );
  }

  Widget _buildEditButton(bool isDark) {
    return Material(
      color: SpendexColors.primary,
      shape: const CircleBorder(),
      elevation: 4,
      shadowColor: SpendexColors.primary.withValues(alpha: 0.4),
      child: InkWell(
        onTap: _isLoading ? null : _showAvatarPicker,
        customBorder: const CircleBorder(),
        child: Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Iconsax.camera,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }
}
