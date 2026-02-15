import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/app_logger.dart';
import '../../data/models/transaction_model.dart';
import '../../data/services/receipt_parser_service.dart';

/// Receipt scanning state
enum ReceiptScanState {
  idle,
  capturing,
  processing,
  extracted,
  error,
}

/// Extracted receipt data
class ExtractedReceiptData {
  const ExtractedReceiptData({
    this.merchantName,
    this.amount,
    this.date,
    this.items = const [],
    this.category,
  });

  final String? merchantName;
  final int? amount; // in paise
  final DateTime? date;
  final List<String> items;
  final String? category;

  double? get amountInRupees => amount != null ? amount! / 100 : null;
}

/// Receipt Scanner Sheet for scanning receipts
class ReceiptScannerSheet extends ConsumerStatefulWidget {
  const ReceiptScannerSheet({
    required this.onReceiptScanned,
    super.key,
  });

  final ValueChanged<CreateTransactionRequest?> onReceiptScanned;

  @override
  ConsumerState<ReceiptScannerSheet> createState() => _ReceiptScannerSheetState();
}

class _ReceiptScannerSheetState extends ConsumerState<ReceiptScannerSheet>
    with SingleTickerProviderStateMixin {
  ReceiptScanState _state = ReceiptScanState.idle;
  // ignore: unused_field
  ExtractedReceiptData? _extractedData;
  String? _errorMessage;

  late AnimationController _scanAnimationController;
  late Animation<double> _scanAnimation;

  // Editable fields for extracted data
  final _amountController = TextEditingController();
  final _merchantController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  // ignore: unused_field
  final __currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _scanAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _scanAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _scanAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _scanAnimationController.dispose();
    _amountController.dispose();
    _merchantController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _captureFromCamera() async {
    setState(() {
      _state = ReceiptScanState.capturing;
      _errorMessage = null;
    });

    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 90,
      );

      if (image != null) {
        await _processImage(image.path);
      } else {
        // User cancelled
        setState(() {
          _state = ReceiptScanState.idle;
        });
      }
    } on PlatformException catch (e) {
      setState(() {
        _state = ReceiptScanState.error;
        _errorMessage = e.code == 'camera_access_denied'
            ? 'Camera permission denied. Please enable in settings.'
            : 'Failed to access camera: ${e.message}';
      });
    } catch (e) {
      setState(() {
        _state = ReceiptScanState.error;
        _errorMessage = 'Failed to capture image. Please try again.';
      });
    }
  }

  Future<void> _pickFromGallery() async {
    setState(() {
      _state = ReceiptScanState.capturing;
      _errorMessage = null;
    });

    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 90,
      );

      if (image != null) {
        await _processImage(image.path);
      } else {
        // User cancelled
        setState(() {
          _state = ReceiptScanState.idle;
        });
      }
    } on PlatformException catch (e) {
      setState(() {
        _state = ReceiptScanState.error;
        _errorMessage = e.code == 'photo_access_denied'
            ? 'Photo library permission denied. Please enable in settings.'
            : 'Failed to access gallery: ${e.message}';
      });
    } catch (e) {
      setState(() {
        _state = ReceiptScanState.error;
        _errorMessage = 'Failed to select image. Please try again.';
      });
    }
  }

  Future<void> _processImage(String imagePath) async {
    setState(() {
      _state = ReceiptScanState.processing;
      _errorMessage = null;
    });

    unawaited(_scanAnimationController.repeat());
    TextRecognizer? textRecognizer;

    try {
      // Create input image from file
      final inputImage = InputImage.fromFilePath(imagePath);

      // Initialize text recognizer
      textRecognizer = TextRecognizer();

      // Perform OCR
      final recognizedText = await textRecognizer.processImage(inputImage);

      // Check if any text was recognized
      if (recognizedText.text.isEmpty) {
        throw Exception(
          'No text found in image. Please ensure the receipt is clear and well-lit.',
        );
      }

      // Parse the recognized text
      await _parseReceiptText(recognizedText.text);
    } on PlatformException catch (e) {
      _handleOcrError('OCR failed: ${e.message ?? 'Unknown platform error'}');
    } catch (e) {
      _handleOcrError(e.toString());
    } finally {
      // Clean up
      _scanAnimationController.stop();
      unawaited(textRecognizer?.close());

      // Delete temporary image file to free up space (sync for better performance)
      try {
        final file = File(imagePath);
        if (file.existsSync()) {
          file.deleteSync();
        }
      } catch (_) {
        // Ignore cleanup errors
      }
    }
  }

  void _handleOcrError(String error) {
    if (kDebugMode) {
      AppLogger.d('OCR Error: $error');
    }

    setState(() {
      _state = ReceiptScanState.error;
      _errorMessage = error.contains('No text found')
          ? 'Could not read text from image. Please try with a clearer photo.'
          : 'Failed to process receipt. Please try again with better lighting.';
    });
  }

  Future<void> _parseReceiptText(String ocrText) async {
    if (kDebugMode) {
      AppLogger.d('OCR Text: $ocrText');
    }

    try {
      // Parse using the service
      final parserService = ReceiptParserService.instance;
      final extractedData = parserService.parseReceiptText(ocrText);

      if (kDebugMode) {
        AppLogger.d('Parsed Amount: ${extractedData.amount}');
        AppLogger.d('Parsed Merchant: ${extractedData.merchantName}');
      }

      // Validate that we got at least an amount
      if (extractedData.amount == null || extractedData.amount! <= 0) {
        throw Exception('Could not find transaction amount in receipt');
      }

      setState(() {
        _state = ReceiptScanState.extracted;
        _extractedData = extractedData;
        _populateFields(extractedData);
      });
    } catch (e) {
      if (kDebugMode) {
        AppLogger.d('Parse Error: $e');
      }

      setState(() {
        _state = ReceiptScanState.error;
        _errorMessage = 'Could not extract receipt data. Please enter manually.';
      });
    }
  }

  // ignore: unused_element
  ExtractedReceiptData _generateMockReceiptData() {
    final random = math.Random();
    final merchants = [
      'Big Bazaar',
      'DMart',
      'Reliance Fresh',
      "Spencer's",
      'More Supermarket',
      'Amazon',
      'Flipkart',
      'Swiggy',
      'Zomato',
    ];
    final categories = [
      'Groceries',
      'Shopping',
      'Food & Dining',
      'Electronics',
    ];

    final amount = (random.nextInt(5000) + 100) * 100; // 100 to 5000 rupees in paise
    final daysAgo = random.nextInt(7);

    return ExtractedReceiptData(
      merchantName: merchants[random.nextInt(merchants.length)],
      amount: amount,
      date: DateTime.now().subtract(Duration(days: daysAgo)),
      items: [
        'Item 1',
        'Item 2',
        'Item 3',
      ],
      category: categories[random.nextInt(categories.length)],
    );
  }

  void _populateFields(ExtractedReceiptData data) {
    if (data.amount != null) {
      _amountController.text = (data.amount! / 100).toStringAsFixed(0);
    }
    if (data.merchantName != null) {
      _merchantController.text = data.merchantName!;
    }
    if (data.date != null) {
      _selectedDate = data.date!;
    }
    _descriptionController.text = 'Purchase at ${data.merchantName ?? 'store'}';
  }

  void _onConfirm() {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      setState(() {
        _errorMessage = 'Please enter a valid amount';
      });
      return;
    }

    final request = CreateTransactionRequest(
      type: TransactionType.expense,
      amount: (amount * 100).round(),
      accountId: '', // Will need to be set by the caller
      description: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
      payee: _merchantController.text.isNotEmpty ? _merchantController.text : null,
      date: _selectedDate,
    );

    widget.onReceiptScanned(request);
    Navigator.of(context).pop();
  }

  void _onCancel() {
    Navigator.of(context).pop();
  }

  void _onReset() {
    setState(() {
      _state = ReceiptScanState.idle;
      _extractedData = null;
      _errorMessage = null;
      _amountController.clear();
      _merchantController.clear();
      _descriptionController.clear();
      _selectedDate = DateTime.now();
    });
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark ? SpendexColors.darkSurface : SpendexColors.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Title
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: SpendexColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Iconsax.receipt,
                      color: SpendexColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Scan Receipt',
                          style: SpendexTheme.headlineMedium.copyWith(
                            color: isDark
                                ? SpendexColors.darkTextPrimary
                                : SpendexColors.lightTextPrimary,
                          ),
                        ),
                        Text(
                          'Capture or upload a receipt',
                          style: SpendexTheme.labelMedium.copyWith(
                            color: isDark
                                ? SpendexColors.darkTextSecondary
                                : SpendexColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _onCancel,
                    icon: const Icon(Iconsax.close_circle),
                  ),
                ],
              ),
            ),

            // Content based on state
            if (_state == ReceiptScanState.idle) _buildIdleState(isDark),
            if (_state == ReceiptScanState.capturing) _buildCapturingState(isDark),
            if (_state == ReceiptScanState.processing) _buildProcessingState(isDark),
            if (_state == ReceiptScanState.extracted) _buildExtractedState(isDark),
            if (_state == ReceiptScanState.error) _buildErrorState(isDark),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildIdleState(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Camera Preview Placeholder
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: isDark ? SpendexColors.darkBackground : SpendexColors.lightBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
                width: 2,
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Iconsax.receipt_2,
                        size: 64,
                        color: isDark
                            ? SpendexColors.darkTextTertiary
                            : SpendexColors.lightTextTertiary,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No receipt captured',
                        style: SpendexTheme.bodyMedium.copyWith(
                          color: isDark
                              ? SpendexColors.darkTextSecondary
                              : SpendexColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Corner markers
                Positioned(
                  top: 16,
                  left: 16,
                  child: _buildCornerMarker(isDark, topLeft: true),
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: _buildCornerMarker(isDark, topRight: true),
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: _buildCornerMarker(isDark, bottomLeft: true),
                ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: _buildCornerMarker(isDark, bottomRight: true),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  isDark: isDark,
                  icon: Iconsax.camera,
                  label: 'Take Photo',
                  onTap: _captureFromCamera,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  isDark: isDark,
                  icon: Iconsax.gallery,
                  label: 'Gallery',
                  onTap: _pickFromGallery,
                  isPrimary: false,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Tips
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: SpendexColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Iconsax.info_circle,
                  color: SpendexColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'For best results, ensure the receipt is well-lit and fully visible in the frame.',
                    style: SpendexTheme.labelMedium.copyWith(
                      color: SpendexColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCornerMarker(
    bool isDark, {
    bool topLeft = false,
    bool topRight = false,
    bool bottomLeft = false,
    bool bottomRight = false,
  }) {
    return SizedBox(
      width: 24,
      height: 24,
      child: CustomPaint(
        painter: _CornerMarkerPainter(
          color: SpendexColors.primary,
          topLeft: topLeft,
          topRight: topRight,
          bottomLeft: bottomLeft,
          bottomRight: bottomRight,
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required bool isDark,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isPrimary = true,
  }) {
    return Material(
      color: isPrimary
          ? SpendexColors.primary
          : (isDark ? SpendexColors.darkCard : SpendexColors.lightCard),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: isPrimary
                ? null
                : Border.all(
                    color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
                  ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: isPrimary
                    ? Colors.white
                    : (isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: SpendexTheme.titleMedium.copyWith(
                  color: isPrimary
                      ? Colors.white
                      : (isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCapturingState(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: SpendexColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: CircularProgressIndicator(
                color: SpendexColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Capturing...',
            style: SpendexTheme.titleMedium.copyWith(
              color: isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingState(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        children: [
          // Scanning animation
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: isDark ? SpendexColors.darkBackground : SpendexColors.lightBackground,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              children: [
                // Placeholder receipt
                Center(
                  child: Icon(
                    Iconsax.receipt_item,
                    size: 80,
                    color: isDark
                        ? SpendexColors.darkTextTertiary.withValues(alpha: 0.3)
                        : SpendexColors.lightTextTertiary.withValues(alpha: 0.3),
                  ),
                ),
                // Scanning line animation
                AnimatedBuilder(
                  animation: _scanAnimation,
                  builder: (context, child) {
                    return Positioned(
                      top: _scanAnimation.value * 160,
                      left: 20,
                      right: 20,
                      child: Container(
                        height: 3,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Colors.transparent,
                              SpendexColors.primary,
                              Colors.transparent,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: SpendexColors.primary.withValues(alpha: 0.5),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: SpendexColors.primary,
                  strokeWidth: 2,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Extracting data from receipt...',
                style: SpendexTheme.titleMedium.copyWith(
                  color: SpendexColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExtractedState(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Success message
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: SpendexColors.income.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: SpendexColors.income.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Iconsax.tick_circle5,
                    color: SpendexColors.income,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Receipt data extracted successfully!',
                    style: SpendexTheme.bodyMedium.copyWith(
                      color: SpendexColors.income,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Editable Fields
          Text(
            'Verify & Edit Details',
            style: SpendexTheme.titleMedium.copyWith(
              color: isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 16),

          // Amount Field
          _buildTextField(
            isDark: isDark,
            controller: _amountController,
            label: 'Amount',
            prefix: '₹',
            keyboardType: TextInputType.number,
            icon: Iconsax.money,
          ),
          const SizedBox(height: 12),

          // Merchant Field
          _buildTextField(
            isDark: isDark,
            controller: _merchantController,
            label: 'Merchant',
            icon: Iconsax.shop,
          ),
          const SizedBox(height: 12),

          // Description Field
          _buildTextField(
            isDark: isDark,
            controller: _descriptionController,
            label: 'Description',
            icon: Iconsax.document_text,
          ),
          const SizedBox(height: 12),

          // Date Field
          GestureDetector(
            onTap: _selectDate,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? SpendexColors.darkBackground : SpendexColors.lightBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Iconsax.calendar,
                    color:
                        isDark ? SpendexColors.darkTextSecondary : SpendexColors.lightTextSecondary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Date',
                        style: SpendexTheme.labelMedium.copyWith(
                          color: isDark
                              ? SpendexColors.darkTextSecondary
                              : SpendexColors.lightTextSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate),
                        style: SpendexTheme.bodyMedium.copyWith(
                          color: isDark
                              ? SpendexColors.darkTextPrimary
                              : SpendexColors.lightTextPrimary,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Icon(
                    Iconsax.arrow_right_3,
                    color:
                        isDark ? SpendexColors.darkTextTertiary : SpendexColors.lightTextTertiary,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _onReset,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(
                      color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
                    ),
                  ),
                  child: const Text('Scan Again'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _onConfirm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Iconsax.tick_circle, size: 20),
                      SizedBox(width: 8),
                      Text('Add Transaction'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required bool isDark,
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? prefix,
    TextInputType? keyboardType,
  }) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark ? SpendexColors.darkBackground : SpendexColors.lightBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
        ),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: SpendexTheme.bodyMedium.copyWith(
          color: isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary,
        ),
        decoration: InputDecoration(
          labelText: label,
          prefixText: prefix,
          prefixIcon: Icon(
            icon,
            size: 20,
            color: isDark ? SpendexColors.darkTextSecondary : SpendexColors.lightTextSecondary,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: SpendexColors.expense.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Iconsax.warning_2,
              color: SpendexColors.expense,
              size: 40,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Failed to scan receipt',
            style: SpendexTheme.titleMedium.copyWith(
              color: SpendexColors.expense,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage ?? 'Please try again with a clearer image',
            style: SpendexTheme.bodyMedium.copyWith(
              color: isDark ? SpendexColors.darkTextSecondary : SpendexColors.lightTextSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _onReset,
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for corner markers
class _CornerMarkerPainter extends CustomPainter {
  _CornerMarkerPainter({
    required this.color,
    this.topLeft = false,
    this.topRight = false,
    this.bottomLeft = false,
    this.bottomRight = false,
  });

  final Color color;
  final bool topLeft;
  final bool topRight;
  final bool bottomLeft;
  final bool bottomRight;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();

    if (topLeft) {
      path
        ..moveTo(0, size.height)
        ..lineTo(0, 0)
        ..lineTo(size.width, 0);
    } else if (topRight) {
      path
        ..moveTo(0, 0)
        ..lineTo(size.width, 0)
        ..lineTo(size.width, size.height);
    } else if (bottomLeft) {
      path
        ..moveTo(0, 0)
        ..lineTo(0, size.height)
        ..lineTo(size.width, size.height);
    } else if (bottomRight) {
      path
        ..moveTo(size.width, 0)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
