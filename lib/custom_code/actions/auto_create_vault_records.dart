// Automatic FlutterFlow imports
import '/backend/backend.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

/// Custom action to automatically create vault records for expired contracts
/// Returns the number of vault records created
Future<int> autoCreateVaultRecords() async {
  try {
    // Get current date
    DateTime currentDate = DateTime.now();

    // Query all active contracts first, then filter by expiration date in memory
    // This avoids the need for a composite index
    QuerySnapshot activeContracts = await ContractRecord.collection
        .where('contractstatus', isEqualTo: 'active')
        .limit(100) // Get more records to filter in memory
        .get();

    // Filter expired contracts in memory
    List<QueryDocumentSnapshot> expiredContracts =
        activeContracts.docs.where((doc) {
      final contract = ContractRecord.fromSnapshot(doc);
      return contract.dateofexpiration != null &&
          contract.dateofexpiration!.isBefore(currentDate);
    }).toList();

    print('Found ${expiredContracts.length} expired contracts');

    // Debug: Print details of expired contracts
    for (var doc in expiredContracts) {
      final contract = ContractRecord.fromSnapshot(doc);
      print(
          'Expired contract: ID=${contract.contractID}, Type=${contract.type}, Expiration=${contract.dateofexpiration}');
    }

    if (expiredContracts.isEmpty) {
      print('No expired contracts found');
      return 0;
    }

    // Get all existing vault records in one query to avoid individual checks
    List<DocumentReference> contractRefs =
        expiredContracts.map((doc) => doc.reference).toList();

    QuerySnapshot existingVaults = await VaultRecord.collection
        .where('vaultID', whereIn: contractRefs)
        .get();

    Set<String> existingVaultIDs = existingVaults.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>?;
      final vaultID = data?['vaultID'] as DocumentReference?;
      return vaultID?.path ?? '';
    }).toSet();

    // Use batch operations for better performance
    WriteBatch batch = FirebaseFirestore.instance.batch();
    int batchCount = 0;
    int vaultRecordsCreated = 0;
    const int maxBatchSize = 500; // Firestore batch limit

    // Process each expired contract
    for (QueryDocumentSnapshot contractDoc in expiredContracts) {
      ContractRecord contract = ContractRecord.fromSnapshot(contractDoc);

      // Check if vault record already exists for this contract
      if (!existingVaultIDs.contains(contractDoc.reference.path)) {
        // Create vault record from contract data with complete mapping
        DocumentReference vaultRef = VaultRecord.collection.doc();
        batch.set(vaultRef, {
          // Core identification fields
          'deceasedid': contract.contractID,
          'deceasedIDstring':
              contract.contractidString ?? 'CONTRACT_${contract.contractID}',
          'vaultID': contractDoc.reference,
          'timestamp': currentDate,

          // Deceased information (required for vault list display)
          'deceasedname': contract.decFullName.isNotEmpty
              ? contract.decFullName
              : [contract.latestDeceased ?? 'Unknown Deceased'],
          'deceaseddateofdeath':
              contract.dateofdeath.isNotEmpty ? contract.dateofdeath : [],
          'deceasedDateofDeath': contract.dateofdeath.isNotEmpty
              ? contract.dateofdeath.first
              : null,

          // Burial/Internment information (required for vault list display)
          'deceasedburialinterment': contract.burialinternment.isNotEmpty
              ? contract.burialinternment
              : [],

          // Applicant information (required for vault list display)
          'applicantname': contract.applicantName.isNotEmpty
              ? contract.applicantName
              : [
                  contract.leessee ??
                      contract.latestAddress ??
                      'Unknown Applicant'
                ],
          'applicantaddress': contract.applcantAddress.isNotEmpty
              ? contract.applcantAddress
              : [
                  contract.street ?? contract.latestAddress ?? 'Unknown Address'
                ],
          'applicantcontactnumber': contract.applicantContactNumber.isNotEmpty
              ? contract.applicantContactNumber
              : (contract.leesseContactNo != null &&
                      contract.leesseContactNo!.isNotEmpty
                  ? [int.tryParse(contract.leesseContactNo!) ?? 0]
                  : []),

          // Status and metadata
          'status': 'expired', // Status for vault record (expired contract)
          'Stringvaultadded':
              'Auto-created from expired contract ${contract.contractID} on ${currentDate.toIso8601String()}',

          // Additional contract information for reference
          'contractType': contract.type ?? 'nitche',
          'tombLocation': contract.location ?? 'Unknown Location',
          'contractAmount': contract.amount ?? '0',
          'contractYears': contract.years ?? '0',
          'contractEffectiveDate': contract.dateEffective,
          'contractExpirationDate': contract.dateofexpiration,
        });

        // Update contract status to expired and clear data columns based on type
        Map<String, dynamic> contractUpdate = {
          'contractstatus': 'expired',
          'status': 'expired',
        };

        // Clear data columns based on contract type
        if (contract.type?.toLowerCase() == 'nitche') {
          // For Nitche contracts: clear all columns except Amount, Location, and Type
          contractUpdate.addAll({
            'tombLocation': null,
            'OR': null,
            'TIN': null,
            'ResidentCert': null,
            'placeIssued': null,
            'dateIssued': null,
            'leessee': null,
            'street': null,
            'status': null,
            'measurement': null,
            'proofoflease': null,
            'applicantName': [],
            'applcantAddress': [],
            'applicantContactNumber': [],
            'pastApplicantName': null,
            'pastApplicantAddress': null,
            'pastApplicantContact': null,
            'applicantStatus': null,
            'decFullName': [],
            'lotLoccation': null,
            'leesseContactNo': null,
            'contractID': null,
            'contractidString': null,
            'dateEffective': null,
            'dateofdeath': [],
            'nitcheid': null,
            'nitcheidString': null,
            'dummy': null,
            'latestContNum': null,
            'latestAddress': null,
            'latestDeceased': null,
            'appliContNumb': null,
            'dateofexpiration': null,
            'contractstatus': null,
            'burialinternment': [],
            'initialfee': null,
            'remainingbalances': null,
            'lotpicture': null,
            'years': null,
            'dateadded': null,
            'amountINT': null,
            'totalContraBalance': null,
            'stringEffectivedate': null,
            'stringExpirationdate': null,
            'email': null,
            'display_name': null,
            'photo_url': null,
            'uid': null,
            'created_time': null,
            'phone_number': null,
            'balance': null,
            'registered': null,
            'lastUpdated': null,
            'timestamp': null,
          });
        } else if (contract.type?.toLowerCase() == 'lot') {
          // For Lot contracts: clear all columns except measurement, amount, street, lotstatus, location
          contractUpdate.addAll({
            'tombLocation': null,
            'OR': null,
            'TIN': null,
            'ResidentCert': null,
            'placeIssued': null,
            'dateIssued': null,
            'leessee': null,
            'status': null,
            'proofoflease': null,
            'applicantName': [],
            'applcantAddress': [],
            'applicantContactNumber': [],
            'pastApplicantName': null,
            'pastApplicantAddress': null,
            'pastApplicantContact': null,
            'applicantStatus': null,
            'decFullName': [],
            'lotLoccation': null,
            'leesseContactNo': null,
            'contractidString': null,
            'dateEffective': null,
            'dateofdeath': [],
            'nitcheid': null,
            'nitcheidString': null,
            'dummy': null,
            'latestContNum': null,
            'latestAddress': null,
            'latestDeceased': null,
            'appliContNumb': null,
            'dateofexpiration': null,
            'contractstatus': null,
            'burialinternment': [],
            'initialfee': null,
            'remainingbalances': null,
            'lotpicture': null,
            'years': null,
            'dateadded': null,
            'amountINT': null,
            'totalContraBalance': null,
            'stringEffectivedate': null,
            'stringExpirationdate': null,
            'email': null,
            'display_name': null,
            'photo_url': null,
            'uid': null,
            'created_time': null,
            'phone_number': null,
            'balance': null,
            'registered': null,
            'contractID': null,
            'lastUpdated': null,
            'timestamp': null,
          });
        }

        print(
            'Updating contract ${contract.contractID} with ${contractUpdate.length} fields');
        print(
            'Contract type: ${contract.type}, Fields to clear: ${contractUpdate.keys.join(', ')}');

        batch.update(contractDoc.reference, contractUpdate);

        batchCount += 2; // One for vault creation, one for contract update
        vaultRecordsCreated++; // Increment count of created vault records

        // Commit batch if it reaches the limit
        if (batchCount >= maxBatchSize) {
          await batch.commit();
          print('Committed batch of $batchCount operations');
          batch = FirebaseFirestore.instance.batch();
          batchCount = 0;
        }

        print(
            'Prepared vault record for expired contract ${contract.contractID}');
      } else {
        print(
            'Vault record already exists for contract ${contract.contractID}');
      }
    }

    // Commit any remaining operations
    if (batchCount > 0) {
      await batch.commit();
      print('Committed final batch of $batchCount operations');
    }

    print(
        'Auto vault creation process completed. Created $vaultRecordsCreated vault records.');
    return vaultRecordsCreated;
  } catch (e) {
    print('Error in autoCreateVaultRecords: $e');
    rethrow;
  }
}
