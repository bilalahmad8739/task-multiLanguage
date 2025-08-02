import 'package:flutter_tts/flutter_tts.dart';
import 'package:task/model/voice_model.dart';


class TTSController {
  final FlutterTts _flutterTts = FlutterTts();
  List<VoiceModel> voices = [];
  int currentVoiceIndex = 0;

  Future<void> initVoices() async {
    try {
      final rawVoices = await _flutterTts.getVoices;
      
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
    } catch (e) {
      print('Error initializing voices: $e');
      voices = [];
    }
  }

  List<String> getSupportedLanguages() {
    if (voices.isEmpty) {
      return [];
    }
    final locales = voices.map((v) => v.locale).where((locale) => locale.isNotEmpty).toSet().toList();
    locales.sort();
    return locales;
  }

  List<VoiceModel> getVoicesByLocale(String locale) {
    return voices.where((v) => v.locale == locale).toList();
  }

  // Debug method to print available voices
  void printAvailableVoices() {
    print('Total voices found: ${voices.length}');
    for (int i = 0; i < voices.length; i++) {
      final voice = voices[i];
      print('Voice $i: ${voice.name} (${voice.locale})');
    }
  }

  Future<void> speak(String text, String locale) async {
    try {
      final availableVoices = getVoicesByLocale(locale);

      if (availableVoices.isEmpty) {
        throw Exception("Selected language '$locale' is not supported on this device.");
      }

      final voice = availableVoices[currentVoiceIndex % availableVoices.length];
      
      // Set voice properties
      await _flutterTts.setVoice(Map<String, String>.from(voice.rawData));
      await _flutterTts.setLanguage(locale);
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setPitch(1.0);
      
      // Speak the text
      await _flutterTts.speak(text);

      currentVoiceIndex++;
    } catch (e) {
      print('Error in speak method: $e');
      throw Exception("Failed to speak text: ${e.toString()}");
    }
  }

  void stop() {
    _flutterTts.stop();
  }
}
