import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import 'package:http/http.dart' as http;
import 'package:stl_app/core/app_colors.dart';

class PdfViewerScreen extends StatefulWidget {
  final String url;
  final String filename;

  const PdfViewerScreen({
    super.key, 
    required this.url,
    required this.filename,
  });

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  PdfController? _pdfController;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  void _loadPdf() async {
    try {
      // Fetch PDF data from URL
      final response = await http.get(Uri.parse(widget.url));
      
      if (response.statusCode == 200) {
        final document = await PdfDocument.openData(response.bodyBytes);
        _pdfController = PdfController(
          document: Future.value(document),
        );
        
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load PDF: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _pdfController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.filename),
        backgroundColor: AppColors.background,
        foregroundColor: Colors.white,
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Ошибка загрузки: $_error',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : _pdfController != null
                  ? PdfView(
                      controller: _pdfController!,
                      scrollDirection: Axis.vertical,
                      onDocumentLoaded: (document) {},
                      onPageChanged: (page) {},
                    )
                  : const Center(child: Text('Не удалось загрузить PDF')),
    );
  }
}
