import 'package:flutter/material.dart';
import 'package:ml_toolkit/ui/baarcode.dart';

import 'package:ml_toolkit/ui/facedetect.dart';
import 'package:ml_toolkit/ui/facedetectpage.dart';
import 'package:ml_toolkit/ui/textrecog.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Toolkit'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Background design
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.lightBlueAccent, Colors.blue],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Main content
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _buildOptionCard(
                    context,
                    'Text Recognition',
                    'assets/icons/text_recognition.png',
                    const TextRecognitionPage(),
                  ),
                  const SizedBox(height: 20),
                  _buildOptionCard(
                    context,
                    'Image Labeling',
                    'assets/icons/image_labeling.png',
                    ImageLabelingPage(),
                  ),
                  const SizedBox(height: 20),
                  _buildOptionCard(
                    context,
                    'Barcode Scanning',
                    'assets/icons/barcode_scanning.png',
                    BarcodeScannerPage(),
                  ),
                  const SizedBox(height: 20),
                  _buildOptionCard(
                    context,
                    'Face Detection',
                    'assets/icons/face_detection.png',
                    FaceDetectionPage(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard(BuildContext context, String title, String imagePath, Widget targetPage) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => targetPage),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 5,
        child: Container(
          padding: const EdgeInsets.all(15.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Row(
            children: [
              Image.asset(imagePath, height: 50, width: 50),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.blueAccent),
            ],
          ),
        ),
      ),
    );
  }
}
