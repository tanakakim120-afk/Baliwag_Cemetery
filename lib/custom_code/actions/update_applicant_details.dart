import 'package:cloud_firestore/cloud_firestore.dart';
import '/backend/backend.dart';

/// Updates applicant details for a specific contract
///
/// Parameters:
/// - contractId: The ID of the contract to update
/// - applicantNames: List of applicant names
/// - applicantAddresses: List of applicant addresses
/// - applicantContacts: List of applicant contact numbers
///
/// Returns:
/// - Future<bool>: true if successful, false if failed
Future<bool> updateApplicantDetails({
  required int contractId,
  required List<String> applicantNames,
  required List<String> applicantAddresses,
  required List<String> applicantContacts,
}) async {
  try {
    print('Starting applicant details update for contract ID: $contractId');

    // Convert contact numbers to integers where possible, keep as strings if not
    List<dynamic> processedContacts = applicantContacts.map((contact) {
      // Try to parse as integer, if fails keep as string
      int? parsedInt = int.tryParse(contact);
      return parsedInt ?? contact;
    }).toList();

    // Find the contract document by contractID
    QuerySnapshot querySnapshot = await ContractRecord.collection
        .where('contractID', isEqualTo: contractId)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) {
      print('No contract found with ID: $contractId');
      return false;
    }

    DocumentReference contractRef = querySnapshot.docs.first.reference;

    // Prepare the update data
    Map<String, dynamic> updateData = {
      'applicantName': applicantNames,
      'applcantAddress':
          applicantAddresses, // Note: field name has typo in schema
      'applicantContactNumber': processedContacts,
      'dateUpdated': FieldValue.serverTimestamp(), // Add timestamp for tracking
    };

    print('Updating contract with data: $updateData');

    // Update the document
    await contractRef.update(updateData);

    print(
        'Successfully updated applicant details for contract ID: $contractId');
    return true;
  } catch (e) {
    print('Error updating applicant details for contract ID $contractId: $e');
    return false;
  }
}

/// Updates applicant details for a specific contract using document reference
///
/// Parameters:
/// - contractRef: The document reference of the contract to update
/// - applicantNames: List of applicant names
/// - applicantAddresses: List of applicant addresses
/// - applicantContacts: List of applicant contact numbers
///
/// Returns:
/// - Future<bool>: true if successful, false if failed
Future<bool> updateApplicantDetailsByRef({
  required DocumentReference contractRef,
  required List<String> applicantNames,
  required List<String> applicantAddresses,
  required List<String> applicantContacts,
}) async {
  try {
    print(
        'Starting applicant details update for contract reference: ${contractRef.id}');

    // Convert contact numbers to integers where possible, keep as strings if not
    List<dynamic> processedContacts = applicantContacts.map((contact) {
      // Try to parse as integer, if fails keep as string
      int? parsedInt = int.tryParse(contact);
      return parsedInt ?? contact;
    }).toList();

    // Prepare the update data
    Map<String, dynamic> updateData = {
      'applicantName': applicantNames,
      'applcantAddress':
          applicantAddresses, // Note: field name has typo in schema
      'applicantContactNumber': processedContacts,
      'dateUpdated': FieldValue.serverTimestamp(), // Add timestamp for tracking
    };

    print('Updating contract with data: $updateData');

    // Update the document
    await contractRef.update(updateData);

    print(
        'Successfully updated applicant details for contract reference: ${contractRef.id}');
    return true;
  } catch (e) {
    print(
        'Error updating applicant details for contract reference ${contractRef.id}: $e');
    return false;
  }
}

/// Validates applicant data before updating
///
/// Parameters:
/// - applicantNames: List of applicant names
/// - applicantAddresses: List of applicant addresses
/// - applicantContacts: List of applicant contact numbers
///
/// Returns:
/// - String?: null if valid, error message if invalid
String? validateApplicantData({
  required List<String> applicantNames,
  required List<String> applicantAddresses,
  required List<String> applicantContacts,
}) {
  // Check if at least one name is provided
  if (applicantNames.isEmpty ||
      applicantNames.every((name) => name.trim().isEmpty)) {
    return 'At least one applicant name is required';
  }

  // Check if at least one address is provided
  if (applicantAddresses.isEmpty ||
      applicantAddresses.every((address) => address.trim().isEmpty)) {
    return 'At least one address is required';
  }

  // Check if at least one contact is provided
  if (applicantContacts.isEmpty ||
      applicantContacts.every((contact) => contact.trim().isEmpty)) {
    return 'At least one contact number is required';
  }

  // Validate contact numbers (should be numeric)
  for (String contact in applicantContacts) {
    if (contact.trim().isNotEmpty) {
      // Remove any non-numeric characters except + for international numbers
      String cleanContact = contact.replaceAll(RegExp(r'[^\d+]'), '');
      if (cleanContact.isEmpty || cleanContact.length < 7) {
        return 'Invalid contact number: $contact';
      }
    }
  }

  return null; // Valid
}
