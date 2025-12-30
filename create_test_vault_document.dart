import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

// Test script to create a vault document
Future<void> createTestVaultDocument() async {
  try {
    // Initialize Firebase (make sure it's already initialized in your app)
    await Firebase.initializeApp();

    // Get Firestore instance
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Create test vault document data
    Map<String, dynamic> vaultData = {
      'deceasedid': 1001,
      'deceasedname': ['John Doe Test'],
      'deceasedDateofDeath': Timestamp.fromDate(DateTime(2024, 1, 15)),
      'timestamp': FieldValue.serverTimestamp(),
      'deceasedIDstring': 'DEC-1001',
      'status': 'active',
      'Stringvaultadded': 'Vault added for testing',
      'deceaseddateofdeath': [Timestamp.fromDate(DateTime(2024, 1, 15))],
      'deceasedburialinterment': [Timestamp.fromDate(DateTime(2024, 1, 20))],
      'applicantname': ['Jane Doe'],
      'applicantaddress': ['123 Test Street, Test City'],
      'applicantcontactnumber': [1234567890],
      'vaultID': null, // Will be set to contract reference if needed
    };

    // Add document to vault collection
    DocumentReference docRef =
        await firestore.collection('vault').add(vaultData);

    print('✅ Test vault document created successfully!');
    print('📄 Document ID: ${docRef.id}');
    print('🔗 Document Path: ${docRef.path}');

    // Optional: Update the document with its own reference as vaultID
    await docRef.update({
      'vaultID': docRef,
    });

    print('🔄 Document updated with vaultID reference');
  } catch (e) {
    print('❌ Error creating test vault document: $e');
  }
}

// Function to create multiple test vault documents
Future<void> createMultipleTestVaultDocuments() async {
  try {
    await Firebase.initializeApp();
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    List<Map<String, dynamic>> testVaults = [
      {
        'deceasedid': 1002,
        'deceasedname': ['Alice Smith'],
        'deceasedDateofDeath': Timestamp.fromDate(DateTime(2024, 2, 10)),
        'timestamp': FieldValue.serverTimestamp(),
        'deceasedIDstring': 'DEC-1002',
        'status': 'active',
        'Stringvaultadded': 'Test vault for Alice Smith',
        'deceaseddateofdeath': [Timestamp.fromDate(DateTime(2024, 2, 10))],
        'deceasedburialinterment': [Timestamp.fromDate(DateTime(2024, 2, 15))],
        'applicantname': ['Bob Smith'],
        'applicantaddress': ['456 Test Avenue, Test City'],
        'applicantcontactnumber': [9876543210],
      },
      {
        'deceasedid': 1003,
        'deceasedname': ['Charlie Brown'],
        'deceasedDateofDeath': Timestamp.fromDate(DateTime(2024, 3, 5)),
        'timestamp': FieldValue.serverTimestamp(),
        'deceasedIDstring': 'DEC-1003',
        'status': 'active',
        'Stringvaultadded': 'Test vault for Charlie Brown',
        'deceaseddateofdeath': [Timestamp.fromDate(DateTime(2024, 3, 5))],
        'deceasedburialinterment': [Timestamp.fromDate(DateTime(2024, 3, 10))],
        'applicantname': ['Lucy Brown'],
        'applicantaddress': ['789 Test Boulevard, Test City'],
        'applicantcontactnumber': [5555555555],
      },
    ];

    // Create documents in batch
    WriteBatch batch = firestore.batch();

    for (Map<String, dynamic> vaultData in testVaults) {
      DocumentReference docRef = firestore.collection('vault').doc();
      batch.set(docRef, vaultData);
    }

    await batch.commit();

    print('✅ Multiple test vault documents created successfully!');
    print('📊 Created ${testVaults.length} test documents');
  } catch (e) {
    print('❌ Error creating multiple test vault documents: $e');
  }
}

// Function to list all vault documents (for verification)
Future<void> listVaultDocuments() async {
  try {
    await Firebase.initializeApp();
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    QuerySnapshot snapshot = await firestore.collection('vault').get();

    print('📋 Current vault documents:');
    print('Total documents: ${snapshot.docs.length}');

    for (QueryDocumentSnapshot doc in snapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      print('📄 Document ID: ${doc.id}');
      print('   Deceased Name: ${data['deceasedname']?.first ?? 'N/A'}');
      print('   Status: ${data['status'] ?? 'N/A'}');
      print('   Date of Death: ${data['deceasedDateofDeath'] ?? 'N/A'}');
      print('   ---');
    }
  } catch (e) {
    print('❌ Error listing vault documents: $e');
  }
}

// Main function to run the test
void main() async {
  print('🚀 Starting vault document creation test...');

  // Create single test document
  await createTestVaultDocument();

  print('\n' + '=' * 50 + '\n');

  // Create multiple test documents
  await createMultipleTestVaultDocuments();

  print('\n' + '=' * 50 + '\n');

  // List all documents to verify
  await listVaultDocuments();

  print('\n✅ Test completed!');
}

