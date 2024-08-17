import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_ml_vision/google_ml_vision.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;

class FaceDetectionPage extends StatefulWidget {
  @override
  _FaceDetectionPageState createState() => _FaceDetectionPageState();
}

class _FaceDetectionPageState extends State<FaceDetectionPage> {
  File? _imageFile;
  List<Face>? _faces;
  final ImagePicker _picker = ImagePicker();
  final FaceDetector _faceDetector = GoogleVision.instance.faceDetector(
    FaceDetectorOptions(
      enableLandmarks: true,
      enableContours: true,
      enableClassification: true, // Enable classification for emotion analysis
    ),
  );

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });

      _detectFaces();
    }
  }

  Future<void> _detectFaces() async {
    final GoogleVisionImage visionImage = GoogleVisionImage.fromFile(_imageFile!);
    final faces = await _faceDetector.processImage(visionImage);

    if (mounted) {
      setState(() {
        _faces = faces;
      });
    }
  }

  Future<void> _highlightFaces() async {
    if (_faces == null || _imageFile == null) return;

    final originalImage = img.decodeImage(_imageFile!.readAsBytesSync());
    for (var face in _faces!) {
      img.drawRect(
        originalImage!,
        x1: face.boundingBox.left.toInt(),
        y1: face.boundingBox.top.toInt(),
        x2: face.boundingBox.right.toInt(),
        y2: face.boundingBox.bottom.toInt(),
        color: img.ColorFloat16.rgb(0,0,0), // Red color
        thickness: 3,
      );
    }
    final directory = await getTemporaryDirectory();
    final path = '${directory.path}/highlighted.png';
    File(path).writeAsBytesSync(img.encodePng(originalImage!));
    setState(() {
      _imageFile = File(path);
    });
  }





  Future<void> _shareImage() async {
    if (_imageFile != null) {
      // Share.shareFiles([_imageFile!.path]);
    }
  }

  @override
  void dispose() {
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Face Detection & Emotion Analysis'),
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          _imageFile == null
              ? Placeholder(fallbackHeight: 300)
              : Image.file(_imageFile!),
          SizedBox(height: 20),
          _faces != null && _faces!.isNotEmpty
              ? Expanded(
            child: ListView.builder(
              itemCount: _faces!.length,
              itemBuilder: (context, index) {
                final face = _faces![index];
                String emotion = face.smilingProbability != null
                    ? face.smilingProbability! > 0.7
                    ? "Happy"
                    : face.smilingProbability! > 0.4
                    ? "Neutral"
                    : "Sad"
                    : "Unknown";

                return ListTile(
                  title: Text('Face ${index + 1}'),
                  subtitle: Text(
                    'Bounding Box: ${face.boundingBox}\n'
                        'Smile Probability: ${(face.smilingProbability ?? 0).toStringAsFixed(2)}\n'
                        'Emotion: $emotion',
                  ),
                );
              },
            ),
          )
              : Container(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Text('No faces detected.'),
          ),
          if (_imageFile != null)
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.camera),
                icon: Icon(Icons.camera_alt),
                label: Text('Camera'),
              ),
              ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.gallery),
                icon: Icon(Icons.photo),
                label: Text('Gallery'),
              ),
            ],
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
