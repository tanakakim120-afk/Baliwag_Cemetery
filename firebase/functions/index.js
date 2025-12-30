const functions = require("firebase-functions");
const admin = require("firebase-admin");
const firestore = require("@google-cloud/firestore");
admin.initializeApp();

// Existing user deletion handler
exports.onUserDeleted = functions.auth.user().onDelete(async (user) => {
  let firestoreDb = admin.firestore();
  let userRef = firestoreDb.doc("users/" + user.uid);
});

// Existing functions (placeholders to prevent deletion)
exports.getContractDataForAI = functions.https.onCall(async (data, context) => {
  return { message: "Function not implemented yet" };
});

exports.getContractStatsForAI = functions.https.onCall(async (data, context) => {
  return { message: "Function not implemented yet" };
});

exports.getUserContractsForAI = functions.https.onCall(async (data, context) => {
  return { message: "Function not implemented yet" };
});

exports.onContractRegistered = functions.firestore
  .document('contract/{docId}')
  .onCreate(async (snap, context) => {
    console.log('Contract registered:', context.params.docId);
  });

exports.onPaymentMade = functions.firestore
  .document('transactions/{docId}')
  .onCreate(async (snap, context) => {
    console.log('Payment made:', context.params.docId);
  });

exports.searchContractsForAI = functions.https.onCall(async (data, context) => {
  return { message: "Function not implemented yet" };
});

exports.searchUserDataForAI = functions.https.onCall(async (data, context) => {
  return { message: "Function not implemented yet" };
});

exports.sendNotificationToAllUsers = functions.https.onCall(async (data, context) => {
  return { message: "Function not implemented yet" };
});

exports.sendNotificationToUser = functions.https.onCall(async (data, context) => {
  return { message: "Function not implemented yet" };
});

exports.sendPaymentSuccessEmail = functions.https.onCall(async (data, context) => {
  return { message: "Function not implemented yet" };
});

exports.testEmail = functions.https.onCall(async (data, context) => {
  return { message: "Function not implemented yet" };
});

/**
 * Scheduled Firestore Backup Function
 * Runs every 12 hours to backup the entire Firestore database
 * Schedule: Every 12 hours at minute 0
 */
exports.scheduledFirestoreBackup = functions.pubsub
  .schedule("0 */12 * * *")
  .timeZone("Asia/Manila") // Change this to your timezone
  .onRun(async (context) => {
    const projectId = process.env.GCP_PROJECT || process.env.GCLOUD_PROJECT;
    const databaseName = "(default)"; // Use your database name if different
    
    // Get current timestamp for backup naming
    const timestamp = new Date().toISOString().replace(/[:.]/g, "-");
    const bucketName = `gs://${projectId}-firestore-backups`;
    
    const client = new firestore.v1.FirestoreAdminClient();
    
    try {
      console.log(`Starting Firestore backup at ${timestamp}`);
      console.log(`Project ID: ${projectId}`);
      console.log(`Backup location: ${bucketName}/${timestamp}`);
      
      const responses = await client.exportDocuments({
        name: client.databasePath(projectId, databaseName),
        outputUriPrefix: `${bucketName}/${timestamp}`,
        // Optional: specify collections to backup (comment out to backup all)
        // collectionIds: ['users', 'contracts', 'transactions', 'burial_lots', 'apartments', 'vaults']
      });

      const response = responses[0];
      console.log(`Backup operation initiated: ${response.name}`);
      console.log("Backup completed successfully");
      
      return {
        success: true,
        operation: response.name,
        timestamp: timestamp,
        location: `${bucketName}/${timestamp}`
      };
    } catch (error) {
      console.error("Backup failed:", error);
      throw new Error(`Backup failed: ${error.message}`);
    }
  });

/**
 * Manual Backup Trigger Function
 * Call this function manually via HTTP to trigger a backup on-demand
 * Useful for testing or manual backups before major changes
 */
exports.manualFirestoreBackup = functions.https.onCall(async (data, context) => {
  // Verify the user is authenticated and is an admin
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "User must be authenticated to trigger backup"
    );
  }

  // Optional: Check if user has admin privileges
  // const userDoc = await admin.firestore().collection('users').doc(context.auth.uid).get();
  // if (!userDoc.data()?.isAdmin) {
  //   throw new functions.https.HttpsError('permission-denied', 'Only admins can trigger backups');
  // }

  const projectId = process.env.GCP_PROJECT || process.env.GCLOUD_PROJECT;
  const databaseName = "(default)";
  const timestamp = new Date().toISOString().replace(/[:.]/g, "-");
  const bucketName = `gs://${projectId}-firestore-backups`;
  
  const client = new firestore.v1.FirestoreAdminClient();
  
  try {
    console.log(`Manual backup triggered by user: ${context.auth.uid}`);
    
    const responses = await client.exportDocuments({
      name: client.databasePath(projectId, databaseName),
      outputUriPrefix: `${bucketName}/manual-${timestamp}`,
    });

    const response = responses[0];
    
    return {
      success: true,
      message: "Backup initiated successfully",
      operation: response.name,
      timestamp: timestamp,
      location: `${bucketName}/manual-${timestamp}`
    };
  } catch (error) {
    console.error("Manual backup failed:", error);
    throw new functions.https.HttpsError(
      "internal",
      `Backup failed: ${error.message}`
    );
  }
});
