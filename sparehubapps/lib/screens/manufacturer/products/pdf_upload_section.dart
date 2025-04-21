import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PdfUploadSection extends StatelessWidget {
  final XFile? selectedPdfFile;
  final String? existingPdfUrl;
  final VoidCallback onPickPdf;
  final VoidCallback onClearPdf;

  const PdfUploadSection({
    super.key,
    required this.selectedPdfFile,
    this.existingPdfUrl,
    required this.onPickPdf,
    required this.onClearPdf,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedPdfFile != null) {
      return _buildSelectedPdfView(context);
    } else if (existingPdfUrl != null) {
      return _buildExistingPdfView(context);
    } else {
      return _buildUploadButton(context);
    }
  }

  Widget _buildSelectedPdfView(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.picture_as_pdf, color: Colors.red),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  File(selectedPdfFile!.path).uri.pathSegments.last,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: onClearPdf,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Selected PDF file',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildExistingPdfView(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.picture_as_pdf, color: Colors.red),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  Uri.parse(existingPdfUrl!).pathSegments.last,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: onPickPdf,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Current PDF file',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadButton(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPickPdf,
      icon: const Icon(Icons.upload_file),
      label: const Text('Upload Technical Specification PDF'),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }
}
