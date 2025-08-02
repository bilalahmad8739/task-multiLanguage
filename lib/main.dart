import 'package:flutter/material.dart';
import 'package:task/views/tts_screen.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TTS Multilingual Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: TTSScreen(),
    );
  }
}
