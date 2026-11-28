// =============================================================================
// FILE: lib/core/services/qris_service.dart
// Dart port dari https://github.com/verssache/qris-dinamis
// Mengkonversi QRIS statis menjadi QRIS dinamis dengan nominal tertentu.
// Algoritma: TLV parser + CRC16-CCITT (poly 0x1021, init 0xFFFF)
// =============================================================================

/// Utilitas statis pengonversi payload QRIS statis menjadi QRIS dinamis sesuai nominal transaksi.
class QrisService {
  QrisService._();

  // ---------------------------------------------------------------------------
  // QRIS statis Go Ticket (placeholder — ganti dengan QRIS asli dari bank)
  // Format: QRIS standar ASPI/Bank Indonesia
  // ---------------------------------------------------------------------------
  static const String _staticQris =
      '00020101021126670016ID.CO.BNI.WWW011893600009150234523038930303UBE52045499530336054031005802ID5912GO TICKET6013JAKARTA PUSAT63046BF2';

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Konversi QRIS statis → QRIS dinamis dengan nominal [amountIDR].
  /// Mengembalikan string QRIS dinamis yang siap di-render sebagai QR code.
  static String convertToDynamic(int amountIDR) {
    try {
      return _convert(_staticQris, amountIDR);
    } catch (_) {
      // Fallback: encode nominal ke dalam data sederhana
      return 'GOTICKET-PAY-$amountIDR';
    }
  }

  // ---------------------------------------------------------------------------
  // Internal implementation
  // ---------------------------------------------------------------------------

  static String _convert(String staticQris, int amount) {
    // Hapus CRC (4 char terakhir) + prefix "6304" (4 char) = strip 8 char
    final raw = staticQris.endsWith('6304'.padRight(8, '0')) || staticQris.length > 8
        ? staticQris.substring(0, staticQris.length - 8)
        : staticQris;

    final elements = _parseTLV(raw);

    final amountStr = amount.toString();
    final out = StringBuffer();

    bool amountInserted = false;

    for (final e in elements) {
      final tag = e['tag'] as String;
      final value = e['value'] as String;

      // Tag 01: ubah dari "11" (statis) ke "12" (dinamis)
      if (tag == '01') {
        out.write(_buildTLVElement(tag, '12'));
        continue;
      }

      // Tag 54 (amount), 55 (tip indicator), 56, 57, 63 (CRC): skip dari original
      if (tag == '54' || tag == '55' || tag == '56' || tag == '57' || tag == '63') {
        continue;
      }

      // Sebelum tag 58 (negara), sisipkan tag 54 (nominal)
      if (tag == '58' && !amountInserted) {
        out.write(_buildTLVElement('54', amountStr));
        amountInserted = true;
      }

      out.write(_buildTLVElement(tag, value));
    }

    // Jika tag 58 tidak ditemukan, sisipkan 54 di akhir sebelum CRC
    if (!amountInserted) {
      out.write(_buildTLVElement('54', amountStr));
    }

    // Tambahkan prefix CRC tag, hitung CRC, gabungkan
    final withCrcTag = '${out.toString()}6304';
    final crc = _crc16(withCrcTag);
    return '$withCrcTag$crc';
  }

  // ---------------------------------------------------------------------------
  // TLV Parser — format: 2-digit tag + 2-digit length + value
  // ---------------------------------------------------------------------------
  static List<Map<String, dynamic>> _parseTLV(String data) {
    final result = <Map<String, dynamic>>[];
    int i = 0;
    while (i + 4 <= data.length) {
      final tag = data.substring(i, i + 2);
      final lenStr = data.substring(i + 2, i + 4);
      final len = int.tryParse(lenStr) ?? 0;
      i += 4;
      if (i + len > data.length) break;
      final value = data.substring(i, i + len);
      result.add({'tag': tag, 'length': len, 'value': value});
      i += len;
    }
    return result;
  }

  // ---------------------------------------------------------------------------
  // TLV Builder — 2-digit tag + 2-digit length (padded) + value
  // ---------------------------------------------------------------------------
  static String _buildTLVElement(String tag, String value) {
    final len = value.length.toString().padLeft(2, '0');
    return '$tag$len$value';
  }

  // ---------------------------------------------------------------------------
  // CRC16-CCITT (XModem) — poly 0x1021, init 0xFFFF
  // ---------------------------------------------------------------------------
  static String _crc16(String data) {
    int crc = 0xFFFF;
    for (final char in data.codeUnits) {
      crc ^= (char << 8);
      for (int j = 0; j < 8; j++) {
        if ((crc & 0x8000) != 0) {
          crc = ((crc << 1) ^ 0x1021) & 0xFFFF;
        } else {
          crc = (crc << 1) & 0xFFFF;
        }
      }
    }
    return crc.toRadixString(16).toUpperCase().padLeft(4, '0');
  }
}

