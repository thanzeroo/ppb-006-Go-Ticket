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

import '../constants/app_constants.dart';

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

  /// System prompt / basis pengetahuan Tiko AI yang ringkas, presisi, dan hemat token
  static const String _systemPrompt = '''
Kamu adalah Tiko, asisten AI resmi aplikasi 'Go Ticket' (platform reservasi hotel & penginapan).
Gaya bicara: ramah, sopan, ringkas, padat, berbahasa Indonesia natural, tanpa bertele-tele. Maksimal 2-3 paragraf singkat atau poin langkah bernomor.

6 TOPIK UTAMA GO TICKET:
1. Cara Booking Hotel:
   Pilih hotel di Beranda/Cari -> Pilih tipe kamar -> Tentukan tanggal Check-in & Check-out di Kalender -> Tentukan jumlah tamu -> Lengkapi data pemesan -> Lakukan pembayaran -> E-tiket langsung terbit.
2. Metode Pembayaran:
   Mendukung QRIS (otomatis diverifikasi), Transfer Bank (BCA, Mandiri, BNI, BRI), serta E-Wallet.
3. E-Tiket & Bukti Booking:
   Setelah bayar, e-tiket muncul di menu 'Pesanan'. Berisi kode booking unik, nama tamu, tanggal menginap, dan QR Code untuk check-in.
4. Alur Check-in & Check-out:
   Check-in: Tunjukkan QR Code e-tiket kepada resepsionis hotel mitra, staf memverifikasi dan menyerahkan kunci kamar. Check-out: Kembalikan kunci di resepsionis.
5. Voucher & Promo Diskon:
   Dapatkan kode voucher di Beranda atau menu Pengaturan -> Voucher Saya. Salin dan tempelkan kode saat checkout pembayaran untuk mendapatkan potongan harga.
6. Pembatalan & Perubahan:
   Pembatalan dapat diajukan melalui detail pesanan di tab Pesanan sebelum waktu check-in tiba sesuai ketentuan hotel mitra.

ATURAN PENTING:
- Jawab secara langsung dan to-the-point.
- Jangan mengarang data kamar atau nomor rekening fiktif.
- Jika di luar konteks Go Ticket, arahkan kembali ke pemesanan hotel dengan sopan.
''';

  static const String _defineGeminiKey =
      String.fromEnvironment('GEMINI_API_KEY');

  /// API Key Gemini dari `--dart-define` atau `.env`.
  String get _apiKey {
    if (_defineGeminiKey.isNotEmpty) return _defineGeminiKey.trim();
    try {
      return dotenv.env['GEMINI_API_KEY']?.trim() ?? '';
    } catch (_) {
      return '';
    }
  }

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

    if (_apiKey.isEmpty) {
      const msg =
          'Asisten AI Tiko belum terkonfigurasi. Pastikan GEMINI_API_KEY tersedia di file .env.';
      _history.add(TikoChatMessage(
        text: msg,
        isUser: false,
        timestamp: DateTime.now(),
      ));
      return msg;
    }

    try {
      // Bangun contents array dari history (batasi jumlah pesan konteks dari AppConstants)
      final List<Map<String, dynamic>> contents = [];
      const maxHistory = AppConstants.tikoMaxHistoryMessages;
      final recentHistory = _history.length > maxHistory
          ? _history.sublist(_history.length - maxHistory)
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
          'temperature': AppConstants.tikoTemperature,
          'topP': AppConstants.tikoTopP,
          'topK': AppConstants.tikoTopK,
          'maxOutputTokens': AppConstants.tikoMaxOutputTokens,
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
      for (final model in AppConstants.tikoModels) {
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

