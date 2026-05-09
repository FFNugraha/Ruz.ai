import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy data for history
    final historyItems = [
      {
        'title': 'Pemindaian Penyakit Padi',
        'subtitle': 'Bercak Daun Coklat (Brown Spot) terdeteksi.',
        'date': 'Hari ini, 09:30',
        'icon': Icons.document_scanner,
        'color': AppColors.warning,
      },
      {
        'title': 'Konsultasi AI',
        'subtitle': 'Menanyakan dosis pupuk Urea untuk padi usia 30 HST.',
        'date': 'Kemarin, 15:45',
        'icon': Icons.chat,
        'color': AppColors.info,
      },
      {
        'title': 'Pemindaian Penyakit Jagung',
        'subtitle': 'Tanaman sehat, tidak ada penyakit terdeteksi.',
        'date': '26 April 2026, 08:15',
        'icon': Icons.document_scanner,
        'color': AppColors.success,
      },
      {
        'title': 'Peringatan IoT',
        'subtitle': 'Kelembapan tanah terlalu kering (<50%), pompa irigasi diaktifkan otomatis.',
        'date': '25 April 2026, 14:20',
        'icon': Icons.sensors,
        'color': AppColors.danger,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Aktivitas'),
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: historyItems.length,
        itemBuilder: (context, index) {
          final item = historyItems[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: CircleAvatar(
                backgroundColor: (item['color'] as Color).withOpacity(0.1),
                child: Icon(
                  item['icon'] as IconData,
                  color: item['color'] as Color,
                ),
              ),
              title: Text(
                item['title'] as String,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(item['subtitle'] as String),
                  const SizedBox(height: 8),
                  Text(
                    item['date'] as String,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              isThreeLine: true,
            ),
          );
        },
      ),
    );
  }
}
