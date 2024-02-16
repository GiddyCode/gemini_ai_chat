import 'package:example/gemini_ai_voice_chat.dart';
import 'package:flutter/material.dart';

const apiKey = "";

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const GeminiVoiceChat(),
    
    );
  }
}
