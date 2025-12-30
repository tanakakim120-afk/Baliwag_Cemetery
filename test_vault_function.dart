import 'package:cloud_firestore/cloud_firestore.dart';

// Simple test function to create a vault document
// Call this from your existing Flutter app
Future<void> createTestVaultDocument() async {
  try {
    print('🚀 Creating test vault document...');

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
    };

    // Add document to vault collection
    DocumentReference docRef =
        await firestore.collection('vault').add(vaultData);

    print('✅ Test vault document created successfully!');
    print('📄 Document ID: ${docRef.id}');
    print('🔗 Document Path: ${docRef.path}');

    // Update the document with its own reference as vaultID
    await docRef.update({
      'vaultID': docRef,
    });

    print('🔄 Document updated with vaultID reference');
  } catch (e) {
    print('❌ Error creating test vault document: $e');
  }
}

// Function to list vault documents
Future<void> listVaultDocuments() async {
  try {
    print('📋 Listing vault documents...');

    FirebaseFirestore firestore = FirebaseFirestore.instance;
    QuerySnapshot snapshot = await firestore.collection('vault').get();

    print('Total documents: ${snapshot.docs.length}');

    for (QueryDocumentSnapshot doc in snapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      print('📄 Document ID: ${doc.id}');
      print('   Deceased Name: ${data['deceasedname']?.first ?? 'N/A'}');
      print('   Status: ${data['status'] ?? 'N/A'}');
      print('   ---');
    }
  } catch (e) {
    print('❌ Error listing vault documents: $e');
  }
}

