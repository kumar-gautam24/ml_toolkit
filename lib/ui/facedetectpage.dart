import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_ml_vision/google_ml_vision.dart';

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
    ),
  );

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);

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

  @override
  void dispose() {
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Face Detection'),
      ),
      body: Column(
        children: [
          _imageFile == null
              ? Container(height: 300, child: Center(child: Text('No Image Selected')))
              : Image.file(_imageFile!),
          _faces != null
              ? Expanded(
            child: ListView.builder(
              itemCount: _faces!.length,
              itemBuilder: (context, index) {
                final face = _faces![index];
                return ListTile(
                  title: Text('Face ${index + 1}'),
                  subtitle: Text(
                    'Bounding Box: ${face.boundingBox}\n'
                        'Smile Probability: ${face.smilingProbability ?? 'N/A'}',
                  ),
                );
              },
            ),
          )
              : Container(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickImage,
        child: Icon(Icons.camera_alt),
      ),
    );
  }
}
