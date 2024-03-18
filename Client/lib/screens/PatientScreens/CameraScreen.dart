import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:doctorgpt/screens/PatientScreens/ViewAnalysisResultScreen.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

//import 'dart:convert';
//import 'package:http/http.dart' as http;

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;

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

  Future<void> _extractText() async {
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
    }
  }

  // kep elkuldese a server-re

  // Future<void> _uploadImage() async {
  //   if (_image == null) return;
  //   final uri = Uri.parse(
  //       'http://192.168.1.4:8000/upload/'); // A szerver lokalis IP cime, ha emulatort hasznalok -> http://10.0.2.2:8000/upload/
  //   final request = http.MultipartRequest('POST', uri)
  //     ..files.add(await http.MultipartFile.fromPath('file', _image!.path));

  //   try {
  //     final response = await request.send();

  //     if (response.statusCode == 200) {
  //       // Sikeres feltöltés
  //       final responseData = await response.stream.toBytes();
  //       final responseString = String.fromCharCodes(responseData);
  //       final decodedResponse =
  //           json.decode(responseString); // Itt dekódoljuk a JSON-t

  //       Navigator.of(context).push(MaterialPageRoute(
  //         builder: (context) =>
  //             ViewAnalysisResultScreen(result: decodedResponse['text']),
  //       ));
  //     } else {
  //       // Sikertelen feltöltés, megjelenítünk egy Snackbar üzenetet
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Failed to upload image. Please try again.')),
  //       );
  //     }
  //   } catch (e) {
  //     // Hálózati vagy egyéb hiba esetén is informáljuk a felhasználót
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('An error occurred. Please try again.')),
  //     );
  //   }
  // }

  Widget _buildImageSection() {
    return Expanded(
      child: _image == null
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('lib/assets/placeholder.png',
                    width: double.infinity),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text(
                    "Add picture to analyze",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                  ),
                ),
              ],
            )
          : Image.file(File(_image!.path)),
    );
  }

  Widget _buildButtonSection() {
    return Column(
      children: [
        _image == null
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: Icon(Icons.photo_library),
                    label: Text('Pic from Gallery'),
                    style: ElevatedButton.styleFrom(
                      primary: Color.fromARGB(255, 255, 255, 255),
                      textStyle: TextStyle(fontSize: 18),
                    ),
                  ),

                  ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: Icon(Icons.camera),
                    label: Text('Take Picture'),
                    style: ElevatedButton.styleFrom(
                      primary: const Color.fromARGB(255, 255, 255, 255),
                      textStyle: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => setState(() => _image = null),
                    icon: Icon(Icons.change_circle),
                    label: Text('Change Picture'),
                    style: ElevatedButton.styleFrom(
                      primary: const Color.fromARGB(255, 255, 255, 255),
                      textStyle: TextStyle(fontSize: 18),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _extractText,
                    icon: Icon(Icons.data_usage),
                    label: Text('Extract Data'),
                    style: ElevatedButton.styleFrom(
                      primary: const Color.fromARGB(255, 255, 255, 255),
                      textStyle: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Analysis' , style: TextStyle(fontSize: 28)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Column(
          children: [
            _buildImageSection(),
            _buildButtonSection(),
          ],
        ),
      ),

      
    );
  }
}
