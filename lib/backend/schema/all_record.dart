import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class AllRecord extends FirestoreRecord {
  AllRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "nitcheid" field.
  int? _nitcheid;
  int get nitcheid => _nitcheid ?? 0;
  bool hasNitcheid() => _nitcheid != null;

  // "status" field.
  String? _status;
  String get status => _status ?? '';
  bool hasStatus() => _status != null;

  // "availability" field.
  String? _availability;
  String get availability => _availability ?? '';
  bool hasAvailability() => _availability != null;

  // "tombLoc" field.
  String? _tombLoc;
  String get tombLoc => _tombLoc ?? '';
  bool hasTombLoc() => _tombLoc != null;

  // "dateCreated" field.
  DateTime? _dateCreated;
  DateTime? get dateCreated => _dateCreated;
  bool hasDateCreated() => _dateCreated != null;

  // "nitcheid2" field.
  String? _nitcheid2;
  String get nitcheid2 => _nitcheid2 ?? '';
  bool hasNitcheid2() => _nitcheid2 != null;

  // "amount" field.
  double? _amount;
  double get amount => _amount ?? 0.0;
  bool hasAmount() => _amount != null;

  // "type" field.
  String? _type;
  String get type => _type ?? '';
  bool hasType() => _type != null;

  // "expirationDate" field.
  DateTime? _expirationDate;
  DateTime? get expirationDate => _expirationDate;
  bool hasExpirationDate() => _expirationDate != null;

  void _initializeFields() {
    _nitcheid = castToType<int>(snapshotData['nitcheid']);
    _status = snapshotData['status'] as String?;
    _availability = snapshotData['availability'] as String?;
    _tombLoc = snapshotData['tombLoc'] as String?;
    _dateCreated = snapshotData['dateCreated'] as DateTime?;
    _nitcheid2 = snapshotData['nitcheid2'] as String?;
    _amount = castToType<double>(snapshotData['amount']);
    _type = snapshotData['type'] as String?;
    _expirationDate = snapshotData['expirationDate'] as DateTime?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('all');

  static Stream<AllRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => AllRecord.fromSnapshot(s));

  static Future<AllRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => AllRecord.fromSnapshot(s));

  static AllRecord fromSnapshot(DocumentSnapshot snapshot) => AllRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static AllRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      AllRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'AllRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is AllRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createAllRecordData({
  int? nitcheid,
  String? status,
  String? availability,
  String? tombLoc,
  DateTime? dateCreated,
  String? nitcheid2,
  double? amount,
  String? type,
  DateTime? expirationDate,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'nitcheid': nitcheid,
      'status': status,
      'availability': availability,
      'tombLoc': tombLoc,
      'dateCreated': dateCreated,
      'nitcheid2': nitcheid2,
      'amount': amount,
      'type': type,
      'expirationDate': expirationDate,
    }.withoutNulls,
  );

  return firestoreData;
}

class AllRecordDocumentEquality implements Equality<AllRecord> {
  const AllRecordDocumentEquality();

  @override
  bool equals(AllRecord? e1, AllRecord? e2) {
    return e1?.nitcheid == e2?.nitcheid &&
        e1?.status == e2?.status &&
        e1?.availability == e2?.availability &&
        e1?.tombLoc == e2?.tombLoc &&
        e1?.dateCreated == e2?.dateCreated &&
        e1?.nitcheid2 == e2?.nitcheid2 &&
        e1?.amount == e2?.amount &&
        e1?.type == e2?.type &&
        e1?.expirationDate == e2?.expirationDate;
  }

  @override
  int hash(AllRecord? e) => const ListEquality().hash([
        e?.nitcheid,
        e?.status,
        e?.availability,
        e?.tombLoc,
        e?.dateCreated,
        e?.nitcheid2,
        e?.amount,
        e?.type,
        e?.expirationDate
      ]);

  @override
  bool isValidKey(Object? o) => o is AllRecord;
}
