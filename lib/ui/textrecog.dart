import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart'; // Import the share package
import 'dart:io';

class TextRecognitionPage extends StatefulWidget {
  const TextRecognitionPage({super.key});

  @override
  _TextRecognitionPageState createState() => _TextRecognitionPageState();
}

class _TextRecognitionPageState extends State<TextRecognitionPage> {
  File? _image;
  String _recognizedText = '';

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _recognizedText = '';
      });
      _recognizeText();
    }
  }

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

    textRecognizer.close();
  }

  void _reset() {
    setState(() {
      _image = null;
      _recognizedText = '';
    });
  }

  // Function to share recognized text
  void _shareText() {
    if (_recognizedText.isNotEmpty) {
      Share.share(_recognizedText);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No text to share')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Text Recognition'),
        backgroundColor: Colors.teal,
        actions: [
          if (_recognizedText.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: _shareText,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _image == null
                  ? Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(child: const Text('No image selected.')),
              )
                  : Card(
                elevation: 5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Image.file(_image!),
              ),
              const SizedBox(height: 20),
              _recognizedText.isNotEmpty
                  ? Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                color: Colors.grey[200],
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
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
                ),
              )
                  : const SizedBox(),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _image != null
                  ? ElevatedButton(
                onPressed: _reset,
                child: const Text('Reset'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              )
                  : const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
