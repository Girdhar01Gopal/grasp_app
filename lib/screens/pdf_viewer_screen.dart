import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class PdfViewerScreen extends StatelessWidget {
  final String pdfTitle;
  final String pdfUrl;

  const PdfViewerScreen({
    super.key,
    required this.pdfTitle,
    required this.pdfUrl,
  });

  /// Opens the PDF link in an external browser to download
  Future<void> _downloadPdf() async {
    final Uri url = Uri.parse(pdfUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      debugPrint("Could not launch $pdfUrl");
    }
  }

  /// Shares the PDF link
  void _sharePdf() {
    Share.share('📄 $pdfTitle\n$pdfUrl');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red.shade700,
        title: Text(
          pdfTitle,
          style: const TextStyle(fontSize: 16),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SfPdfViewer.network(pdfUrl),

      /// Floating Download + Share buttons
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            heroTag: "download_btn",
            backgroundColor: Colors.blue.shade700,
            icon: const Icon(Icons.download_rounded, color: Colors.white),
            label: const Text(
              "Download",
              style: TextStyle(color: Colors.white),
            ),
            onPressed: _downloadPdf,
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: "share_btn",
            backgroundColor: Colors.green.shade600,
            icon: const Icon(Icons.share_rounded, color: Colors.white),
            label: const Text(
              "Share",
              style: TextStyle(color: Colors.white),
            ),
            onPressed: _sharePdf,
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
