import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'dart:io';

class ImageLabelingPage extends StatefulWidget {
  @override
  _ImageLabelingPageState createState() => _ImageLabelingPageState();
}

class _ImageLabelingPageState extends State<ImageLabelingPage> {
  File? _image;
  List<ImageLabel>? _labels;
  final ImageLabeler _imageLabeler = ImageLabeler(options: ImageLabelerOptions());

  Future<void> _getImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      setState(() {
        _image = file;
        _labels = null; // Reset labels when a new image is picked
      });

      _processImage(file);
    }
  }

  Future<void> _processImage(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final labels = await _imageLabeler.processImage(inputImage);

    setState(() {
      _labels = labels;
    });
  }

  @override
  void dispose() {
    _imageLabeler.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Labeling'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 20),
          _image != null
              ? SizedBox(height:300,
              child: Image.file(_image!))
              : Placeholder(fallbackHeight: 200, fallbackWidth: double.infinity),
          SizedBox(height: 20),
          _labels != null
              ? Expanded(
            child: ListView.builder(
              itemCount: _labels!.length,
              itemBuilder: (context, index) {
                final label = _labels![index];
                return ListTile(
                  title: Text(label.label),
                  subtitle: Text('Confidence: ${label.confidence.toStringAsFixed(2)}'),
                );
              },
            ),
          )
              : Text('Select an image to start labeling.'),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () => _getImage(ImageSource.camera),
                icon: Icon(Icons.camera_alt),
                label: Text('Camera'),
              ),
              ElevatedButton.icon(
                onPressed: () => _getImage(ImageSource.gallery),
                icon: Icon(Icons.photo),
                label: Text('Gallery'),
              ),
            ],
          ),
          if (_image != null)
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _image = null;
                  _labels = null;
                });
              },
              icon: Icon(Icons.refresh),
              label: Text('Reset'),
            ),
        ],
      ),
    );
  }
}
