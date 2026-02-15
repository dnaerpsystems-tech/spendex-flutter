import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../app/theme.dart';
import '../providers/pdf_import_provider.dart';
import '../widgets/import_progress_indicator.dart';

/// PDF/CSV Import Screen
/// Allows users to upload bank statements for transaction extraction
class PdfImportScreen extends ConsumerStatefulWidget {
  const PdfImportScreen({super.key});

  @override
  ConsumerState<PdfImportScreen> createState() => _PdfImportScreenState();
}

class _PdfImportScreenState extends ConsumerState<PdfImportScreen> {
  File? _selectedFile;
  String? _fileError;

  // File validation constraints
  static const int _maxFileSizeBytes = 10 * 1024 * 1024; // 10 MB
  static const List<String> _allowedExtensions = ['pdf', 'csv'];

  @override
  void dispose() {
    // Clear any import state when leaving the screen
    ref.read(pdfImportProvider.notifier).clearCurrentImport();
    super.dispose();
  }

  Future<void> _pickFile() async {
    setState(() {
      _selectedFile = null;
      _fileError = null;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: _allowedExtensions,
      );

      if (result == null || result.files.isEmpty) {
        // User cancelled the picker
        return;
      }

      final pickedFile = result.files.first;

      // Validate file path exists
      if (pickedFile.path == null) {
        setState(() {
          _fileError = 'Invalid file selected';
        });
        return;
      }

      final file = File(pickedFile.path!);

      // Validate file exists (sync check for better performance)
      if (!file.existsSync()) {
        setState(() {
          _fileError = 'File does not exist';
        });
        return;
      }

      // Validate file size (sync check for better performance)
      final fileSize = file.lengthSync();
      if (fileSize > _maxFileSizeBytes) {
        setState(() {
          _fileError = 'File size exceeds 10 MB limit (${_formatFileSize(fileSize)})';
        });
        return;
      }

      // Validate file extension
      final extension = pickedFile.extension?.toLowerCase();
      if (extension == null || !_allowedExtensions.contains(extension)) {
        setState(() {
          _fileError = 'Only PDF and CSV files are supported';
        });
        return;
      }

      setState(() {
        _selectedFile = file;
        _fileError = null;
      });
    } catch (e) {
      setState(() {
        _fileError = 'Failed to pick file: $e';
      });
    }
  }

  Future<void> _uploadFile() async {
    if (_selectedFile == null) {
      setState(() {
        _fileError = 'Please select a file first';
      });
      return;
    }

    final extension = _selectedFile!.path.split('.').last.toLowerCase();

    try {
      // Upload file based on type
      final importModel = extension == 'pdf'
          ? await ref.read(pdfImportProvider.notifier).uploadPdf(_selectedFile!)
          : await ref.read(pdfImportProvider.notifier).uploadCsv(_selectedFile!, {});

      if (!mounted) {
        return;
      }

      if (importModel != null) {
        // Upload successful, navigate to preview screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File uploaded successfully'),
            backgroundColor: SpendexColors.income,
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Navigate to import preview screen
        context.go('/bank-import/preview/${importModel.id}');
      } else {
        // Upload failed, show error
        final error = ref.read(pdfImportProvider).error;
        _showErrorSnackBar(error ?? 'Upload failed');
      }
    } catch (e) {
      if (!mounted) {
        return;
      }
      _showErrorSnackBar('Upload error: $e');
    }
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

  String _formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    }
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final importState = ref.watch(pdfImportProvider);

    return Scaffold(
      backgroundColor: isDark ? SpendexColors.darkBackground : SpendexColors.lightBackground,
      appBar: AppBar(
        title: const Text('PDF/CSV Import'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: importState.isUploading
            ? Center(
                child: ImportProgressIndicator(
                  progress: importState.uploadProgress,
                  message: 'Uploading file...',
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Text(
                      'Upload Bank Statement',
                      style: SpendexTheme.headlineMedium.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Upload your bank statement in PDF or CSV format to automatically extract transactions',
                      style: SpendexTheme.bodyMedium.copyWith(
                        color: isDark
                            ? SpendexColors.darkTextSecondary
                            : SpendexColors.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // File picker button
                    GestureDetector(
                      onTap: _pickFile,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: isDark ? SpendexColors.darkCard : SpendexColors.lightCard,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _fileError != null
                                ? SpendexColors.expense
                                : (_selectedFile != null
                                    ? SpendexColors.primary
                                    : (isDark
                                        ? SpendexColors.darkBorder
                                        : SpendexColors.lightBorder)),
                            width: _selectedFile != null ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: (_fileError != null
                                        ? SpendexColors.expense
                                        : SpendexColors.primary)
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(40),
                              ),
                              child: Center(
                                child: Icon(
                                  _fileError != null
                                      ? Iconsax.close_circle
                                      : (_selectedFile != null
                                          ? Iconsax.document_text
                                          : Iconsax.document_upload),
                                  size: 40,
                                  color: _fileError != null
                                      ? SpendexColors.expense
                                      : SpendexColors.primary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            if (_selectedFile == null) ...[
                              Text(
                                'Choose File',
                                style: SpendexTheme.titleMedium.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap to select PDF or CSV file',
                                style: SpendexTheme.bodyMedium.copyWith(
                                  color: isDark
                                      ? SpendexColors.darkTextSecondary
                                      : SpendexColors.lightTextSecondary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ] else ...[
                              Text(
                                _selectedFile!.path.split('/').last,
                                style: SpendexTheme.titleMedium.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              FutureBuilder<int>(
                                future: _selectedFile!.length(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return Text(
                                      _formatFileSize(snapshot.data!),
                                      style: SpendexTheme.bodyMedium.copyWith(
                                        color: isDark
                                            ? SpendexColors.darkTextSecondary
                                            : SpendexColors.lightTextSecondary,
                                      ),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    // Error message
                    if (_fileError != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: SpendexColors.expense.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: SpendexColors.expense.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Iconsax.danger,
                              color: SpendexColors.expense,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _fileError!,
                                style: SpendexTheme.bodyMedium.copyWith(
                                  color: SpendexColors.expense,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // File requirements info
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: SpendexColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: SpendexColors.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Iconsax.info_circle,
                                color: SpendexColors.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'File Requirements',
                                style: SpendexTheme.titleMedium.copyWith(
                                  color: SpendexColors.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildRequirement('Supported formats: PDF, CSV'),
                          const SizedBox(height: 8),
                          _buildRequirement('Maximum file size: 10 MB'),
                          const SizedBox(height: 8),
                          _buildRequirement(
                            'Supported banks: HDFC, ICICI, SBI, Axis, Kotak, and more',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Upload button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _selectedFile != null && _fileError == null ? _uploadFile : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: SpendexColors.primary,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: SpendexColors.primary.withValues(alpha: 0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Iconsax.document_upload,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Upload & Process',
                              style: SpendexTheme.titleMedium.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildRequirement(String text) {
    return Row(
      children: [
        const Icon(
          Iconsax.tick_circle,
          color: SpendexColors.primary,
          size: 16,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: SpendexTheme.bodyMedium.copyWith(
              color: SpendexColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}
