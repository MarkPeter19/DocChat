import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:doctorgpt/screens/PatientScreens/ViewAnalysisResultScreen.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:permission_handler/permission_handler.dart';

//import 'dart:convert';
//import 'package:http/http.dart' as http;

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  bool _isLoading = false;

  //permissions
  Future<void> _checkCameraPermission() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      status = await Permission.camera.request();
    }
    if (status.isGranted) {
      _pickImage(ImageSource.camera);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Camera permission denied')),
      );
    }
  }

  // Future<void> _checkGalleryPermission() async {
  //   var status = await Permission.photos.status;
  //   if (!status.isGranted) {
  //     status = await Permission.photos.request();
  //   }
  //   if (status.isGranted) {
  //     _pickImage(ImageSource.gallery);
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Gallery permission denied')),
  //     );
  //   }
  // }

  //pick image from gallery/camera
  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      setState(() {
        _image = pickedFile; //kivalasztott kep galleriabol/keszitve
      });
    } catch (e) {
      print(e); // Kezeld a kivételt megfelelően
    }
  }

  // OCR - extract data from image
  Future<void> _extractText() async {
    setState(() {
      _isLoading = true;
    });

    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select an image first.')),
      );
      return;
    }

    final inputImage = InputImage.fromFilePath(_image!.path);
    final textRecognizer = TextRecognizer();

    try {
      final RecognizedText recognizedText =
          await textRecognizer.processImage(inputImage);
      final String text = recognizedText.text;

      if (text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No text recognized in the image')),
        );
        return;
      }

      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ViewAnalysisResultScreen(result: text),
      ));
    } catch (e) {
      print("Error recognizing text: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to recognize text from image')),
      );
    } finally {
      textRecognizer.close();
      setState(() {
        _isLoading = false;
      });
    }
  }

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Analysis', style: TextStyle(fontSize: 26)),
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context)),
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          SizedBox(
            height: MediaQuery.of(context).size.height *
                0.5, // Fix magasság a képnek
            child: Center(
              child: _image == null
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset('lib/assets/placeholder.png',
                          fit: BoxFit.contain),
                    )
                  : Image.file(File(_image!.path), fit: BoxFit.contain),
            ),
          ),
          SizedBox(height: 25),
          Text("Add picture to analyze",
              style: TextStyle(
                  fontSize: 26, color: Color.fromRGBO(235, 144, 47, 1))),
          Padding(
            padding: const EdgeInsets.only(
                top: 20, bottom: 20), // Gombok közötti távolság
            child: Column(
              mainAxisSize:
                  MainAxisSize.min, 
              children: [
                _image == null
                    ? ElevatedButton.icon(
                        onPressed: () => _checkCameraPermission(),
                        icon: Icon(Icons.camera),
                        label: Text('Take Picture'),
                      )
                    : ElevatedButton.icon(
                        onPressed: () => setState(() => _image = null),
                        icon: Icon(Icons.photo),
                        label: Text('Change Picture'),
                      ),
                SizedBox(height: 10), // Gombok közötti távolság
                ElevatedButton.icon(
                  onPressed: _image == null
                      ? () => _pickImage(ImageSource.gallery)
                      : _extractText,
                  icon: Icon(
                      _image == null ? Icons.photo_library : Icons.analytics),
                  label: Text(
                      _image == null ? 'Pick from Gallery' : 'Extract Data'),
                  
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
