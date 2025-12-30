import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

/// transactions
class TransactionsRecord extends FirestoreRecord {
  TransactionsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "uID" field.
  String? _uID;
  String get uID => _uID ?? '';
  bool hasUID() => _uID != null;

  // "transaction_date" field.
  DateTime? _transactionDate;
  DateTime? get transactionDate => _transactionDate;
  bool hasTransactionDate() => _transactionDate != null;

  // "name" field.
  String? _name;
  String get name => _name ?? '';
  bool hasName() => _name != null;

  // "status" field.
  String? _status;
  String get status => _status ?? '';
  bool hasStatus() => _status != null;

  // "loc" field.
  String? _loc;
  String get loc => _loc ?? '';
  bool hasLoc() => _loc != null;

  // "payment_method" field.
  String? _paymentMethod;
  String get paymentMethod => _paymentMethod ?? '';
  bool hasPaymentMethod() => _paymentMethod != null;

  // "rem_balance" field.
  String? _remBalance;
  String get remBalance => _remBalance ?? '';
  bool hasRemBalance() => _remBalance != null;

  // "type" field.
  String? _type;
  String get type => _type ?? '';
  bool hasType() => _type != null;

  // "isClicked" field.
  bool? _isClicked;
  bool get isClicked => _isClicked ?? false;
  bool hasIsClicked() => _isClicked != null;

  // "email" field.
  String? _email;
  String get email => _email ?? '';
  bool hasEmail() => _email != null;

  // "address" field.
  String? _address;
  String get address => _address ?? '';
  bool hasAddress() => _address != null;

  // "Stringtransactiondate" field.
  String? _stringtransactiondate;
  String get stringtransactiondate => _stringtransactiondate ?? '';
  bool hasStringtransactiondate() => _stringtransactiondate != null;

  // "amount" field.
  int? _amount;
  int get amount => _amount ?? 0;
  bool hasAmount() => _amount != null;

  // "loctype" field.
  String? _loctype;
  String get loctype => _loctype ?? '';
  bool hasLoctype() => _loctype != null;

  // "paymenttype" field.
  String? _paymenttype;
  String get paymenttype => _paymenttype ?? '';
  bool hasPaymenttype() => _paymenttype != null;

  // "tld" field.
  String? _tld;
  String get tld => _tld ?? '';
  bool hasTld() => _tld != null;

  // "deceased" field.
  String? _deceased;
  String get deceased => _deceased ?? '';
  bool hasDeceased() => _deceased != null;

  // "contract_id" field.
  String? _contractId;
  String get contractId => _contractId ?? '';
  bool hasContractId() => _contractId != null;

  void _initializeFields() {
    _uID = snapshotData['uID'] as String?;
    _transactionDate = snapshotData['transaction_date'] as DateTime?;
    _name = snapshotData['name'] as String?;
    _status = snapshotData['status'] as String?;
    _loc = snapshotData['loc'] as String?;
    _paymentMethod = snapshotData['payment_method'] as String?;
    _remBalance = snapshotData['rem_balance'] as String?;
    _type = snapshotData['type'] as String?;
    _isClicked = snapshotData['isClicked'] as bool?;
    _email = snapshotData['email'] as String?;
    _address = snapshotData['address'] as String?;
    _stringtransactiondate = snapshotData['Stringtransactiondate'] as String?;
    _amount = castToType<int>(snapshotData['amount']);
    _loctype = snapshotData['loctype'] as String?;
    _paymenttype = snapshotData['paymenttype'] as String?;
    _tld = snapshotData['tld'] as String?;
    _deceased = snapshotData['deceased'] as String?;
    _contractId = snapshotData['contract_id'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('transactions');

  static Stream<TransactionsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => TransactionsRecord.fromSnapshot(s));

  static Future<TransactionsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => TransactionsRecord.fromSnapshot(s));

  static TransactionsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      TransactionsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static TransactionsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      TransactionsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'TransactionsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is TransactionsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createTransactionsRecordData({
  String? uID,
  DateTime? transactionDate,
  String? name,
  String? status,
  String? loc,
  String? paymentMethod,
  String? remBalance,
  String? type,
  bool? isClicked,
  String? email,
  String? address,
  String? stringtransactiondate,
  int? amount,
  String? loctype,
  String? paymenttype,
  String? tld,
  String? deceased,
  String? contractId,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'uID': uID,
      'transaction_date': transactionDate,
      'name': name,
      'status': status,
      'loc': loc,
      'payment_method': paymentMethod,
      'rem_balance': remBalance,
      'type': type,
      'isClicked': isClicked,
      'email': email,
      'address': address,
      'Stringtransactiondate': stringtransactiondate,
      'amount': amount,
      'loctype': loctype,
      'paymenttype': paymenttype,
      'tld': tld,
      'deceased': deceased,
      'contract_id': contractId,
    }.withoutNulls,
  );

  return firestoreData;
}

class TransactionsRecordDocumentEquality
    implements Equality<TransactionsRecord> {
  const TransactionsRecordDocumentEquality();

  @override
  bool equals(TransactionsRecord? e1, TransactionsRecord? e2) {
    return e1?.uID == e2?.uID &&
        e1?.transactionDate == e2?.transactionDate &&
        e1?.name == e2?.name &&
        e1?.status == e2?.status &&
        e1?.loc == e2?.loc &&
        e1?.paymentMethod == e2?.paymentMethod &&
        e1?.remBalance == e2?.remBalance &&
        e1?.type == e2?.type &&
        e1?.isClicked == e2?.isClicked &&
        e1?.email == e2?.email &&
        e1?.address == e2?.address &&
        e1?.stringtransactiondate == e2?.stringtransactiondate &&
        e1?.amount == e2?.amount &&
        e1?.loctype == e2?.loctype &&
        e1?.paymenttype == e2?.paymenttype &&
        e1?.tld == e2?.tld &&
        e1?.deceased == e2?.deceased &&
        e1?.contractId == e2?.contractId;
  }

  @override
  int hash(TransactionsRecord? e) => const ListEquality().hash([
        e?.uID,
        e?.transactionDate,
        e?.name,
        e?.status,
        e?.loc,
        e?.paymentMethod,
        e?.remBalance,
        e?.type,
        e?.isClicked,
        e?.email,
        e?.address,
        e?.stringtransactiondate,
        e?.amount,
        e?.loctype,
        e?.paymenttype,
        e?.tld,
        e?.deceased,
        e?.contractId
      ]);

  @override
  bool isValidKey(Object? o) => o is TransactionsRecord;
}
