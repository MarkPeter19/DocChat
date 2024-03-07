import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:doctorgpt/screens/PatientScreens/ViewAnalysisResultScreen.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'dart:convert';
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
      SnackBar(content: Text('No image selected')),
    );
    return;
  }

  final inputImage = InputImage.fromFilePath(_image!.path);
  final textDetector = GoogleMlKit.vision.textRecognizer();

  try {
    final RecognizedText recognizedText = await textDetector.processImage(inputImage);
    Map<String, dynamic> structuredResults = {};

    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        // Itt próbáljuk meg azonosítani a sorokat és értékeket, amiket strukturálni szeretnénk
        // Ez függ a konkrét adatstruktúrától, amit vissza szeretnénk kapni
        // Például: "Hemoglobina (HGB): 15,6 g/dl" -> {"Hemoglobina (HGB)": "15,6 g/dl"}

        // Egyszerű szövegfelismerés esetén
        String key = line.text.split(':')[0].trim();
        String value = line.text.split(':').length > 1 ? line.text.split(':')[1].trim() : '';
        structuredResults[key] = value;
      }
    }

    if (structuredResults.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No text found in the image')),
      );
    } else {
      // Navigálás az eredmények megjelenítésére
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ViewAnalysisResultScreen(result: jsonEncode(structuredResults)),
      ));
    }
  } catch (e) {
    print(e);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error processing image: $e')),
    );
  } finally {
    textDetector.close();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Analysis'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (_image != null) Image.file(File(_image!.path)),
              ElevatedButton(
                onPressed: () => _pickImage(ImageSource.camera),
                child: Text('Take Picture'),
              ),
              ElevatedButton(
                onPressed: () => _pickImage(ImageSource.gallery),
                child: Text('Pick from Gallery'),
              ),
              ElevatedButton(
                onPressed: _extractText,
                child: Text('Extract Data'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
