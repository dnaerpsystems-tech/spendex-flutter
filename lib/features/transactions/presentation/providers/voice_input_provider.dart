import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../../../core/utils/app_logger.dart';
import '../../data/models/transaction_model.dart';
import '../../data/services/voice_parser_service.dart';

/// Voice Input States
enum VoiceInputState {
  idle,
  listening,
  processing,
  parsed,
  error,
}

/// Voice Input Data
class VoiceInputData extends Equatable {
  const VoiceInputData({
    this.state = VoiceInputState.idle,
    this.recognizedText = '',
    this.parsedRequest,
    this.parsedAmount,
    this.parsedType,
    this.parsedCategory,
    this.parsedDescription,
    this.errorMessage,
  });

  const VoiceInputData.initial()
      : state = VoiceInputState.idle,
        recognizedText = '',
        parsedRequest = null,
        parsedAmount = null,
        parsedType = null,
        parsedCategory = null,
        parsedDescription = null,
        errorMessage = null;

  final VoiceInputState state;
  final String recognizedText;
  final CreateTransactionRequest? parsedRequest;
  final int? parsedAmount;
  final String? parsedType;
  final String? parsedCategory;
  final String? parsedDescription;
  final String? errorMessage;

  VoiceInputData copyWith({
    VoiceInputState? state,
    String? recognizedText,
    CreateTransactionRequest? parsedRequest,
    int? parsedAmount,
    String? parsedType,
    String? parsedCategory,
    String? parsedDescription,
    String? errorMessage,
    bool clearError = false,
    bool clearParsedData = false,
  }) {
    return VoiceInputData(
      state: state ?? this.state,
      recognizedText: recognizedText ?? this.recognizedText,
      parsedRequest: clearParsedData ? null : (parsedRequest ?? this.parsedRequest),
      parsedAmount: clearParsedData ? null : (parsedAmount ?? this.parsedAmount),
      parsedType: clearParsedData ? null : (parsedType ?? this.parsedType),
      parsedCategory: clearParsedData ? null : (parsedCategory ?? this.parsedCategory),
      parsedDescription: clearParsedData ? null : (parsedDescription ?? this.parsedDescription),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  /// Check if voice input is active
  bool get isActive => state == VoiceInputState.listening || state == VoiceInputState.processing;

  /// Check if result is ready
  bool get hasResult => state == VoiceInputState.parsed && parsedRequest != null;

  /// Check if there's an error
  bool get hasError => state == VoiceInputState.error;

  /// Get amount in rupees for display
  double? get amountInRupees => parsedAmount != null ? parsedAmount! / 100 : null;

  @override
  List<Object?> get props => [
        state,
        recognizedText,
        parsedRequest,
        parsedAmount,
        parsedType,
        parsedCategory,
        parsedDescription,
        errorMessage,
      ];
}

/// Voice Input Notifier
class VoiceInputNotifier extends StateNotifier<VoiceInputData> {
  VoiceInputNotifier() : super(const VoiceInputData.initial()) {
    _initializeSpeech();
  }

  final _parserService = VoiceParserService.instance;
  final SpeechToText _speech = SpeechToText();
  bool _isInitialized = false;
  double _currentSoundLevel = 0;

  /// Initialize speech recognition
  Future<void> _initializeSpeech() async {
    try {
      _isInitialized = await _speech.initialize(
        onError: _onSpeechError,
        onStatus: _onSpeechStatus,
      );

      if (!_isInitialized) {
        state = state.copyWith(
          state: VoiceInputState.error,
          errorMessage: 'Speech recognition is not available on this device.',
        );
      }
    } catch (e) {
      state = state.copyWith(
        state: VoiceInputState.error,
        errorMessage: 'Failed to initialize speech recognition: $e',
      );
    }
  }

  /// Check if speech recognition permission is granted
  Future<bool> _checkPermission() async {
    if (!_isInitialized) {
      state = state.copyWith(
        state: VoiceInputState.error,
        errorMessage: 'Speech recognition is not initialized.',
      );
      return false;
    }

    final available = await _speech.hasPermission;

    if (!available) {
      state = state.copyWith(
        state: VoiceInputState.error,
        errorMessage: 'Microphone permission is required. Please grant permission in settings.',
      );
    }

    return available;
  }

  /// Start listening for voice input
  Future<void> startListening() async {
    // Check if already listening
    if (_speech.isListening) {
      return;
    }

    // Check initialization
    if (!_isInitialized) {
      state = state.copyWith(
        state: VoiceInputState.error,
        errorMessage: 'Speech recognition is not initialized. Please restart the app.',
      );
      return;
    }

    // Check permissions
    final hasPermission = await _checkPermission();
    if (!hasPermission) {
      return;
    }

    // Reset state for new listening session
    state = state.copyWith(
      state: VoiceInputState.listening,
      recognizedText: '',
      clearParsedData: true,
      clearError: true,
    );

    try {
      await _speech.listen(
        onResult: _onSpeechResult,
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        onSoundLevelChange: (level) => _currentSoundLevel = level,
        // ignore: deprecated_member_use
        cancelOnError: true,
      );
    } catch (e) {
      state = state.copyWith(
        state: VoiceInputState.error,
        errorMessage: 'Failed to start listening: $e',
      );
    }
  }

  /// Stop listening and process the result
  Future<void> stopListening() async {
    // Check if actually listening
    if (!_speech.isListening) {
      return;
    }

    // Stop speech recognition
    try {
      await _speech.stop();
      // The final result will be processed in _onSpeechResult callback
    } catch (e) {
      state = state.copyWith(
        state: VoiceInputState.error,
        errorMessage: 'Failed to stop listening: $e',
      );
    }
  }

  /// Handle speech recognition results
  void _onSpeechResult(SpeechRecognitionResult result) {
    // Only update if still in listening state
    if (state.state != VoiceInputState.listening) {
      return;
    }

    final recognizedText = result.recognizedWords;

    // Update state with recognized text
    state = state.copyWith(recognizedText: recognizedText);

    // If this is a final result, process it
    if (result.finalResult) {
      _processFinalResult(recognizedText);
    }
  }

  /// Process final speech result
  void _processFinalResult(String text) {
    if (text.isEmpty) {
      state = state.copyWith(
        state: VoiceInputState.error,
        errorMessage: 'No speech detected. Please try again.',
      );
      return;
    }

    // Haptic feedback
    HapticFeedback.lightImpact();

    // Move to processing state
    state = state.copyWith(state: VoiceInputState.processing);

    // Parse the recognized text
    _parseRecognizedText(text);
  }

  /// Get current sound level (for UI if needed)
  double get currentSoundLevel => _currentSoundLevel;

  /// Handle speech recognition errors
  void _onSpeechError(SpeechRecognitionError error) {
    String errorMessage;

    switch (error.errorMsg) {
      case 'error_no_match':
        errorMessage = 'Could not understand. Please speak clearly and try again.';
        break;
      case 'error_network':
        errorMessage = 'Network error. Check your internet connection.';
        break;
      case 'error_busy':
        errorMessage = 'Speech recognition is busy. Please try again.';
        break;
      case 'error_audio':
        errorMessage = 'Microphone error. Check your device settings.';
        break;
      case 'error_permission':
        errorMessage = 'Microphone permission denied. Please enable it in settings.';
        break;
      case 'error_speech_timeout':
        errorMessage = 'No speech detected. Please try again.';
        break;
      default:
        errorMessage = 'Speech recognition error: ${error.errorMsg}';
    }

    state = state.copyWith(
      state: VoiceInputState.error,
      errorMessage: errorMessage,
    );
  }

  /// Handle speech recognition status changes
  void _onSpeechStatus(String status) {
    AppLogger.d('Speech status: $status');

    if (status == 'done' && state.state == VoiceInputState.listening) {
      if (state.recognizedText.isEmpty) {
        state = state.copyWith(
          state: VoiceInputState.error,
          errorMessage: 'No speech detected. Please try again.',
        );
      }
    }
  }

  /// Simulate speech recognition with example text (for demo)
  Future<void> simulateVoiceInput(String text) async {
    state = state.copyWith(
      state: VoiceInputState.listening,
      recognizedText: '',
      clearParsedData: true,
      clearError: true,
    );

    // Simulate typing effect
    for (var i = 0; i <= text.length; i++) {
      await Future.delayed(const Duration(milliseconds: 50));
      if (state.state != VoiceInputState.listening) {
        break;
      }
      state = state.copyWith(recognizedText: text.substring(0, i));
    }

    // Process after "speaking"
    await Future.delayed(const Duration(milliseconds: 500));
    state = state.copyWith(state: VoiceInputState.processing);

    await Future.delayed(const Duration(milliseconds: 500));
    _parseRecognizedText(text);
  }

  /// Update recognized text (called during speech recognition)
  void updateRecognizedText(String text) {
    if (state.state == VoiceInputState.listening) {
      state = state.copyWith(recognizedText: text);
    }
  }

  /// Parse the recognized text into transaction data
  void _parseRecognizedText(String text) {
    final parsedRequest = _parserService.parseVoiceInput(text);

    if (parsedRequest != null && _parserService.isValidTransaction(parsedRequest)) {
      final amount = _parserService.extractAmount(text);
      final type = _parserService.detectType(text);
      final category = _parserService.extractCategory(text);
      final description = _parserService.extractDescription(text, type);

      state = state.copyWith(
        state: VoiceInputState.parsed,
        parsedRequest: parsedRequest,
        parsedAmount: amount,
        parsedType: type.label,
        parsedCategory: category,
        parsedDescription: description.isNotEmpty ? description : null,
      );
    } else {
      state = state.copyWith(
        state: VoiceInputState.error,
        errorMessage: 'Could not understand the transaction. Please try phrases like:\n'
            '"Spent 500 on groceries" or "Received 10000 salary"',
      );
    }
  }

  /// Edit parsed amount
  void updateParsedAmount(int amountInPaise) {
    if (state.parsedRequest != null) {
      final updatedRequest = CreateTransactionRequest(
        type: state.parsedRequest!.type,
        amount: amountInPaise,
        accountId: state.parsedRequest!.accountId,
        categoryId: state.parsedRequest!.categoryId,
        description: state.parsedRequest!.description,
        payee: state.parsedRequest!.payee,
        date: state.parsedRequest!.date,
      );
      state = state.copyWith(
        parsedRequest: updatedRequest,
        parsedAmount: amountInPaise,
      );
    }
  }

  /// Reset to initial state
  void reset() {
    // Cancel any active listening
    if (_speech.isListening) {
      _speech.cancel();
    }

    state = const VoiceInputData.initial();
    _currentSoundLevel = 0;
  }

  /// Check if speech recognition is available
  bool get isSpeechAvailable => _isInitialized;

  /// Check if currently listening
  bool get isListening => _speech.isListening;

  /// Cancel listening without processing
  Future<void> cancelListening() async {
    if (_speech.isListening) {
      try {
        await _speech.cancel();
        state = state.copyWith(
          state: VoiceInputState.idle,
          recognizedText: '',
          clearParsedData: true,
          clearError: true,
        );
      } catch (e) {
        AppLogger.d('Error canceling speech: $e');
      }
    }
  }

  /// Retry initialization (can be called from UI)
  Future<void> retryInitialization() async {
    state = const VoiceInputData.initial();
    _isInitialized = false;
    await _initializeSpeech();
  }

  /// Get example commands
  List<String> getExampleCommands() {
    return _parserService.getExampleCommands();
  }
}

/// Voice Input Provider
final voiceInputProvider = StateNotifierProvider<VoiceInputNotifier, VoiceInputData>((ref) {
  return VoiceInputNotifier();
});

/// Voice Input State Provider (convenience)
final voiceInputStateProvider = Provider<VoiceInputState>((ref) {
  return ref.watch(voiceInputProvider).state;
});

/// Parsed Transaction Provider
final parsedTransactionProvider = Provider<CreateTransactionRequest?>((ref) {
  return ref.watch(voiceInputProvider).parsedRequest;
});
