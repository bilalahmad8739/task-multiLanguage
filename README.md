# TTS Multilingual Demo App

A Flutter application that demonstrates Text-to-Speech (TTS) functionality with support for multiple languages and voice switching capabilities.

## Features

- **Multi-language Support**: English, French, Spanish, German, and UK English
- **Voice Switching**: Automatically cycles through available voices for each language
- **Real-time Voice Count**: Shows how many voices are available for each language
- **Language Detection**: Automatically detects if a language is supported by the device
- **Reset Functionality**: Manual voice reset button to start from the first voice
- **Clean UI**: Modern card-based design with proper error handling

## Demo Video

📹 **[Watch Demo Video](demo/demo_video.mp4)**

*Note: Please add your screen recording to the `demo/` folder and update the link above.*

## Setup Instructions

### Prerequisites

- Flutter SDK (version 3.4.3 or higher)
- Dart SDK
- Android Studio / VS Code
- Android device or emulator / iOS device or simulator

### Installation Steps

1. **Clone the repository**
   ```bash
   git clone <https://github.com/bilalahmad8739/task-multiLanguage>
   cd task
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   flutter run
   ```

### Dependencies

The app uses the following main dependencies:
- `flutter_tts: ^3.6.3` - For text-to-speech functionality

## How to Use

1. **Select Language**: Choose from the dropdown menu (English, French, Spanish, German, UK English)
2. **Enter Text**: Type the text you want to convert to speech
3. **Press Play**: Click the blue "Play" button to hear the text
4. **Voice Switching**: Press "Play" again to switch to the next available voice
5. **Reset Voice**: Use the orange "Reset Voice" button to start from the first voice

## Example Usage

1. Select **French** → Enter **"Bonjour, comment ça va?"** → Press **Play** → Uses **Male French voice**
2. Press **Play** again → Automatically switches to **Female French voice** (if available)
3. Press **Play** again → Cycles back to **Male French voice** or next available voice

## Project Structure

```
lib/
├── controller/
│   └── tts_controller.dart      # TTS logic and voice management
├── model/
│   └── voice_model.dart         # Voice data model
├── views/
│   └── tts_screen.dart          # Main UI screen
└── main.dart                    # App entry point
```

## Known Limitations & Assumptions

### Device Limitations
- **Voice Availability**: The number of available voices depends on the device's TTS engine and installed language packs
- **Language Support**: Not all languages may be supported on all devices
- **Voice Quality**: Voice quality and pronunciation may vary between devices and TTS engines

### Technical Limitations
- **Single Voice**: If only one voice is available for a language, voice switching won't work
- **Platform Differences**: TTS behavior may vary between Android and iOS
- **Network Dependency**: Some TTS engines may require internet connection for certain languages

### Assumptions
- **Default TTS Engine**: Uses the device's default TTS engine
- **Voice Indexing**: Assumes voices are indexed consistently across play sessions
- **Language Codes**: Uses standard locale codes (e.g., 'en-US', 'fr-FR')

## Troubleshooting

### Common Issues

1. **No voices found**
   - Check device TTS settings
   - Ensure language packs are installed
   - Try different languages

2. **Voice not switching**
   - Check voice count in the dropdown
   - Use "Reset Voice" button
   - Try different languages

3. **App not speaking**
   - Check device volume
   - Ensure TTS is enabled in device settings
   - Check console logs for errors

### Debug Information

The app provides detailed console logs for debugging:
- Available voices for each language
- Voice switching information
- Error messages and exceptions

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For issues and questions:
- Check the troubleshooting section above
- Review console logs for error messages
- Create an issue in the repository

---

**Note**: This app is designed for educational and demonstration purposes. For production use, consider additional error handling, accessibility features, and platform-specific optimizations.
