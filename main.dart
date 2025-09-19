import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tesseract_ocr/tesseract_ocr.dart';
import 'package:flutter_tts/flutter_tts.dart';

void main() {
  runApp(const FidelOCRApp());
}

class FidelOCRApp extends StatelessWidget {
  const FidelOCRApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: OCRHomePage(),
    );
  }
}

class OCRHomePage extends StatefulWidget {
  @override
  State<OCRHomePage> createState() => _OCRHomePageState();
}

class _OCRHomePageState extends State<OCRHomePage> {
  File? _image;
  String _extractedText = "";
  final picker = ImagePicker();
  final FlutterTts flutterTts = FlutterTts();

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      _extractText(pickedFile.path);
    }
  }

  Future<void> _extractText(String imagePath) async {
    String text = await TesseractOcr.extractText(imagePath, language: 'amh');
    setState(() {
      _extractedText = text;
    });
  }

  Future<void> _speakText() async {
    if (_extractedText.isNotEmpty) {
      await flutterTts.speak(_extractedText);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Fidel OCR Demo")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_image != null)
              Image.file(_image!, height: 250, fit: BoxFit.contain),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _pickImage(ImageSource.camera),
              icon: const Icon(Icons.camera),
              label: const Text("Scan via Camera"),
            ),
            ElevatedButton.icon(
              onPressed: () => _pickImage(ImageSource.gallery),
              icon: const Icon(Icons.photo),
              label: const Text("Pick from Gallery"),
            ),
            const SizedBox(height: 20),
            Text(_extractedText, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _speakText,
              icon: const Icon(Icons.volume_up),
              label: const Text("Read Aloud"),
            ),
          ],
        ),
      ),
    );
  }
}
