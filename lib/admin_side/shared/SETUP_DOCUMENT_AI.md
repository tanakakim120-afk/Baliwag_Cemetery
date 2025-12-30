# Document AI Setup Guide

## Quick Setup Steps

### 1. Enable Document AI API
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select project: `tomb-nav-30luyb`
3. Navigate to "APIs & Services" > "Library"
4. Search for "Document AI API"
5. Click "Enable"

### 2. Create Document AI Processor
1. Go to [Document AI Console](https://console.cloud.google.com/ai/document-ai)
2. Click "Create Processor"
3. Choose "Form Parser" processor type
4. Select location: "us-central1" (recommended)
5. Name: "tomb-nav-lease-verifier"
6. Click "Create"
7. **Copy the Processor ID** (it will look like: `abc123def456ghi789`)

### 3. Update Configuration
Edit `lib/admin_side/shared/api_config.dart` and replace:
```dart
static const String documentAiProcessorId = 'YOUR_PROCESSOR_ID';
```
with your actual processor ID:
```dart
static const String documentAiProcessorId = 'your-actual-processor-id-here';
```

### 4. Test the Setup
1. Rebuild the app: `flutter build web --release`
2. Deploy: `firebase deploy --only hosting`
3. Test by uploading a PDF lease document

## Current Configuration Status
- ✅ Project ID: `tomb-nav-30luyb`
- ✅ API Key: `AIzaSyBUH3RmID74yenhMNSYxbjAIxaTSGY8qk4`
- ⏳ Processor ID: Needs to be created and configured

## Troubleshooting
- If you get "Processor not found" error, check the processor ID
- If you get "API not enabled" error, ensure Document AI API is enabled
- If you get "Permission denied" error, check API key permissions

## Alternative: Use Basic Validation Only
If you don't want to set up Document AI, the system will fall back to basic validation:
- File size checks
- File type validation
- Basic keyword analysis
- No advanced fraud detection
