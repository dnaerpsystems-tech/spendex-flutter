import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  VoiceInputNotifier() : super(const VoiceInputData.initial());

  final _parserService = VoiceParserService.instance;

  // TODO: Replace with actual speech_to_text implementation
  // For now, we simulate voice recognition with mock data

  /// Start listening for voice input
  Future<void> startListening() async {
    state = state.copyWith(
      state: VoiceInputState.listening,
      recognizedText: '',
      clearParsedData: true,
      clearError: true,
    );

    // TODO: Implement actual speech recognition
    // This is a mock implementation that simulates listening
    // In production, use the speech_to_text package:
    //
    // final speech = SpeechToText();
    // bool available = await speech.initialize();
    // if (available) {
    //   speech.listen(
    //     onResult: (result) {
    //       _onSpeechResult(result.recognizedWords);
    //     },
    //     onSoundLevelChange: (level) {
    //       // Update UI with sound level for visual feedback
    //     },
    //   );
    // }
  }

  /// Stop listening and process the result
  Future<void> stopListening() async {
    if (state.state != VoiceInputState.listening) return;

    state = state.copyWith(state: VoiceInputState.processing);

    // TODO: In production, stop actual speech recognition
    // speech.stop();

    // If we have recognized text, parse it
    if (state.recognizedText.isNotEmpty) {
      _parseRecognizedText(state.recognizedText);
    } else {
      state = state.copyWith(
        state: VoiceInputState.error,
        errorMessage: 'No speech detected. Please try again.',
      );
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
    for (int i = 0; i <= text.length; i++) {
      await Future.delayed(const Duration(milliseconds: 50));
      if (state.state != VoiceInputState.listening) break;
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
    state = const VoiceInputData.initial();
  }

  /// Get example commands
  List<String> getExampleCommands() {
    return _parserService.getExampleCommands();
  }
}

/// Voice Input Provider
final voiceInputProvider =
    StateNotifierProvider<VoiceInputNotifier, VoiceInputData>((ref) {
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
