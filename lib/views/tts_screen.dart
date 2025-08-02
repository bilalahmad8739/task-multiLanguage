import 'package:flutter/material.dart';
import 'package:task/controller/tts_controller.dart';


class TTSScreen extends StatefulWidget {
  @override
  State<TTSScreen> createState() => _TTSScreenState();
}

class _TTSScreenState extends State<TTSScreen> {
  final TTSController _ttsController = TTSController();
  final TextEditingController _textController = TextEditingController();

  bool _isLoading = true;
  String? _selectedLanguage;
  List<String> _languages = [];

  @override
  void initState() {
    super.initState();
    _loadVoices();
  }

  Future<void> _loadVoices() async {
    setState(() => _isLoading = true);
    try {
      await _ttsController.initVoices();
      _ttsController.printAvailableVoices(); // Debug info
      _languages = _ttsController.getSupportedLanguages();
      
      if (_languages.isEmpty) {
        _showSnack("No supported languages found on this device");
      }
    } catch (e) {
      _showSnack("Error loading voices: ${e.toString()}");
      _languages = [];
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSpeak() async {
    if (_selectedLanguage == null || _textController.text.trim().isEmpty) {
      _showSnack("Please select a language and enter text");
      return;
    }

    try {
      await _ttsController.speak(_textController.text.trim(), _selectedLanguage!);
    } catch (e) {
      _showSnack(e.toString());
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _ttsController.stop();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text("TTS Demo")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text("TTS Multilingual Demo")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_languages.isEmpty)
              Container(
                padding: EdgeInsets.all(16),
                margin: EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange),
                ),
                child: Text(
                  "No supported languages found on this device. Please check your device's TTS settings.",
                  style: TextStyle(color: Colors.orange.shade800),
                ),
              ),
            DropdownButton<String>(
              value: _selectedLanguage,
              isExpanded: true,
              hint: Text("Select Language"),
              items: _languages.map((lang) {
                return DropdownMenuItem(
                  value: lang,
                  child: Text(lang),
                );
              }).toList(),
              onChanged: _languages.isEmpty ? null : (value) {
                setState(() {
                  _selectedLanguage = value;
                  _ttsController.currentVoiceIndex = 0;
                });
              },
            ),
            SizedBox(height: 16),
            TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: "Enter a sentence",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: (_selectedLanguage == null || _textController.text.trim().isEmpty || _languages.isEmpty) 
                  ? null 
                  : _handleSpeak,
              icon: Icon(Icons.play_arrow,size: 30,),
              label: Text("Play"),
            ),
          ],
        ),
      ),
    );
  }
}
