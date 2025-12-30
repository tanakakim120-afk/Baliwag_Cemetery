# Firestore Automated Backup System

## Overview
This system automatically backs up your Firestore database every 12 hours to prevent data loss. Backups are stored in Google Cloud Storage and can be restored when needed.

## What's Included
1. **Scheduled Backup** - Runs automatically every 12 hours
2. **Manual Backup** - Trigger backups on-demand (e.g., before major updates)
3. **Secure Storage** - All backups stored in Google Cloud Storage

---

## Setup Instructions

### Step 1: Install Dependencies
Navigate to the functions directory and install the new dependencies:

```bash
cd firebase/functions
npm install
```

### Step 2: Create Google Cloud Storage Bucket
You need a storage bucket for backups. Replace `YOUR-PROJECT-ID` with your actual Firebase project ID:

```bash
# Install Google Cloud SDK if not already installed
# Download from: https://cloud.google.com/sdk/docs/install

# Login to Google Cloud
gcloud auth login

# Set your project
gcloud config set project YOUR-PROJECT-ID

# Create the backup bucket (replace YOUR-PROJECT-ID)
gsutil mb -l asia-southeast1 gs://YOUR-PROJECT-ID-firestore-backups

# Enable versioning for backup bucket (optional but recommended)
gsutil versioning set on gs://YOUR-PROJECT-ID-firestore-backups
```

### Step 3: Set IAM Permissions
Grant the necessary permissions for Cloud Functions to write backups:

```bash
# Get your project number
PROJECT_NUMBER=$(gcloud projects describe YOUR-PROJECT-ID --format="value(projectNumber)")

# Grant Firestore import/export permissions
gcloud projects add-iam-policy-binding YOUR-PROJECT-ID \
  --member="serviceAccount:YOUR-PROJECT-ID@appspot.gserviceaccount.com" \
  --role="roles/datastore.importExportAdmin"

# Grant Storage permissions
gcloud projects add-iam-policy-binding YOUR-PROJECT-ID \
  --member="serviceAccount:YOUR-PROJECT-ID@appspot.gserviceaccount.com" \
  --role="roles/storage.admin"
```

### Step 4: Deploy Cloud Functions
Deploy the backup functions to Firebase:

```bash
# From project root
firebase deploy --only functions

# Or deploy specific functions only
firebase deploy --only functions:scheduledFirestoreBackup,functions:manualFirestoreBackup
```

### Step 5: Configure Timezone (Optional)
Edit `firebase/functions/index.js` line 19 to set your timezone:
```javascript
.timeZone("Asia/Manila") // Change to your timezone
```

Common timezones:
- America/New_York
- America/Los_Angeles
- Europe/London
- Asia/Tokyo
- UTC

### Step 6: Verify Schedule
The backup runs at **00:00 and 12:00** (midnight and noon) in your configured timezone.

To change the schedule, modify the cron expression on line 18:
```javascript
.schedule("0 */12 * * *") // Current: Every 12 hours
```

Example schedules:
- `0 */6 * * *` - Every 6 hours
- `0 2,14 * * *` - At 2 AM and 2 PM
- `0 0 * * *` - Once daily at midnight
- `0 0,6,12,18 * * *` - Every 6 hours (0:00, 6:00, 12:00, 18:00)

---

## Usage

### Automatic Backups
Once deployed, backups run automatically every 12 hours. No action needed!

### Manual Backup (Flutter/Dart)
You can trigger a manual backup from your Flutter app:

```dart
import 'package:cloud_functions/cloud_functions.dart';

Future<void> triggerManualBackup() async {
  try {
    final callable = FirebaseFunctions.instance.httpsCallable('manualFirestoreBackup');
    final result = await callable.call();
    
    print('Backup successful!');
    print('Location: ${result.data['location']}');
    print('Timestamp: ${result.data['timestamp']}');
    
    // Show success message to user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Database backup completed successfully')),
    );
  } catch (e) {
    print('Backup failed: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Backup failed: $e')),
    );
  }
}
```

### Manual Backup (Web Console)
1. Go to Firebase Console → Functions
2. Find `manualFirestoreBackup`
3. Click "Test function"
4. Add authentication token
5. Click "Run"

---

## Monitoring Backups

### View Backup Logs
```bash
# View function logs
firebase functions:log --only scheduledFirestoreBackup

# Or in Google Cloud Console
# Go to: Cloud Functions → Your Function → Logs
```

### List All Backups
```bash
# List all backups in your bucket
gsutil ls -r gs://YOUR-PROJECT-ID-firestore-backups/
```

### Check Backup Size
```bash
# Check total backup storage usage
gsutil du -sh gs://YOUR-PROJECT-ID-firestore-backups/
```

---

## Restoring from Backup

### Option 1: Using gcloud Command
```bash
# List available backups
gsutil ls gs://YOUR-PROJECT-ID-firestore-backups/

# Restore from a specific backup (replace timestamp)
gcloud firestore import gs://YOUR-PROJECT-ID-firestore-backups/2025-01-15T00-00-00-000Z

# Restore specific collections only
gcloud firestore import gs://YOUR-PROJECT-ID-firestore-backups/2025-01-15T00-00-00-000Z \
  --collection-ids='users,contracts,transactions'
```

### Option 2: Using Google Cloud Console
1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Navigate to **Firestore** → **Import/Export**
3. Click **Import**
4. Select your backup bucket and timestamp folder
5. Choose collections to restore (or all)
6. Click **Import**

### Restore to Different Project (Disaster Recovery)
```bash
# Export from one project and import to another
gcloud firestore import gs://YOUR-PROJECT-ID-firestore-backups/2025-01-15T00-00-00-000Z \
  --project=YOUR-NEW-PROJECT-ID
```

---

## Backup Retention & Cost Management

### Set Lifecycle Policy (Auto-delete old backups)
Save this as `lifecycle.json`:
```json
{
  "lifecycle": {
    "rule": [
      {
        "action": {"type": "Delete"},
        "condition": {"age": 30}
      }
    ]
  }
}
```

Apply the policy:
```bash
# Delete backups older than 30 days
gsutil lifecycle set lifecycle.json gs://YOUR-PROJECT-ID-firestore-backups/
```

### Estimated Costs
- **Cloud Storage**: ~$0.02 per GB/month (Standard storage)
- **Cloud Functions**: ~$0.40 per million invocations
- **Firestore Export**: Free for first 1 GB, then ~$0.12 per GB

**Example**: 
- Database size: 5 GB
- Backups per day: 2
- Monthly backups: 60
- Storage needed: ~300 GB (without cleanup)
- Monthly cost: ~$6-8 (with 30-day retention: ~$3-4)

---

## Troubleshooting

### Error: Permission Denied
```bash
# Re-grant permissions
gcloud projects add-iam-policy-binding YOUR-PROJECT-ID \
  --member="serviceAccount:YOUR-PROJECT-ID@appspot.gserviceaccount.com" \
  --role="roles/datastore.importExportAdmin"
```

### Error: Bucket doesn't exist
```bash
# Create the bucket
gsutil mb -l asia-southeast1 gs://YOUR-PROJECT-ID-firestore-backups
```

### Error: Function timeout
For large databases, increase timeout in `firebase/functions/index.js`:
```javascript
exports.scheduledFirestoreBackup = functions
  .runWith({ timeoutSeconds: 540, memory: '2GB' }) // Add this line
  .pubsub
  .schedule("0 */12 * * *")
  // ... rest of function
```

### Verify Function is Scheduled
```bash
# Check deployed functions
firebase functions:list

# Check Cloud Scheduler jobs
gcloud scheduler jobs list
```

---

## Security Best Practices

1. **Restrict Manual Backup Access**: Uncomment lines 73-75 in `index.js` to require admin privileges
2. **Enable Bucket Versioning**: Prevents accidental deletion
3. **Set Up Alerts**: Configure Cloud Monitoring to alert on backup failures
4. **Test Restore Regularly**: Perform test restores quarterly to ensure backups work
5. **Multi-Region Storage**: For critical data, use multi-region buckets

---

## Adding Backup Button to Admin Dashboard

You can add a backup button to your admin dashboard:

```dart
ElevatedButton.icon(
  icon: Icon(Icons.backup),
  label: Text('Backup Database Now'),
  onPressed: () async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text('Creating backup...'),
          ],
        ),
      ),
    );
    
    try {
      final callable = FirebaseFunctions.instance
          .httpsCallable('manualFirestoreBackup');
      final result = await callable.call();
      
      Navigator.pop(context); // Close loading dialog
      
      // Show success
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Backup completed successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      
      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Backup failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  },
)
```

---

## Support & Resources

- [Firebase Backup Documentation](https://firebase.google.com/docs/firestore/manage-data/export-import)
- [Cloud Storage Pricing](https://cloud.google.com/storage/pricing)
- [Cron Schedule Expression](https://crontab.guru/)

---

## Quick Reference

```bash
# Deploy functions
firebase deploy --only functions

# View logs
firebase functions:log

# List backups
gsutil ls gs://YOUR-PROJECT-ID-firestore-backups/

# Restore backup
gcloud firestore import gs://YOUR-PROJECT-ID-firestore-backups/TIMESTAMP/

# Check backup size
gsutil du -sh gs://YOUR-PROJECT-ID-firestore-backups/
```

---

**Remember**: Always test your backup and restore process before relying on it for production data!

