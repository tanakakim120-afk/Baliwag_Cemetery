import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  // Initialize Firebase
  await Firebase.initializeApp();

  // Get Firestore instance
  final firestore = FirebaseFirestore.instance;

  // Test contract data
  final testContracts = [
    {
      // Test Contract 1 - Lot type (Active)
      'contractID': 1001,
      'contractidString': '1001',
      'type': 'Lot',
      'status': 'active',
      'contractstatus': 'active',
      'location': 'Block A, Lot 15',
      'street': 'Main Street',
      'measurement': '2m x 3m',
      'amount': '5000',
      'dateadded': DateTime.now().subtract(Duration(days: 365)),
      'dateEffective': DateTime.now().subtract(Duration(days: 365)),
      'dateofexpiration':
          DateTime.now().add(Duration(days: 365)), // Active for 1 year
      'leessee': 'John Doe',
      'applicantName': ['John Doe'],
      'applcantAddress': ['123 Main St, City'],
      'applicantContactNumber': [9876543210],
      'decFullName': ['Maria Doe'],
      'dateofdeath': [DateTime.now().subtract(Duration(days: 400))],
      'burialinternment': [DateTime.now().subtract(Duration(days: 390))],
    },
    {
      // Test Contract 2 - Lot type (Expired)
      'contractID': 1002,
      'contractidString': '1002',
      'type': 'Lot',
      'status': 'expired',
      'contractstatus': 'expired',
      'location': 'Block B, Lot 22',
      'street': 'Second Street',
      'measurement': '2.5m x 3m',
      'amount': '6000',
      'dateadded': DateTime.now().subtract(Duration(days: 800)),
      'dateEffective': DateTime.now().subtract(Duration(days: 800)),
      'dateofexpiration':
          DateTime.now().subtract(Duration(days: 30)), // Expired 30 days ago
      'leessee': 'Jane Smith',
      'applicantName': ['Jane Smith'],
      'applcantAddress': ['456 Oak Ave, City'],
      'applicantContactNumber': [9876543211],
      'decFullName': ['Robert Smith'],
      'dateofdeath': [DateTime.now().subtract(Duration(days: 850))],
      'burialinternment': [DateTime.now().subtract(Duration(days: 840))],
    },
    {
      // Test Contract 3 - Nitche type (Active)
      'contractID': 1003,
      'contractidString': '1003',
      'type': 'nitche',
      'status': 'available',
      'contractstatus': 'available',
      'location': '7',
      'amount': '1000',
      'dateadded': DateTime.now().subtract(Duration(days: 180)),
      'dateEffective': DateTime.now().subtract(Duration(days: 180)),
      'dateofexpiration': DateTime.now().add(Duration(days: 185)), // Active
      'leessee': null, // Nitche contracts have null leessee
      'nitcheid': 7,
      'nitcheidString': '7',
      'decFullName': ['Carlos Garcia'],
      'dateofdeath': [DateTime.now().subtract(Duration(days: 200))],
      'burialinternment': [DateTime.now().subtract(Duration(days: 190))],
    },
    {
      // Test Contract 4 - Nitche type (Expired)
      'contractID': 1004,
      'contractidString': '1004',
      'type': 'nitche',
      'status': 'available',
      'contractstatus': 'available',
      'location': '12',
      'amount': '1000',
      'dateadded': DateTime.now().subtract(Duration(days: 400)),
      'dateEffective': DateTime.now().subtract(Duration(days: 400)),
      'dateofexpiration':
          DateTime.now().subtract(Duration(days: 15)), // Expired 15 days ago
      'leessee': null, // Nitche contracts have null leessee
      'nitcheid': 12,
      'nitcheidString': '12',
      'decFullName': ['Ana Rodriguez'],
      'dateofdeath': [DateTime.now().subtract(Duration(days: 420))],
      'burialinternment': [DateTime.now().subtract(Duration(days: 410))],
    },
    {
      // Test Contract 5 - Lot type (Active, with multiple deceased)
      'contractID': 1005,
      'contractidString': '1005',
      'type': 'Lot',
      'status': 'active',
      'contractstatus': 'active',
      'location': 'Block C, Lot 8',
      'street': 'Third Avenue',
      'measurement': '3m x 4m',
      'amount': '8000',
      'dateadded': DateTime.now().subtract(Duration(days: 500)),
      'dateEffective': DateTime.now().subtract(Duration(days: 500)),
      'dateofexpiration': DateTime.now().add(Duration(days: 200)), // Active
      'leessee': 'Michael Johnson',
      'applicantName': ['Michael Johnson', 'Sarah Johnson'],
      'applcantAddress': ['789 Pine St, City', '789 Pine St, City'],
      'applicantContactNumber': [9876543212, 9876543213],
      'decFullName': ['Elizabeth Johnson', 'William Johnson'],
      'dateofdeath': [
        DateTime.now().subtract(Duration(days: 600)),
        DateTime.now().subtract(Duration(days: 550))
      ],
      'burialinternment': [
        DateTime.now().subtract(Duration(days: 590)),
        DateTime.now().subtract(Duration(days: 540))
      ],
    },
  ];

  // Add test contracts to Firestore
  print('Creating 5 test contracts...');

  for (int i = 0; i < testContracts.length; i++) {
    try {
      await firestore.collection('contract').add(testContracts[i]);
      print(
          '✅ Created test contract ${i + 1} (ID: ${testContracts[i]['contractID']})');
    } catch (e) {
      print('❌ Failed to create test contract ${i + 1}: $e');
    }
  }

  print('\n📋 Test Contract Summary:');
  print('1. Contract 1001 - Lot type (Active) - John Doe');
  print('2. Contract 1002 - Lot type (Expired) - Jane Smith');
  print('3. Contract 1003 - Nitche type (Active) - Carlos Garcia');
  print('4. Contract 1004 - Nitche type (Expired) - Ana Rodriguez');
  print(
      '5. Contract 1005 - Lot type (Active) - Michael Johnson (Multiple deceased)');

  print('\n🧪 Testing Scenarios:');
  print('• Contracts 1002 & 1004 are expired and should create vault records');
  print(
      '• Contract 1004 (nitche) should only maintain specific fields in vault');
  print(
      '• Contracts 1001, 1003, 1005 are active and should show in ManageContract');
  print('• Contract 1005 has multiple deceased for testing array handling');

  print('\nDone! You can now test your application with these contracts.');
}








