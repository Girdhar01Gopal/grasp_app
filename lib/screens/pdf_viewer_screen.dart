import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'dart:io';

class PdfViewerScreen extends StatefulWidget {
  final String pdfTitle;
  final String pdfUrl;

  const PdfViewerScreen({
    super.key,
    required this.pdfTitle,
    required this.pdfUrl,
  });

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  final CacheManager _cacheManager = DefaultCacheManager();
  File? _cachedFile;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final cachedInfo = await _cacheManager.getFileFromCache(widget.pdfUrl);
      if (cachedInfo != null) {
        if (!mounted) return;
        setState(() {
          _cachedFile = cachedInfo.file;
          _loading = false;
        });
        return;
      }

      final connectivityResult = await Connectivity().checkConnectivity();
      final hasConnection = connectivityResult is List<ConnectivityResult>
          ? connectivityResult.any(
              (result) => result != ConnectivityResult.none,
            )
          : connectivityResult != ConnectivityResult.none;

      if (!hasConnection) {
        if (!mounted) return;
        setState(() {
          _error =
              'No internet connection and this PDF is not available offline yet.';
          _loading = false;
        });
        return;
      }

      final file = await _cacheManager.getSingleFile(widget.pdfUrl);
      if (!mounted) return;
      setState(() {
        _cachedFile = file;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error =
            'Failed to load PDF. Check your connection or try again later.';
        _loading = false;
      });
    }
  }

  void _clearCache() async {
    await _cacheManager.removeFile(widget.pdfUrl);
    setState(() {
      _cachedFile = null;
      _loading = true;
    });
    _loadPdf();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: const Color(0xFFC49B3B),
        title: Text(
          widget.pdfTitle,
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Clear Cache & Reload',
            onPressed: _clearCache,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!))
          : _cachedFile != null
          ? SfPdfViewer.file(
              _cachedFile!,
              canShowScrollHead: true,
              canShowScrollStatus: true,
              pageLayoutMode: PdfPageLayoutMode.continuous,
              onDocumentLoadFailed: (details) {
                setState(() {
                  _error = 'PDF ERROR: \\${details.error}';
                });
              },
            )
          : const Center(child: Text('No PDF file loaded.')),
    );
  }
}
