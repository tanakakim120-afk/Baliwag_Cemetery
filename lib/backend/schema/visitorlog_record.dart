import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class VisitorlogRecord extends FirestoreRecord {
  VisitorlogRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "timestamp" field.
  DateTime? _timestamp;
  DateTime? get timestamp => _timestamp;
  bool hasTimestamp() => _timestamp != null;

  // "name" field.
  String? _name;
  String get name => _name ?? '';
  bool hasName() => _name != null;

  // "visitorid" field.
  String? _visitorid;
  String get visitorid => _visitorid ?? '';
  bool hasVisitorid() => _visitorid != null;

  // "Stringtimestamp" field.
  String? _stringtimestamp;
  String get stringtimestamp => _stringtimestamp ?? '';
  bool hasStringtimestamp() => _stringtimestamp != null;

  // "email" field.
  String? _email;
  String get email => _email ?? '';
  bool hasEmail() => _email != null;

  // "display_name" field.
  String? _displayName;
  String get displayName => _displayName ?? '';
  bool hasDisplayName() => _displayName != null;

  // "photo_url" field.
  String? _photoUrl;
  String get photoUrl => _photoUrl ?? '';
  bool hasPhotoUrl() => _photoUrl != null;

  // "uid" field.
  String? _uid;
  String get uid => _uid ?? '';
  bool hasUid() => _uid != null;

  // "created_time" field.
  DateTime? _createdTime;
  DateTime? get createdTime => _createdTime;
  bool hasCreatedTime() => _createdTime != null;

  // "phone_number" field.
  String? _phoneNumber;
  String get phoneNumber => _phoneNumber ?? '';
  bool hasPhoneNumber() => _phoneNumber != null;

  void _initializeFields() {
    _timestamp = snapshotData['timestamp'] as DateTime?;
    _name = snapshotData['name'] as String?;
    _visitorid = snapshotData['visitorid'] as String?;
    _stringtimestamp = snapshotData['Stringtimestamp'] as String?;
    _email = snapshotData['email'] as String?;
    _displayName = snapshotData['display_name'] as String?;
    _photoUrl = snapshotData['photo_url'] as String?;
    _uid = snapshotData['uid'] as String?;
    _createdTime = snapshotData['created_time'] as DateTime?;
    _phoneNumber = snapshotData['phone_number'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('visitorlog');

  static Stream<VisitorlogRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => VisitorlogRecord.fromSnapshot(s));

  static Future<VisitorlogRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => VisitorlogRecord.fromSnapshot(s));

  static VisitorlogRecord fromSnapshot(DocumentSnapshot snapshot) =>
      VisitorlogRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static VisitorlogRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      VisitorlogRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'VisitorlogRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is VisitorlogRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createVisitorlogRecordData({
  DateTime? timestamp,
  String? name,
  String? visitorid,
  String? stringtimestamp,
  String? email,
  String? displayName,
  String? photoUrl,
  String? uid,
  DateTime? createdTime,
  String? phoneNumber,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'timestamp': timestamp,
      'name': name,
      'visitorid': visitorid,
      'Stringtimestamp': stringtimestamp,
      'email': email,
      'display_name': displayName,
      'photo_url': photoUrl,
      'uid': uid,
      'created_time': createdTime,
      'phone_number': phoneNumber,
    }.withoutNulls,
  );

  return firestoreData;
}

class VisitorlogRecordDocumentEquality implements Equality<VisitorlogRecord> {
  const VisitorlogRecordDocumentEquality();

  @override
  bool equals(VisitorlogRecord? e1, VisitorlogRecord? e2) {
    return e1?.timestamp == e2?.timestamp &&
        e1?.name == e2?.name &&
        e1?.visitorid == e2?.visitorid &&
        e1?.stringtimestamp == e2?.stringtimestamp &&
        e1?.email == e2?.email &&
        e1?.displayName == e2?.displayName &&
        e1?.photoUrl == e2?.photoUrl &&
        e1?.uid == e2?.uid &&
        e1?.createdTime == e2?.createdTime &&
        e1?.phoneNumber == e2?.phoneNumber;
  }

  @override
  int hash(VisitorlogRecord? e) => const ListEquality().hash([
        e?.timestamp,
        e?.name,
        e?.visitorid,
        e?.stringtimestamp,
        e?.email,
        e?.displayName,
        e?.photoUrl,
        e?.uid,
        e?.createdTime,
        e?.phoneNumber
      ]);

  @override
  bool isValidKey(Object? o) => o is VisitorlogRecord;
}
