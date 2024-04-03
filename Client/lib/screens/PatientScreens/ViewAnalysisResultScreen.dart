import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:doctorgpt/services/patient_services.dart';

class ViewAnalysisResultScreen extends StatefulWidget {
  final String result;

  ViewAnalysisResultScreen({required this.result});

  @override
  _ViewAnalysisResultScreenState createState() =>
      _ViewAnalysisResultScreenState();
}

class _ViewAnalysisResultScreenState extends State<ViewAnalysisResultScreen> {
  final TextEditingController _textEditingController = TextEditingController();
  final PatientServices patientServices = PatientServices();
  bool _isSaved = false;
  String? _savedDocumentId;

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
    String patientId = FirebaseAuth.instance.currentUser!.uid; 
    String analysisContent = _textEditingController.text;
    Timestamp uploadTime = Timestamp.now();

    DocumentReference docRef = FirebaseFirestore.instance
        .collection('patients')
        .doc(patientId)
        .collection('documents')
        .doc(); // Létrehozunk egy új DocumentReferencet egy új ID-val

    await docRef.set({
      'analysisResult': analysisContent,
      'uploadDate': uploadTime,
      // További mezők...
    }).then((_) {
      _savedDocumentId = docRef.id; // Elmentjük a dokumentum ID-ját
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Document saved successfully!')));
      setState(() {
        _isSaved = true;  // Frissítjük az állapotot, hogy a dokumentum elmentésre került
      });
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save document: $error')));
    });
  }


 void _sendToDoctor() async {
    if (_savedDocumentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No document saved to send')),
      );
      return;
    }
    
    try {
      String patientId = FirebaseAuth.instance.currentUser!.uid;
      await patientServices.sendDocumentToDoctor(patientId, _savedDocumentId!);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Document sent to doctor for review')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending document to doctor: $e')),
      );
    }
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
              onPressed: () async {
                _sendToDoctor();
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
