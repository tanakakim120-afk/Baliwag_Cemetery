import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class AuditRecord extends FirestoreRecord {
  AuditRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "id" field.
  DocumentReference? _id;
  DocumentReference? get id => _id;
  bool hasId() => _id != null;

  // "name" field.
  String? _name;
  String get name => _name ?? '';
  bool hasName() => _name != null;

  // "action" field.
  String? _action;
  String get action => _action ?? '';
  bool hasAction() => _action != null;

  // "timestamp" field.
  DateTime? _timestamp;
  DateTime? get timestamp => _timestamp;
  bool hasTimestamp() => _timestamp != null;

  // "Stringtimestamp" field.
  String? _stringtimestamp;
  String get stringtimestamp => _stringtimestamp ?? '';
  bool hasStringtimestamp() => _stringtimestamp != null;

  // "ipAddress" field.
  String? _ipAddress;
  String get ipAddress => _ipAddress ?? '';
  bool hasIpAddress() => _ipAddress != null;

  // "userId" field.
  String? _userId;
  String get userId => _userId ?? '';
  bool hasUserId() => _userId != null;

  void _initializeFields() {
    _id = snapshotData['id'] as DocumentReference?;
    _name = snapshotData['name'] as String?;
    _action = snapshotData['action'] as String?;
    _timestamp = snapshotData['timestamp'] as DateTime?;
    _stringtimestamp = snapshotData['Stringtimestamp'] as String?;
    _ipAddress = snapshotData['ipAddress'] as String?;
    _userId = snapshotData['userId'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('audit');

  static Stream<AuditRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => AuditRecord.fromSnapshot(s));

  static Future<AuditRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => AuditRecord.fromSnapshot(s));

  static AuditRecord fromSnapshot(DocumentSnapshot snapshot) => AuditRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static AuditRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      AuditRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'AuditRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is AuditRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createAuditRecordData({
  DocumentReference? id,
  String? name,
  String? action,
  DateTime? timestamp,
  String? stringtimestamp,
  String? ipAddress,
  String? userId,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'id': id,
      'name': name,
      'action': action,
      'timestamp': timestamp,
      'Stringtimestamp': stringtimestamp,
      'ipAddress': ipAddress,
      'userId': userId,
    }.withoutNulls,
  );

  return firestoreData;
}

class AuditRecordDocumentEquality implements Equality<AuditRecord> {
  const AuditRecordDocumentEquality();

  @override
  bool equals(AuditRecord? e1, AuditRecord? e2) {
    return e1?.id == e2?.id &&
        e1?.name == e2?.name &&
        e1?.action == e2?.action &&
        e1?.timestamp == e2?.timestamp &&
        e1?.stringtimestamp == e2?.stringtimestamp &&
        e1?.ipAddress == e2?.ipAddress &&
        e1?.userId == e2?.userId;
  }

  @override
  int hash(AuditRecord? e) => const ListEquality().hash([
        e?.id,
        e?.name,
        e?.action,
        e?.timestamp,
        e?.stringtimestamp,
        e?.ipAddress,
        e?.userId
      ]);

  @override
  bool isValidKey(Object? o) => o is AuditRecord;
}
