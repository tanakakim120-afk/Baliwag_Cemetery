import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

/// Accounts
class RegisteredBeneficiariesRecord extends FirestoreRecord {
  RegisteredBeneficiariesRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "email" field.
  String? _email;
  String get email => _email ?? '';
  bool hasEmail() => _email != null;

  // "fullname" field.
  String? _fullname;
  String get fullname => _fullname ?? '';
  bool hasFullname() => _fullname != null;

  // "display_name" field.
  String? _displayName;
  String get displayName => _displayName ?? '';
  bool hasDisplayName() => _displayName != null;

  // "phone_number" field.
  String? _phoneNumber;
  String get phoneNumber => _phoneNumber ?? '';
  bool hasPhoneNumber() => _phoneNumber != null;

  // "created_time" field.
  DateTime? _createdTime;
  DateTime? get createdTime => _createdTime;
  bool hasCreatedTime() => _createdTime != null;

  // "uid" field.
  String? _uid;
  String get uid => _uid ?? '';
  bool hasUid() => _uid != null;

  // "contractID" field.
  int? _contractID;
  int get contractID => _contractID ?? 0;
  bool hasContractID() => _contractID != null;

  void _initializeFields() {
    _email = snapshotData['email'] as String?;
    _fullname = snapshotData['fullname'] as String?;
    _displayName = snapshotData['display_name'] as String?;
    _phoneNumber = snapshotData['phone_number'] as String?;
    _createdTime = snapshotData['created_time'] as DateTime?;
    _uid = snapshotData['uid'] as String?;
    _contractID = castToType<int>(snapshotData['contractID']);
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('registeredBeneficiaries');

  static Stream<RegisteredBeneficiariesRecord> getDocument(
          DocumentReference ref) =>
      ref.snapshots().map((s) => RegisteredBeneficiariesRecord.fromSnapshot(s));

  static Future<RegisteredBeneficiariesRecord> getDocumentOnce(
          DocumentReference ref) =>
      ref.get().then((s) => RegisteredBeneficiariesRecord.fromSnapshot(s));

  static RegisteredBeneficiariesRecord fromSnapshot(
          DocumentSnapshot snapshot) =>
      RegisteredBeneficiariesRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static RegisteredBeneficiariesRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      RegisteredBeneficiariesRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'RegisteredBeneficiariesRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is RegisteredBeneficiariesRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createRegisteredBeneficiariesRecordData({
  String? email,
  String? fullname,
  String? displayName,
  String? phoneNumber,
  DateTime? createdTime,
  String? uid,
  int? contractID,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'email': email,
      'fullname': fullname,
      'display_name': displayName,
      'phone_number': phoneNumber,
      'created_time': createdTime,
      'uid': uid,
      'contractID': contractID,
    }.withoutNulls,
  );

  return firestoreData;
}

class RegisteredBeneficiariesRecordDocumentEquality
    implements Equality<RegisteredBeneficiariesRecord> {
  const RegisteredBeneficiariesRecordDocumentEquality();

  @override
  bool equals(
      RegisteredBeneficiariesRecord? e1, RegisteredBeneficiariesRecord? e2) {
    return e1?.email == e2?.email &&
        e1?.fullname == e2?.fullname &&
        e1?.displayName == e2?.displayName &&
        e1?.phoneNumber == e2?.phoneNumber &&
        e1?.createdTime == e2?.createdTime &&
        e1?.uid == e2?.uid &&
        e1?.contractID == e2?.contractID;
  }

  @override
  int hash(RegisteredBeneficiariesRecord? e) => const ListEquality().hash([
        e?.email,
        e?.fullname,
        e?.displayName,
        e?.phoneNumber,
        e?.createdTime,
        e?.uid,
        e?.contractID
      ]);

  @override
  bool isValidKey(Object? o) => o is RegisteredBeneficiariesRecord;
}
