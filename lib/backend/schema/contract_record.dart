import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ContractRecord extends FirestoreRecord {
  ContractRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "contractID" field.
  int? _contractID;
  int get contractID => _contractID ?? 0;
  bool hasContractID() => _contractID != null;

  // "tombLocation" field.
  String? _tombLocation;
  String get tombLocation => _tombLocation ?? '';
  bool hasTombLocation() => _tombLocation != null;

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

  // "pastApplicantName" field - stores the name of the previous applicant
  String? _pastApplicantName;
  String get pastApplicantName => _pastApplicantName ?? '';
  bool hasPastApplicantName() => _pastApplicantName != null;

  // "pastApplicantAddress" field - stores the address of the previous applicant
  String? _pastApplicantAddress;
  String get pastApplicantAddress => _pastApplicantAddress ?? '';
  bool hasPastApplicantAddress() => _pastApplicantAddress != null;

  // "pastApplicantContact" field - stores the contact number of the previous applicant
  String? _pastApplicantContact;
  String get pastApplicantContact => _pastApplicantContact ?? '';
  bool hasPastApplicantContact() => _pastApplicantContact != null;

  // "applicantStatus" field - indicates if applicant is current or past
  String? _applicantStatus;
  String get applicantStatus => _applicantStatus ?? 'current';
  bool hasApplicantStatus() => _applicantStatus != null;

  // "decFullName" field.
  List<String>? _decFullName;
  List<String> get decFullName => _decFullName ?? const [];
  bool hasDecFullName() => _decFullName != null;

  // "lotLoccation" field.
  String? _lotLoccation;
  String get lotLoccation => _lotLoccation ?? '';
  bool hasLotLoccation() => _lotLoccation != null;

  // "leesseContactNo" field.
  String? _leesseContactNo;
  String get leesseContactNo => _leesseContactNo ?? '';
  bool hasLeesseContactNo() => _leesseContactNo != null;

  // "Location" field.
  String? _location;
  String get location => _location ?? '';
  bool hasLocation() => _location != null;

  // "contractidString" field.
  String? _contractidString;
  String get contractidString => _contractidString ?? '';
  bool hasContractidString() => _contractidString != null;

  // "dateEffective" field.
  DateTime? _dateEffective;
  DateTime? get dateEffective => _dateEffective;
  bool hasDateEffective() => _dateEffective != null;

  // "dateofdeath" field.
  List<DateTime>? _dateofdeath;
  List<DateTime> get dateofdeath => _dateofdeath ?? const [];
  bool hasDateofdeath() => _dateofdeath != null;

  // "nitcheid" field.
  int? _nitcheid;
  int get nitcheid => _nitcheid ?? 0;
  bool hasNitcheid() => _nitcheid != null;

  // "nitcheidString" field.
  String? _nitcheidString;
  String get nitcheidString => _nitcheidString ?? '';
  bool hasNitcheidString() => _nitcheidString != null;

  // "dummy" field.
  String? _dummy;
  String get dummy => _dummy ?? '';
  bool hasDummy() => _dummy != null;

  // "latestContNum" field.
  int? _latestContNum;
  int get latestContNum => _latestContNum ?? 0;
  bool hasLatestContNum() => _latestContNum != null;

  // "latestAddress" field.
  String? _latestAddress;
  String get latestAddress => _latestAddress ?? '';
  bool hasLatestAddress() => _latestAddress != null;

  // "latestDeceased" field.
  String? _latestDeceased;
  String get latestDeceased => _latestDeceased ?? '';
  bool hasLatestDeceased() => _latestDeceased != null;

  // "appliContNumb" field.
  List<String>? _appliContNumb;
  List<String> get appliContNumb => _appliContNumb ?? const [];
  bool hasAppliContNumb() => _appliContNumb != null;

  // "Lotstatus" field.
  String? _lotstatus;
  String get lotstatus => _lotstatus ?? '';
  bool hasLotstatus() => _lotstatus != null;

  // "dateofexpiration" field.
  DateTime? _dateofexpiration;
  DateTime? get dateofexpiration => _dateofexpiration;
  bool hasDateofexpiration() => _dateofexpiration != null;

  // "contractstatus" field.
  String? _contractstatus;
  String get contractstatus => _contractstatus ?? '';
  bool hasContractstatus() => _contractstatus != null;

  // "burialinternment" field.
  List<DateTime>? _burialinternment;
  List<DateTime> get burialinternment => _burialinternment ?? const [];
  bool hasBurialinternment() => _burialinternment != null;

  // "initialfee" field.
  double? _initialfee;
  double get initialfee => _initialfee ?? 0.0;
  bool hasInitialfee() => _initialfee != null;

  // "remainingbalances" field.
  List<String>? _remainingbalances;
  List<String> get remainingbalances => _remainingbalances ?? const [];
  bool hasRemainingbalances() => _remainingbalances != null;

  // "lotpicture" field.
  String? _lotpicture;
  String get lotpicture => _lotpicture ?? '';
  bool hasLotpicture() => _lotpicture != null;

  // "years" field.
  String? _years;
  String get years => _years ?? '';
  bool hasYears() => _years != null;

  // "dateadded" field.
  DateTime? _dateadded;
  DateTime? get dateadded => _dateadded;
  bool hasDateadded() => _dateadded != null;

  // "amountINT" field.
  int? _amountINT;
  int get amountINT => _amountINT ?? 0;
  bool hasAmountINT() => _amountINT != null;

  // "totalContraBalance" field.
  double? _totalContraBalance;
  double get totalContraBalance => _totalContraBalance ?? 0.0;
  bool hasTotalContraBalance() => _totalContraBalance != null;

  // "stringEffectivedate" field.
  String? _stringEffectivedate;
  String get stringEffectivedate => _stringEffectivedate ?? '';
  bool hasStringEffectivedate() => _stringEffectivedate != null;

  // "stringExpirationdate" field.
  String? _stringExpirationdate;
  String get stringExpirationdate => _stringExpirationdate ?? '';
  bool hasStringExpirationdate() => _stringExpirationdate != null;

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

  // "balance" field.
  int? _balance;
  int get balance => _balance ?? 0;
  bool hasBalance() => _balance != null;

  // "registered" field.
  String? _registered;
  String get registered => _registered ?? '';
  bool hasRegistered() => _registered != null;

  void _initializeFields() {
    _contractID = castToType<int>(snapshotData['contractID']);
    _tombLocation = snapshotData['tombLocation'] as String?;
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
    _pastApplicantName = snapshotData['pastApplicantName'] as String?;
    _pastApplicantAddress = snapshotData['pastApplicantAddress'] as String?;
    _pastApplicantContact = snapshotData['pastApplicantContact'] as String?;
    _applicantStatus = snapshotData['applicantStatus'] as String?;
    _decFullName = getDataList(snapshotData['decFullName']);
    _lotLoccation = snapshotData['lotLoccation'] as String?;
    _leesseContactNo = snapshotData['leesseContactNo'] as String?;
    _location = snapshotData['Location'] as String?;
    _contractidString = snapshotData['contractidString'] as String?;
    _dateEffective = snapshotData['dateEffective'] as DateTime?;
    _dateofdeath = getDataList(snapshotData['dateofdeath']);
    _nitcheid = castToType<int>(snapshotData['nitcheid']);
    _nitcheidString = snapshotData['nitcheidString'] as String?;
    _dummy = snapshotData['dummy'] as String?;
    _latestContNum = castToType<int>(snapshotData['latestContNum']);
    _latestAddress = snapshotData['latestAddress'] as String?;
    _latestDeceased = snapshotData['latestDeceased'] as String?;
    _appliContNumb = getDataList(snapshotData['appliContNumb']);
    _lotstatus = snapshotData['Lotstatus'] as String?;
    _dateofexpiration = snapshotData['dateofexpiration'] as DateTime?;
    _contractstatus = snapshotData['contractstatus'] as String?;
    _burialinternment = getDataList(snapshotData['burialinternment']);
    _initialfee = castToType<double>(snapshotData['initialfee']);
    _remainingbalances = getDataList(snapshotData['remainingbalances']);
    _lotpicture = snapshotData['lotpicture'] as String?;
    _years = snapshotData['years'] as String?;
    _dateadded = snapshotData['dateadded'] as DateTime?;
    _amountINT = castToType<int>(snapshotData['amountINT']);
    _totalContraBalance =
        castToType<double>(snapshotData['totalContraBalance']);
    _stringEffectivedate = snapshotData['stringEffectivedate'] as String?;
    _stringExpirationdate = snapshotData['stringExpirationdate'] as String?;
    _email = snapshotData['email'] as String?;
    _displayName = snapshotData['display_name'] as String?;
    _photoUrl = snapshotData['photo_url'] as String?;
    _uid = snapshotData['uid'] as String?;
    _createdTime = snapshotData['created_time'] as DateTime?;
    _phoneNumber = snapshotData['phone_number'] as String?;
    _balance = castToType<int>(snapshotData['balance']);
    _registered = snapshotData['registered'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('contract');

  static Stream<ContractRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => ContractRecord.fromSnapshot(s));

  static Future<ContractRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => ContractRecord.fromSnapshot(s));

  static ContractRecord fromSnapshot(DocumentSnapshot snapshot) =>
      ContractRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static ContractRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      ContractRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'ContractRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is ContractRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createContractRecordData({
  int? contractID,
  String? tombLocation,
  String? amount,
  String? or, // OR field as String
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
  String? lotLoccation,
  String? leesseContactNo,
  String? location,
  String? contractidString,
  DateTime? dateEffective,
  int? nitcheid,
  String? nitcheidString,
  String? dummy,
  int? latestContNum,
  String? latestAddress,
  String? latestDeceased,
  String? lotstatus,
  DateTime? dateofexpiration,
  String? contractstatus,
  double? initialfee,
  String? lotpicture,
  String? years,
  DateTime? dateadded,
  int? amountINT,
  double? totalContraBalance,
  String? stringEffectivedate,
  String? stringExpirationdate,
  String? email,
  String? displayName,
  String? photoUrl,
  String? uid,
  DateTime? createdTime,
  String? phoneNumber,
  int? balance,
  String? registered,
  String? pastApplicantName,
  String? pastApplicantAddress,
  String? pastApplicantContact,
  String? applicantStatus,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'contractID': contractID,
      'tombLocation': tombLocation,
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
      'lotLoccation': lotLoccation,
      'leesseContactNo': leesseContactNo,
      'Location': location,
      'contractidString': contractidString,
      'dateEffective': dateEffective,
      'nitcheid': nitcheid,
      'nitcheidString': nitcheidString,
      'dummy': dummy,
      'latestContNum': latestContNum,
      'latestAddress': latestAddress,
      'latestDeceased': latestDeceased,
      'Lotstatus': lotstatus,
      'dateofexpiration': dateofexpiration,
      'contractstatus': contractstatus,
      'initialfee': initialfee,
      'lotpicture': lotpicture,
      'years': years,
      'dateadded': dateadded,
      'amountINT': amountINT,
      'totalContraBalance': totalContraBalance,
      'stringEffectivedate': stringEffectivedate,
      'stringExpirationdate': stringExpirationdate,
      'email': email,
      'display_name': displayName,
      'photo_url': photoUrl,
      'uid': uid,
      'created_time': createdTime,
      'phone_number': phoneNumber,
      'balance': balance,
      'registered': registered,
      'pastApplicantName': pastApplicantName,
      'pastApplicantAddress': pastApplicantAddress,
      'pastApplicantContact': pastApplicantContact,
      'applicantStatus': applicantStatus,
    }.withoutNulls,
  );

  return firestoreData;
}

class ContractRecordDocumentEquality implements Equality<ContractRecord> {
  const ContractRecordDocumentEquality();

  @override
  bool equals(ContractRecord? e1, ContractRecord? e2) {
    const listEquality = ListEquality();
    return e1?.contractID == e2?.contractID &&
        e1?.tombLocation == e2?.tombLocation &&
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
        e1?.pastApplicantName == e2?.pastApplicantName &&
        e1?.pastApplicantAddress == e2?.pastApplicantAddress &&
        e1?.pastApplicantContact == e2?.pastApplicantContact &&
        e1?.applicantStatus == e2?.applicantStatus &&
        listEquality.equals(e1?.decFullName, e2?.decFullName) &&
        e1?.lotLoccation == e2?.lotLoccation &&
        e1?.leesseContactNo == e2?.leesseContactNo &&
        e1?.location == e2?.location &&
        e1?.contractidString == e2?.contractidString &&
        e1?.dateEffective == e2?.dateEffective &&
        listEquality.equals(e1?.dateofdeath, e2?.dateofdeath) &&
        e1?.nitcheid == e2?.nitcheid &&
        e1?.nitcheidString == e2?.nitcheidString &&
        e1?.dummy == e2?.dummy &&
        e1?.latestContNum == e2?.latestContNum &&
        e1?.latestAddress == e2?.latestAddress &&
        e1?.latestDeceased == e2?.latestDeceased &&
        listEquality.equals(e1?.appliContNumb, e2?.appliContNumb) &&
        e1?.lotstatus == e2?.lotstatus &&
        e1?.dateofexpiration == e2?.dateofexpiration &&
        e1?.contractstatus == e2?.contractstatus &&
        listEquality.equals(e1?.burialinternment, e2?.burialinternment) &&
        e1?.initialfee == e2?.initialfee &&
        listEquality.equals(e1?.remainingbalances, e2?.remainingbalances) &&
        e1?.lotpicture == e2?.lotpicture &&
        e1?.years == e2?.years &&
        e1?.dateadded == e2?.dateadded &&
        e1?.amountINT == e2?.amountINT &&
        e1?.totalContraBalance == e2?.totalContraBalance &&
        e1?.stringEffectivedate == e2?.stringEffectivedate &&
        e1?.stringExpirationdate == e2?.stringExpirationdate &&
        e1?.email == e2?.email &&
        e1?.displayName == e2?.displayName &&
        e1?.photoUrl == e2?.photoUrl &&
        e1?.uid == e2?.uid &&
        e1?.createdTime == e2?.createdTime &&
        e1?.phoneNumber == e2?.phoneNumber &&
        e1?.balance == e2?.balance &&
        e1?.registered == e2?.registered;
  }

  @override
  int hash(ContractRecord? e) => const ListEquality().hash([
        e?.contractID,
        e?.tombLocation,
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
        e?.pastApplicantName,
        e?.pastApplicantAddress,
        e?.pastApplicantContact,
        e?.applicantStatus,
        e?.decFullName,
        e?.lotLoccation,
        e?.leesseContactNo,
        e?.location,
        e?.contractidString,
        e?.dateEffective,
        e?.dateofdeath,
        e?.nitcheid,
        e?.nitcheidString,
        e?.dummy,
        e?.latestContNum,
        e?.latestAddress,
        e?.latestDeceased,
        e?.appliContNumb,
        e?.lotstatus,
        e?.dateofexpiration,
        e?.contractstatus,
        e?.burialinternment,
        e?.initialfee,
        e?.remainingbalances,
        e?.lotpicture,
        e?.years,
        e?.dateadded,
        e?.amountINT,
        e?.totalContraBalance,
        e?.stringEffectivedate,
        e?.stringExpirationdate,
        e?.email,
        e?.displayName,
        e?.photoUrl,
        e?.uid,
        e?.createdTime,
        e?.phoneNumber,
        e?.balance,
        e?.registered
      ]);

  @override
  bool isValidKey(Object? o) => o is ContractRecord;
}
