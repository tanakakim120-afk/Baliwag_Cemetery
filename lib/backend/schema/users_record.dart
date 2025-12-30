import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class UsersRecord extends FirestoreRecord {
  UsersRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

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

  // "password" field.
  String? _password;
  String get password => _password ?? '';
  bool hasPassword() => _password != null;

  // "fullname" field.
  String? _fullname;
  String get fullname => _fullname ?? '';
  bool hasFullname() => _fullname != null;

  // "address" field.
  String? _address;
  String get address => _address ?? '';
  bool hasAddress() => _address != null;

  // "type" field.
  String? _type;
  String get type => _type ?? '';
  bool hasType() => _type != null;

  // "Stringusercreated" field.
  String? _stringusercreated;
  String get stringusercreated => _stringusercreated ?? '';
  bool hasStringusercreated() => _stringusercreated != null;

  // "registeredDeceasedID" field.
  List<int>? _registeredDeceasedID;
  List<int> get registeredDeceasedID => _registeredDeceasedID ?? const [];
  bool hasRegisteredDeceasedID() => _registeredDeceasedID != null;

  // "isSuspended" field.
  bool? _isSuspended;
  bool get isSuspended => _isSuspended ?? false;
  bool hasIsSuspended() => _isSuspended != null;

  // "suspensionStartDate" field.
  DateTime? _suspensionStartDate;
  DateTime? get suspensionStartDate => _suspensionStartDate;
  bool hasSuspensionStartDate() => _suspensionStartDate != null;

  // "suspensionEndDate" field.
  DateTime? _suspensionEndDate;
  DateTime? get suspensionEndDate => _suspensionEndDate;
  bool hasSuspensionEndDate() => _suspensionEndDate != null;

  // "suspensionReason" field.
  String? _suspensionReason;
  String get suspensionReason => _suspensionReason ?? '';
  bool hasSuspensionReason() => _suspensionReason != null;

  void _initializeFields() {
    _email = snapshotData['email'] as String?;
    _displayName = snapshotData['display_name'] as String?;
    _photoUrl = snapshotData['photo_url'] as String?;
    _uid = snapshotData['uid'] as String?;
    _createdTime = snapshotData['created_time'] as DateTime?;
    _phoneNumber = snapshotData['phone_number'] as String?;
    _password = snapshotData['password'] as String?;
    _fullname = snapshotData['fullname'] as String?;
    _address = snapshotData['address'] as String?;
    _type = snapshotData['type'] as String?;
    _stringusercreated = snapshotData['Stringusercreated'] as String?;
    _registeredDeceasedID = getDataList(snapshotData['registeredDeceasedID']);
    _isSuspended = snapshotData['isSuspended'] as bool?;
    _suspensionStartDate = snapshotData['suspensionStartDate'] as DateTime?;
    _suspensionEndDate = snapshotData['suspensionEndDate'] as DateTime?;
    _suspensionReason = snapshotData['suspensionReason'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('users');

  static Stream<UsersRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => UsersRecord.fromSnapshot(s));

  static Future<UsersRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => UsersRecord.fromSnapshot(s));

  static UsersRecord fromSnapshot(DocumentSnapshot snapshot) => UsersRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static UsersRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      UsersRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'UsersRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is UsersRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createUsersRecordData({
  String? email,
  String? displayName,
  String? photoUrl,
  String? uid,
  DateTime? createdTime,
  String? phoneNumber,
  String? password,
  String? fullname,
  String? address,
  String? type,
  String? stringusercreated,
  bool? isSuspended,
  DateTime? suspensionStartDate,
  DateTime? suspensionEndDate,
  String? suspensionReason,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'email': email,
      'display_name': displayName,
      'photo_url': photoUrl,
      'uid': uid,
      'created_time': createdTime,
      'phone_number': phoneNumber,
      'password': password,
      'fullname': fullname,
      'address': address,
      'type': type,
      'Stringusercreated': stringusercreated,
      'isSuspended': isSuspended,
      'suspensionStartDate': suspensionStartDate,
      'suspensionEndDate': suspensionEndDate,
      'suspensionReason': suspensionReason,
    }.withoutNulls,
  );

  return firestoreData;
}

class UsersRecordDocumentEquality implements Equality<UsersRecord> {
  const UsersRecordDocumentEquality();

  @override
  bool equals(UsersRecord? e1, UsersRecord? e2) {
    const listEquality = ListEquality();
    return e1?.email == e2?.email &&
        e1?.displayName == e2?.displayName &&
        e1?.photoUrl == e2?.photoUrl &&
        e1?.uid == e2?.uid &&
        e1?.createdTime == e2?.createdTime &&
        e1?.phoneNumber == e2?.phoneNumber &&
        e1?.password == e2?.password &&
        e1?.fullname == e2?.fullname &&
        e1?.address == e2?.address &&
        e1?.type == e2?.type &&
        e1?.stringusercreated == e2?.stringusercreated &&
        listEquality.equals(
            e1?.registeredDeceasedID, e2?.registeredDeceasedID) &&
        e1?.isSuspended == e2?.isSuspended &&
        e1?.suspensionStartDate == e2?.suspensionStartDate &&
        e1?.suspensionEndDate == e2?.suspensionEndDate &&
        e1?.suspensionReason == e2?.suspensionReason;
  }

  @override
  int hash(UsersRecord? e) => const ListEquality().hash([
        e?.email,
        e?.displayName,
        e?.photoUrl,
        e?.uid,
        e?.createdTime,
        e?.phoneNumber,
        e?.password,
        e?.fullname,
        e?.address,
        e?.type,
        e?.stringusercreated,
        e?.registeredDeceasedID,
        e?.isSuspended,
        e?.suspensionStartDate,
        e?.suspensionEndDate,
        e?.suspensionReason
      ]);

  @override
  bool isValidKey(Object? o) => o is UsersRecord;
}
