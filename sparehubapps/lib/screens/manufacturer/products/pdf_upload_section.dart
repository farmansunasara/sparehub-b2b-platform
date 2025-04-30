import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';

class PdfUploadSection extends StatefulWidget {
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
  State<PdfUploadSection> createState() => _PdfUploadSectionState();
}

class _PdfUploadSectionState extends State<PdfUploadSection> {
  bool _isPicking = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedOpacity(
      opacity: 1.0,
      duration: const Duration(milliseconds: 300),
      child: widget.selectedPdfFile != null
          ? _buildSelectedPdfView(context)
          : widget.existingPdfUrl != null
              ? _buildExistingPdfView(context)
              : _buildUploadButton(context, theme),
    );
  }

  Widget _buildSelectedPdfView(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: theme.cardTheme.elevation,
      shape: theme.cardTheme.shape,
      color: theme.cardTheme.color,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.picture_as_pdf, color: Colors.red, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    File(widget.selectedPdfFile!.path).uri.pathSegments.last,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Semantics(
                  label: 'Clear selected PDF',
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: widget.onClearPdf,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Selected PDF file',
              style: GoogleFonts.poppins(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExistingPdfView(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: theme.cardTheme.elevation,
      shape: theme.cardTheme.shape,
      color: theme.cardTheme.color,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.picture_as_pdf, color: Colors.red, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    Uri.parse(widget.existingPdfUrl!).pathSegments.last,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Semantics(
                  label: 'Replace existing PDF',
                  child: IconButton(
                    icon: const Icon(Icons.edit, color: Color(0xFFFF9800)),
                    onPressed: widget.onPickPdf,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Current PDF file',
              style: GoogleFonts.poppins(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadButton(BuildContext context, ThemeData theme) {
    return Semantics(
      label: 'Upload PDF file',
      child: ElevatedButton.icon(
        onPressed: _isPicking
            ? null
            : () async {
                setState(() {
                  _isPicking = true;
                });
                try {
                  final ImagePicker picker = ImagePicker();
                  final XFile? file = await picker.pickMedia();
                  if (file != null) {
                    if (!file.path.toLowerCase().endsWith('.pdf')) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Please select a PDF file',
                              style: GoogleFonts.poppins(),
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                      return;
                    }
                    final fileSize = await File(file.path).length();
                    final sizeInMB = fileSize / (1024 * 1024);
                    if (sizeInMB > 5) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'PDF file size must be less than 5MB',
                              style: GoogleFonts.poppins(),
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                      return;
                    }
                    widget.onPickPdf();
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Error picking PDF: ${e.toString()}',
                          style: GoogleFonts.poppins(),
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } finally {
                  if (mounted) {
                    setState(() {
                      _isPicking = false;
                    });
                  }
                }
              },
        icon: _isPicking
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.upload_file),
        label: Text(
          'Upload PDF',
          style: GoogleFonts.poppins(),
        ),
        style: theme.elevatedButtonTheme.style?.copyWith(
          backgroundColor: MaterialStateProperty.all(const Color(0xFFFF9800)),
          foregroundColor: MaterialStateProperty.all(Colors.white),
          padding: MaterialStateProperty.all(
            const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          ),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }
}