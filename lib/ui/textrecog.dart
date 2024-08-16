import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class TextRecognitionPage extends StatefulWidget {
  const TextRecognitionPage({super.key});

  @override
  _TextRecognitionPageState createState() => _TextRecognitionPageState();
}

class _TextRecognitionPageState extends State<TextRecognitionPage> {
  File? _image;
  String _recognizedText = '';

  // Function to pick an image from the camera or gallery
  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _recognizedText = ''; // Reset text when a new image is picked
      });
      _recognizeText();
    }
  }

  // Function to recognize text using Google ML Kit Text Recognition
  Future<void> _recognizeText() async {
    if (_image == null) return;

    final inputImage = InputImage.fromFilePath(_image!.path);
    final textRecognizer = TextRecognizer();
    final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

    String resultText = '';
    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        resultText += line.text + '\n';
      }
    }

    setState(() {
      _recognizedText = resultText.isNotEmpty ? resultText : 'No text recognized.';
    });

    // Close the text recognizer when done
    textRecognizer.close();
  }

  // Function to reset the image and recognized text
  void _reset() {
    setState(() {
      _image = null;
      _recognizedText = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Text Recognition'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _image == null
                    ? const Text('No image selected.')
                    : Image.file(_image!),
                const SizedBox(height: 20),
                _recognizedText.isNotEmpty
                    ? Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    border: Border.all(color: Colors.grey, width: 2.0),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 7,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: SelectableText(
                    _recognizedText,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.left,
                    toolbarOptions: const ToolbarOptions(
                      copy: true,
                      selectAll: true,
                    ),
                    showCursor: true,
                    cursorColor: Colors.blue,
                    cursorWidth: 2.0,
                  ),
                )
                    : const SizedBox(),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () => _pickImage(ImageSource.camera),
                      child: const Text('Pick from Camera'),
                    ),
                    ElevatedButton(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      child: const Text('Pick from Gallery'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _image != null
                    ? ElevatedButton(
                  onPressed: _reset,
                  child: const Text('Reset'),
                )
                    : const SizedBox(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
