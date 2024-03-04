import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:doctorgpt/screens/PatientScreens/ViewAnalysisResultScreen.dart';
import 'dart:convert';

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

  Future<void> _uploadImage() async {
    if (_image == null) return;
    final uri = Uri.parse(
        'http://10.0.2.2:8000/upload/'); // Az Android Emulátor esetében a localhost elérése 10.0.2.2
    final request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('file', _image!.path));
    
    final response = await request.send();

    if (response.statusCode == 200) {
      // Sikeres feltöltés
      final responseData = await response.stream.toBytes();
      final responseString = String.fromCharCodes(responseData);
      final decodedResponse = json.decode(responseString); // Itt dekódoljuk a JSON-t

      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) =>
            ViewAnalysisResultScreen(result: decodedResponse['text']),
      ));
    } else {
      print('Failed to upload image');
    }
  }

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
      body: Center(
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
              onPressed: _uploadImage,
              child: Text('Extract Data'),
            ),
          ],
        ),
      ),
    );
  }
}
