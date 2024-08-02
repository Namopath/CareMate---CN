import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:caremate/services/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

const String apiKey = "AIzaSyCLQfdYZE8yyME3S4vC237PoURs79wPxrI";

SpeechToText _speechToText = SpeechToText();

FlutterTts flutterTts = FlutterTts();

class VoiceAssistantPage extends StatefulWidget {
  VoiceAssistantPage({super.key});

  @override
  State<VoiceAssistantPage> createState() => _VoiceAssistantPageState();
}

class _VoiceAssistantPageState extends State<VoiceAssistantPage> {
  var response;
  String _lastWords = "";
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
      model: 'gemini-1.5-pro-latest',
      apiKey: apiKey,
      systemInstruction: Content.text("You are an elder caretaker robot. Your name is CareMate. You give users advice about how to care for their relatives in short sentences and in a friendly welcoming tone with no emojis. You can also answer basic real world questions2"));

  // setup speech2text
  Future _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
  }

  // listen speech to text
  Future _startListening() async {
    isListening = true;
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {});
  }

  // stop listen speech to text
  Future _stopListening() async {
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
  Future _speak(String text) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);
    await flutterTts.speak(text);
  }

  // stop text to speech
  Future _stop() async {
    await flutterTts.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        title: Text(AppLocalizations.of(context)!.assistant,
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
            SingleChildScrollView(
              child: SizedBox(
                height: 140,
                child: Text(response ?? AppLocalizations.of(context)!.caremate_name,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.sen(
                        fontSize: 20, fontWeight: FontWeight.bold)),
              ),
            ),

            const SizedBox(height: 40),

            // mic button
            GestureDetector(
              onTap: () async {
                if (_speechEnabled) {
                  _speechToText.isNotListening
                      ? await _startListening()
                      : await _stopListening();
                }

                if (isListening == false && _lastWords != "") {
                  final responseAI =
                      await model.generateContent([Content.text(_lastWords)]);

                  setState(() {
                    response = responseAI.text;
                  });

                  await _speak(response);
                }
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
