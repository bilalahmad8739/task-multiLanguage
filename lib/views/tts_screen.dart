import 'package:flutter/material.dart';
import 'package:task/controller/tts_controller.dart';


class TTSScreen extends StatefulWidget {
  @override
  State<TTSScreen> createState() => _TTSScreenState();
}

class _TTSScreenState extends State<TTSScreen> {
  final TTSController _ttsController = TTSController();
  final TextEditingController _textController = TextEditingController();

  String? _selectedLanguage;
  List<String> _languages = [];
  bool _isInitialized = false;
  String _statusMessage = "Initializing...";
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _initializeTTS();
  }

  Future<void> _initializeTTS() async {
    try {
      print('Starting TTS initialization...');
      setState(() {
        _statusMessage = "Initializing TTS...";
      });
      
      // Initialize the TTS controller
      await _ttsController.initVoices();
      
      // Load languages
      _languages = _ttsController.getSupportedLanguages();
      print('Available languages: $_languages');
      
      if (_languages.isNotEmpty) {
        _selectedLanguage = _languages[0]; // Set default language
        print('Default language set to: $_selectedLanguage');
      }
      
      setState(() {
        _isInitialized = true;
        _statusMessage = "Ready to speak";
      });
      
      // Debug: Print available voices
      _ttsController.printAvailableVoices();
      
    } catch (e) {
      print('Error initializing TTS: $e');
      setState(() {
        _statusMessage = "Error: ${e.toString()}";
      });
      _showSnack("Error initializing TTS: ${e.toString()}");
    }
  }

  Future<void> _handleSpeak() async {
    print('Play button pressed');
    print('Selected language: $_selectedLanguage');
    print('Text: "${_textController.text}"');
    print('Is initialized: $_isInitialized');
    
    if (_selectedLanguage == null || _textController.text.trim().isEmpty) {
      _showSnack("Please select a language and enter text");
      return;
    }

    if (!_isInitialized) {
      _showSnack("TTS is not initialized yet. Please wait...");
      return;
    }

    // Check if language is supported by the device
    if (!_ttsController.isLanguageSupported(_selectedLanguage!)) {
      _showSnack("Selected language '$_selectedLanguage' is not supported by this device");
      return;
    }

    try {
      setState(() {
        _isSpeaking = true;
        _statusMessage = "Speaking...";
      });
      
      await _ttsController.speak(_textController.text.trim(), _selectedLanguage!);
      
      setState(() {
        _isSpeaking = false;
        _statusMessage = "Ready to speak";
      });
      
      // Show voice switching info
      final voiceCount = _ttsController.getVoiceCountForLanguage(_selectedLanguage!);
      if (voiceCount > 1) {
        _showSnack("Switched to next voice. ${voiceCount} voices available for $_selectedLanguage");
      } else {
        _showSnack("Only 1 voice available for $_selectedLanguage. No voice switching possible.");
      }
      
    } catch (e) {
      print('Error in _handleSpeak: $e');
      setState(() {
        _isSpeaking = false;
        _statusMessage = "Error occurred";
      });
      _showSnack("Error: ${e.toString()}");
    }
  }

  void _resetVoiceIndex() {
    _ttsController.resetVoiceIndex();
    _showSnack("Voice index reset. Will start from first voice next time.");
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 3),
      ),
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
    return Scaffold(
      appBar: AppBar(
        title: Text("TTS Multilingual Demo"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Status card
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(
                        _isInitialized ? Icons.check_circle : Icons.hourglass_empty,
                        color: _isInitialized ? Colors.green : Colors.orange,
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _statusMessage,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (_selectedLanguage != null && _isInitialized)
                              Text(
                                "Voice count: ${_ttsController.getVoiceCountForLanguage(_selectedLanguage!)}",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Select Language",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: 8),
                      DropdownButton<String>(
                        value: _selectedLanguage,
                        isExpanded: true,
                        hint: Text("Select Language"),
                        items: _languages.map((lang) {
                          final isSupported = _ttsController.isLanguageSupported(lang);
                          final voiceCount = _ttsController.getVoiceCountForLanguage(lang);
                          return DropdownMenuItem(
                            value: lang,
                            child: Row(
                              children: [
                                Text(lang),
                                SizedBox(width: 8),
                                Text(
                                  "($voiceCount voices)",
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                                if (!isSupported)
                                  Padding(
                                    padding: EdgeInsets.only(left: 8),
                                    child: Text(
                                      "(Not supported)",
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: _isInitialized ? (value) {
                          setState(() {
                            _selectedLanguage = value;
                            _ttsController.resetVoiceIndex(); // Reset when language changes
                          });
                          print('Language changed to: $value');
                        } : null,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Enter Text",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: _textController,
                        maxLines: 3,
                        enabled: _isInitialized && !_isSpeaking,
                        onChanged: (value) {
                          setState(() {}); // Trigger rebuild to update button state
                        },
                        decoration: InputDecoration(
                          hintText: "Enter text to speak...",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.blue, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: (_selectedLanguage == null || 
                                 _textController.text.trim().isEmpty || 
                                 !_isInitialized ||
                                 _isSpeaking) 
                          ? null 
                          : _handleSpeak,
                      icon: _isSpeaking 
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Icon(Icons.play_arrow, size: 30),
                      label: Text(
                        _isSpeaking ? "Speaking..." : "Play",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _isInitialized ? _resetVoiceIndex : null,
                    icon: Icon(Icons.refresh, size: 20),
                    label: Text("Reset Voice"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
