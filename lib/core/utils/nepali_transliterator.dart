import 'package:indic_transliteration_dart/indic_transliteration_dart.dart';

/// Romanized (phonetic) typing → Devanagari for product names and labels.
class NepaliTransliterator {
  NepaliTransliterator._();

  static bool _ready = false;

  static void _ensureReady() {
    if (_ready) return;
    initializeSchemes();
    _ready = true;
  }

  /// Converts romanized Nepali typing to Devanagari in real time.
  static String fromRoman(String roman) {
    final raw = roman.trim().toLowerCase();
    if (raw.isEmpty) return '';

    _ensureReady();
    final normalized = _normalizeRoman(raw);
    try {
      final dev = transliterate(normalized, fromScheme: itrans, toScheme: devanagari);
      if (dev.isNotEmpty && _hasDevanagari(dev)) return dev;
    } catch (_) {
      // fall through
    }
    try {
      final dev = transliterate(normalized, fromScheme: hk, toScheme: devanagari);
      if (dev.isNotEmpty && _hasDevanagari(dev)) return dev;
    } catch (_) {
      // fall through
    }
    return _fallbackConvert(normalized);
  }

  static bool _hasDevanagari(String s) =>
      s.runes.any((r) => r >= 0x0900 && r <= 0x097F);

  /// Insert schwa between consonant clusters for ITRANS (golbheda → golabheda).
  static String _normalizeRoman(String input) {
    const vowels = 'aeiou';
    const consonants = 'bcdfghjklmnpqrstvwxyz';
    final out = StringBuffer();

    for (var i = 0; i < input.length; i++) {
      final c = input[i];
      if (c == ' ') {
        out.write(' ');
        continue;
      }
      out.write(c);
      if (!consonants.contains(c)) continue;

      final next = i + 1 < input.length ? input[i + 1] : '';
      if (next.isEmpty || next == ' ' || vowels.contains(next)) continue;

      if (consonants.contains(next)) {
        final pair = '$c$next';
        if (_digraphs.contains(pair) || (c == 's' && next == 'h')) continue;
        out.write('a');
      }
    }
    return out.toString();
  }

  static const _digraphs = {
    'kh', 'gh', 'ch', 'jh', 'th', 'dh', 'ph', 'bh', 'sh', 'ng', 'ny', 'ts', 'dd', 'tt',
  };

  static String _fallbackConvert(String input) {
    final buf = StringBuffer();
    var i = 0;
    while (i < input.length) {
      if (input[i] == ' ') {
        buf.write(' ');
        i++;
        continue;
      }
      var matched = false;
      for (var len = 4; len >= 1; len--) {
        if (i + len > input.length) continue;
        final chunk = input.substring(i, i + len);
        final dev = _syllableMap[chunk];
        if (dev != null) {
          buf.write(dev);
          i += len;
          matched = true;
          break;
        }
      }
      if (!matched) {
        buf.write(input[i]);
        i++;
      }
    }
    return buf.toString();
  }

  static const _syllableMap = {
    'ka': 'क', 'kha': 'ख', 'ga': 'ग', 'gha': 'घ', 'nga': 'ङ',
    'cha': 'च', 'chha': 'छ', 'ja': 'ज', 'jha': 'झ', 'nya': 'ञ',
    'ta': 'त', 'tha': 'थ', 'da': 'द', 'dha': 'ध', 'na': 'न',
    'pa': 'प', 'pha': 'फ', 'ba': 'ब', 'bha': 'भ', 'ma': 'म',
    'ya': 'य', 'ra': 'र', 'la': 'ल', 'va': 'व', 'wa': 'व',
    'sa': 'स', 'sha': 'श', 'ha': 'ह',
    'a': 'अ', 'aa': 'आ', 'i': 'इ', 'ii': 'ई', 'ee': 'ई',
    'u': 'उ', 'uu': 'ऊ', 'oo': 'ऊ', 'e': 'ए', 'ai': 'ऐ', 'o': 'ओ', 'au': 'औ',
  };
}
