import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:logger/logger.dart';

class ViewPDFScreen extends StatelessWidget {
  final String pdfUrl;

  ViewPDFScreen({required this.pdfUrl});

  final Logger _logger = Logger();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF Viewer'),
      ),
      body: Center(
        child: PDFView(
          filePath: pdfUrl,
          enableSwipe: true,
          swipeHorizontal: true,
          autoSpacing: false,
          pageFling: false,
          pageSnap: true,
          defaultPage: 0,
          fitPolicy: FitPolicy.BOTH,
          onPageChanged: (int? page, int? total) {
            if (page != null && total != null) {
              _logger.d('Page changed: $page/$total');
            } else {
              _logger.e('Page changed: invalid page or total');
            }
          },
          onViewCreated: (PDFViewController? controller) {
            _logger.d('PDF View Controller created');
          },
        ),
      ),
    );
  }
}
