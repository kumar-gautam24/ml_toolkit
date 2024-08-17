import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_ml_vision/google_ml_vision.dart';
import 'package:share_plus/share_plus.dart';

class BarcodeScannerPage extends StatefulWidget {
  @override
  _BarcodeScannerPageState createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage> {
  File? _imageFile;
  String? _barcodeResult;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();
  final BarcodeDetector _barcodeDetector = GoogleVision.instance.barcodeDetector();

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _barcodeResult = null;
        _isLoading = true;
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
      _isLoading = false;
    });
  }

  void _shareBarcode() {
    if (_barcodeResult != null) {
      Share.share('Scanned Barcode Result: $_barcodeResult');
    }
  }

  @override
  void dispose() {
    _barcodeDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Barcode Scanner'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade300, Colors.deepPurple.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _imageFile == null
                  ? Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'No Image Selected',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              )
                  : Column(
                children: [
                  Container(
                    height: 300,
                    margin: EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.file(_imageFile!),
                    ),
                  ),
                  if (_isLoading)
                    CircularProgressIndicator(),
                ],
              ),
              SizedBox(height: 20),
              _barcodeResult != null
                  ? Card(
                margin: EdgeInsets.symmetric(horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Barcode Result: $_barcodeResult',
                    style: TextStyle(fontSize: 18, color: Colors.deepPurple.shade900),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
                  : Container(),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.camera),
                icon: Icon(Icons.camera_alt),
                label: Text('Pick from Camera'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple.shade700,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.gallery),
                icon: Icon(Icons.photo_library),
                label: Text('Pick from Gallery'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple.shade700,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _barcodeResult != null
          ? FloatingActionButton.extended(
        onPressed: _shareBarcode,
        label: Text('Share'),
        icon: Icon(Icons.share),
        backgroundColor: Colors.deepPurple,
      )
          : null,
    );
  }
}
