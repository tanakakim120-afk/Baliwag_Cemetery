import '/backend/backend.dart';

// Processes expired contracts and creates corresponding vault documents when applicable.
Future<void> processExpiredContracts() async {
  try {
    final DateTime now = DateTime.now();

    // Query all contracts that have expired
    final List<ContractRecord> expiredContracts = await queryContractRecordOnce(
      queryBuilder: (contractRecord) =>
          contractRecord.where('dateofexpiration', isLessThan: now),
    );

    print('Found ${expiredContracts.length} expired contracts to process');

    for (final ContractRecord contract in expiredContracts) {
      print(
          'Processing expired contract ${contract.contractID} of type: ${contract.type}');
      print('Contract expiration date: ${contract.dateofexpiration}');
      print('Current date: $now');
      await _createVaultFromExpiredContract(contract);
    }
  } catch (e) {
    // Intentionally swallow to avoid breaking page load; logs remain in console
    // ignore: avoid_print
    print('Error processing expired contracts: $e');
  }
}

// Create vault document from expired contract
Future<void> _createVaultFromExpiredContract(ContractRecord contract) async {
  try {
    print(
        'Processing expired contract ${contract.contractID} of type: ${contract.type}');

    // First, always clean up the expired contract regardless of other conditions
    await _updateExpiredContract(contract);
    print('Cleaned up expired contract ${contract.contractID}');

    // Then, attempt to create vault if conditions are met
    // Check if vault already exists for this contract
    final existingVaults = await queryVaultRecordOnce(
      queryBuilder: (vaultRecord) =>
          vaultRecord.where('vaultID', isEqualTo: contract.reference),
    );

    if (existingVaults.isNotEmpty) {
      print(
          'Vault already exists for contract ${contract.contractID} - skipping vault creation');
      return;
    }

    // For Lot contracts, check if applicant and deceased details are available for vault creation
    if (contract.type?.toLowerCase() == 'lot') {
      final bool hasApplicantDetails =
          contract.applicantName != null && contract.applicantName!.isNotEmpty;
      final bool hasDeceasedDetails =
          contract.decFullName != null && contract.decFullName!.isNotEmpty;

      if (!hasApplicantDetails || !hasDeceasedDetails) {
        print(
            'Skipping vault creation for Lot contract ${contract.contractID} - missing applicant or deceased details');
        return;
      }
    }

    // Create vault document with transferred data
    final vaultData = createVaultRecordData(
      // Deceased details
      deceasedname: contract.decFullName,
      deceaseddateofdeath: contract.dateofdeath,
      deceasedburialinterment: contract.burialinternment,
      // Applicant details
      applicantname: contract.applicantName,
      applicantaddress: contract.applcantAddress,
      applicantcontactnumber: contract.applicantContactNumber,
      // Vault metadata
      status: 'active',
      timestamp: DateTime.now(),
      vaultID: contract.reference,
      deceasedIDstring: contract.contractidString,
      stringvaultadded:
          'Vault created from expired contract ${contract.contractID}',
    );

    await VaultRecord.collection.add(vaultData);
    print('Created vault for expired contract ${contract.contractID}');
  } catch (e) {
    // ignore: avoid_print
    print('Error processing expired contract ${contract.contractID}: $e');
  }
}

// Update expired contract based on type
Future<void> _updateExpiredContract(ContractRecord contract) async {
  try {
    print(
        'Updating expired contract ${contract.contractID} of type: ${contract.type}');
    Map<String, dynamic> updateData = {};

    if (contract.type?.toLowerCase() == 'nitche') {
      print('Processing NITCHE contract - keeping only Location and amount');
      print('Nitche contract ID: ${contract.contractID}');
      print('Nitche location: ${contract.location}');
      print('Nitche amount: ${contract.amount}');
      // For NITCHE: keep only Location and amount, null everything else
      updateData = {
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
        'applicantName': null,
        'applcantAddress': null,
        'applicantContactNumber': null,
        'pastApplicantName': null,
        'pastApplicantAddress': null,
        'pastApplicantContact': null,
        'applicantStatus': null,
        'decFullName': null,
        'lotLoccation': null,
        'leesseContactNo': null,
        'contractID': null,
        'contractidString': null,
        'dateEffective': null,
        'dateofdeath': null,
        'nitcheid': null,
        'nitcheidString': null,
        'dummy': null,
        'latestContNum': null,
        'latestAddress': null,
        'latestDeceased': null,
        'appliContNumb': null,
        'dateofexpiration': null,
        'contractstatus': null,
        'burialinternment': null,
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
        // Keep Location and amount
        'Location': contract.location,
        'amount': contract.amount,
      };
    } else if (contract.type?.toLowerCase() == 'lot') {
      print(
          'Processing LOT contract - keeping measurement, amount, street, lotstatus, location');
      // For LOT: keep measurement, amount, street, lotstatus, location, null everything else
      // Specifically clearing: dateofexpiration, OR, ResidentCert, TIN, dateEffective, dateIssued, leessee, years
      updateData = {
        'tombLocation': null,
        'OR': null,
        'TIN': null,
        'ResidentCert': null,
        'placeIssued': null,
        'dateIssued': null,
        'leessee': null,
        'status': null,
        'proofoflease': null,
        'applicantName': null,
        'applcantAddress': null,
        'applicantContactNumber': null,
        'pastApplicantName': null,
        'pastApplicantAddress': null,
        'pastApplicantContact': null,
        'applicantStatus': null,
        'decFullName': null,
        'lotLoccation': null,
        'leesseContactNo': null,
        'contractidString': null,
        'dateEffective': null,
        'dateofdeath': null,
        'nitcheid': null,
        'nitcheidString': null,
        'dummy': null,
        'latestContNum': null,
        'latestAddress': null,
        'latestDeceased': null,
        'appliContNumb': null,
        'dateofexpiration': null,
        'contractstatus': null,
        'burialinternment': null,
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
        // Keep measurement, amount, street, lotstatus, location
        'measurement': contract.measurement,
        'amount': contract.amount,
        'street': contract.street,
        'lotstatus': contract.lotstatus,
        'Location': contract.location,
      };
    }

    if (updateData.isNotEmpty) {
      print(
          'Updating contract ${contract.contractID} with ${updateData.length} fields');
      await contract.reference.update(updateData);
      print(
          'Successfully updated expired contract ${contract.contractID} based on type ${contract.type}');
      print('Updated ${updateData.length} fields');
    } else {
      print(
          'No update data for contract ${contract.contractID} - type: ${contract.type}');
    }
  } catch (e) {
    // ignore: avoid_print
    print('Error updating expired contract ${contract.contractID}: $e');
  }
}
