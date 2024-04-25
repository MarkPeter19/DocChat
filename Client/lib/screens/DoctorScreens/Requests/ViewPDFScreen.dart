import 'package:flutter/material.dart';
import 'package:advance_pdf_viewer2/advance_pdf_viewer.dart';

class ViewPDFScreen extends StatefulWidget {
  final String pdfUrl;

  ViewPDFScreen({required this.pdfUrl});

  @override
  _ViewPDFScreenState createState() => _ViewPDFScreenState();
}

class _ViewPDFScreenState extends State<ViewPDFScreen> {
  late PDFDocument _document;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    PDFDocument doc = await PDFDocument.fromURL(widget.pdfUrl);
    setState(() {
      _document = doc;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF Viewer'),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : PDFViewer(document: _document),
    );
  }
}
