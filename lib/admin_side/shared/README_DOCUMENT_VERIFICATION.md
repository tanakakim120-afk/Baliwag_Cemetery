# Document Verification API Setup

This document explains how to set up the document verification feature for proof of lease validation.

## Overview

The document verification system analyzes uploaded lease documents to determine if they are legitimate. It uses Google Cloud Document AI for PDF analysis and basic validation for other file types.

## Setup Instructions

### 1. Google Cloud Document AI Setup

1. **Create a Google Cloud Project**
   - Go to [Google Cloud Console](https://console.cloud.google.com/)
   - Create a new project or select an existing one
   - Note your Project ID

2. **Enable Document AI API**
   - Navigate to "APIs & Services" > "Library"
   - Search for "Document AI API"
   - Click "Enable"

3. **Create a Document AI Processor**
   - Go to Document AI in the Google Cloud Console
   - Click "Create Processor"
   - Choose "Form Parser" or "Document OCR" processor
   - Select your preferred location (e.g., "us")
   - Note the Processor ID

4. **Create API Key**
   - Go to "APIs & Services" > "Credentials"
   - Click "Create Credentials" > "API Key"
   - Copy the API key

### 2. Update Configuration

Edit `lib/admin_side/shared/api_config.dart` and replace the placeholder values:

```dart
class ApiConfig {
  // Replace with your actual values
  static const String googleCloudProjectId = 'your-actual-project-id';
  static const String documentAiProcessorId = 'your-actual-processor-id';
  static const String googleCloudApiKey = 'your-actual-api-key';
  
  // ... rest of configuration
}
```

### 3. Alternative Services (Optional)

If you prefer different verification services, you can modify the `DocumentVerificationService` to use:

- **Snappt API**: Specialized in rental document fraud detection
- **AWS Textract**: Amazon's document analysis service
- **Azure Form Recognizer**: Microsoft's document intelligence service

## How It Works

### Document Upload Process

1. **File Selection**: User selects a lease document (PDF, DOC, DOCX, JPG, PNG)
2. **Document Verification**: System analyzes the document using configured APIs
3. **Validation Results**: 
   - If valid: Document is uploaded with confidence score
   - If invalid: User sees detailed error dialog with option to upload anyway
4. **Admin Override**: Administrators can upload unverified documents if needed

### Verification Criteria

The system checks for:

- **File Size**: Documents must be between 1KB and 10MB
- **Content Analysis**: Looks for lease-related keywords
- **Text Extraction**: Extracts and analyzes document text
- **Pattern Detection**: Identifies suspicious or repetitive content
- **Confidence Scoring**: Assigns a confidence score (0-100%)

### Keywords Checked

The system looks for these lease-related terms:
- lease, rental, tenant, landlord, property, address
- monthly, rent, deposit, agreement, terms, signature
- premises, occupancy, utilities, maintenance, liability
- insurance, notice, termination

## Configuration Options

### Thresholds

```dart
// Minimum confidence required for automatic approval
static const double minimumConfidenceThreshold = 0.5;

// High confidence threshold for premium features
static const double highConfidenceThreshold = 0.8;

// Minimum number of lease keywords required
static const int minimumKeywordCount = 3;
```

### File Restrictions

```dart
// File size limits
static const int minimumDocumentSize = 1000; // 1KB
static const int maximumDocumentSize = 10000000; // 10MB

// Allowed file types
static const List<String> allowedMimeTypes = [
  'application/pdf',
  'image/jpeg',
  'image/png',
  'image/jpg',
];
```

## Error Handling

The system handles various error scenarios:

- **API Failures**: Falls back to basic validation
- **Invalid Documents**: Shows detailed error dialog
- **Network Issues**: Provides appropriate error messages
- **File Format Issues**: Validates file types and sizes

## Security Considerations

1. **API Key Security**: Store API keys securely, consider using environment variables
2. **Document Privacy**: Ensure documents are processed securely
3. **Data Retention**: Configure appropriate data retention policies
4. **Access Control**: Limit who can override verification results

## Testing

To test the verification system:

1. Upload a legitimate lease document - should pass verification
2. Upload a random image - should fail verification
3. Upload a very small file - should fail size validation
4. Upload a document with no lease keywords - should fail content validation

## Troubleshooting

### Common Issues

1. **API Key Invalid**: Check that the API key is correct and has proper permissions
2. **Processor Not Found**: Verify the processor ID and location
3. **Quota Exceeded**: Check Google Cloud quotas and billing
4. **Network Errors**: Ensure internet connectivity and firewall settings

### Debug Mode

Enable debug logging by adding print statements in the verification service to see detailed analysis results.

## Future Enhancements

Potential improvements:

1. **Machine Learning**: Train custom models for better fraud detection
2. **Signature Verification**: Add digital signature validation
3. **Document Templates**: Compare against known lease templates
4. **Real-time Validation**: Validate documents as they're being filled out
5. **Batch Processing**: Verify multiple documents at once

## Support

For issues with this feature:

1. Check the Google Cloud Console for API errors
2. Review the verification service logs
3. Test with known good and bad documents
4. Verify configuration settings are correct
