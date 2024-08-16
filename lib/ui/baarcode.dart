import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_ml_vision/google_ml_vision.dart';

class BarcodeScannerPage extends StatefulWidget {
  @override
  _BarcodeScannerPageState createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage> {
  File? _imageFile;
  String? _barcodeResult;
  final ImagePicker _picker = ImagePicker();
  final BarcodeDetector _barcodeDetector = GoogleVision.instance.barcodeDetector();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });

      _scanBarcode();
    }
  }

  Future<void> _scanBarcode() async {
    final GoogleVisionImage visionImage = GoogleVisionImage.fromFile(_imageFile!);
    final List<Barcode> barcodes = await _barcodeDetector.detectInImage(visionImage);

    String? result;
    if (barcodes.isNotEmpty) {
      result = barcodes.first.rawValue;
    } else {
      result = 'No barcode found';
    }

    setState(() {
      _barcodeResult = result;
    });
  }

  @override
  void dispose() {
    _barcodeDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Barcode Scanner')),
      body: Column(
        children: [
          _imageFile == null
              ? Container(height: 300, child: Center(child: Text('No Image Selected')))
              : Image.file(_imageFile!),
          SizedBox(height: 20),
          _barcodeResult != null
              ? Text('Barcode Result: $_barcodeResult')
              : Container(
            child: Text('No barcode found'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickImage,
        child: Icon(Icons.camera_alt),
      ),
    );
  }
}

