import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class VaultRecord extends FirestoreRecord {
  VaultRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "deceasedid" field.
  int? _deceasedid;
  int get deceasedid => _deceasedid ?? 0;
  bool hasDeceasedid() => _deceasedid != null;

  // "deceasedname" field.
  List<String>? _deceasedname;
  List<String> get deceasedname => _deceasedname ?? const [];
  bool hasDeceasedname() => _deceasedname != null;

  // "deceasedDateofDeath" field.
  DateTime? _deceasedDateofDeath;
  DateTime? get deceasedDateofDeath => _deceasedDateofDeath;
  bool hasDeceasedDateofDeath() => _deceasedDateofDeath != null;

  // "timestamp" field.
  DateTime? _timestamp;
  DateTime? get timestamp => _timestamp;
  bool hasTimestamp() => _timestamp != null;

  // "deceasedIDstring" field.
  String? _deceasedIDstring;
  String get deceasedIDstring => _deceasedIDstring ?? '';
  bool hasDeceasedIDstring() => _deceasedIDstring != null;

  // "status" field.
  String? _status;
  String get status => _status ?? '';
  bool hasStatus() => _status != null;

  // "Stringvaultadded" field.
  String? _stringvaultadded;
  String get stringvaultadded => _stringvaultadded ?? '';
  bool hasStringvaultadded() => _stringvaultadded != null;

  // "deceaseddateofdeath" field.
  List<DateTime>? _deceaseddateofdeath;
  List<DateTime> get deceaseddateofdeath => _deceaseddateofdeath ?? const [];
  bool hasDeceaseddateofdeath() => _deceaseddateofdeath != null;

  // "deceasedburialinterment" field.
  List<DateTime>? _deceasedburialinterment;
  List<DateTime> get deceasedburialinterment =>
      _deceasedburialinterment ?? const [];
  bool hasDeceasedburialinterment() => _deceasedburialinterment != null;

  // "applicantname" field.
  List<String>? _applicantname;
  List<String> get applicantname => _applicantname ?? const [];
  bool hasApplicantname() => _applicantname != null;

  // "applicantaddress" field.
  List<String>? _applicantaddress;
  List<String> get applicantaddress => _applicantaddress ?? const [];
  bool hasApplicantaddress() => _applicantaddress != null;

  // "applicantcontactnumber" field.
  List<int>? _applicantcontactnumber;
  List<int> get applicantcontactnumber => _applicantcontactnumber ?? const [];
  bool hasApplicantcontactnumber() => _applicantcontactnumber != null;

  // "vaultID" field.
  DocumentReference? _vaultID;
  DocumentReference? get vaultID => _vaultID;
  bool hasVaultID() => _vaultID != null;

  void _initializeFields() {
    _deceasedid = castToType<int>(snapshotData['deceasedid']);
    _deceasedname = getDataList(snapshotData['deceasedname']);
    _deceasedDateofDeath = snapshotData['deceasedDateofDeath'] as DateTime?;
    _timestamp = snapshotData['timestamp'] as DateTime?;
    _deceasedIDstring = snapshotData['deceasedIDstring'] as String?;
    _status = snapshotData['status'] as String?;
    _stringvaultadded = snapshotData['Stringvaultadded'] as String?;
    _deceaseddateofdeath = getDataList(snapshotData['deceaseddateofdeath']);
    _deceasedburialinterment =
        getDataList(snapshotData['deceasedburialinterment']);
    _applicantname = getDataList(snapshotData['applicantname']);
    _applicantaddress = getDataList(snapshotData['applicantaddress']);
    _applicantcontactnumber =
        getDataList(snapshotData['applicantcontactnumber']);
    _vaultID = snapshotData['vaultID'] as DocumentReference?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('vault');

  static Stream<VaultRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => VaultRecord.fromSnapshot(s));

  static Future<VaultRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => VaultRecord.fromSnapshot(s));

  static VaultRecord fromSnapshot(DocumentSnapshot snapshot) => VaultRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static VaultRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      VaultRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'VaultRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is VaultRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createVaultRecordData({
  int? deceasedid,
  List<String>? deceasedname,
  DateTime? deceasedDateofDeath,
  DateTime? timestamp,
  String? deceasedIDstring,
  String? status,
  String? stringvaultadded,
  List<DateTime>? deceaseddateofdeath,
  List<DateTime>? deceasedburialinterment,
  List<String>? applicantname,
  List<String>? applicantaddress,
  List<int>? applicantcontactnumber,
  DocumentReference? vaultID,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'deceasedid': deceasedid,
      'deceasedname': deceasedname,
      'deceasedDateofDeath': deceasedDateofDeath,
      'timestamp': timestamp,
      'deceasedIDstring': deceasedIDstring,
      'status': status,
      'Stringvaultadded': stringvaultadded,
      'deceaseddateofdeath': deceaseddateofdeath,
      'deceasedburialinterment': deceasedburialinterment,
      'applicantname': applicantname,
      'applicantaddress': applicantaddress,
      'applicantcontactnumber': applicantcontactnumber,
      'vaultID': vaultID,
    }.withoutNulls,
  );

  return firestoreData;
}

class VaultRecordDocumentEquality implements Equality<VaultRecord> {
  const VaultRecordDocumentEquality();

  @override
  bool equals(VaultRecord? e1, VaultRecord? e2) {
    const listEquality = ListEquality();
    return e1?.deceasedid == e2?.deceasedid &&
        listEquality.equals(e1?.deceasedname, e2?.deceasedname) &&
        e1?.deceasedDateofDeath == e2?.deceasedDateofDeath &&
        e1?.timestamp == e2?.timestamp &&
        e1?.deceasedIDstring == e2?.deceasedIDstring &&
        e1?.status == e2?.status &&
        e1?.stringvaultadded == e2?.stringvaultadded &&
        listEquality.equals(e1?.deceaseddateofdeath, e2?.deceaseddateofdeath) &&
        listEquality.equals(
            e1?.deceasedburialinterment, e2?.deceasedburialinterment) &&
        listEquality.equals(e1?.applicantname, e2?.applicantname) &&
        listEquality.equals(e1?.applicantaddress, e2?.applicantaddress) &&
        listEquality.equals(
            e1?.applicantcontactnumber, e2?.applicantcontactnumber) &&
        e1?.vaultID == e2?.vaultID;
  }

  @override
  int hash(VaultRecord? e) => const ListEquality().hash([
        e?.deceasedid,
        e?.deceasedname,
        e?.deceasedDateofDeath,
        e?.timestamp,
        e?.deceasedIDstring,
        e?.status,
        e?.stringvaultadded,
        e?.deceaseddateofdeath,
        e?.deceasedburialinterment,
        e?.applicantname,
        e?.applicantaddress,
        e?.applicantcontactnumber,
        e?.vaultID
      ]);

  @override
  bool isValidKey(Object? o) => o is VaultRecord;
}
