import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ExpiredContractRecord extends FirestoreRecord {
  ExpiredContractRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "contractID" field.
  int? _contractID;
  int get contractID => _contractID ?? 0;
  bool hasContractID() => _contractID != null;

  // "contractidString" field.
  String? _contractidString;
  String get contractidString => _contractidString ?? '';
  bool hasContractidString() => _contractidString != null;

  // "tombLocation" field.
  String? _tombLocation;
  String get tombLocation => _tombLocation ?? '';
  bool hasTombLocation() => _tombLocation != null;

  // "Location" field.
  String? _location;
  String get location => _location ?? '';
  bool hasLocation() => _location != null;

  // "amount" field.
  String? _amount;
  String get amount => _amount ?? '';
  bool hasAmount() => _amount != null;

  // "OR" field.
  String? _or;
  String get or => _or ?? '';
  bool hasOr() => _or != null;

  // "TIN" field.
  String? _tin;
  String get tin => _tin ?? '';
  bool hasTin() => _tin != null;

  // "ResidentCert" field.
  String? _residentCert;
  String get residentCert => _residentCert ?? '';
  bool hasResidentCert() => _residentCert != null;

  // "placeIssued" field.
  String? _placeIssued;
  String get placeIssued => _placeIssued ?? '';
  bool hasPlaceIssued() => _placeIssued != null;

  // "dateIssued" field.
  DateTime? _dateIssued;
  DateTime? get dateIssued => _dateIssued;
  bool hasDateIssued() => _dateIssued != null;

  // "type" field.
  String? _type;
  String get type => _type ?? '';
  bool hasType() => _type != null;

  // "leessee" field.
  String? _leessee;
  String get leessee => _leessee ?? '';
  bool hasLeessee() => _leessee != null;

  // "street" field.
  String? _street;
  String get street => _street ?? '';
  bool hasStreet() => _street != null;

  // "status" field.
  String? _status;
  String get status => _status ?? '';
  bool hasStatus() => _status != null;

  // "measurement" field.
  String? _measurement;
  String get measurement => _measurement ?? '';
  bool hasMeasurement() => _measurement != null;

  // "proofoflease" field.
  String? _proofoflease;
  String get proofoflease => _proofoflease ?? '';
  bool hasProofoflease() => _proofoflease != null;

  // "applicantName" field.
  List<String>? _applicantName;
  List<String> get applicantName => _applicantName ?? const [];
  bool hasApplicantName() => _applicantName != null;

  // "applcantAddress" field.
  List<String>? _applcantAddress;
  List<String> get applcantAddress => _applcantAddress ?? const [];
  bool hasApplcantAddress() => _applcantAddress != null;

  // "applicantContactNumber" field.
  List<int>? _applicantContactNumber;
  List<int> get applicantContactNumber => _applicantContactNumber ?? const [];
  bool hasApplicantContactNumber() => _applicantContactNumber != null;

  // "decFullName" field.
  List<String>? _decFullName;
  List<String> get decFullName => _decFullName ?? const [];
  bool hasDecFullName() => _decFullName != null;

  // "dateofdeath" field.
  List<DateTime>? _dateofdeath;
  List<DateTime> get dateofdeath => _dateofdeath ?? const [];
  bool hasDateofdeath() => _dateofdeath != null;

  // "burialinternment" field.
  List<DateTime>? _burialinternment;
  List<DateTime> get burialinternment => _burialinternment ?? const [];
  bool hasBurialinternment() => _burialinternment != null;

  // "dateEffective" field.
  DateTime? _dateEffective;
  DateTime? get dateEffective => _dateEffective;
  bool hasDateEffective() => _dateEffective != null;

  // "dateofexpiration" field.
  DateTime? _dateofexpiration;
  DateTime? get dateofexpiration => _dateofexpiration;
  bool hasDateofexpiration() => _dateofexpiration != null;

  // "initialfee" field.
  double? _initialfee;
  double get initialfee => _initialfee ?? 0.0;
  bool hasInitialfee() => _initialfee != null;

  // "timestamp" field.
  DateTime? _timestamp;
  DateTime? get timestamp => _timestamp;
  bool hasTimestamp() => _timestamp != null;

  // "expiredDate" field.
  DateTime? _expiredDate;
  DateTime? get expiredDate => _expiredDate;
  bool hasExpiredDate() => _expiredDate != null;

  // "originalContractRef" field.
  DocumentReference? _originalContractRef;
  DocumentReference? get originalContractRef => _originalContractRef;
  bool hasOriginalContractRef() => _originalContractRef != null;

  // "leesseContactNo" field.
  String? _leesseContactNo;
  String get leesseContactNo => _leesseContactNo ?? '';
  bool hasLeesseContactNo() => _leesseContactNo != null;

  // "latestAddress" field.
  String? _latestAddress;
  String get latestAddress => _latestAddress ?? '';
  bool hasLatestAddress() => _latestAddress != null;

  void _initializeFields() {
    _contractID = castToType<int>(snapshotData['contractID']);
    _contractidString = snapshotData['contractidString'] as String?;
    _tombLocation = snapshotData['tombLocation'] as String?;
    _location = snapshotData['Location'] as String?;
    _amount = snapshotData['amount'] as String?;
    _or = snapshotData['OR'] as String?;
    _tin = snapshotData['TIN'] as String?;
    _residentCert = snapshotData['ResidentCert'] as String?;
    _placeIssued = snapshotData['placeIssued'] as String?;
    _dateIssued = snapshotData['dateIssued'] as DateTime?;
    _type = snapshotData['type'] as String?;
    _leessee = snapshotData['leessee'] as String?;
    _street = snapshotData['street'] as String?;
    _status = snapshotData['status'] as String?;
    _measurement = snapshotData['measurement'] as String?;
    _proofoflease = snapshotData['proofoflease'] as String?;
    _applicantName = getDataList(snapshotData['applicantName']);
    _applcantAddress = getDataList(snapshotData['applcantAddress']);
    _applicantContactNumber =
        getDataList(snapshotData['applicantContactNumber']);
    _decFullName = getDataList(snapshotData['decFullName']);
    _dateofdeath = getDataList(snapshotData['dateofdeath']);
    _burialinternment = getDataList(snapshotData['burialinternment']);
    _dateEffective = snapshotData['dateEffective'] as DateTime?;
    _dateofexpiration = snapshotData['dateofexpiration'] as DateTime?;
    _initialfee = castToType<double>(snapshotData['initialfee']);
    _timestamp = snapshotData['timestamp'] as DateTime?;
    _expiredDate = snapshotData['expiredDate'] as DateTime?;
    _originalContractRef =
        snapshotData['originalContractRef'] as DocumentReference?;
    _leesseContactNo = snapshotData['leesseContactNo'] as String?;
    _latestAddress = snapshotData['latestAddress'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('expiredContract');

  static Stream<ExpiredContractRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => ExpiredContractRecord.fromSnapshot(s));

  static Future<ExpiredContractRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => ExpiredContractRecord.fromSnapshot(s));

  static ExpiredContractRecord fromSnapshot(DocumentSnapshot snapshot) =>
      ExpiredContractRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static ExpiredContractRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      ExpiredContractRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'ExpiredContractRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is ExpiredContractRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createExpiredContractRecordData({
  int? contractID,
  String? contractidString,
  String? tombLocation,
  String? location,
  String? amount,
  String? or,
  String? tin,
  String? residentCert,
  String? placeIssued,
  DateTime? dateIssued,
  String? type,
  String? leessee,
  String? street,
  String? status,
  String? measurement,
  String? proofoflease,
  List<String>? applicantName,
  List<String>? applcantAddress,
  List<int>? applicantContactNumber,
  List<String>? decFullName,
  List<DateTime>? dateofdeath,
  List<DateTime>? burialinternment,
  DateTime? dateEffective,
  DateTime? dateofexpiration,
  double? initialfee,
  DateTime? timestamp,
  DateTime? expiredDate,
  DocumentReference? originalContractRef,
  String? leesseContactNo,
  String? latestAddress,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'contractID': contractID,
      'contractidString': contractidString,
      'tombLocation': tombLocation,
      'Location': location,
      'amount': amount,
      'OR': or,
      'TIN': tin,
      'ResidentCert': residentCert,
      'placeIssued': placeIssued,
      'dateIssued': dateIssued,
      'type': type,
      'leessee': leessee,
      'street': street,
      'status': status,
      'measurement': measurement,
      'proofoflease': proofoflease,
      'applicantName': applicantName,
      'applcantAddress': applcantAddress,
      'applicantContactNumber': applicantContactNumber,
      'decFullName': decFullName,
      'dateofdeath': dateofdeath,
      'burialinternment': burialinternment,
      'dateEffective': dateEffective,
      'dateofexpiration': dateofexpiration,
      'initialfee': initialfee,
      'timestamp': timestamp,
      'expiredDate': expiredDate,
      'originalContractRef': originalContractRef,
      'leesseContactNo': leesseContactNo,
      'latestAddress': latestAddress,
    }.withoutNulls,
  );

  return firestoreData;
}

class ExpiredContractRecordDocumentEquality
    implements Equality<ExpiredContractRecord> {
  const ExpiredContractRecordDocumentEquality();

  @override
  bool equals(ExpiredContractRecord? e1, ExpiredContractRecord? e2) {
    const listEquality = ListEquality();
    return e1?.contractID == e2?.contractID &&
        e1?.contractidString == e2?.contractidString &&
        e1?.tombLocation == e2?.tombLocation &&
        e1?.location == e2?.location &&
        e1?.amount == e2?.amount &&
        e1?.or == e2?.or &&
        e1?.tin == e2?.tin &&
        e1?.residentCert == e2?.residentCert &&
        e1?.placeIssued == e2?.placeIssued &&
        e1?.dateIssued == e2?.dateIssued &&
        e1?.type == e2?.type &&
        e1?.leessee == e2?.leessee &&
        e1?.street == e2?.street &&
        e1?.status == e2?.status &&
        e1?.measurement == e2?.measurement &&
        e1?.proofoflease == e2?.proofoflease &&
        listEquality.equals(e1?.applicantName, e2?.applicantName) &&
        listEquality.equals(e1?.applcantAddress, e2?.applcantAddress) &&
        listEquality.equals(
            e1?.applicantContactNumber, e2?.applicantContactNumber) &&
        listEquality.equals(e1?.decFullName, e2?.decFullName) &&
        listEquality.equals(e1?.dateofdeath, e2?.dateofdeath) &&
        listEquality.equals(e1?.burialinternment, e2?.burialinternment) &&
        e1?.dateEffective == e2?.dateEffective &&
        e1?.dateofexpiration == e2?.dateofexpiration &&
        e1?.initialfee == e2?.initialfee &&
        e1?.timestamp == e2?.timestamp &&
        e1?.expiredDate == e2?.expiredDate &&
        e1?.originalContractRef == e2?.originalContractRef &&
        e1?.leesseContactNo == e2?.leesseContactNo &&
        e1?.latestAddress == e2?.latestAddress;
  }

  @override
  int hash(ExpiredContractRecord? e) => const ListEquality().hash([
        e?.contractID,
        e?.contractidString,
        e?.tombLocation,
        e?.location,
        e?.amount,
        e?.or,
        e?.tin,
        e?.residentCert,
        e?.placeIssued,
        e?.dateIssued,
        e?.type,
        e?.leessee,
        e?.street,
        e?.status,
        e?.measurement,
        e?.proofoflease,
        e?.applicantName,
        e?.applcantAddress,
        e?.applicantContactNumber,
        e?.decFullName,
        e?.dateofdeath,
        e?.burialinternment,
        e?.dateEffective,
        e?.dateofexpiration,
        e?.initialfee,
        e?.timestamp,
        e?.expiredDate,
        e?.originalContractRef,
        e?.leesseContactNo,
        e?.latestAddress
      ]);

  @override
  bool isValidKey(Object? o) => o is ExpiredContractRecord;
}
