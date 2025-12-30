import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart';

class LogoUtils {
  static String? _logoBase64;

  /// Get the logo as base64 string for PDF generation
  /// This method caches the logo to avoid loading it multiple times
  static Future<String> getLogoBase64() async {
    if (_logoBase64 != null) {
      return _logoBase64!;
    }

    try {
      // Load the logo file from assets
      final ByteData data = await rootBundle.load('assets/images/logo.png');
      final Uint8List bytes = data.buffer.asUint8List();

      // Convert to base64
      _logoBase64 = base64Encode(bytes);
      return _logoBase64!;
    } catch (e) {
      // Fallback to a placeholder if logo loading fails
      print('Error loading logo: $e');
      return 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==';
    }
  }

  /// Clear the cached logo (useful for testing or memory management)
  static void clearCache() {
    _logoBase64 = null;
  }
}

