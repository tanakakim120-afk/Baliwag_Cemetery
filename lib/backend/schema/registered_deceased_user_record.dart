import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class RegisteredDeceasedUserRecord extends FirestoreRecord {
  RegisteredDeceasedUserRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "userID" field.
  String? _userID;
  String get userID => _userID ?? '';
  bool hasUserID() => _userID != null;

  // "contractID" field.
  int? _contractID;
  int get contractID => _contractID ?? 0;
  bool hasContractID() => _contractID != null;

  // "registeredDeceased" field.
  String? _registeredDeceased;
  String get registeredDeceased => _registeredDeceased ?? '';
  bool hasRegisteredDeceased() => _registeredDeceased != null;

  // "deceasedDateOfDeath" field.
  DateTime? _deceasedDateOfDeath;
  DateTime? get deceasedDateOfDeath => _deceasedDateOfDeath;
  bool hasDeceasedDateOfDeath() => _deceasedDateOfDeath != null;

  // "applicants" field.
  String? _applicants;
  String get applicants => _applicants ?? '';
  bool hasApplicants() => _applicants != null;

  // "regisFullName" field.
  List<String>? _regisFullName;
  List<String> get regisFullName => _regisFullName ?? const [];
  bool hasRegisFullName() => _regisFullName != null;

  // "regisEmail" field.
  List<String>? _regisEmail;
  List<String> get regisEmail => _regisEmail ?? const [];
  bool hasRegisEmail() => _regisEmail != null;

  // "add" field.
  String? _add;
  String get add => _add ?? '';
  bool hasAdd() => _add != null;

  // "deceasedDateOfExpiration" field.
  DateTime? _deceasedDateOfExpiration;
  DateTime? get deceasedDateOfExpiration => _deceasedDateOfExpiration;
  bool hasDeceasedDateOfExpiration() => _deceasedDateOfExpiration != null;

  void _initializeFields() {
    _userID = snapshotData['userID'] as String?;
    _contractID = castToType<int>(snapshotData['contractID']);
    _registeredDeceased = snapshotData['registeredDeceased'] as String?;
    _deceasedDateOfDeath = snapshotData['deceasedDateOfDeath'] as DateTime?;
    _applicants = snapshotData['applicants'] as String?;
    _regisFullName = getDataList(snapshotData['regisFullName']);
    _regisEmail = getDataList(snapshotData['regisEmail']);
    _add = snapshotData['add'] as String?;
    _deceasedDateOfExpiration =
        snapshotData['deceasedDateOfExpiration'] as DateTime?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('registeredDeceasedUser');

  static Stream<RegisteredDeceasedUserRecord> getDocument(
          DocumentReference ref) =>
      ref.snapshots().map((s) => RegisteredDeceasedUserRecord.fromSnapshot(s));

  static Future<RegisteredDeceasedUserRecord> getDocumentOnce(
          DocumentReference ref) =>
      ref.get().then((s) => RegisteredDeceasedUserRecord.fromSnapshot(s));

  static RegisteredDeceasedUserRecord fromSnapshot(DocumentSnapshot snapshot) =>
      RegisteredDeceasedUserRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static RegisteredDeceasedUserRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      RegisteredDeceasedUserRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'RegisteredDeceasedUserRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is RegisteredDeceasedUserRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createRegisteredDeceasedUserRecordData({
  String? userID,
  int? contractID,
  String? registeredDeceased,
  DateTime? deceasedDateOfDeath,
  String? applicants,
  String? add,
  DateTime? deceasedDateOfExpiration,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'userID': userID,
      'contractID': contractID,
      'registeredDeceased': registeredDeceased,
      'deceasedDateOfDeath': deceasedDateOfDeath,
      'applicants': applicants,
      'add': add,
      'deceasedDateOfExpiration': deceasedDateOfExpiration,
    }.withoutNulls,
  );

  return firestoreData;
}

class RegisteredDeceasedUserRecordDocumentEquality
    implements Equality<RegisteredDeceasedUserRecord> {
  const RegisteredDeceasedUserRecordDocumentEquality();

  @override
  bool equals(
      RegisteredDeceasedUserRecord? e1, RegisteredDeceasedUserRecord? e2) {
    const listEquality = ListEquality();
    return e1?.userID == e2?.userID &&
        e1?.contractID == e2?.contractID &&
        e1?.registeredDeceased == e2?.registeredDeceased &&
        e1?.deceasedDateOfDeath == e2?.deceasedDateOfDeath &&
        e1?.applicants == e2?.applicants &&
        listEquality.equals(e1?.regisFullName, e2?.regisFullName) &&
        listEquality.equals(e1?.regisEmail, e2?.regisEmail) &&
        e1?.add == e2?.add &&
        e1?.deceasedDateOfExpiration == e2?.deceasedDateOfExpiration;
  }

  @override
  int hash(RegisteredDeceasedUserRecord? e) => const ListEquality().hash([
        e?.userID,
        e?.contractID,
        e?.registeredDeceased,
        e?.deceasedDateOfDeath,
        e?.applicants,
        e?.regisFullName,
        e?.regisEmail,
        e?.add,
        e?.deceasedDateOfExpiration
      ]);

  @override
  bool isValidKey(Object? o) => o is RegisteredDeceasedUserRecord;
}
