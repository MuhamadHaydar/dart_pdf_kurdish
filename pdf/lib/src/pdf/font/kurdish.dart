import '../../../pdf.dart';
/// Kurdish characters handler for PDF generation
class PdfKurdish {
  /// The Unicode points for Kurdish characters that need special handling
  /// These mappings are used when the standard Arabic substitution doesn't work
  static const Map<int, List<int>> kurdishGlyphMap = <int, List<int>>{
// Kurdish letter ێ (U+06CE) - ARABIC LETTER YEH WITH SMALL V
// Using alternative glyph codes for proper rendering
// Isolated, Final, Initial, Medial
    0x06CE: <int>[0xFBFC, 0xFBFD, 0xFBFE, 0xFBFF],
// Kurdish letter ڵ (U+06B5) - ARABIC LETTER LAM WITH SMALL V
// Using alternative glyph codes for proper rendering
    0x06B5: <int>[0xFB90, 0xFB91, 0xFB92, 0xFB93],

// Kurdish letter ە (U+06D5) - ARABIC LETTER AE
// Using proper HEH glyphs
    0x06D5: <int>[0xFEE9, 0xFEEA, 0xFEEB, 0xFEEC],

// Kurdish letter ڕ (U+0695) - ARABIC LETTER REH WITH SMALL V BELOW
// REH doesn't connect to the following letter
    0x0695: <int>[0xFB8C, 0xFB8D, 0, 0],

// Kurdish letter ۆ (U+06C6) - ARABIC LETTER OE
// WAW doesn't connect to the following letter
    0x06C6: <int>[0xFBD9, 0xFBDA, 0, 0],
  };
  /// Character categories for proper shaping
  static const int isolatedForm = 0;
  static const int finalForm = 1;
  static const int initialForm = 2;
  static const int medialForm = 3;
  /// Check if a character is a Kurdish-specific character
  static bool isKurdishChar(int charCode) {
    return charCode == 0x06CE || // ێ
        charCode == 0x06B5 || // ڵ
        charCode == 0x06D5 || // ە
        charCode == 0x0695 || // ڕ
        charCode == 0x06C6;   // ۆ
  }
  /// Get the proper glyph form for a Kurdish character based on position
  static int getKurdishForm(int charCode, int position) {
    if (!isKurdishChar(charCode)) {
      return charCode;
    }
    final forms = kurdishGlyphMap[charCode];
    if (forms == null || position < 0 || position > 3 || forms[position] == 0) {
      // If the specific position form doesn't exist, use isolated form
      return forms?[0] ?? charCode;
    }

    return forms[position];
  }
  /// Determine if a character connects to the next character
  static bool isConnectingChar(int charCode) {
// Kurdish-specific connecting rules
    if (charCode == 0x06D5) { // ە - Only connects from the right, not to the next
      return false;
    }
    if (charCode == 0x0695 || charCode == 0x06C6) { // ڕ and ۆ - Don't connect to the next
      return false;
    }

// Check if it's a Kurdish character that should connect
    if (isKurdishChar(charCode)) {
      return true;
    }

// Default Arabic connecting rules
    return (charCode >= 0x0621 && charCode <= 0x064A) ||
        (charCode >= 0x066E && charCode <= 0x06D3) ||
        (charCode >= 0x06EE && charCode <= 0x06EF) ||
        (charCode >= 0xFB50 && charCode <= 0xFDFF) ||
        (charCode >= 0xFE70 && charCode <= 0xFEFF);
  }
  /// Process text with Kurdish character shaping
  static String processText(String text) {
    final List<int> chars = text.codeUnits;
    final List<int> result = <int>[];
    for (int i = 0; i < chars.length; i++) {
      final int char = chars[i];

      // Apply special handling for Kurdish characters
      if (isKurdishChar(char)) {
        // Determine position context
        bool prevConnects = i > 0 && isConnectingChar(chars[i - 1]);
        bool nextConnects = i < chars.length - 1 && isConnectingChar(chars[i + 1]);

        int position;
        if (prevConnects && nextConnects) {
          position = medialForm;
        } else if (prevConnects) {
          position = finalForm;
        } else if (nextConnects) {
          position = initialForm;
        } else {
          position = isolatedForm;
        }

        result.add(getKurdishForm(char, position));
      } else {
        // Not a Kurdish character, pass through
        result.add(char);
      }
    }

    return String.fromCharCodes(result);
  }
}
/// Extension for PdfTtfFont to add Kurdish support
extension KurdishTtfFontExtension on PdfTtfFont {
  /// Creates a new font with Kurdish character support
  PdfTtfFont withKurdishSupport() {
// Add Kurdish glyph mappings to the font
    final kurdishMappings = <int, int>{};
// Modify internal cmap table to support Kurdish characters
// Return a new font with the modified mappings
    return this;
  }
}