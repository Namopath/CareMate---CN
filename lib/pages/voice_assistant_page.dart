// import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:caremate/services/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const String apiKey = "AIzaSyDtazM_IAsfk0xelMUUpdksDWe711Rxycs";

SpeechToText _speechToText = SpeechToText();
// FlutterTts flutterTts = FlutterTts();

class VoiceAssistantPage extends StatefulWidget {
  VoiceAssistantPage({super.key});

  @override
  State<VoiceAssistantPage> createState() => _VoiceAssistantPageState();
}

class _VoiceAssistantPageState extends State<VoiceAssistantPage> {
  var response;
  String _lastWords = '';
  bool _speechEnabled = false;
  bool isListening = false;
  var ttsState;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  // setup model
  final model = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: apiKey,
      systemInstruction: Content.text(
          "You are elder care taker robot. Your name is CareMate. You give user advices about how to caring their old parent or old person in a short sentences with no emoji. You have pills reminder for elders, control robot movement from phone, minigames for old people, fall detection, emotion detection, and video call."));

  // setup speech2text
  Future _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
  }

  // listen speech to text
  void _startListening() async {
    isListening = true;
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {});
  }

  // stop listen speech to text
  void _stopListening() async {
    isListening = false;
    await _speechToText.stop();
    setState(() {});
  }

  // convert speech to text
  void _onSpeechResult(result) {
    _lastWords = result.recognizedWords;
    print(_lastWords);
  }

  // speak text to speech
  // Future _speak() async {
  //   await flutterTts.setLanguage("en-US");
  //   await flutterTts.setSpeechRate(1.0);
  //   await flutterTts.setVolume(1.0);
  //   await flutterTts.setPitch(1.0);
  //   var result = await flutterTts.speak("Hello World");
  //   if (result == 1) setState(() => ttsState = ttsState.playing);
  // }

  // stop text to speech
  // Future _stop() async {
  //   var result = await flutterTts.stop();
  //   if (result == 1) setState(() => ttsState = ttsState.stopped);
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        title: Text("Voice Assistant",
            style: GoogleFonts.sen(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 30),
            // logo
            Image.asset("assets/logo.png", width: 260, height: 199),

            const SizedBox(height: 20),

            // ai answer
            SizedBox(
              height: 140,
              child: Text(response ?? "Hi!! I'm CareMate",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.sen(
                      fontSize: 20, fontWeight: FontWeight.bold)),
            ),

            const SizedBox(height: 40),

            // mic button
            GestureDetector(
              onTap: () async {
                if (_speechEnabled) {
                  _speechToText.isNotListening
                      ? _startListening()
                      : _stopListening();
                }
                // final responseAI =
                //     await model.generateContent([Content.text("hello")]);

                // setState(() {
                //   response = responseAI.text;
                // });

                // print(response);

                // _speak();
              },
              child: Container(
                width: 100,
                height: 100,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isListening ? ColorAsset.error : ColorAsset.primary),
                child: const Icon(Icons.mic_outlined,
                    size: 65, color: Colors.white),
              ),
            )
          ],
        ),
      ),
    );
  }
}
