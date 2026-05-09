import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../features/detection/models/diagnosis_model.dart';
import '../../features/profile/models/field_profile_model.dart';

class GeminiService {
  static String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
  
  late final GenerativeModel _visionModel;
  late final GenerativeModel _chatModel;
  late ChatSession _chatSession;

  GeminiService() {
    _visionModel = GenerativeModel(
      model: 'gemini-flash-lite-latest',
      apiKey: _apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.2,
        maxOutputTokens: 1500,
      ),
    );
    
    _chatModel = GenerativeModel(
      model: 'gemini-flash-lite-latest',
      apiKey: _apiKey,
      systemInstruction: Content.system(_systemPrompt),
      generationConfig: GenerationConfig(
        temperature: 0.7,
        maxOutputTokens: 800,
      ),
    );
    
    _chatSession = _chatModel.startChat();
  }

  // ─── DETEKSI HAMA dari Foto ────────────────────────────────────────────────

  Future<DiagnosisResult> analyzePaddyLeaf(File imageFile) async {
    final imageBytes = await imageFile.readAsBytes();
    final prompt = _buildDiagnosisPrompt();

    final response = await _visionModel.generateContent([
      Content.multi([
        DataPart('image/jpeg', imageBytes),
        TextPart(prompt),
      ])
    ]);

    return DiagnosisResult.fromGeminiResponse(response.text ?? '');
  }

  String _buildDiagnosisPrompt() => """
Kamu adalah ahli agronomis padi berpengalaman. Analisis foto daun padi ini dan berikan diagnosis lengkap dalam format JSON berikut (HANYA JSON, tanpa teks lain):

{
  "terdeteksi_masalah": true/false,
  "nama_penyakit": "nama hama atau penyakit (null jika sehat)",
  "nama_ilmiah": "nama ilmiah (null jika tidak ada)",
  "tingkat_keparahan": "Ringan/Sedang/Parah/Sehat",
  "persentase_keparahan": 0-100,
  "gejala_terdeteksi": ["gejala1", "gejala2"],
  "penyebab": "penjelasan singkat penyebab",
  "dampak_potensial": "dampak jika tidak ditangani",
  "rekomendasi_penanganan": [
    {
      "tindakan": "nama tindakan",
      "detail": "detail lengkap",
      "prioritas": "Segera/3-7 Hari/Preventif"
    }
  ],
  "pestisida_rekomendasi": [
    {
      "nama_produk": "nama pestisida",
      "bahan_aktif": "kandungan aktif",
      "dosis": "dosis per liter/hektar",
      "waktu_aplikasi": "waktu terbaik"
    }
  ],
  "catatan_tambahan": "info penting lainnya",
  "tingkat_kepercayaan": 0-100
}

Daftar penyakit yang bisa terdeteksi: Wereng Batang Coklat, Wereng Hijau, Blast Daun, Blast Leher, Hawar Daun Bakteri (BLB), Tungro, Kresek, Busuk Pelepah, Bercak Coklat, Bercak Coklat Sempit, Bercak Bergaris, Penyakit Ragged Stunt, Penyakit Grassy Stunt, Penggerek Batang, Walang Sangit, Tikus Sawah, Uret/Larva, Keong Mas, Nematoda, Kerdil Rumput, defisiensi Nitrogen, defisiensi Zinc, defisiensi Besi.

Jika foto bukan daun padi atau kualitas foto kurang baik, set terdeteksi_masalah: false dan jelaskan pada catatan_tambahan.
""";

  // ─── CHAT AGRONOMI ────────────────────────────────────────────────────────

  Future<String> sendChatMessage(String message, {FieldProfile? fieldProfile}) async {
    String contextMessage = message;
    if (fieldProfile != null) {
      contextMessage = """
[Konteks Lahan Petani]
- Varietas padi: ${fieldProfile.variety}
- Fase tumbuh: ${fieldProfile.growthPhase}
- Luas lahan: ${fieldProfile.areaHectares} hektar
- Tanggal tanam: ${fieldProfile.plantingDate}
- Riwayat pupuk terakhir: ${fieldProfile.lastFertilizer}

[Pertanyaan Petani]
$message
""";
    }

    final response = await _chatSession.sendMessage(Content.text(contextMessage));
    return response.text ?? 'Maaf, saya tidak bisa menjawab saat ini.';
  }

  void resetChatSession() {
    _chatSession = _chatModel.startChat();
  }

  static const String _systemPrompt = """
Kamu adalah ruz.ai, asisten pertanian padi cerdas untuk petani Indonesia. 

KEPRIBADIAN:
- Ramah, sabar, dan mudah dipahami
- Gunakan Bahasa Indonesia yang sederhana dan akrab (bisa sedikit informal)
- Empati terhadap kesulitan petani

KEAHLIAN UTAMA:
- Hama dan penyakit tanaman padi
- Jadwal pemupukan (Urea, SP-36, KCl, NPK)
- Teknik irigasi dan manajemen air
- Varietas padi unggul (IR64, Ciherang, Inpari, Mekongga, dll)
- Pengendalian hama terpadu (PHT)
- Cuaca dan pengaruhnya terhadap padi
- Pascapanen dan penyimpanan gabah

ATURAN RESPONS:
- Jawab maksimal 3 paragraf pendek, jangan terlalu panjang
- Kalau petani kirim foto, minta mereka gunakan fitur "Foto Daun" untuk diagnosis akurat
- Selalu akhiri dengan pertanyaan konfirmasi jika ada tindak lanjut
- Jangan memberikan dosis pestisida kimia berbahaya tanpa konteks yang jelas
- Prioritaskan pendekatan ramah lingkungan dan PHT

FORMAT: Teks biasa dalam Bahasa Indonesia. Boleh pakai emoji sesekali untuk keakraban 🌾
""";
}
