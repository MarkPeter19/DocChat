import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ViewAnalysisResultScreen extends StatefulWidget {
  final String result;

  ViewAnalysisResultScreen({required this.result});

  @override
  _ViewAnalysisResultScreenState createState() =>
      _ViewAnalysisResultScreenState();
}

class _ViewAnalysisResultScreenState extends State<ViewAnalysisResultScreen> {
  final TextEditingController _textEditingController = TextEditingController();
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _textEditingController.text = widget.result;
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  Future<void> _saveDocument() async {
    String patientId = FirebaseAuth
        .instance.currentUser!.uid; // A bejelentkezett beteg azonosítója
    String analysisContent =
        _textEditingController.text; // A TextField-ből származó szöveg
    Timestamp uploadTime = Timestamp.now(); //aktualis ido

    await FirebaseFirestore.instance
        .collection('patients')
        .doc(patientId)
        .collection('documents')
        .add({
      'analysisResult': analysisContent, // A dokumentum tartalma
      'uploadDate': uploadTime,
      // Itt adhatsz meg további mezőket, ha szükséges
    }).then((docRef) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Document saved successfully!')));
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save document: $error')));
    });
  }

  
  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('View Result', style: TextStyle(fontSize: 26)),
      leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context)),
    ),
    body: Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: TextField(
                controller: _textEditingController,
                maxLines: null, // Több soros bevitelhez
                style: TextStyle(fontSize: 16.0),
                decoration: InputDecoration(
                  hintText: 'Enter analysis result here...',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ),
        ),
        if (!_isSaved)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            child: ElevatedButton.icon(
              onPressed: () async {
                await _saveDocument();
                setState(() {
                  _isSaved = true;
                });
              },
              icon: Icon(Icons.save),
              label: Text('Save'),
              style: ElevatedButton.styleFrom(
                primary: Theme.of(context).colorScheme.primary,
                onPrimary: Colors.white,
                minimumSize: Size(double.infinity, 50), // Gomb szélességének és magasságának beállítása
              ),
            ),
          ),
        if (_isSaved)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            child: ElevatedButton.icon(
              onPressed: () {
                // A "Send to Doctor" logikájának implementálása itt lesz később
              },
              icon: Icon(Icons.send),
              label: Text('Send to Doctor'),
              style: ElevatedButton.styleFrom(
                primary: Theme.of(context).colorScheme.secondary,
                onPrimary: Colors.white,
                minimumSize: Size(double.infinity, 50), // Gomb szélességének és magasságának beállítása
              ),
            ),
          ),
      ],
    ),
  );
}

}
