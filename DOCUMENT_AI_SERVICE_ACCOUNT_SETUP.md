# Document AI Service Account Setup Guide

This guide will help you set up the full Document AI with text extraction capabilities.

## 🚀 Quick Setup Steps

### 1. Create Service Account in Google Cloud Console

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your project: `tomb-nav-30luyb`
3. Navigate to **IAM & Admin** → **Service Accounts**
4. Click **Create Service Account**
5. Fill in the details:
   - **Name**: `document-ai-service`
   - **Description**: `Service account for Lease_Custom_Extractor processor`
6. Click **Create and Continue**

### 2. Assign Roles

Add these roles to your service account:
- **Document AI API User**
- **Document AI Editor** (optional, for advanced features)

Click **Done**

### 3. Create and Download Key

1. Find your newly created service account
2. Click on the **Actions** menu (three dots) → **Manage keys**
3. Click **Add Key** → **Create new key**
4. Select **JSON** format
5. Click **Create**
6. **Important**: Save the downloaded JSON file securely

### 4. Extract Credentials from JSON

Open the downloaded JSON file and find these values:

```json
{
  "type": "service_account",
  "project_id": "tomb-nav-30luyb",
  "private_key_id": "...",
  "private_key": "-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n",
  "client_email": "document-ai-service@tomb-nav-30luyb.iam.gserviceaccount.com",
  "client_id": "...",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  ...
}
```

### 5. Update Configuration

Edit `lib/admin_side/shared/api_config.dart` and replace the empty values:

```dart
// Service Account Configuration for Document AI
static const String serviceAccountEmail = 'document-ai-service@tomb-nav-30luyb.iam.gserviceaccount.com'; // Copy from JSON
static const String serviceAccountPrivateKey = '-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n'; // Copy from JSON
```

**Important**: 
- Copy the entire `client_email` value
- Copy the entire `private_key` value including the `-----BEGIN PRIVATE KEY-----` and `-----END PRIVATE KEY-----` parts
- Keep the `\n` characters in the private key

### 6. Install Dependencies and Deploy

```bash
# Install dependencies (including JWT library)
flutter pub get

# Build and deploy
flutter build web
firebase deploy --only hosting
```

**Note**: The JWT signing implementation has been updated to use proper RSA signing with the `dart_jsonwebtoken` package for reliable authentication with Google's OAuth2 service.

## 🔧 Alternative: Use Environment Variables (Recommended for Production)

For better security, use environment variables instead of hardcoding credentials:

### 1. Create Environment File

Create a `.env` file in your project root:

```env
GOOGLE_SERVICE_ACCOUNT_EMAIL=document-ai-service@tomb-nav-30luyb.iam.gserviceaccount.com
GOOGLE_SERVICE_ACCOUNT_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
```

### 2. Update Configuration

```dart
import 'dart:io';

class ApiConfig {
  static String get serviceAccountEmail => 
      Platform.environment['GOOGLE_SERVICE_ACCOUNT_EMAIL'] ?? '';
  
  static String get serviceAccountPrivateKey => 
      Platform.environment['GOOGLE_SERVICE_ACCOUNT_PRIVATE_KEY'] ?? '';
}
```

### 3. Add to .gitignore

Add `.env` to your `.gitignore` file to keep credentials secure.

## 🧪 Testing the Setup

### 1. Test with Sample Document

1. Go to your deployed app: https://tomb-nav-30luyb.web.app
2. Navigate to a form that accepts document uploads
3. Upload a PDF lease document
4. Check the browser console for logs:
   - ✅ `"Using Document AI with service account authentication..."`
   - ✅ `"Document AI processing successful!"`
   - ✅ Extracted text should appear in the verification result

### 2. Expected Behavior

**With Full Document AI:**
- **PDFs**: Full text extraction, entity recognition, high confidence scores
- **Images**: OCR text extraction (if processor supports it)
- **Confidence**: Typically 70-95% for legitimate lease documents
- **Extracted Text**: Full document content available for analysis

**Fallback (if credentials missing):**
- **PDFs**: Basic validation only (structure, size, filename)
- **Images**: Basic validation with lower confidence
- **Confidence**: 30-50% for basic validation
- **Extracted Text**: "Text extraction not available without Document AI service"

## 🚨 Troubleshooting

### Common Issues

1. **"Service account credentials not configured"**
   - Check that `serviceAccountEmail` and `serviceAccountPrivateKey` are not empty
   - Verify the private key includes the full `-----BEGIN PRIVATE KEY-----` format

2. **"Token exchange failed"**
   - Verify the service account email is correct
   - Check that the service account has the required roles
   - Ensure Document AI API is enabled

3. **"Document AI API error: 403"**
   - Check service account permissions
   - Verify the processor ID is correct
   - Ensure the service account has access to the processor

4. **"Document AI API error: 404"**
   - Verify the processor ID: `282fc31e9911b7cd`
   - Check that the processor is enabled
   - Verify the location is correct: `us`

### Debug Steps

1. **Check Browser Console**: Look for detailed error messages
2. **Verify Processor**: Go to [Document AI Console](https://console.cloud.google.com/ai/document-ai) and confirm processor status
3. **Test API Access**: Use the Google Cloud Console to test the processor manually
4. **Check Quotas**: Ensure you haven't exceeded API quotas

## 🔒 Security Best Practices

1. **Never commit service account keys to version control**
2. **Use environment variables in production**
3. **Rotate service account keys regularly**
4. **Limit service account permissions to minimum required**
5. **Monitor API usage and costs**

## 📊 Expected Performance

**With Full Document AI:**
- **Text Extraction**: 95%+ accuracy for standard lease documents
- **Processing Time**: 2-5 seconds per document
- **Confidence Scores**: 70-95% for legitimate documents
- **Entity Recognition**: Identifies names, addresses, dates, amounts

**Costs**: 
- Document AI charges per page processed
- Typical cost: $0.50-1.50 per 1,000 pages
- Monitor usage in Google Cloud Console

## 🎯 Success Indicators

You'll know the setup is working when:
- ✅ Documents upload without authentication errors
- ✅ Browser console shows "Document AI processing successful!"
- ✅ Verification results show high confidence scores (70%+)
- ✅ Extracted text contains actual document content
- ✅ No fallback to basic validation messages

---

**Need Help?** Check the [Google Cloud Document AI documentation](https://cloud.google.com/document-ai/docs) for detailed API reference and troubleshooting guides.
