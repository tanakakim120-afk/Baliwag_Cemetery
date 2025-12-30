import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'api_config.dart';

class DocumentVerificationService {
  /// Verifies if a document is legitimate by analyzing its content and structure
  static Future<DocumentVerificationResult> verifyDocument({
    required Uint8List documentBytes,
    required String fileName,
    required String mimeType,
  }) async {
    try {
      print('🔍 Document Verification Debug:');
      print('   File: $fileName');
      print('   MIME Type: $mimeType');
      print('   Size: ${documentBytes.length} bytes');

      DocumentVerificationResult result;

      // For PDF documents, use Document AI
      if (mimeType == 'application/pdf') {
        print('   Using Document AI for PDF verification...');
        print('   Service Account Email: ${ApiConfig.serviceAccountEmail}');
        print(
            '   Private Key Length: ${ApiConfig.serviceAccountPrivateKey.length}');
        result = await _verifyWithDocumentAI(documentBytes, fileName);
      }
      // For image documents, use basic validation
      else if (mimeType.startsWith('image/')) {
        print('   Using basic validation for image...');
        result = await _verifyImageDocument(documentBytes, fileName);
      }
      // For other document types, use basic validation
      else {
        print('   Using basic validation for other document type...');
        result = await _verifyBasicDocument(documentBytes, fileName, mimeType);
      }

      print(
          '   Result: Valid=${result.isValid}, Confidence=${(result.confidence * 100).toStringAsFixed(1)}%');
      print('   Issues: ${result.detectedIssues.length}');

      return result;
    } catch (e) {
      print('   Error during verification: $e');
      return DocumentVerificationResult(
        isValid: false,
        confidence: 0.0,
        message: 'Error during document verification: $e',
        extractedText: '',
        detectedIssues: ['Verification service error'],
      );
    }
  }

  /// Verifies PDF documents using Google Cloud Document AI
  static Future<DocumentVerificationResult> _verifyWithDocumentAI(
    Uint8List documentBytes,
    String fileName,
  ) async {
    try {
      print('Using Document AI with service account authentication...');

      // Generate JWT token for service account authentication
      final jwtToken = await _generateJWTToken();
      if (jwtToken == null) {
        print('Failed to generate JWT token, falling back to basic validation');
        return await _verifyPDFWithBasicValidation(documentBytes, fileName);
      }

      // Encode document to base64
      final base64Document = base64Encode(documentBytes);

      // Prepare request body
      final requestBody = {
        'rawDocument': {
          'content': base64Document,
          'mimeType': 'application/pdf',
        },
        'fieldMask': 'text,entities,confidence',
      };

      // Make API request with OAuth2 token
      print('   Making Document AI API request...');
      print('   Endpoint: ${ApiConfig.documentAiEndpoint}');
      print('   Token Length: ${jwtToken.length}');

      final response = await http.post(
        Uri.parse(ApiConfig.documentAiEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },
        body: jsonEncode(requestBody),
      );

      print('   Document AI Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('✅ Document AI processing successful!');
        return _parseDocumentAIResponse(responseData);
      } else {
        // If API fails, fall back to basic validation
        print(
            '❌ Document AI API error: ${response.statusCode} - ${response.body}');
        return await _verifyPDFWithBasicValidation(documentBytes, fileName);
      }
    } catch (e) {
      print('Document AI error: $e, falling back to basic validation');
      return await _verifyPDFWithBasicValidation(documentBytes, fileName);
    }
  }

  /// Generates JWT token for service account authentication
  static Future<String?> _generateJWTToken() async {
    try {
      // Service account credentials
      final serviceAccountEmail = ApiConfig.serviceAccountEmail;
      final privateKey = ApiConfig.serviceAccountPrivateKey;

      print('🔑 JWT Generation Debug:');
      print('   Email: $serviceAccountEmail');
      print('   Key Length: ${privateKey.length}');
      print('   Key Starts with: ${privateKey.substring(0, 20)}...');

      if (serviceAccountEmail.isEmpty || privateKey.isEmpty) {
        print('❌ Service account credentials not configured');
        return null;
      }

      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final expiry = now + 3600; // 1 hour expiry

      // Create JWT using dart_jsonwebtoken library
      final jwt = JWT({
        'iss': serviceAccountEmail,
        'scope': 'https://www.googleapis.com/auth/cloud-platform',
        'aud': 'https://oauth2.googleapis.com/token',
        'iat': now,
        'exp': expiry,
      });

      // Sign with private key using RSA
      print('   Creating JWT with RSA signing...');
      final token = jwt.sign(
        RSAPrivateKey(privateKey),
        algorithm: JWTAlgorithm.RS256,
      );
      print('   JWT Token Length: ${token.length}');

      // Exchange JWT for access token
      print('   Exchanging JWT for access token...');
      final tokenResponse = await http.post(
        Uri.parse('https://oauth2.googleapis.com/token'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body:
            'grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=$token',
      );
      print('   Token Response Status: ${tokenResponse.statusCode}');

      if (tokenResponse.statusCode == 200) {
        final tokenData = jsonDecode(tokenResponse.body);
        return tokenData['access_token'];
      } else {
        print(
            'Token exchange failed: ${tokenResponse.statusCode} - ${tokenResponse.body}');
        return null;
      }
    } catch (e) {
      print('JWT generation error: $e');
      return null;
    }
  }

  /// Enhanced PDF validation when Document AI is not available
  static Future<DocumentVerificationResult> _verifyPDFWithBasicValidation(
    Uint8List documentBytes,
    String fileName,
  ) async {
    final issues = <String>[];
    var confidence = 0.4; // Higher base confidence for PDFs

    // Check file size
    if (documentBytes.length < ApiConfig.minimumDocumentSize) {
      issues.add('PDF appears to be too small for a legitimate lease');
      confidence -= 0.3;
    }

    if (documentBytes.length > ApiConfig.maximumDocumentSize) {
      issues.add('PDF appears to be unusually large');
      confidence -= 0.1;
    }

    // Check PDF header (basic validation)
    final pdfHeader = String.fromCharCodes(documentBytes.take(4));
    if (pdfHeader != '%PDF') {
      issues.add('File does not appear to be a valid PDF');
      confidence -= 0.4;
    } else {
      confidence += 0.1; // Boost confidence for valid PDF structure
    }

    // Check filename
    final fileNameLower = fileName.toLowerCase();
    final leaseIndicators = [
      'lease',
      'rental',
      'agreement',
      'contract',
      'tenancy'
    ];
    final hasLeaseIndicator =
        leaseIndicators.any((indicator) => fileNameLower.contains(indicator));

    if (hasLeaseIndicator) {
      confidence += 0.2;
    } else {
      issues.add('Filename does not suggest this is a lease document');
      confidence -= 0.1;
    }

    // Check for PDF structure indicators
    final pdfContent = String.fromCharCodes(documentBytes.take(1000));
    final hasPdfStructure =
        pdfContent.contains('obj') && pdfContent.contains('stream');
    if (hasPdfStructure) {
      confidence += 0.1;
    } else {
      issues.add('PDF structure appears incomplete');
      confidence -= 0.1;
    }

    // PDFs without text extraction are less reliable for lease verification
    issues.add('PDF content cannot be fully verified without text extraction');
    confidence -= 0.1;

    return DocumentVerificationResult(
      isValid:
          issues.isEmpty && confidence > ApiConfig.minimumConfidenceThreshold,
      confidence: confidence,
      message: issues.isEmpty
          ? 'PDF document appears valid (basic validation only)'
          : 'PDF document validation issues detected',
      extractedText:
          'Text extraction not available without Document AI service',
      detectedIssues: issues,
    );
  }

  /// Verifies image documents using basic validation
  static Future<DocumentVerificationResult> _verifyImageDocument(
    Uint8List documentBytes,
    String fileName,
  ) async {
    // Basic image validation - be more strict
    final issues = <String>[];
    var confidence =
        0.3; // Lower base confidence for images (requires more validation)

    // Check file size (should be reasonable for a lease document)
    if (documentBytes.length < ApiConfig.minimumDocumentSize) {
      issues.add('Document appears to be too small for a legitimate lease');
      confidence -= 0.2;
    }

    if (documentBytes.length > ApiConfig.maximumDocumentSize) {
      issues.add('Document appears to be unusually large');
      confidence -= 0.1;
    }

    // Check if filename suggests it's a lease document
    final fileNameLower = fileName.toLowerCase();
    final leaseIndicators = [
      'lease',
      'rental',
      'agreement',
      'contract',
      'tenancy'
    ];
    final hasLeaseIndicator =
        leaseIndicators.any((indicator) => fileNameLower.contains(indicator));

    if (hasLeaseIndicator) {
      confidence += 0.2; // Boost confidence if filename suggests lease
    } else {
      issues.add('Filename does not suggest this is a lease document');
      confidence -= 0.1;
    }

    // Images without OCR are inherently less reliable for lease verification
    issues.add('Image files cannot be fully verified without text extraction');
    confidence -= 0.1;

    return DocumentVerificationResult(
      isValid:
          issues.isEmpty && confidence > ApiConfig.minimumConfidenceThreshold,
      confidence: confidence,
      message: issues.isEmpty
          ? 'Image document appears valid (basic validation only)'
          : 'Image document validation issues detected',
      extractedText: 'Text extraction not available for image files',
      detectedIssues: issues,
    );
  }

  /// Basic document validation for other file types
  static Future<DocumentVerificationResult> _verifyBasicDocument(
    Uint8List documentBytes,
    String fileName,
    String mimeType,
  ) async {
    final issues = <String>[];
    var confidence = 0.2; // Much lower base confidence for non-PDF documents

    // Check file size
    if (documentBytes.length < 1000) {
      issues.add('Document appears to be too small');
      confidence -= 0.2;
    }

    // Check file extension matches MIME type
    final extension = fileName.split('.').last.toLowerCase();
    if (mimeType == 'application/pdf' && extension != 'pdf') {
      issues.add('File extension does not match MIME type');
      confidence -= 0.2;
    }

    // Check if filename suggests it's a lease document
    final fileNameLower = fileName.toLowerCase();
    final leaseIndicators = [
      'lease',
      'rental',
      'agreement',
      'contract',
      'tenancy'
    ];
    final hasLeaseIndicator =
        leaseIndicators.any((indicator) => fileNameLower.contains(indicator));

    if (hasLeaseIndicator) {
      confidence += 0.3; // Boost confidence if filename suggests lease
    } else {
      issues.add('Filename does not suggest this is a lease document');
      confidence -= 0.1;
    }

    // Non-PDF documents are inherently less reliable for lease verification
    issues.add(
        'Document type cannot be fully verified without advanced text extraction');
    confidence -= 0.1;

    return DocumentVerificationResult(
      isValid:
          issues.isEmpty && confidence > ApiConfig.minimumConfidenceThreshold,
      confidence: confidence,
      message: issues.isEmpty
          ? 'Document appears valid (basic validation only)'
          : 'Document validation issues detected',
      extractedText: 'Text extraction not available for this file type',
      detectedIssues: issues,
    );
  }

  /// Parses Document AI API response
  static DocumentVerificationResult _parseDocumentAIResponse(
      Map<String, dynamic> responseData) {
    final issues = <String>[];
    var confidence = 0.0;
    var extractedText = '';

    try {
      // Extract text from response
      final document = responseData['document'];
      if (document != null) {
        extractedText = document['text'] ?? '';

        // Get entities from Document AI response
        final entities = document['entities'] as List<dynamic>? ?? [];
        print('🔍 Document AI Entities Found: ${entities.length}');

        // Calculate confidence based on Document AI entity extraction
        if (entities.isNotEmpty) {
          // Count successfully extracted entities
          final extractedEntities = entities
              .where((entity) =>
                  entity['mentionText'] != null &&
                  entity['mentionText'].toString().trim().isNotEmpty)
              .length;

          // Calculate confidence based on entity extraction success
          // Your processor has 15 fields, so we'll use that as the baseline
          const totalExpectedFields = 15;
          confidence =
              (extractedEntities / totalExpectedFields).clamp(0.0, 1.0);

          print(
              '📊 Entity-based confidence: ${(confidence * 100).toStringAsFixed(1)}%');
          print(
              '   Extracted entities: $extractedEntities out of $totalExpectedFields');

          // Boost confidence if we have key required fields
          final entityTypes =
              entities.map((e) => e['type']?.toString() ?? '').toSet();
          final requiredFields = [
            'Contract_number',
            'Client_name',
            'Total_amount',
            'Lot_location'
          ];
          final foundRequiredFields = requiredFields
              .where((field) => entityTypes.any((type) => type.contains(field)))
              .length;

          if (foundRequiredFields >= 3) {
            confidence = (confidence + 0.3).clamp(0.0, 1.0);
            print('📈 Boosted confidence for required fields: +30%');
          }
        } else {
          // Fallback to keyword-based confidence if no entities
          final textLower = extractedText.toLowerCase();
          final foundKeywords = ApiConfig.leaseKeywords
              .where((keyword) => textLower.contains(keyword))
              .length;
          confidence =
              (foundKeywords / ApiConfig.leaseKeywords.length).clamp(0.0, 1.0);
          print(
              '📊 Keyword-based confidence: ${(confidence * 100).toStringAsFixed(1)}%');
        }

        // Additional validation checks
        if (extractedText.length < 100) {
          issues.add('Document appears to contain very little text');
          confidence -= 0.2;
        }

        // Check for repeated text (potential fraud indicator)
        final words = extractedText.split(' ');
        final uniqueWords = words.toSet();
        if (words.length > 50 && uniqueWords.length < words.length * 0.3) {
          issues.add('Document contains suspiciously repetitive text');
          confidence -= 0.1;
        }

        // Check if document contains lease-specific content
        final textLower = extractedText.toLowerCase();
        final hasLeaseContent = textLower.contains('contract') ||
            textLower.contains('lease') ||
            textLower.contains('agreement');

        if (!hasLeaseContent) {
          issues.add(
              'Document does not appear to contain lease agreement content');
          confidence -= 0.2;
        }
      }

      // Check overall confidence
      if (confidence < ApiConfig.minimumConfidenceThreshold) {
        issues.add('Document confidence score is low');
      }

      print('🎯 Final confidence: ${(confidence * 100).toStringAsFixed(1)}%');
    } catch (e) {
      issues.add('Error parsing document analysis results');
      confidence = 0.0;
    }

    return DocumentVerificationResult(
      isValid:
          issues.isEmpty && confidence > ApiConfig.minimumConfidenceThreshold,
      confidence: confidence,
      message: issues.isEmpty
          ? 'Document appears to be a legitimate lease agreement'
          : 'Document validation issues detected',
      extractedText: extractedText,
      detectedIssues: issues,
    );
  }
}

/// Result of document verification
class DocumentVerificationResult {
  final bool isValid;
  final double confidence; // 0.0 to 1.0
  final String message;
  final String extractedText;
  final List<String> detectedIssues;

  DocumentVerificationResult({
    required this.isValid,
    required this.confidence,
    required this.message,
    required this.extractedText,
    required this.detectedIssues,
  });

  @override
  String toString() {
    return 'DocumentVerificationResult(isValid: $isValid, confidence: $confidence, message: $message, issues: $detectedIssues)';
  }
}
