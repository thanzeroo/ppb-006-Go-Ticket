// =============================================================================
// FILE: lib/core/services/tiko_chat_service.dart
// RESPONSIBILITY: Service untuk berkomunikasi dengan Gemini API.
//                 Mengirim pertanyaan user beserta system prompt Tiko,
//                 dan menerima respons AI.
// =============================================================================

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// Model untuk satu pesan chat
class TikoChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  const TikoChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

/// Service singleton untuk chatbot Tiko via Gemini API
class TikoChatService {
  TikoChatService._();
  static final TikoChatService instance = TikoChatService._();

  /// Riwayat chat untuk konteks percakapan
  final List<TikoChatMessage> _history = [];
  List<TikoChatMessage> get history => List.unmodifiable(_history);

  /// System prompt / data pengetahuan Tiko khusus Pihak Hotel (Pengurusan & Operasional)
  static const String _systemPrompt = '''
=== IDENTITAS & GAYA BICARA ===
Kamu adalah asisten AI bernama Tiko khusus untuk portal Mitra Pengelola Hotel 'Go Ticket Hotel'.
Tugas utamamu adalah membantu Administrator Hotel, Staf Front Office, dan Maintenance dalam mengurus operasional dan manajemen hotel.
Gunakan bahasa Indonesia yang profesional, ramah, jelas, dan langsung ke inti. Jangan bertele-tele.
Jika jawabannya berupa langkah-langkah, tulis berurutan dengan nomor.
Jika user menyapa, balas dengan sapaan hangat lalu tanyakan apa yang bisa dibantu terkait pengelolaan hotel.
Jangan pernah mengaku sebagai manusia. Jika ditanya, katakan kamu asisten AI pengurusan hotel Go Ticket.

=== FOKUS KEPENGURUSAN HOTEL (3 ROLE PIHAK HOTEL) ===
1. ADMINISTRATOR HOTEL (Manager / Owner Hotel)
   - Dashboard Eksekutif: memantau total pendapatan kotor, total kamar dibooking, dan kepuasan tamu (rating ulasan) berdasarkan periode (Hari Ini, 7 Hari Terakhir, Bulan Ini, Semua).
   - Manajemen Kamar & Tarif: menambah tipe kamar, mengatur kuota unit fisik kamar, harga dasar & harga weekend, serta fasilitas kamar.
   - Manajemen Staf & Tim: menambah karyawan baru (Staf Front Office, Maintenance, serta Administrator maksimal 3 akun per hotel), mengatur shift operasional (Pagi, Siang, Malam, Full Time), dan memantau status On-Duty / Off-Duty.
   - Keuangan & Pencairan Dana: memantau mutasi transaksi booking, pendapatan bersih hotel, dan mengajukan penarikan dana (payout) ke rekening bank mitra.

2. STAF FRONT OFFICE (Resepsionis)
   - Dashboard Operasional: memantau kedatangan tamu hari ini (expected check-in), keberangkatan (expected check-out), dan okupansi kamar.
   - Verifikasi Booking: memeriksa pesanan masuk dari aplikasi Go Ticket dan memvalidasi pembayaran.
   - Check-In Tamu: memverifikasi kode booking / e-tiket tamu, menyerahkan kunci kamar, dan mengubah status kamar menjadi Occupied.
   - Check-Out Tamu: menyelesaikan masa menginap tamu (normal, check-out lebih awal, atau perpanjangan), lalu otomatis memasukkan kamar ke antrean pembersihan (Dirty).

3. MAINTENANCE (Housekeeping & Teknisi)
   - Kebersihan Kamar (Housekeeping): melihat daftar kamar yang baru check-out (Dirty), melakukan pembersihan & sanitasi, mengisi checklist kebersihan, dan mengubah status kamar menjadi Siap Huni (Clean & Ready).
   - Laporan Kerusakan (Maintenance Ticket): mencatat kerusakan fasilitas kamar (AC, listrik, air, furnitur) lengkap dengan bukti foto dan memperbarui status perbaikan hingga selesai.

=== SIKLUS STATUS KAMAR DI HOTEL ===
Available (siap dijual) -> Booked/Confirmed (sudah dipesan tamu) -> Occupied (tamu sedang menginap)
-> Dirty (tamu sudah check-out) -> Cleaning (sedang dibersihkan petugas) -> Clean & Ready -> Available kembali.

=== PANDUAN MENJAWAB ===
- Fokus pada solusi operasional hotel, tata cara penggunaan fitur di portal Administrator, Front Office, dan Maintenance.
- Jika ditanya hal teknis di luar kepengurusan hotel atau di luar sistem Go Ticket (seperti topik politik, coding, PR sekolah), tolak dengan sopan dan arahkan kembali ke topik pengelolaan hotel.
- Jangan mengarang angka nominal komisi, harga kamar spesifik, atau nomor kontak/rekening yang tidak tersedia di sistem.
- Jangan pernah meminta atau menyimpan password, PIN, atau data sensitif user di chat.
''';

  /// API Key Gemini dari .env
  String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

  /// Daftar model — coba dari yang paling ringan & stabil dulu
  static const List<String> _models = [
    'gemini-flash-lite-latest',
    'gemini-3.5-flash-lite',
    'gemini-flash-latest',
  ];

  /// Bangun URL endpoint untuk model tertentu
  String _apiUrlForModel(String model) =>
      'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$_apiKey';

  /// Kirim pesan dan dapatkan respons dari Tiko
  Future<String> sendMessage(String userMessage) async {
    // Tambahkan pesan user ke history
    _history.add(TikoChatMessage(
      text: userMessage,
      isUser: true,
      timestamp: DateTime.now(),
    ));

    try {
      // Bangun contents array dari history (batasi 10 pesan terakhir agar ringan)
      final List<Map<String, dynamic>> contents = [];
      final recentHistory = _history.length > 10
          ? _history.sublist(_history.length - 10)
          : _history;

      for (final msg in recentHistory) {
        contents.add({
          'role': msg.isUser ? 'user' : 'model',
          'parts': [
            {'text': msg.text}
          ],
        });
      }

      final body = jsonEncode({
        'system_instruction': {
          'parts': [
            {'text': _systemPrompt}
          ]
        },
        'contents': contents,
        'generationConfig': {
          'temperature': 0.7,
          'topP': 0.9,
          'topK': 20,
          'maxOutputTokens': 512,
        },
        'safetySettings': [
          {
            'category': 'HARM_CATEGORY_HARASSMENT',
            'threshold': 'BLOCK_NONE',
          },
          {
            'category': 'HARM_CATEGORY_HATE_SPEECH',
            'threshold': 'BLOCK_NONE',
          },
          {
            'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
            'threshold': 'BLOCK_NONE',
          },
          {
            'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
            'threshold': 'BLOCK_NONE',
          },
        ],
      });

      // Coba setiap model — fallback jika 503/404/429
      for (final model in _models) {
        debugPrint('🤖 [TikoChatService] Mencoba model: $model');

        final response = await http.post(
          Uri.parse(_apiUrlForModel(model)),
          headers: {'Content-Type': 'application/json'},
          body: body,
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          final candidates = data['candidates'] as List<dynamic>?;
          if (candidates != null && candidates.isNotEmpty) {
            final content =
                candidates[0]['content'] as Map<String, dynamic>?;
            final parts = content?['parts'] as List<dynamic>?;
            if (parts != null && parts.isNotEmpty) {
              final replyText = parts[0]['text'] as String? ?? '';
              final cleanReply = replyText.trim();

              if (cleanReply.isNotEmpty) {
                _history.add(TikoChatMessage(
                  text: cleanReply,
                  isUser: false,
                  timestamp: DateTime.now(),
                ));

                debugPrint('✅ [TikoChatService] Berhasil dengan model: $model');
                return cleanReply;
              }
            }
          }
        }

        // Jika 503, 429, 404 — coba model berikutnya
        final code = response.statusCode;
        debugPrint(
            '⚠️ [TikoChatService] Model $model gagal ($code), coba model lain...');

        if (code != 503 && code != 429 && code != 404) {
          // Error lain (400, 401, dll) — jangan retry, langsung gagal
          debugPrint(
              '❌ [TikoChatService] API Error $code: ${response.body}');
          break;
        }
      }

      final fallback = 'Maaf, server AI sedang sibuk. Coba lagi dalam beberapa saat ya! 🙏';
      _history.add(TikoChatMessage(
        text: fallback,
        isUser: false,
        timestamp: DateTime.now(),
      ));
      return fallback;
    } catch (e) {
      debugPrint('❌ [TikoChatService] Exception: $e');
      final errorMsg = 'Maaf, terjadi kesalahan. Pastikan koneksi internet kamu stabil dan coba lagi ya! 🙏';
      _history.add(TikoChatMessage(
        text: errorMsg,
        isUser: false,
        timestamp: DateTime.now(),
      ));
      return errorMsg;
    }
  }

  /// Hapus semua riwayat chat
  void clearHistory() {
    _history.clear();
  }
}

