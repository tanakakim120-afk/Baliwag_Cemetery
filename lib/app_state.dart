import 'package:flutter/material.dart';
import '/backend/backend.dart';
import '/backend/api_requests/api_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'flutter_flow/flutter_flow_util.dart';
import 'dart:convert';

class FFAppState extends ChangeNotifier {
  static FFAppState _instance = FFAppState._internal();

  factory FFAppState() {
    return _instance;
  }

  FFAppState._internal();

  static void reset() {
    _instance = FFAppState._internal();
  }

  Future initializePersistedState() async {
    prefs = await SharedPreferences.getInstance();

    // Initialize nitcheid with persistence
    _safeInit(() {
      _nitcheid =
          prefs.getInt('ff_nitcheid') ?? 1; // Default to 1 if no stored value
      print('App State: nitcheid initialized to $_nitcheid');
    });

    // Initialize contractid with persistence
    _safeInit(() {
      _contractid =
          prefs.getInt('ff_contractid') ?? 1; // Default to 1 if no stored value
      print('App State: contractid initialized to $_contractid');
    });

    _safeInit(() {
      _nitcheprice = prefs.getDouble('ff_nitcheprice') ?? _nitcheprice;
    });
    _safeInit(() {
      _lotprice = prefs.getDouble('ff_lotprice') ?? _lotprice;
    });

    // Verify persistence is working
    print('App State: Persistence initialized successfully');
    print(
        'App State: Current values - nitcheid: $_nitcheid, contractid: $_contractid');

    // Test persistence by saving current values
    await persistCurrentState();

    // Sync IDs with database to prevent duplicates
    await syncIdsWithDatabase();
  }

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  // Method to manually persist current state
  Future<void> persistCurrentState() async {
    if (prefs != null) {
      await prefs.setInt('ff_nitcheid', _nitcheid);
      await prefs.setInt('ff_contractid', _contractid);
      print(
          'App State: Manually persisted - nitcheid: $_nitcheid, contractid: $_contractid');
    }
  }

  // Method to sync app state IDs with database to prevent duplicates
  Future<void> syncIdsWithDatabase() async {
    try {
      print('App State: Starting ID sync with database...');

      // Sync contract ID
      await getNextAvailableContractId();

      // Sync nitche ID
      await getNextAvailableNitcheId();

      print('App State: ID sync completed successfully');
    } catch (e) {
      print('App State: Error during ID sync: $e');
    }
  }

  late SharedPreferences prefs;

  int _Integer = 0;
  int get Integer => _Integer;
  set Integer(int value) {
    _Integer = value;
  }

  int _nitcheid = 1; // Start at 1 for first nitche
  int get nitcheid => _nitcheid;
  set nitcheid(int value) {
    _nitcheid = value;
    _persistNitcheId();
  }

  // Method to increment nitcheid for new nitches (using contract ID logic but separate variable)
  int getNextNitcheId() {
    final int currentId = _nitcheid;
    _nitcheid++;
    _persistNitcheId();
    print('App State: Generated new nitche ID: $currentId');
    return currentId;
  }

  // Method to get the next available nitche ID by checking database
  Future<int> getNextAvailableNitcheId() async {
    try {
      // Query the database to find the highest existing nitche ID
      final contracts = await queryContractRecordOnce(
          queryBuilder: (contractRecord) => contractRecord
              .where('type', isEqualTo: 'nitche')
              .orderBy('nitcheid', descending: true));

      int maxId = 0;
      if (contracts.isNotEmpty) {
        maxId = contracts.first.nitcheid ?? 0;
      }

      // Set nitche ID to max + 1 to avoid duplicates
      _nitcheid = maxId + 1;
      _persistNitcheId();
      print(
          'App State: Synced nitche ID to: $_nitcheid (max nitcheid in DB: $maxId)');
      return _nitcheid;
    } catch (e) {
      print('App State: Error syncing nitche ID: $e');
      // Fallback to current method
      return getNextNitcheId();
    }
  }

  // Helper method to persist nitcheid
  Future<void> _persistNitcheId() async {
    if (prefs != null) {
      await prefs.setInt('ff_nitcheid', _nitcheid);
      print('App State: Persisted nitcheid: $_nitcheid');
    }
  }

  bool _ShowComponent = false;
  bool get ShowComponent => _ShowComponent;
  set ShowComponent(bool value) {
    _ShowComponent = value;
  }

  bool _searchLot = false;
  bool get searchLot => _searchLot;
  set searchLot(bool value) {
    _searchLot = value;
  }

  List<String> _originalList = [];
  List<String> get originalList => _originalList;
  set originalList(List<String> value) {
    _originalList = value;
  }

  void addToOriginalList(String value) {
    originalList.add(value);
  }

  void removeFromOriginalList(String value) {
    originalList.remove(value);
  }

  void removeAtIndexFromOriginalList(int index) {
    originalList.removeAt(index);
  }

  void updateOriginalListAtIndex(
    int index,
    String Function(String) updateFn,
  ) {
    originalList[index] = updateFn(_originalList[index]);
  }

  void insertAtIndexInOriginalList(int index, String value) {
    originalList.insert(index, value);
  }

  List<String> _filteredList = [];
  List<String> get filteredList => _filteredList;
  set filteredList(List<String> value) {
    _filteredList = value;
  }

  void addToFilteredList(String value) {
    filteredList.add(value);
  }

  void removeFromFilteredList(String value) {
    filteredList.remove(value);
  }

  void removeAtIndexFromFilteredList(int index) {
    filteredList.removeAt(index);
  }

  void updateFilteredListAtIndex(
    int index,
    String Function(String) updateFn,
  ) {
    filteredList[index] = updateFn(_filteredList[index]);
  }

  void insertAtIndexInFilteredList(int index, String value) {
    filteredList.insert(index, value);
  }

  String _searchQuery = '';
  String get searchQuery => _searchQuery;
  set searchQuery(String value) {
    _searchQuery = value;
  }

  int _contractid = 1; // Start at 1 for first contract
  int get contractid => _contractid;
  set contractid(int value) {
    _contractid = value;
    _persistContractId();
  }

  int _newVaultCount = 0;
  int get newVaultCount => _newVaultCount;
  set newVaultCount(int value) {
    _newVaultCount = value;
    notifyListeners();
  }

  DateTime _vaultNotificationBaseline = DateTime.now();
  DateTime get vaultNotificationBaseline => _vaultNotificationBaseline;
  set vaultNotificationBaseline(DateTime value) {
    _vaultNotificationBaseline = value;
    notifyListeners();
  }

  void clearVaultNotification() {
    _newVaultCount = 0;
    _vaultNotificationBaseline = DateTime.now();
    notifyListeners();
  }

  // Method to increment contractid for new contracts
  int getNextContractId() {
    final int currentId = _contractid;
    _contractid++;
    _persistContractId();
    print('App State: Generated new contract ID: $currentId');
    return currentId;
  }

  // Method to get the next available contract ID by checking database
  Future<int> getNextAvailableContractId() async {
    try {
      // Query the database to find the highest existing contract ID
      final contracts = await queryContractRecordOnce(
        queryBuilder: (contractRecord) =>
            contractRecord.orderBy('contractID', descending: true).limit(1),
      );

      int maxId = 0;
      if (contracts.isNotEmpty) {
        maxId = contracts.first.contractID ?? 0;
      }

      // Set app state to max + 1 to avoid duplicates
      _contractid = maxId + 1;
      _persistContractId();
      print(
          'App State: Synced contract ID to: $_contractid (max in DB: $maxId)');
      return _contractid;
    } catch (e) {
      print('App State: Error syncing contract ID: $e');
      // Fallback to current method
      return getNextContractId();
    }
  }

  // Helper method to persist contractid
  Future<void> _persistContractId() async {
    if (prefs != null) {
      await prefs.setInt('ff_contractid', _contractid);
      print('App State: Persisted contractid: $_contractid');
    }
  }

  bool _expirationDate = false;
  bool get expirationDate => _expirationDate;
  set expirationDate(bool value) {
    _expirationDate = value;
  }

  DateTime? _expirationDateBalance =
      DateTime.fromMillisecondsSinceEpoch(1871811960000);
  DateTime? get expirationDateBalance => _expirationDateBalance;
  set expirationDateBalance(DateTime? value) {
    _expirationDateBalance = value;
  }

  double _nitcheprice = 0.0;
  double get nitcheprice => _nitcheprice;
  set nitcheprice(double value) {
    _nitcheprice = value;
    prefs.setDouble('ff_nitcheprice', value);
  }

  double _lotprice = 0.0;
  double get lotprice => _lotprice;
  set lotprice(double value) {
    _lotprice = value;
    prefs.setDouble('ff_lotprice', value);
  }

  dynamic _chartData;
  dynamic get chartData => _chartData;
  set chartData(dynamic value) {
    _chartData = value;
  }

  DateTime? _searchStartDate;
  DateTime? get searchStartDate => _searchStartDate;
  set searchStartDate(DateTime? value) {
    _searchStartDate = value;
  }

  String _searchEndDate = '';
  String get searchEndDate => _searchEndDate;
  set searchEndDate(String value) {
    _searchEndDate = value;
  }

  bool _searchDeceasedadmin = false;
  bool get searchDeceasedadmin => _searchDeceasedadmin;
  set searchDeceasedadmin(bool value) {
    _searchDeceasedadmin = value;
  }

  String _qrcode = '';
  String get qrcode => _qrcode;
  set qrcode(String value) {
    _qrcode = value;
  }
}

void _safeInit(Function() initializeField) {
  try {
    initializeField();
  } catch (_) {}
}

Future _safeInitAsync(Function() initializeField) async {
  try {
    await initializeField();
  } catch (_) {}
}
