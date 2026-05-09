import 'dart:convert';

class DiagnosisResult {
  final bool masalahTerdeteksi;
  final String? namaPenyakit;
  final String? namaIlmiah;
  final String tingkatKeparahan;
  final int persentaseKeparahan;
  final List<String> gejalaTermdeteksi;
  final String penyebab;
  final String dampakPotensial;
  final List<RekomendasiPenanganan> rekomendasiPenanganan;
  final List<PestisidaRekomendasi> pestisidaRekomendasi;
  final String catatanTambahan;
  final int tingkatKepercayaan;
  final DateTime timestamp;

  const DiagnosisResult({
    required this.masalahTerdeteksi,
    this.namaPenyakit,
    this.namaIlmiah,
    required this.tingkatKeparahan,
    required this.persentaseKeparahan,
    required this.gejalaTermdeteksi,
    required this.penyebab,
    required this.dampakPotensial,
    required this.rekomendasiPenanganan,
    required this.pestisidaRekomendasi,
    required this.catatanTambahan,
    required this.tingkatKepercayaan,
    required this.timestamp,
  });

  factory DiagnosisResult.fromGeminiResponse(String response) {
    try {
      // Bersihkan response dari markdown code blocks jika ada
      final cleaned = response
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();
      
      final json = jsonDecode(cleaned) as Map<String, dynamic>;

      return DiagnosisResult(
        masalahTerdeteksi: json['terdeteksi_masalah'] ?? false,
        namaPenyakit: json['nama_penyakit'],
        namaIlmiah: json['nama_ilmiah'],
        tingkatKeparahan: json['tingkat_keparahan'] ?? 'Tidak diketahui',
        persentaseKeparahan: json['persentase_keparahan'] ?? 0,
        gejalaTermdeteksi: List<String>.from(json['gejala_terdeteksi'] ?? []),
        penyebab: json['penyebab'] ?? '-',
        dampakPotensial: json['dampak_potensial'] ?? '-',
        rekomendasiPenanganan: (json['rekomendasi_penanganan'] as List? ?? [])
            .map((e) => RekomendasiPenanganan.fromJson(e))
            .toList(),
        pestisidaRekomendasi: (json['pestisida_rekomendasi'] as List? ?? [])
            .map((e) => PestisidaRekomendasi.fromJson(e))
            .toList(),
        catatanTambahan: json['catatan_tambahan'] ?? '',
        tingkatKepercayaan: json['tingkat_kepercayaan'] ?? 0,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      // Fallback jika parsing gagal
      return DiagnosisResult(
        masalahTerdeteksi: false,
        tingkatKeparahan: 'Error',
        persentaseKeparahan: 0,
        gejalaTermdeteksi: [],
        penyebab: 'Gagal menganalisis respons AI',
        dampakPotensial: '-',
        rekomendasiPenanganan: [],
        pestisidaRekomendasi: [],
        catatanTambahan: 'Error: $e\\nResponse: $response',
        tingkatKepercayaan: 0,
        timestamp: DateTime.now(),
      );
    }
  }

  Map<String, dynamic> toFirestore() => {
    'masalah_terdeteksi': masalahTerdeteksi,
    'nama_penyakit': namaPenyakit,
    'tingkat_keparahan': tingkatKeparahan,
    'persentase_keparahan': persentaseKeparahan,
    'timestamp': timestamp.toIso8601String(),
    'tingkat_kepercayaan': tingkatKepercayaan,
  };
}

class RekomendasiPenanganan {
  final String tindakan;
  final String detail;
  final String prioritas;

  const RekomendasiPenanganan({
    required this.tindakan,
    required this.detail,
    required this.prioritas,
  });

  factory RekomendasiPenanganan.fromJson(Map<String, dynamic> json) =>
      RekomendasiPenanganan(
        tindakan: json['tindakan'] ?? '',
        detail: json['detail'] ?? '',
        prioritas: json['prioritas'] ?? 'Normal',
      );
}

class PestisidaRekomendasi {
  final String namaProduk;
  final String bahanAktif;
  final String dosis;
  final String waktuAplikasi;

  const PestisidaRekomendasi({
    required this.namaProduk,
    required this.bahanAktif,
    required this.dosis,
    required this.waktuAplikasi,
  });

  factory PestisidaRekomendasi.fromJson(Map<String, dynamic> json) =>
      PestisidaRekomendasi(
        namaProduk: json['nama_produk'] ?? '',
        bahanAktif: json['bahan_aktif'] ?? '',
        dosis: json['dosis'] ?? '',
        waktuAplikasi: json['waktu_aplikasi'] ?? '',
      );
}
