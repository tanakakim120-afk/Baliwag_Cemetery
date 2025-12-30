import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class PriceRecord extends FirestoreRecord {
  PriceRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "nitcheprice" field.
  int? _nitcheprice;
  int get nitcheprice => _nitcheprice ?? 0;
  bool hasNitcheprice() => _nitcheprice != null;

  // "lotprice" field.
  int? _lotprice;
  int get lotprice => _lotprice ?? 0;
  bool hasLotprice() => _lotprice != null;

  // "nitcheid1" field.
  int? _nitcheid1;
  int get nitcheid1 => _nitcheid1 ?? 0;
  bool hasNitcheid1() => _nitcheid1 != null;

  // "lotid2" field.
  int? _lotid2;
  int get lotid2 => _lotid2 ?? 0;
  bool hasLotid2() => _lotid2 != null;

  void _initializeFields() {
    _nitcheprice = castToType<int>(snapshotData['nitcheprice']);
    _lotprice = castToType<int>(snapshotData['lotprice']);
    _nitcheid1 = castToType<int>(snapshotData['nitcheid1']);
    _lotid2 = castToType<int>(snapshotData['lotid2']);
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('price');

  static Stream<PriceRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => PriceRecord.fromSnapshot(s));

  static Future<PriceRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => PriceRecord.fromSnapshot(s));

  static PriceRecord fromSnapshot(DocumentSnapshot snapshot) => PriceRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static PriceRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      PriceRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'PriceRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is PriceRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createPriceRecordData({
  int? nitcheprice,
  int? lotprice,
  int? nitcheid1,
  int? lotid2,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'nitcheprice': nitcheprice,
      'lotprice': lotprice,
      'nitcheid1': nitcheid1,
      'lotid2': lotid2,
    }.withoutNulls,
  );

  return firestoreData;
}

class PriceRecordDocumentEquality implements Equality<PriceRecord> {
  const PriceRecordDocumentEquality();

  @override
  bool equals(PriceRecord? e1, PriceRecord? e2) {
    return e1?.nitcheprice == e2?.nitcheprice &&
        e1?.lotprice == e2?.lotprice &&
        e1?.nitcheid1 == e2?.nitcheid1 &&
        e1?.lotid2 == e2?.lotid2;
  }

  @override
  int hash(PriceRecord? e) => const ListEquality()
      .hash([e?.nitcheprice, e?.lotprice, e?.nitcheid1, e?.lotid2]);

  @override
  bool isValidKey(Object? o) => o is PriceRecord;
}
