import 'package:flutter_tts/flutter_tts.dart';
import 'package:task/model/voice_model.dart';


class TTSController {
  final FlutterTts _flutterTts = FlutterTts();
  List<VoiceModel> voices = [];
  int currentVoiceIndex = 0;

  // Predefined languages with their locale codes
  static const Map<String, String> supportedLanguages = {
    'English': 'en-US',
    'French': 'fr-FR',
    'Spanish': 'es-ES',
    'German': 'de-DE',
    'UK English': 'en-GB',
  };

  Future<void> initVoices() async {
    try {
      print('Initializing TTS voices...');
      
      // First, try to get available voices
      final rawVoices = await _flutterTts.getVoices;
      print('Raw voices type: ${rawVoices.runtimeType}');
      
      if (rawVoices is List) {
        voices = rawVoices
            .where((v) => v is Map)
            .map((v) {
              try {
                return VoiceModel.fromMap(Map<String, dynamic>.from(v));
              } catch (e) {
                print('Error parsing voice: $e');
                return null;
              }
            })
            .where((v) => v != null)
            .cast<VoiceModel>()
            .toList();
      } else {
        print('getVoices returned unexpected type: ${rawVoices.runtimeType}');
        voices = [];
      }
      
      print('Successfully initialized ${voices.length} voices');
      
      // Print all available voices for debugging
      for (int i = 0; i < voices.length; i++) {
        final voice = voices[i];
        print('Voice $i: ${voice.name} (${voice.locale}) - Raw data: ${voice.rawData}');
      }
      
    } catch (e) {
      print('Error initializing voices: $e');
      voices = [];
      // Don't throw here, let the app continue with empty voices
    }
  }

  List<String> getSupportedLanguages() {
    // Return the predefined language names
    return supportedLanguages.keys.toList();
  }

  List<VoiceModel> getVoicesByLocale(String locale) {
    final localeVoices = voices.where((v) => v.locale == locale).toList();
    print('Found ${localeVoices.length} voices for locale: $locale');
    for (int i = 0; i < localeVoices.length; i++) {
      print('  Voice $i: ${localeVoices[i].name}');
    }
    return localeVoices;
  }

  // Debug method to print available voices
  void printAvailableVoices() {
    print('Total voices found: ${voices.length}');
    for (int i = 0; i < voices.length; i++) {
      final voice = voices[i];
      print('Voice $i: ${voice.name} (${voice.locale})');
    }
  }

  Future<void> speak(String text, String languageName) async {
    try {
      print('Attempting to speak: "$text" in language: $languageName');
      
      // Get the locale code for the selected language
      final locale = supportedLanguages[languageName];
      if (locale == null) {
        throw Exception("Selected language '$languageName' is not supported.");
      }
      
      print('Using locale: $locale');

      // Try to find voices for the specific locale
      final availableVoices = getVoicesByLocale(locale);
      print('Available voices for $locale: ${availableVoices.length}');
      
      if (availableVoices.isNotEmpty) {
        // Use a specific voice if available - this enables voice switching
        final selectedVoiceIndex = currentVoiceIndex % availableVoices.length;
        final voice = availableVoices[selectedVoiceIndex];
        
        print('Current voice index: $currentVoiceIndex');
        print('Selected voice index: $selectedVoiceIndex');
        print('Using voice: ${voice.name}');
        
        // Set the voice
        await _flutterTts.setVoice(Map<String, String>.from(voice.rawData));
        print('Using voice ${selectedVoiceIndex + 1}/${availableVoices.length}: ${voice.name} for locale: $locale');
      } else {
        // If no specific voice found, just set the language and let system choose voice
        print('No specific voice found for locale: $locale, using system default');
        // Reset voice index since we're using system default
        currentVoiceIndex = 0;
      }
      
      // Set language and speech properties
      await _flutterTts.setLanguage(locale);
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setPitch(1.0);
      
      print('Starting speech...');
      // Speak the text
      await _flutterTts.speak(text);
      print('Speech completed successfully');

      // Increment voice index for next play (enables voice switching)
      currentVoiceIndex++;
      print('Voice index incremented to: $currentVoiceIndex');
      
    } catch (e) {
      print('Error in speak method: $e');
      throw Exception("Failed to speak text: ${e.toString()}");
    }
  }

  void stop() {
    _flutterTts.stop();
  }

  // Method to check if a language is supported by the device
  bool isLanguageSupported(String languageName) {
    final locale = supportedLanguages[languageName];
    if (locale == null) return false;
    
    final availableVoices = getVoicesByLocale(locale);
    return availableVoices.isNotEmpty;
  }

  // Method to get available voice count for a language
  int getVoiceCountForLanguage(String languageName) {
    final locale = supportedLanguages[languageName];
    if (locale == null) return 0;
    
    final availableVoices = getVoicesByLocale(locale);
    return availableVoices.length;
  }

  // Method to reset voice index for a language
  void resetVoiceIndex() {
    currentVoiceIndex = 0;
    print('Voice index reset to: $currentVoiceIndex');
  }
}
