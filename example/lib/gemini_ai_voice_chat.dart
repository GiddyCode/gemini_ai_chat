import 'dart:math';
import 'package:example/env.dart';
import 'package:example/gemini_ai_image_chat.dart';
import 'package:example/gemini_ai_text_chat.dart';
import 'package:flutter/material.dart';
import 'package:gemini_ai_chat/gemini_ai.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:svg_flutter/svg.dart';

class GeminiVoiceChat extends StatefulWidget {
  const GeminiVoiceChat({Key? key}) : super(key: key);

  @override
  State<GeminiVoiceChat> createState() => _GeminiVoiceChatState();
}

class _GeminiVoiceChatState extends State<GeminiVoiceChat>
    with SingleTickerProviderStateMixin {
  bool _hasSpeech = false;
  bool _logEvents = false;
  bool _onDevice = false;
  final TextEditingController _pauseForController =
      TextEditingController(text: '3');
  final TextEditingController _listenForController =
      TextEditingController(text: '30');
  double level = 0.0;
  double minSoundLevel = 50000;
  double maxSoundLevel = -50000;
  String lastWords = '';
  String lastError = '';
  String lastStatus = '';
  String _currentLocaleId = '';
  final SpeechToText speech = SpeechToText();
  bool loading = false;
  List textChat = [];
  List textWithImageChat = [];
  late AnimationController _animController;
  final TextEditingController _textController = TextEditingController();
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    initSpeechState();
    _animController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    super.initState();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  final geminiAI = GeminiAI(
    apiKey: Env.key,
  );

  // Text only input
  void fromText({required String query}) {
    setState(() {
      loading = true;
      textChat.add({
        "role": "User",
        "text": query,
      });
      _textController.clear();
    });
    scrollToTheEnd();

    geminiAI.generateTextFromQuery(query).then((value) {
      setState(() {
        loading = false;
        textChat.add({
          "role": "Gemini",
          "text": value.text,
        });
      });
      scrollToTheEnd();
    }).onError((error, stackTrace) {
      setState(() {
        loading = false;
        textChat.add({
          "role": "Gemini",
          "text": error.toString(),
        });
      });
      scrollToTheEnd();
    });
  }

  void scrollToTheEnd() {
    _controller.jumpTo(_controller.position.maxScrollExtent);
  }

  /// This initializes SpeechToText. That only has to be done
  /// once per application, though calling it again is harmless
  /// it also does nothing. The UX of the sample app ensures that
  /// it can only be called once.
  Future<void> initSpeechState() async {
    _logEvent('Initialize');
    try {
      var hasSpeech = await speech.initialize(
        onError: errorListener,
        onStatus: statusListener,
        debugLogging: _logEvents,
      );
      if (hasSpeech) {
        // Get the list of languages installed on the supporting platform so they
        // can be displayed in the UI for selection by the user.

        var systemLocale = await speech.systemLocale();
        _currentLocaleId = systemLocale?.localeId ?? '';
      }
      if (!mounted) return;

      setState(() {
        _hasSpeech = hasSpeech;
      });
    } catch (e) {
      setState(() {
        lastError = 'Speech recognition failed: ${e.toString()}';
        _hasSpeech = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
         appBar: AppBar(
          title: Text("Gemini AI"),
          elevation: 2,
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                child: Image.asset("assets/images/user.png"),
              ),
            ),
          ],
        ),
        body: Column(children: [
          Expanded(
            child: ListView.builder(
              controller: _controller,
              itemCount: textChat.length,
              padding: const EdgeInsets.only(bottom: 20, top: 10),
              itemBuilder: (context, index) {
                bool isMyText =
                    textChat[index]["role"] == "User" ? true : false;
                return ListTile(
                  isThreeLine: true,
                  leading: !isMyText
                      ? CircleAvatar(
                          child:
                              SvgPicture.asset("assets/svgs/gemini_bg.svg"),
                        )
                      : null,
                  trailing: !isMyText
                      ? null
                      : CircleAvatar(
                          child: Image.asset("assets/images/user.png"),
                        ),
                  title: Align(
                      alignment: !isMyText
                          ? Alignment.centerLeft
                          : Alignment.centerRight,
                      child: Text(
                        !isMyText ? "Gemini AI" : "Me",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      )),
                  subtitle: Align(
                      alignment: !isMyText
                          ? Alignment.centerLeft
                          : Alignment.centerRight,
                      child: Text(textChat[index]["text"])),
                );
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.all(10),
            padding:
                const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.grey.shade100),
            child: Column(
              children: [
                !_hasSpeech || speech.isListening
                    ? const Text("What would you like to do today?")
                    : const SizedBox.shrink(),
                Container(
                  alignment: Alignment.bottomRight,
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          lastWords,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                          maxLines: null,
                        ),
                      ),
                    ],
                  ),
                ),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: 60,
                      width: 220,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: Colors.primaries[5].shade50),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.keyboard_alt_outlined),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          const GeminiTextChat()));
                            },
                          ),
                          const Spacer(),
                          IconButton(
                              onPressed: !_hasSpeech || speech.isListening
                                  ? null
                                  : startListening,
                              icon: loading
                                  ? const CircularProgressIndicator()
                                  : const Icon(Icons.mic_none)),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.camera_alt_outlined),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          const GeminiImageChat()));
                            },
                          ),
                        ],
                      ),
                    ),
                    !_hasSpeech || speech.isListening
                        ? Stack(
                            alignment: Alignment.center,
                            children: [
                              RotationTransition(
                                turns: _animController,
                                child: SvgPicture.asset(
                                  "assets/svgs/fab_bg.svg",
                                  height: level * 1.7 + 45,
                                  width: level * 1.7 + 45,
                                ),
                              ),
                              const Icon(
                                Icons.mic,
                              ),
                            ],
                          )
                        : const SizedBox(),
                  ],
                ),
              ],
            ),
          ),
          SpeechStatusWidget(speech: speech),
          const SizedBox(height: 10),
        ]),
      ),
    );
  }

  void startListening() {
    _logEvent('start listening');
    lastWords = '';
    lastError = '';
    final pauseFor = int.tryParse(_pauseForController.text);
    final listenFor = int.tryParse(_listenForController.text);
    final options = SpeechListenOptions(
        onDevice: _onDevice,
        listenMode: ListenMode.confirmation,
        cancelOnError: true,
        partialResults: true,
        autoPunctuation: true,
        enableHapticFeedback: true);

    speech.listen(
      onResult: resultListener,
      listenFor: Duration(seconds: listenFor ?? 30),
      pauseFor: Duration(seconds: pauseFor ?? 3),
      localeId: _currentLocaleId,
      onSoundLevelChange: soundLevelListener,
      listenOptions: options,
    );
    setState(() {});
  }

  void stopListening() {
    _logEvent('stop');
    speech.stop();
    setState(() {
      level = 0.0;
    });
  }

  void cancelListening() {
    _logEvent('cancel');
    speech.cancel();
    setState(() {
      level = 0.0;
    });
  }

  /// This callback is invoked each time new recognition results are
  /// available after `listen` is called.
  void resultListener(SpeechRecognitionResult result) {
    _logEvent(
        'Result listener final: ${result.finalResult}, words: ${result.recognizedWords}');
    setState(() {
      lastWords = result.recognizedWords;
      // lastWords = '${result.recognizedWords} - ${result.finalResult}';
      //add the chat stuff here
      _hasSpeech && !speech.isListening
          ? fromText(query: lastWords)
          : _logEvent('No message to send');
      ;
    });
  }

  void soundLevelListener(double level) {
    minSoundLevel = min(minSoundLevel, level);
    maxSoundLevel = max(maxSoundLevel, level);
    // _logEvent('sound level $level: $minSoundLevel - $maxSoundLevel ');
    setState(() {
      this.level = level;
    });
  }

  void errorListener(SpeechRecognitionError error) {
    _logEvent(
        'Received error status: $error, listening: ${speech.isListening}');
    setState(() {
      lastError = '${error.errorMsg} - ${error.permanent}';
    });
  }

  void statusListener(String status) {
    _logEvent(
        'Received listener status: $status, listening: ${speech.isListening}');
    setState(() {
      lastStatus = status;
    });
  }

  void _switchLang(selectedVal) {
    setState(() {
      _currentLocaleId = selectedVal;
    });
    debugPrint(selectedVal);
  }

  void _logEvent(String eventDescription) {
    if (_logEvents) {
      var eventTime = DateTime.now().toIso8601String();
      debugPrint('$eventTime $eventDescription');
    }
  }

  void _switchLogging(bool? val) {
    setState(() {
      _logEvents = val ?? false;
    });
  }

  void _switchOnDevice(bool? val) {
    setState(() {
      _onDevice = val ?? false;
    });
  }
}

/// Display the current status of the listener
class SpeechStatusWidget extends StatelessWidget {
  const SpeechStatusWidget({
    Key? key,
    required this.speech,
  }) : super(key: key);

  final SpeechToText speech;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.background,
      child: Center(
        child: speech.isListening
            ? const Text(
                "I'm listening...",
                style: TextStyle(fontWeight: FontWeight.bold),
              )
            : const Text(
                'Not listening',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}
