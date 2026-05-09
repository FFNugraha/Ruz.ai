import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/gemini_service.dart';
import 'diagnosis_result_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final ImagePicker _picker = ImagePicker();
  final GeminiService _geminiService = GeminiService();
  bool _isAnalyzing = false;

  Future<void> _takePhoto(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _isAnalyzing = true;
        });

        final File imageFile = File(image.path);
        
        // Kirim ke Gemini tanpa perlu unggah ke Firebase
        final result = await _geminiService.analyzePaddyLeaf(imageFile);

        if (mounted) {
          setState(() {
            _isAnalyzing = false;
          });
          
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DiagnosisResultScreen(
                imageFile: imageFile,
                result: result,
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Deteksi Hama')),
      body: Center(
        child: _isAnalyzing 
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: AppColors.primary),
                const SizedBox(height: 16),
                const Text(
                  'Sedang menganalisis daun...',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Menggunakan Gemini AI',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.camera_alt, size: 80, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'Arahkan kamera ke daun padi yang sakit',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: const Icon(Icons.camera),
                  label: const Text('Buka Kamera'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                  onPressed: () => _takePhoto(ImageSource.camera),
                ),
                const SizedBox(height: 16),
                TextButton.icon(
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Pilih dari Galeri'),
                  onPressed: () => _takePhoto(ImageSource.gallery),
                ),
              ],
            ),
      ),
    );
  }
}
