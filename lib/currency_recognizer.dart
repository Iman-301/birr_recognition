import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'components/image_picker.dart';
import 'components/prediction_widget.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';

class CurrencyRecognizer extends StatefulWidget {
  const CurrencyRecognizer({super.key});

  @override
  _CurrencyRecognizerState createState() => _CurrencyRecognizerState();
}

class _CurrencyRecognizerState extends State<CurrencyRecognizer> {
  late Interpreter _interpreter;
  late List<String> _classes;
  late FlutterTts? _flutterTts;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isMaleVoice = true;
  bool eng = false;
  int _currentLanguage = 1;
  File? _selectedImage;
  String _predicted = "---------";

  @override
  void initState() {
    super.initState();

    _flutterTts = FlutterTts();
    _loadModel();
    _loadClasses();
  }

  @override
  void dispose() {
    _flutterTts?.stop();
    _interpreter.close();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _speak(String prediction) async {
    String voiceType = _isMaleVoice ? "male" : "female";
    String fileName = "$prediction$voiceType";
    String filePath = "assets/voices/$fileName.mp3";

    if (prediction == "-1") {
      filePath = "assets/voices/again.mp3";
    }

    try {
      // Play audio from byte buffer
      ByteData bytes = await rootBundle.load(filePath);
      Uint8List soundBytes = bytes.buffer.asUint8List();

      // Play audio from byte buffer
      await _audioPlayer.play(BytesSource(soundBytes));
    } catch (e) {
      print("Error playing audio: $e");
    }
  }

  void _toggleVoice() {
    setState(() {
      _isMaleVoice = !_isMaleVoice;
    });
  }

  Future<void> _speakPrediction(String text) async {
    if (_flutterTts == null) return;
    await _flutterTts!.setLanguage("en-US");
    await _flutterTts!.setPitch(1.0);
    await _flutterTts!.speak(text);
    print("Speaking: $text");
  }

  Future<void> _loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset("assets/model.tflite");
    } catch (e) {
      print("Error loading model: $e");
    }
  }

  Future<void> _loadClasses() async {
    try {
      final classesJson = await rootBundle.loadString('assets/classes.json');
      setState(() {
        _classes = List<String>.from(jsonDecode(classesJson));
      });
    } catch (e) {
      print("Error loading classes: $e");
      setState(() {
        _classes = ["Unknown"];
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _predicted = "Predicting..."; // Reset prediction before running
      });
      _runModel(File(pickedFile.path));
    }
  }

  Future<void> _runModel(File imageFile) async {
    setState(() {
      _predicted = "Predicting...";
    });

    try {
      // Load and decode the image
      final image = img.decodeImage(await imageFile.readAsBytes());
      if (image == null) {
        setState(() {
          _predicted = "Invalid image selected!";
        });
        return;
      }

      // Resize the image to the required input shape (e.g., 224x224)
      final inputShape = _interpreter.getInputTensor(0).shape;
      final height = inputShape[1];
      final width = inputShape[2];
      final resizedImage = img.copyResize(image, width: width, height: height);

      // Convert the image to a normalized float32 input tensor
      final inputBuffer = Float32List(height * width * 3);
      for (int i = 0; i < height; i++) {
        for (int j = 0; j < width; j++) {
          final pixel = resizedImage.getPixel(j, i);
          final index = (i * width + j) * 3;
          inputBuffer[index] = img.getRed(pixel) / 255.0; // Normalize to [0, 1]
          inputBuffer[index + 1] = img.getGreen(pixel) / 255.0;
          inputBuffer[index + 2] = img.getBlue(pixel) / 255.0;
        }
      }

      // Prepare the output buffer
      final outputShape = _interpreter.getOutputTensor(0).shape;
      final numClasses = outputShape[1];
      final outputBuffer = Float32List(outputShape[0] * numClasses)
          .reshape([outputShape[0], numClasses]);

      // Run inference
      _interpreter.run(
          inputBuffer.reshape([1, height, width, 3]), outputBuffer);

      // Extract predictions
      final predictions = outputBuffer[0];
      final predictedIndex = predictions
          .indexOf(predictions.reduce((double a, double b) => a > b ? a : b));

      // Update the UI with the predicted class
      setState(() {
        _predicted = _classes.isNotEmpty && predictedIndex != 10
            ? "${_classes[predictedIndex]} Birr"
            : "Background / Unknown";
      });

      final num = [
        "100",
        "100",
        "10",
        "10",
        "200",
        "200",
        "50",
        "50",
        "5",
        "5",
        "-1"
      ];

      if (eng == true) {
        _speakPrediction(_predicted == "no money note found"
            ? "no money note found"
            : "$_predicted.");
      } else {
        _speak(num[predictedIndex]);
      }
    } catch (e) {
      setState(() {
        _predicted = "Error during prediction: $e";
      });
      print("Error during prediction: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Currency Recognition",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/bg.jpg"),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            children: [
              ImagePickerWidget(
                selectedImage: _selectedImage,
                onImagePicked: _pickImage,
              ),
              const SizedBox(height: 45),
              PredictionWidget(
                size: size,
                predicted: _predicted,
                onCameraTap: () => _pickImage(ImageSource.camera),
                onGalleryTap: () => _pickImage(ImageSource.gallery),
                currentLanguage: _currentLanguage,
                onToggle: (index) {
                  if (index == 0) {
                    setState(() {
                      eng = true;
                      _isMaleVoice = true;
                      _currentLanguage = 0;
                    });
                  } else if (index == 1) {
                    setState(() {
                      eng = false;
                      _isMaleVoice = true;
                      _currentLanguage = 1;
                    });
                  } else {
                    setState(() {
                      eng = false;
                      _isMaleVoice = false;
                      _currentLanguage = 2;
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}