import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../models/diagnosis_model.dart';

class DiagnosisResultScreen extends StatelessWidget {
  final File imageFile;
  final DiagnosisResult result;

  const DiagnosisResultScreen({
    super.key,
    required this.imageFile,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasil Diagnosis'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Thumbnail gambar
            ClipRendezvous(context),
            const SizedBox(height: 16),
            _buildStatusBadge(),
            const SizedBox(height: 16),
            if (result.masalahTerdeteksi) ...[
              _buildDiagnosisCard(),
              const SizedBox(height: 16),
              _buildGejalaSection(),
              const SizedBox(height: 16),
              _buildRekomendasiSection(),
            ] else ...[
              const Card(
                color: AppColors.cardBg,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Tidak ada masalah signifikan yang terdeteksi. Tanaman Anda tampaknya sehat, atau foto tidak dapat dianalisis dengan baik.',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget ClipRendezvous(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(
          image: FileImage(imageFile),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color badgeColor;
    String badgeText;
    IconData badgeIcon;

    if (!result.masalahTerdeteksi) {
      badgeColor = AppColors.success;
      badgeText = 'SEHAT';
      badgeIcon = Icons.check_circle;
    } else if (result.tingkatKeparahan.toLowerCase().contains('parah')) {
      badgeColor = AppColors.danger;
      badgeText = 'HAMA PARAH';
      badgeIcon = Icons.warning;
    } else {
      badgeColor = AppColors.warning;
      badgeText = 'HAMA TERDETEKSI';
      badgeIcon = Icons.error;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(badgeIcon, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            badgeText,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiagnosisCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              result.namaPenyakit ?? 'Penyakit Tidak Diketahui',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            if (result.namaIlmiah != null)
              Text(
                '(${result.namaIlmiah})',
                style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
              ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tingkat Keparahan:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  '${result.tingkatKeparahan} (${result.persentaseKeparahan}%)',
                  style: TextStyle(
                    color: result.tingkatKeparahan.toLowerCase().contains('parah')
                        ? AppColors.danger
                        : AppColors.warning,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: result.persentaseKeparahan / 100,
              backgroundColor: Colors.grey[200],
              color: result.tingkatKeparahan.toLowerCase().contains('parah')
                  ? AppColors.danger
                  : AppColors.warning,
            ),
            const SizedBox(height: 16),
            const Text('Penyebab:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(result.penyebab),
          ],
        ),
      ),
    );
  }

  Widget _buildGejalaSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Gejala Terdeteksi:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: result.gejalaTermdeteksi.map((gejala) {
            return Chip(
              label: Text(gejala),
              backgroundColor: AppColors.cardBg,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRekomendasiSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Rekomendasi Penanganan:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...result.rekomendasiPenanganan.map((rek) {
          Color prioColor = Colors.grey;
          if (rek.prioritas.toLowerCase().contains('segera')) {
            prioColor = AppColors.danger;
          } else if (rek.prioritas.toLowerCase().contains('preventif')) prioColor = AppColors.success;
          else prioColor = AppColors.warning;

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Icon(Icons.healing, color: prioColor),
              title: Text(rek.tindakan, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(rek.detail),
              trailing: Text(
                rek.prioritas,
                style: TextStyle(color: prioColor, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          );
        }),
      ],
    );
  }
}
