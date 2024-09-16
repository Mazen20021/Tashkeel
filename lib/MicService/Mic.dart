import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class MicService {
  final stt.SpeechToText speech = stt.SpeechToText();
  final Function(String) onTextRecognized;
  final VoidCallback onDone;

  MicService({
    required this.onTextRecognized,
    required this.onDone,
  });

  Future<bool> getMicrophonePermission() async {
    bool hasPermission = await speech.initialize(
      onError: (error) => print('Error initializing speech recognition: $error'),
    );

    if (!hasPermission) {
      bool isPermissionGranted = await speech.requestPermission();
      if (!isPermissionGranted) {
      }
      return isPermissionGranted;
    }
    return true;
  }

  bool isSpeechRecognitionAvailable(BuildContext context) {
    try {
      return speech.isAvailable;
    } catch (e) {
      if (e is PlatformException) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في سماع الصوت ${e.message}')),
        );
      }
      return false;
    }
  }

  void startSpeechRecognition(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const  SnackBar(content:  Text('تكلم')),
    );
    try {
      bool available = await speech.initialize(
        onStatus: (status) => onDone(),
        onError: (error) => onDone(),
      );

      if (available) {
        speech.listen(
          localeId: 'ar',
          listenFor: const Duration(minutes: 60),
          cancelOnError: true,
          partialResults: true,
          onResult: (result) {
            onTextRecognized(result.recognizedWords);
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const  SnackBar(content:  Text(' حدث خطأ لا يمكن سماعك')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content:  Text('حدث خطأ بسبب ${e}')),
      );
    }
  }

  void stopSpeechRecognition() {
    speech.stop();
  }

  void disposeSpeechRecognition() {
    speech.cancel();
  }
}

extension on stt.SpeechToText {
  requestPermission() {}
}
