import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_dimensions.dart';

class OcrPage extends StatefulWidget {
  const OcrPage({super.key});

  @override
  State<OcrPage> createState() => _OcrPageState();
}

class _OcrPageState extends State<OcrPage> {
  File? _image;
  String? _result;
  bool _isLoading = false;
  final _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, maxWidth: 1024);
    if (picked != null) {
      setState(() {
        _image = File(picked.path);
        _result = null;
      });
      _processImage();
    }
  }

  Future<void> _processImage() async {
    if (_image == null) return;
    setState(() => _isLoading = true);
    try {
      // OCR processing via math engine when available
      // For now, show the image for manual expression entry
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() => _result = 'Image loaded. Use calculator for processing.');
    } catch (e) {
      setState(() => _result = 'Error: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Math OCR')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Scan a math expression',
              style: TextStyle(fontSize: AppDimensions.fontSizeXl, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppDimensions.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Camera'),
                  onPressed: () => _pickImage(ImageSource.camera),
                ),
                const SizedBox(width: AppDimensions.md),
                ElevatedButton.icon(
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Gallery'),
                  onPressed: () => _pickImage(ImageSource.gallery),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.lg),
            if (_image != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
                child: Image.file(_image!, height: 300, width: double.infinity, fit: BoxFit.contain),
              ),
              const SizedBox(height: AppDimensions.md),
            ],
            if (_isLoading)
              const Center(child: CircularProgressIndicator()),
            if (_result != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.md),
                  child: Text(_result!, style: const TextStyle(fontSize: AppDimensions.fontSizeLg)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
