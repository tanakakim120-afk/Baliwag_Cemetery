import '/backend/backend.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_data_table.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import '/flutter_flow/upload_data.dart';
import '/backend/firebase_storage/storage.dart';
import '/admin_side/shared/deceased_entry.dart';
import '/custom_code/logo_utils.dart';
import '/custom_code/dashboard_theme.dart';
import 'dart:ui';
import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'manage_contract_model.dart';
export 'manage_contract_model.dart';

class ManageContractWidget extends StatefulWidget {
  const ManageContractWidget({super.key});

  static String routeName = 'ManageContract';
  static String routePath = '/manageContract';

  @override
  State<ManageContractWidget> createState() => _ManageContractWidgetState();
}

class _ManageContractWidgetState extends State<ManageContractWidget> {
  late ManageContractModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ManageContractModel());

    // Initialize Stripe
    _initializeStripe();

    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();

    // Initialize pay balance modal controllers
    _model.payerNameController ??= TextEditingController();
    _model.amountController ??= TextEditingController();
    _model.payerNameFocusNode ??= FocusNode();
    _model.amountFocusNode ??= FocusNode();

    // Initialize renew contract modal controllers
    _model.renewalFeeController ??= TextEditingController();
    _model.renewalFeeFocusNode ??= FocusNode();
    _model.contractDurationController ??= TextEditingController();
    _model.totalContractValueController ??= TextEditingController();
    _model.contractDurationFocusNode ??= FocusNode();
    _model.totalContractValueFocusNode ??= FocusNode();

    // Add listener to text controller for real-time search
    _model.textController!.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await _processExpiredContracts();
      safeSetState(() {});
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  // Initialize Stripe with publishable key
  void _initializeStripe() {
    try {
      Stripe.publishableKey =
          'pk_test_51RTQKu4DfUiWZHPINZ8dyjbBV6GoaY27XUdepPsbqYnWZUnfrKs4oR2kvNhuLsdArbhx0J335KmpaF0nf7bI9aaW005eomnkfx';
      print('Stripe initialized successfully');
    } catch (e) {
      print('Error initializing Stripe: $e');
    }
  }

  // Process expired contracts and create vault documents
  Future<void> _processExpiredContracts() async {
    try {
      final now = DateTime.now();

      // Query all contracts that have expired
      final expiredContracts = await queryContractRecordOnce(
        queryBuilder: (contractRecord) {
          return contractRecord.where('dateofexpiration', isLessThan: now);
        },
      );

      print('Found ${expiredContracts.length} expired contracts to process');

      for (final contract in expiredContracts) {
        print(
          'Processing expired contract ${contract.contractID} of type: ${contract.type}',
        );
        print('Contract expiration date: ${contract.dateofexpiration}');
        print('Current date: $now');
        await _createVaultFromExpiredContract(contract);
      }
    } catch (e) {
      print('Error processing expired contracts: $e');
    }
  }

  // Create vault document from expired contract
  Future<void> _createVaultFromExpiredContract(ContractRecord contract) async {
    try {
      print(
        'Processing expired contract ${contract.contractID} of type: ${contract.type}',
      );

      // First, always clean up the expired contract regardless of other conditions
      await _updateExpiredContract(contract);
      print('Cleaned up expired contract ${contract.contractID}');

      // Then, attempt to create vault if conditions are met
      // Check if vault already exists for this contract
      final existingVaults = await queryVaultRecordOnce(
        queryBuilder: (vaultRecord) {
          return vaultRecord.where('vaultID', isEqualTo: contract.reference);
        },
      );

      if (existingVaults.isNotEmpty) {
        print(
          'Vault already exists for contract ${contract.contractID} - skipping vault creation',
        );
        return;
      }

      // For Lot contracts, check if applicant and deceased details are available for vault creation
      if (contract.type?.toLowerCase() == 'lot') {
        final hasApplicantDetails = contract.applicantName != null &&
            contract.applicantName!.isNotEmpty;
        final hasDeceasedDetails =
            contract.decFullName != null && contract.decFullName!.isNotEmpty;

        if (!hasApplicantDetails || !hasDeceasedDetails) {
          print(
            'Skipping vault creation for Lot contract ${contract.contractID} - missing applicant or deceased details',
          );
          return;
        }
      }

      // Create vault document with transferred data
      final vaultData = createVaultRecordData(
        // Deceased details
        deceasedname: contract.decFullName,
        deceaseddateofdeath: contract.dateofdeath,
        deceasedburialinterment: contract.burialinternment,
        // Applicant details
        applicantname: contract.applicantName,
        applicantaddress: contract.applcantAddress,
        applicantcontactnumber: contract.applicantContactNumber,
        // Vault metadata
        status: 'active',
        timestamp: DateTime.now(),
        vaultID: contract.reference,
        deceasedIDstring: contract.contractidString,
        stringvaultadded:
            'Vault created from expired contract ${contract.contractID}',
      );

      await VaultRecord.collection.add(vaultData);
      print('Created vault for expired contract ${contract.contractID}');
    } catch (e) {
      print('Error processing expired contract ${contract.contractID}: $e');
    }
  }

  // Update expired contract based on type
  Future<void> _updateExpiredContract(ContractRecord contract) async {
    try {
      print(
        'Updating expired contract ${contract.contractID} of type: ${contract.type}',
      );
      Map<String, dynamic> updateData = {};

      if (contract.type?.toLowerCase() == 'nitche') {
        print('Processing NITCHE contract - keeping only Location and amount');
        print('Nitche contract ID: ${contract.contractID}');
        print('Nitche location: ${contract.location}');
        print('Nitche amount: ${contract.amount}');
        // For NITCHE: keep only Location and amount, null everything else
        updateData = {
          'tombLocation': null,
          'OR': null,
          'TIN': null,
          'ResidentCert': null,
          'placeIssued': null,
          'dateIssued': null,
          'leessee': null,
          'street': null,
          'status': null,
          'measurement': null,
          'proofoflease': null,
          'applicantName': null,
          'applcantAddress': null,
          'applicantContactNumber': null,
          'pastApplicantName': null,
          'pastApplicantAddress': null,
          'pastApplicantContact': null,
          'applicantStatus': null,
          'decFullName': null,
          'lotLoccation': null,
          'leesseContactNo': null,
          'contractID': null,
          'contractidString': null,
          'dateEffective': null,
          'dateofdeath': null,
          'nitcheid': null,
          'nitcheidString': null,
          'dummy': null,
          'latestContNum': null,
          'latestAddress': null,
          'latestDeceased': null,
          'appliContNumb': null,
          'dateofexpiration': null,
          'contractstatus': null,
          'burialinternment': null,
          'initialfee': null,
          'remainingbalances': null,
          'lotpicture': null,
          'years': null,
          'dateadded': null,
          'amountINT': null,
          'totalContraBalance': null,
          'stringEffectivedate': null,
          'stringExpirationdate': null,
          'email': null,
          'display_name': null,
          'photo_url': null,
          'uid': null,
          'created_time': null,
          'phone_number': null,
          'balance': null,
          'registered': null,
          'lastUpdated': null,
          'timestamp': null,
          // Keep Location and amount
          'Location': contract.location,
          'amount': contract.amount,
        };
      } else if (contract.type?.toLowerCase() == 'lot') {
        print(
          'Processing LOT contract - keeping measurement, amount, street, lotstatus, location',
        );
        // For LOT: keep measurement, amount, street, lotstatus, location, null everything else
        // Specifically clearing: dateofexpiration, OR, ResidentCert, TIN, dateEffective, dateIssued, leessee, years
        updateData = {
          'tombLocation': null,
          'OR': null,
          'TIN': null,
          'ResidentCert': null,
          'placeIssued': null,
          'dateIssued': null,
          'leessee': null,
          'status': null,
          'proofoflease': null,
          'applicantName': null,
          'applcantAddress': null,
          'applicantContactNumber': null,
          'pastApplicantName': null,
          'pastApplicantAddress': null,
          'pastApplicantContact': null,
          'applicantStatus': null,
          'decFullName': null,
          'lotLoccation': null,
          'leesseContactNo': null,
          'contractidString': null,
          'dateEffective': null,
          'dateofdeath': null,
          'nitcheid': null,
          'nitcheidString': null,
          'dummy': null,
          'latestContNum': null,
          'latestAddress': null,
          'latestDeceased': null,
          'appliContNumb': null,
          'dateofexpiration': null,
          'contractstatus': null,
          'burialinternment': null,
          'initialfee': null,
          'remainingbalances': null,
          'lotpicture': null,
          'years': null,
          'dateadded': null,
          'amountINT': null,
          'totalContraBalance': null,
          'stringEffectivedate': null,
          'stringExpirationdate': null,
          'email': null,
          'display_name': null,
          'photo_url': null,
          'uid': null,
          'created_time': null,
          'phone_number': null,
          'balance': null,
          'registered': null,
          'contractID': null,
          // Keep measurement, amount, street, lotstatus, location
          'measurement': contract.measurement,
          'amount': contract.amount,
          'street': contract.street,
          'lotstatus': contract.lotstatus,
          'Location': contract.location,
        };
      }

      if (updateData.isNotEmpty) {
        print(
          'Updating contract ${contract.contractID} with ${updateData.length} fields',
        );
        await contract.reference.update(updateData);
        print(
          'Successfully updated expired contract ${contract.contractID} based on type ${contract.type}',
        );
        print('Updated ${updateData.length} fields');
      } else {
        print(
          'No update data for contract ${contract.contractID} - type: ${contract.type}',
        );
      }
    } catch (e) {
      print('Error updating expired contract ${contract.contractID}: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return StreamBuilder<List<ContractRecord>>(
      stream: queryContractRecord(
        queryBuilder: (contractRecord) {
          print('Querying contracts with future expiration dates...');
          final now = DateTime.now();
          // Add 1 day buffer to handle timezone issues
          final bufferDate = now.subtract(Duration(days: 1));
          return contractRecord.where(
            'dateofexpiration',
            isGreaterThan: bufferDate,
          );
        },
      ),
      builder: (context, snapshot) {
        // Debug: Print snapshot information
        print(
          'Snapshot state: hasData=${snapshot.hasData}, hasError=${snapshot.hasError}, error=${snapshot.error}',
        );

        // Customize what your widget looks like when it's loading.
        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 60.0,
                    height: 60.0,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        DashboardTheme.primary,
                      ),
                      strokeWidth: 3.0,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Loading Active Contracts...',
                    style: DashboardTheme.bodyText,
                  ),
                ],
              ),
            ),
          );
        }
        List<ContractRecord> allContractList = snapshot.data!;

        // Debug: Print the data we're getting
        print('Total contracts found: ${allContractList.length}');
        for (var contract in allContractList) {
          print(
            'Contract: type=${contract.type}, status=${contract.status}, contractID=${contract.contractID}',
          );
        }

        // Debug: Check what filter is currently selected
        print('Current filter selected: ${_model.selectedFilter}');

        // Debug: Check contract types
        final nitcheContracts =
            allContractList.where((c) => c.type == 'nitche').toList();
        final lotContracts =
            allContractList.where((c) => c.type == 'lot').toList();
        print(
          'Contract types - Nitche: ${nitcheContracts.length}, Lot: ${lotContracts.length}',
        );

        // Filter the data based on selected filter and search text
        List<ContractRecord> filteredContractList = allContractList.where((
          contract,
        ) {
          // Apply status filter based on contract status
          bool passesStatusFilter = true;
          if (_model.selectedFilter != null && _model.selectedFilter != 'all') {
            final now = DateTime.now();
            // Add 1 day buffer to handle timezone issues
            final bufferDate = now.subtract(Duration(days: 1));
            final isOngoing = contract.dateofexpiration != null &&
                bufferDate.isBefore(contract.dateofexpiration!);

            if (_model.selectedFilter == 'active') {
              passesStatusFilter = isOngoing; // Ongoing = active
            } else if (_model.selectedFilter == 'expired') {
              passesStatusFilter = !isOngoing; // Not ongoing = expired
            }
          }

          if (!passesStatusFilter) return false;

          // Apply contract type filter
          bool passesTypeFilter = true;
          if (_model.selectedContractType != null &&
              _model.selectedContractType != 'all') {
            if (_model.selectedContractType == 'active') {
              // Show only active contracts (ongoing contracts)
              final now = DateTime.now();
              final bufferDate = now.subtract(Duration(days: 1));
              final isOngoing = contract.dateofexpiration != null &&
                  bufferDate.isBefore(contract.dateofexpiration!);
              passesTypeFilter = isOngoing;
            } else {
              // Filter by specific contract type
              passesTypeFilter = contract.type.toLowerCase() ==
                  _model.selectedContractType!.toLowerCase();
            }
          }

          if (!passesTypeFilter) return false;

          // Apply date range filter based on dateofexpiration
          bool passesDateFilter = true;
          if (_model.startDate != null || _model.endDate != null) {
            // Only apply date filter if the contract has a dateofexpiration
            if (contract.dateofexpiration != null) {
              // Check if dateofexpiration is on or after startDate
              if (_model.startDate != null) {
                final startOfDay = DateTime(
                  _model.startDate!.year,
                  _model.startDate!.month,
                  _model.startDate!.day,
                );
                if (contract.dateofexpiration!.isBefore(startOfDay)) {
                  passesDateFilter = false;
                }
              }

              // Check if dateofexpiration is on or before endDate
              if (_model.endDate != null && passesDateFilter) {
                final endOfDay = DateTime(
                  _model.endDate!.year,
                  _model.endDate!.month,
                  _model.endDate!.day,
                  23,
                  59,
                  59,
                );
                if (contract.dateofexpiration!.isAfter(endOfDay)) {
                  passesDateFilter = false;
                }
              }
            } else {
              // If no dateofexpiration, exclude from date-filtered results
              passesDateFilter = false;
            }
          }

          if (!passesDateFilter) return false;

          // Then apply search filter
          if (_model.textController?.text.isNotEmpty == true) {
            final searchText = _model.textController!.text.toLowerCase();

            // Use mapping methods for consistent search
            final contractNumber = _getContractNumber(contract).toLowerCase();
            final location = _getContractLocation(contract).toLowerCase();
            final type = contract.type.toLowerCase();
            final status = contract.status.toLowerCase();
            final amount = contract.amount ?? '0';
            final lessee = contract.leessee?.toLowerCase() ?? '';

            // Search in multiple fields
            bool matchesSearch = contractNumber.contains(searchText) ||
                location.contains(searchText) ||
                type.contains(searchText) ||
                status.contains(searchText) ||
                amount.contains(searchText) ||
                lessee.contains(searchText);

            // Search based on contract status
            if (searchText == 'active' || searchText == 'expired') {
              final now = DateTime.now();
              // Add 1 day buffer to handle timezone issues
              final bufferDate = now.subtract(Duration(days: 1));
              final isOngoing = contract.dateofexpiration != null &&
                  bufferDate.isBefore(contract.dateofexpiration!);

              if (searchText == 'active') {
                matchesSearch = isOngoing; // Ongoing = active
              } else if (searchText == 'expired') {
                matchesSearch = !isOngoing; // Not ongoing = expired
              }
            }

            return matchesSearch;
          }

          return true;
        }).toList();

        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Scaffold(
            key: scaffoldKey,
            backgroundColor: DashboardTheme.background,
            body: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Sidebar
                if (responsiveVisibility(
                  context: context,
                  phone: false,
                  tablet: false,
                ))
                  Container(
                    width: 320,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: DashboardTheme.surface,
                      boxShadow: DashboardTheme.mainShadow,
                    ),
                    child: Column(
                      children: [
                        // Logo and Title Section
                        Container(
                          padding: EdgeInsets.all(
                            DashboardTheme.sectionSpacing,
                          ),
                          child: Column(
                            children: [
                              // Logo Container with gradient and shadow
                              Container(
                                width: 160,
                                height: 160,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    DashboardTheme.cardRadius,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: DashboardTheme.primary.withOpacity(
                                        0.1,
                                      ),
                                      blurRadius: 20,
                                      offset: Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.asset(
                                    'assets/images/logo.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              SizedBox(height: 16),
                              // Main Title
                              Text(
                                'BALIWAG PUBLIC CEMETERY',
                                style: DashboardTheme.sectionHeader.copyWith(
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),

                        Divider(height: 1, color: DashboardTheme.border),

                        // Navigation Section
                        Expanded(
                          child: SingleChildScrollView(
                            padding: EdgeInsets.symmetric(
                              horizontal: DashboardTheme.elementSpacing,
                              vertical: 8,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: DashboardTheme.sectionSpacing),

                                // Platform Navigation Section
                                _buildSectionTitle('Platform Navigation'),
                                SizedBox(height: DashboardTheme.elementSpacing),
                                _buildNavItem(
                                  icon: Icons.dashboard_rounded,
                                  title: 'Dashboard',
                                  onTap: () => context.pushNamed('dashboard'),
                                ),

                                SizedBox(
                                  height: DashboardTheme.containerPadding,
                                ),

                                // Action Section
                                _buildSectionTitle('Action'),
                                SizedBox(height: DashboardTheme.elementSpacing),
                                _buildNavItem(
                                  icon: Icons.description_rounded,
                                  title: 'Manage Contract',
                                  isActive: true,
                                  onTap: () {},
                                ),
                                _buildNavItem(
                                  icon: Icons.apartment_rounded,
                                  title: 'Apartment Niche',
                                  onTap: () =>
                                      context.pushNamed('apartmentList'),
                                ),
                                _buildNavItem(
                                  icon: Icons.add_location_alt_rounded,
                                  title: 'Create Plot',
                                  onTap: () =>
                                      context.pushNamed('burialLotsList'),
                                ),
                                _buildNavItem(
                                  icon: Icons.inbox_rounded,
                                  title: 'Vault',
                                  onTap: () {
                                    FFAppState().clearVaultNotification();
                                    context.pushNamed('VaultList');
                                  },
                                  notificationCount: FFAppState().newVaultCount,
                                ),
                                _buildNavItem(
                                  icon: Icons.people_rounded,
                                  title: 'User Management',
                                  onTap: () => context.pushNamed('userlist'),
                                ),
                                _buildNavItem(
                                  icon: Icons.receipt_long_rounded,
                                  title: 'Transaction',
                                  onTap: () => context.pushNamed('transaction'),
                                ),
                                _buildNavItem(
                                  icon: Icons.history_rounded,
                                  title: 'Audit Trail',
                                  onTap: () => context.pushNamed('audit'),
                                ),
                                _buildNavItem(
                                  icon: Icons.people_outline_rounded,
                                  title: 'Visitor Log',
                                  onTap: () => context.pushNamed('visitorLog'),
                                ),

                                const SizedBox(
                                  height: DashboardTheme.containerPadding,
                                ),

                                // Logout Button
                                Container(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: () async {
                                      await FirebaseAuth.instance.signOut();
                                      context.goNamed('login');
                                    },
                                    icon: Icon(
                                      Icons.logout_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    label: Text(
                                      'Logout',
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFEF4444),
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      minimumSize: const Size(0, 48),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Main Content Area
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: DashboardTheme.background,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(0),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Enhanced Header Section
                        Container(
                          padding: const EdgeInsets.all(
                            DashboardTheme.containerPadding,
                          ),
                          decoration: DashboardTheme.headerDecoration,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title and Description with enhanced styling
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Contract Management',
                                    style: DashboardTheme.pageTitle,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'View and manage all contracts with future expiration dates including niches and lots',
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      color: const Color(0xFF6B7280),
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(
                                height: DashboardTheme.containerPadding,
                              ),

                              // Enhanced Search and Actions Row
                              Row(
                                children: [
                                  // Enhanced Search Bar
                                  Expanded(
                                    child: Container(
                                      height: 48,
                                      decoration:
                                          DashboardTheme.searchBarDecoration,
                                      child: TextFormField(
                                        controller: _model.textController,
                                        obscureText: false,
                                        decoration: InputDecoration(
                                          hintText:
                                              'Search contracts by ID, type, lessee',
                                          hintStyle:
                                              DashboardTheme.caption.copyWith(
                                            color: const Color(0xFF9CA3AF),
                                          ),
                                          border: InputBorder.none,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
                                          prefixIcon: Icon(
                                            Icons.search_rounded,
                                            color: DashboardTheme.secondary,
                                            size: 22,
                                          ),
                                          suffixIcon: _model.textController
                                                      ?.text.isNotEmpty ==
                                                  true
                                              ? IconButton(
                                                  onPressed: () {
                                                    _model.textController
                                                        ?.clear();
                                                  },
                                                  icon: Icon(
                                                    Icons.clear_rounded,
                                                    color: DashboardTheme
                                                        .secondary,
                                                    size: 20,
                                                  ),
                                                )
                                              : null,
                                        ),
                                        style: DashboardTheme.inputText,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: DashboardTheme.sectionSpacing,
                                  ),

                                  // Contract Type Dropdown
                                  Container(
                                    height: 48,
                                    width: 200,
                                    decoration:
                                        DashboardTheme.searchBarDecoration,
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: _model.selectedContractType,
                                        hint: Text(
                                          'All Contract Types',
                                          style:
                                              DashboardTheme.caption.copyWith(
                                            color: const Color(0xFF9CA3AF),
                                          ),
                                        ),
                                        isExpanded: true,
                                        items: [
                                          DropdownMenuItem<String>(
                                            value: 'all',
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.list_alt_rounded,
                                                  color:
                                                      DashboardTheme.secondary,
                                                  size: 18,
                                                ),
                                                const SizedBox(width: 8),
                                                Text('All Contract Types'),
                                              ],
                                            ),
                                          ),
                                          DropdownMenuItem<String>(
                                            value: 'active',
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.check_circle_rounded,
                                                  color:
                                                      const Color(0xFF10B981),
                                                  size: 18,
                                                ),
                                                const SizedBox(width: 8),
                                                Text('Active Contracts'),
                                              ],
                                            ),
                                          ),
                                          DropdownMenuItem<String>(
                                            value: 'nitche',
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.apartment_rounded,
                                                  color:
                                                      const Color(0xFF3B82F6),
                                                  size: 18,
                                                ),
                                                const SizedBox(width: 8),
                                                Text('Nitche Contracts'),
                                              ],
                                            ),
                                          ),
                                          DropdownMenuItem<String>(
                                            value: 'lot',
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.location_on_rounded,
                                                  color:
                                                      const Color(0xFF8B5CF6),
                                                  size: 18,
                                                ),
                                                const SizedBox(width: 8),
                                                Text('Lot Contracts'),
                                              ],
                                            ),
                                          ),
                                        ],
                                        onChanged: (String? value) {
                                          setState(() {
                                            _model.selectedContractType = value;
                                          });
                                        },
                                        style: DashboardTheme.inputText,
                                        icon: Icon(
                                          Icons.keyboard_arrow_down_rounded,
                                          color: DashboardTheme.secondary,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(
                                    width: DashboardTheme.sectionSpacing,
                                  ),

                                  // Date Range Buttons
                                  _buildDateButton(
                                    onPressed: () async {
                                      final DateTime? picked =
                                          await showDatePicker(
                                        context: context,
                                        initialDate:
                                            _model.startDate ?? DateTime.now(),
                                        firstDate: DateTime(2020),
                                        lastDate: DateTime(2050),
                                      );
                                      if (picked != null) {
                                        setState(() {
                                          _model.startDate = picked;
                                        });
                                      }
                                    },
                                    label: 'Start Date',
                                    date: _model.startDate,
                                    icon: Icons.calendar_today_rounded,
                                  ),

                                  const SizedBox(width: 8),

                                  _buildDateButton(
                                    onPressed: () async {
                                      final DateTime? picked =
                                          await showDatePicker(
                                        context: context,
                                        initialDate:
                                            _model.endDate ?? DateTime.now(),
                                        firstDate:
                                            _model.startDate ?? DateTime(2020),
                                        lastDate: DateTime(2050),
                                      );
                                      if (picked != null) {
                                        setState(() {
                                          _model.endDate = picked;
                                        });
                                      }
                                    },
                                    label: 'End Date',
                                    date: _model.endDate,
                                    icon: Icons.calendar_today_rounded,
                                  ),

                                  // Reset Date Filter Button
                                  if (_model.startDate != null ||
                                      _model.endDate != null)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8),
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            _model.startDate = null;
                                            _model.endDate = null;
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.red.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: Colors.red.withOpacity(
                                                0.3,
                                              ),
                                              width: 1,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.clear_rounded,
                                                size: 18,
                                                color: Colors.red.shade700,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Reset Dates',
                                                style: DashboardTheme.caption
                                                    .copyWith(
                                                  color: Colors.red.shade700,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),

                                  const SizedBox(width: 12),

                                  // Enhanced Action Buttons
                                  _buildActionButton(
                                    onPressed: () async {
                                      // Download contract report
                                      await _downloadContractListPDF(
                                        contractData: allContractList,
                                      );
                                    },
                                    icon: Icons.download_rounded,
                                    label: 'Export Report',
                                    isPrimary: true, // Blue like dashboard
                                  ),

                                  // const SizedBox(width: 12),

                                  // // Add Past Contract Button
                                  // _buildActionButton(
                                  //   onPressed: () {
                                  //     _showAddPastContractModal(context);
                                  //   },
                                  //   icon: Icons.add_circle_outline_rounded,
                                  //   label: 'Add Past Contract',
                                  //   isPrimary: false, // Secondary style
                                  // ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: DashboardTheme.sectionSpacing),

                        // Enhanced Data Table Section
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.fromLTRB(
                              DashboardTheme.sectionSpacing,
                              0,
                              DashboardTheme.sectionSpacing,
                              DashboardTheme.sectionSpacing,
                            ),
                            decoration: DashboardTheme.mainContainerDecoration,
                            child: Column(
                              children: [
                                // Filter Summary Header
                                Container(
                                  padding: const EdgeInsets.all(
                                    DashboardTheme.sectionSpacing,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(
                                        DashboardTheme.mainRadius,
                                      ),
                                      topRight: Radius.circular(
                                        DashboardTheme.mainRadius,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      // Filter Summary
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Filter Summary',
                                              style: DashboardTheme.inputText
                                                  .copyWith(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color:
                                                    DashboardTheme.textPrimary,
                                              ),
                                            ),
                                            SizedBox(height: 8),
                                            Wrap(
                                              spacing: 16,
                                              runSpacing: 8,
                                              children: [
                                                if (_model.textController?.text
                                                        .isNotEmpty ==
                                                    true)
                                                  Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 6,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: DashboardTheme
                                                          .primary
                                                          .withOpacity(0.1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                        16,
                                                      ),
                                                    ),
                                                    child: Text(
                                                      'Search: "${_model.textController!.text}"',
                                                      style: DashboardTheme
                                                          .inputText
                                                          .copyWith(
                                                        fontSize: 12,
                                                        color: DashboardTheme
                                                            .primary,
                                                      ),
                                                    ),
                                                  ),
                                                if (_model.selectedFilter !=
                                                        null &&
                                                    _model.selectedFilter !=
                                                        'all')
                                                  Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 6,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: Color(
                                                        0xFF10B981,
                                                      ).withOpacity(0.1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                        16,
                                                      ),
                                                    ),
                                                    child: Text(
                                                      'Status: ${_model.selectedFilter}',
                                                      style: DashboardTheme
                                                          .inputText
                                                          .copyWith(
                                                        fontSize: 12,
                                                        color: Color(
                                                          0xFF10B981,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                if (_model.selectedContractType !=
                                                        null &&
                                                    _model.selectedContractType !=
                                                        'all')
                                                  Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 6,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: Color(
                                                        0xFF3B82F6,
                                                      ).withOpacity(0.1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                        16,
                                                      ),
                                                    ),
                                                    child: Text(
                                                      'Type: ${_model.selectedContractType}',
                                                      style: DashboardTheme
                                                          .inputText
                                                          .copyWith(
                                                        fontSize: 12,
                                                        color: Color(
                                                          0xFF3B82F6,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Record Count
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: DashboardTheme.primary
                                              .withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text(
                                          '${filteredContractList.length} of ${allContractList.length} records',
                                          style:
                                              DashboardTheme.inputText.copyWith(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: DashboardTheme.primary,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 16),
                                      // Status Badge showing Active Contract
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: DashboardTheme.success
                                              .withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: DashboardTheme.success,
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.check_circle_rounded,
                                              color: DashboardTheme.success,
                                              size: 18,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Active Contract',
                                              style: DashboardTheme.inputText
                                                  .copyWith(
                                                color: DashboardTheme.success,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Enhanced Data Table
                                Expanded(
                                  child: FlutterFlowDataTable<ContractRecord>(
                                    controller:
                                        _model.paginatedDataTableController1,
                                    data: filteredContractList,
                                    columnsBuilder: (onSortChanged) => [
                                      _buildDataColumn(
                                        'Contract ID',
                                        Icons.numbers_rounded,
                                      ),
                                      _buildDataColumn(
                                        _getLocationColumnLabel(),
                                        Icons.location_on_rounded,
                                      ),
                                      _buildDataColumn(
                                        'Deceased',
                                        Icons.person_rounded,
                                      ),
                                      _buildDataColumn(
                                        'Effective',
                                        Icons.calendar_today_rounded,
                                      ),
                                      _buildDataColumn(
                                        'Expiration',
                                        Icons.calendar_month_rounded,
                                      ),
                                      _buildDataColumn(
                                        'Status',
                                        Icons.info_rounded,
                                      ),
                                      _buildDataColumn(
                                        'Balance',
                                        Icons.attach_money_rounded,
                                      ),
                                      _buildDataColumn(
                                        'Action',
                                        Icons.settings_rounded,
                                      ),
                                    ],
                                    dataRowBuilder: (
                                      contract,
                                      contractIndex,
                                      selected,
                                      onSelectChanged,
                                    ) =>
                                        DataRow(
                                      color: MaterialStateProperty.all(
                                        contractIndex % 2 == 0
                                            ? const Color(0xFFF9FAFB)
                                            : Colors.white,
                                      ),
                                      cells: [
                                        // Contract ID - Map to Firestore document ID
                                        _buildDataCell(
                                          child: Text(
                                            _getContractNumber(contract),
                                            style: GoogleFonts.inter(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: const Color(
                                                0xFF1F2937,
                                              ),
                                            ),
                                          ),
                                        ),
                                        // Location - Map to appropriate location field
                                        _buildDataCell(
                                          child: Text(
                                            _getContractLocation(contract),
                                            style: GoogleFonts.inter(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: const Color(
                                                0xFF374151,
                                              ),
                                            ),
                                          ),
                                        ),
                                        // Deceased - Show last deceased name
                                        _buildDataCell(
                                          child: Text(
                                            _getDeceasedName(contract),
                                            style: GoogleFonts.inter(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: const Color(
                                                0xFF374151,
                                              ),
                                            ),
                                          ),
                                        ),
                                        // Effective Date - Map to contract start date
                                        _buildDataCell(
                                          child: Text(
                                            _getEffectiveDate(contract),
                                            style: GoogleFonts.inter(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: const Color(
                                                0xFF374151,
                                              ),
                                            ),
                                          ),
                                        ),
                                        // Expiration Date - Map to contract end date
                                        _buildDataCell(
                                          child: Text(
                                            _getExpirationDate(contract),
                                            style: GoogleFonts.inter(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: const Color(
                                                0xFF374151,
                                              ),
                                            ),
                                          ),
                                        ),
                                        // Status - Map to contract status
                                        _buildDataCell(
                                          child: _buildContractStatusBadge(
                                            contract.status,
                                            contract.dateofexpiration,
                                          ),
                                        ),
                                        // Balance - Map to contract amount
                                        _buildDataCell(
                                          child: Text(
                                            _getContractBalance(contract),
                                            style: GoogleFonts.inter(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: const Color(
                                                0xFF000000,
                                              ),
                                            ),
                                          ),
                                        ),
                                        // Action - Contract actions
                                        _buildDataCell(
                                          child: _buildContractActions(
                                            contract,
                                          ),
                                        ),
                                      ],
                                    ),
                                    paginated: true,
                                    selectable: false,
                                    hidePaginator: false,
                                    showFirstLastButtons: false,
                                    headingRowHeight: 70.0,
                                    dataRowHeight: 70.0,
                                    columnSpacing: 24.0,
                                    headingRowColor: const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(24),
                                    addHorizontalDivider: true,
                                    addTopAndBottomDivider: false,
                                    hideDefaultHorizontalDivider: true,
                                    horizontalDividerColor: const Color(
                                      0xFFE5E7EB,
                                    ),
                                    horizontalDividerThickness: 1.0,
                                    addVerticalDivider: false,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper method to build section titles
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title,
        style: DashboardTheme.caption.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  // Helper method to build navigation items
  Widget _buildNavItem({
    required IconData icon,
    required String title,
    bool isActive = false,
    required VoidCallback onTap,
    int notificationCount = 0,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DashboardTheme.inputRadius),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ), // Standardized height
          decoration: BoxDecoration(
            color: isActive ? DashboardTheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(DashboardTheme.inputRadius),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isActive ? Colors.white : DashboardTheme.secondary,
                size: 22,
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: DashboardTheme.inputText.copyWith(
                  color: isActive ? Colors.white : DashboardTheme.textPrimary,
                ),
              ),
              if (notificationCount > 0) ...[
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$notificationCount',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build action buttons
  Widget _buildActionButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required bool isPrimary,
    bool isSmall = false,
  }) {
    final backgroundColor = isPrimary
        ? const Color(0xFF3B82F6) // Clean blue for primary
        : const Color(0xFFF8FAFC); // Light gray for secondary
    final textColor =
        isPrimary ? Colors.white : const Color(0xFF374151); // Dark gray text
    final iconColor =
        isPrimary ? Colors.white : const Color(0xFF6B7280); // Medium gray icon
    final borderColor = isPrimary
        ? Colors.transparent
        : const Color(0xFFE5E7EB); // Subtle border for secondary

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        // Remove colored shadows for cleaner look
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: isSmall ? 16 : 18, color: iconColor),
        label: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: isSmall ? 12 : 14,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 0,
          padding: EdgeInsets.symmetric(
            horizontal: isSmall ? 16 : 24,
            vertical: isSmall ? 12 : 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: borderColor, width: 1),
          ),
          minimumSize: Size(0, isSmall ? 40 : 48),
        ),
      ),
    );
  }

  // Helper method to build date buttons
  Widget _buildDateButton({
    required VoidCallback onPressed,
    required String label,
    required DateTime? date,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18, color: const Color(0xFF6B7280)),
        label: Text(
          date != null ? dateTimeFormat('MMM dd, yyyy', date) : label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: date != null
                ? const Color(0xFF374151)
                : const Color(0xFF9CA3AF),
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF8FAFC),
          foregroundColor: const Color(0xFF374151),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
          ),
          minimumSize: const Size(0, 48),
        ),
      ),
    );
  }

  // Helper method to build data columns
  DataColumn2 _buildDataColumn(String label, IconData icon) {
    return DataColumn2(
      label: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1F2937),
          ),
        ),
      ),
    );
  }

  // Helper method to build data cells
  DataCell _buildDataCell({required Widget child}) {
    return DataCell(
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: child,
      ),
    );
  }

  // Helper methods for contract data mapping
  String _getContractNumber(ContractRecord contract) {
    // Contract ID = Firestore document ID
    return contract.reference.id;
  }

  String _getContractLocation(ContractRecord contract) {
    // Add "Nitche" label before location data if contract type is nitche
    if (contract.location.isNotEmpty) {
      if (contract.type?.toLowerCase() == 'nitche') {
        return 'Nitche ${contract.location}';
      }
      return contract.location;
    }
    return 'N/A';
  }

  String _getLocationColumnLabel() {
    // Always return 'Location' as the column header
    return 'Location';
  }

  String _getEffectiveDate(ContractRecord contract) {
    // Effective = dateEffective
    if (contract.dateEffective != null) {
      return '${contract.dateEffective!.month}/${contract.dateEffective!.day}/${contract.dateEffective!.year}';
    }
    return 'N/A';
  }

  String _getExpirationDate(ContractRecord contract) {
    // Expiration = dateofexpiration
    if (contract.dateofexpiration != null) {
      return '${contract.dateofexpiration!.month}/${contract.dateofexpiration!.day}/${contract.dateofexpiration!.year}';
    }
    return 'N/A';
  }

  String _getContractBalance(ContractRecord contract) {
    // Balance = balance
    return 'Php. ${contract.balance}';
  }

  // Helper method to get contract duration
  int _getContractDuration(ContractRecord contract) {
    if (_model.renewalExpirationDate != null) {
      final currentExpiration = contract.dateofexpiration ?? DateTime.now();
      final int currentYear = currentExpiration.year;
      final int expirationYear = _model.renewalExpirationDate!.year;
      final int duration = expirationYear - currentYear;
      return duration > 0 ? duration : 0;
    }
    return 0;
  }

  // Helper method to get total contract value
  double _getTotalContractValue(ContractRecord contract) {
    final int duration = _getContractDuration(contract);
    if (duration > 0) {
      final double renewalFee = double.tryParse(contract.amount ?? '0') ?? 0.0;
      return (duration * renewalFee) - renewalFee;
    }
    return 0.0;
  }

  Future<void> _showRenewalSuccessModal(
    String renewalFee,
    DateTime newExpirationDate,
    String totalContractValue,
  ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.check_circle,
                color: const Color(0xFF10B981),
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Renewal Successful',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          content: Container(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF10B981)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Contract renewal payment processed successfully!',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF10B981),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow('Payment Amount', '₱$renewalFee'),
                      _buildDetailRow(
                        'New Expiration',
                        '${newExpirationDate.month}/${newExpirationDate.day}/${newExpirationDate.year}',
                      ),
                      _buildDetailRow('New Balance', '₱$totalContractValue'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'The contract has been successfully renewed. You can view the updated details in the contract list.',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate back to manage contract page
                context.goNamed('manageContract');
              },
              child: Text(
                'Close',
                style: GoogleFonts.inter(color: const Color(0xFF6B7280)),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate to transaction page
                context.goNamed('transaction');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
              ),
              child: Text(
                'View Transactions',
                style: GoogleFonts.inter(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showPayBalanceModal(ContractRecord contract) async {
    // Clear previous values and errors
    _model.payerNameController?.clear();
    _model.amountController?.clear();
    _model.payerNameError = null;
    _model.amountError = null;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            // Validation functions
            void validatePayerName(String value) {
              setState(() {
                if (value.trim().isEmpty) {
                  _model.payerNameError = 'Payer name is required';
                } else if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
                  _model.payerNameError = 'Only letters and spaces are allowed';
                } else if (value.trim().length < 2) {
                  _model.payerNameError = 'Name must be at least 2 characters';
                } else {
                  _model.payerNameError = null;
                }
              });
            }

            void validateAmount(String value) {
              setState(() {
                if (value.trim().isEmpty) {
                  _model.amountError = 'Amount is required';
                } else {
                  final amount = int.tryParse(value.trim());
                  if (amount == null) {
                    _model.amountError = 'Please enter a valid number';
                  } else if (amount <= 0) {
                    _model.amountError = 'Amount must be greater than 0';
                  } else if (contract.type?.toLowerCase() == 'nitche' ||
                      contract.type?.toLowerCase() == 'lot') {
                    final initialFee = contract.initialfee ?? 0;
                    if (amount < initialFee) {
                      final contractType =
                          contract.type?.toLowerCase() == 'nitche'
                              ? 'nitche'
                              : 'lot';
                      _model.amountError =
                          'Minimum payment for $contractType is ₱$initialFee';
                    } else {
                      _model.amountError = null;
                    }
                  } else {
                    _model.amountError = null;
                  }
                }
              });
            }

            return AlertDialog(
              title: Text(
                'Pay Balance',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
              ),
              content: Container(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Contract: ${contract.reference.id}',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Current Balance: ₱${contract.balance}',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _model.payerNameController,
                      focusNode: _model.payerNameFocusNode,
                      onChanged: validatePayerName,
                      decoration: InputDecoration(
                        labelText: 'Payer Name',
                        hintText: 'Enter payer name',
                        errorText: _model.payerNameError,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: _model.payerNameError != null
                                ? const Color(0xFFEF4444)
                                : const Color(0xFF18651C),
                            width: 2,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: _model.payerNameError != null
                                ? const Color(0xFFEF4444)
                                : const Color(0xFFD1D5DB),
                            width: 1,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFFEF4444),
                            width: 1,
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFFEF4444),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _model.amountController,
                      focusNode: _model.amountFocusNode,
                      keyboardType: TextInputType.number,
                      onChanged: validateAmount,
                      decoration: InputDecoration(
                        labelText: 'Amount to Pay',
                        hintText: (contract.type?.toLowerCase() == 'nitche' ||
                                contract.type?.toLowerCase() == 'lot')
                            ? 'Minimum ₱${contract.initialfee ?? 0} (initial fee)'
                            : 'Enter amount',
                        prefixText: '₱',
                        errorText: _model.amountError,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: _model.amountError != null
                                ? const Color(0xFFEF4444)
                                : const Color(0xFF18651C),
                            width: 2,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: _model.amountError != null
                                ? const Color(0xFFEF4444)
                                : const Color(0xFFD1D5DB),
                            width: 1,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFFEF4444),
                            width: 1,
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFFEF4444),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    // Show minimum requirement hint for nitche and lot contracts
                    if (contract.type?.toLowerCase() == 'nitche' ||
                        contract.type?.toLowerCase() == 'lot') ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFF59E0B)),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: const Color(0xFFF59E0B),
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Minimum payment for ${contract.type?.toLowerCase() == 'nitche' ? 'nitche' : 'lot'} contracts is ₱${contract.initialfee ?? 0} (initial fee)',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: const Color(0xFF92400E),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.inter(color: const Color(0xFF6B7280)),
                  ),
                ),
                ElevatedButton(
                  onPressed: (_model.payerNameError == null &&
                          _model.amountError == null &&
                          _model.payerNameController?.text.trim().isNotEmpty ==
                              true &&
                          _model.amountController?.text.trim().isNotEmpty ==
                              true)
                      ? () async {
                          final payerName =
                              _model.payerNameController?.text.trim();
                          final amountText =
                              _model.amountController?.text.trim();

                          // Final validation before proceeding
                          if (payerName == null || payerName.isEmpty) {
                            return;
                          }

                          final amount = int.tryParse(amountText!);
                          if (amount == null || amount <= 0) {
                            return;
                          }

                          // Show transaction summary before payment
                          await _showTransactionSummary(
                            contract,
                            payerName,
                            amount,
                          );
                          Navigator.of(context).pop();
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: (_model.payerNameError == null &&
                            _model.amountError == null &&
                            _model.payerNameController?.text
                                    .trim()
                                    .isNotEmpty ==
                                true &&
                            _model.amountController?.text.trim().isNotEmpty ==
                                true)
                        ? const Color(0xFF18651C)
                        : const Color(0xFF9CA3AF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Process Payment',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showTransactionSummary(
    ContractRecord contract,
    String payerName,
    int amount,
  ) async {
    // Reset terms agreement state
    _model.agreeToTerms = false;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Transaction Summary',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
              ),
              content: Container(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Transaction Details Box
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFFE5E7EB),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Transaction Details',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1F2937),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Name:',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                              Text(
                                '$payerName',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF1F2937),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                contract.type.toLowerCase() == 'nitche'
                                    ? 'Pay for Niche #:'
                                    : 'Pay for:',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                              Text(
                                _getContractLocation(contract),
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF1F2937),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Payment For:',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                              Text(
                                'Balance Payment',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF1F2937),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Current Balance:',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                              Text(
                                '₱${contract.balance}',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF1F2937),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Payment Amount:',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                              Text(
                                '₱$amount',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF1F2937),
                                ),
                              ),
                            ],
                          ),
                          // Only show Change row if there's actual change (amount > balance)
                          if (amount > contract.balance) ...[
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Change:',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF6B7280),
                                  ),
                                ),
                                Text(
                                  '₱${amount - contract.balance}',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF10B981),
                                  ),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Date:',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                              Text(
                                '${dateTimeFormat('yMMMd', DateTime.now())}',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF1F2937),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Time:',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                              Text(
                                '${dateTimeFormat('jm', DateTime.now())}',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF1F2937),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Payment Gateway Information
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Payment Gateway Information:',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1F2937),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '• By clicking the Proceed button below, this page will redirect to the payment gateway.',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '• All transactions are protected and treated confidential.',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '• Please do not reload the page to prevent unexpected result.',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Terms and Conditions
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'The Baliwag Municipality Terms',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1F2937),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'By proceeding with this payment, you agree to the terms and conditions set forth by Baliwag Municipality. All payments are final and non-refundable. The municipality reserves the right to modify contract terms as necessary.',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Terms Agreement Checkbox
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: (_model.agreeToTerms ?? false)
                            ? const Color(0xFFF0FDF4)
                            : const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: (_model.agreeToTerms ?? false)
                              ? const Color(0xFF10B981)
                              : const Color(0xFFFECACA),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Checkbox(
                            value: _model.agreeToTerms ?? false,
                            onChanged: (value) {
                              setState(() {
                                _model.agreeToTerms = value;
                              });
                            },
                            activeColor: const Color(0xFF10B981),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _model.agreeToTerms =
                                      !(_model.agreeToTerms ?? false);
                                });
                              },
                              child: Text(
                                'I agree to the Terms and Conditions',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF1F2937),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    Navigator.of(
                      context,
                    ).pop(); // Close transaction summary modal
                    // Show Pay Balance modal again
                    await _showPayBalanceModal(contract);
                  },
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.inter(
                      color: const Color(0xFFEF4444),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: (_model.agreeToTerms ?? false)
                      ? () async {
                          // Close current modal first
                          Navigator.of(context).pop();
                          // Wait a moment for the modal to close, then show transaction details
                          await Future.delayed(
                            const Duration(milliseconds: 50),
                          );
                          await _showTransactionDetails(
                            contract,
                            payerName,
                            amount,
                            contract.balance ?? 0,
                            (contract.balance ?? 0) - amount,
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: (_model.agreeToTerms ?? false)
                        ? const Color(0xFF8B5CF6)
                        : const Color(0xFF9CA3AF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: (_model.agreeToTerms ?? false) ? 2 : 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: Text(
                    'Proceed',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showTransactionDetails(
    ContractRecord contract,
    String payerName,
    int amount,
    int currentBalance,
    int newBalance,
  ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Below are the details of your payment.',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1F2937),
            ),
          ),
          content: Container(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Recipient Details Section
                _buildTransactionSection('Recipient Details', [
                  _buildDetailRow('Bank', 'Land Bank of the Philippines'),
                  _buildDetailRow('Account Name', 'Municipality of Baliwag'),
                  _buildDetailRow('Account Number', '0101-2407-03'),
                ]),
                const SizedBox(height: 16),

                // Transaction Details Section
                _buildTransactionSection('Transaction Details', [
                  _buildDetailRow(
                    'Date',
                    dateTimeFormat('yMMMd', DateTime.now()),
                  ),
                  _buildDetailRow('Currency', 'PHP'),
                  _buildDetailRow('Amount to pay', '₱${contract.balance ?? 0}'),
                ]),
                const SizedBox(height: 16),

                // Transaction Breakdown Section
                _buildTransactionSection('Transaction Breakdown', [
                  _buildDetailRow(
                    'Current Balance',
                    '₱${contract.balance ?? 0}',
                  ),
                  // Show Change if amount > balance, otherwise show New Balance
                  if (amount > (contract.balance ?? 0))
                    _buildDetailRow(
                      'Change',
                      '₱${amount - (contract.balance ?? 0)}',
                    )
                  else
                    _buildDetailRow(
                      'New Balance',
                      '₱${(contract.balance ?? 0) - amount}',
                    ),
                  _buildDetailRow('Amount to pay', '₱$amount'),
                  _buildDetailRow('Total', '₱$amount', isTotal: true),
                ]),
                const SizedBox(height: 16),

                // Customer Details Section
                _buildTransactionSection('Customer Details', [
                  _buildDetailRow('Full Name', payerName),
                ]),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close transaction details modal
                // Show transaction summary modal again
                await _showTransactionSummary(contract, payerName, amount);
              },
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(
                  color: const Color(0xFF6B7280),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                // Proceed with Stripe payment
                await _processStripePayment(contract, payerName, amount);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(
                  0xFF10B981,
                ), // Green color as in image
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Pay',
                style: GoogleFonts.inter(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showRenewalTransactionSummary(
    ContractRecord contract,
    String payerName,
    int renewalFee,
    DateTime newExpirationDate,
    String location,
    int contractDuration,
    int totalContractValue,
  ) async {
    // Reset terms agreement state
    _model.agreeToTerms = false;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Transaction Summary',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
              ),
              content: Container(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Transaction Details Box
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFFE5E7EB),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Transaction Details',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1F2937),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Name:',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                              Text(
                                payerName,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF1F2937),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                contract.type.toLowerCase() == 'nitche'
                                    ? 'Pay for Niche #:'
                                    : 'Pay for:',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                              Text(
                                location,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF1F2937),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Payment For:',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                              Text(
                                'Renewal of Contract',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF1F2937),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Downpayment:',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                              Text(
                                '₱$renewalFee',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF1F2937),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total Balance for $contractDuration/yrs:',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                              Text(
                                '₱$totalContractValue',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF1F2937),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'New Expiration Date:',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                              Text(
                                dateTimeFormat('yMMMd', newExpirationDate),
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF1F2937),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Date:',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                              Text(
                                '${dateTimeFormat('yMMMd', DateTime.now())}',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF1F2937),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Time:',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                              Text(
                                '${dateTimeFormat('jm', DateTime.now())}',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF1F2937),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Payment Gateway Information
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFFF59E0B),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Payment Gateway Information:',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF92400E),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '• By clicking the Proceed button below, this page will redirect to the payment gateway.',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: const Color(0xFF92400E),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '• All transactions are protected and treated confidential.',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: const Color(0xFF92400E),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '• Please do not reload the page to prevent unexpected result.',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: const Color(0xFF92400E),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Terms and Conditions
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFFD1D5DB),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'The Baliwag Municipality Terms',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF374151),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'By proceeding with this transaction, you agree to the terms and conditions set forth by the Municipality of Baliwag. All payments are final and non-refundable. The municipality reserves the right to modify these terms at any time.',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Terms Agreement Checkbox
                    Row(
                      children: [
                        Checkbox(
                          value: _model.agreeToTerms ?? false,
                          onChanged: (bool? value) {
                            setState(() {
                              _model.agreeToTerms = value;
                            });
                          },
                          activeColor: const Color(0xFF8B5CF6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _model.agreeToTerms =
                                    !(_model.agreeToTerms ?? false);
                              });
                            },
                            child: Text(
                              'I agree to the Terms and Conditions',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: const Color(0xFF374151),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    Navigator.of(
                      context,
                    ).pop(); // Close transaction summary modal
                    // Show Renew Contract modal again
                    await _showRenewContractModal(contract);
                  },
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.inter(
                      color: const Color(0xFFEF4444),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: (_model.agreeToTerms ?? false)
                      ? () async {
                          // Close current modal first
                          Navigator.of(context).pop();
                          // Wait a moment for the modal to close, then show transaction details
                          await Future.delayed(
                            const Duration(milliseconds: 50),
                          );
                          await _showRenewalTransactionDetails(
                            contract,
                            payerName,
                            renewalFee,
                            newExpirationDate,
                            location,
                            contractDuration,
                            totalContractValue,
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: (_model.agreeToTerms ?? false)
                        ? const Color(0xFF8B5CF6)
                        : const Color(0xFF9CA3AF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: (_model.agreeToTerms ?? false) ? 2 : 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: Text(
                    'Proceed',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showRenewalTransactionDetails(
    ContractRecord contract,
    String payerName,
    int renewalFee,
    DateTime newExpirationDate,
    String location,
    int contractDuration,
    int totalContractValue,
  ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Below are the details of your payment.',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1F2937),
            ),
          ),
          content: Container(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Recipient Details Section
                _buildTransactionSection('Recipient Details', [
                  _buildDetailRow('Bank', 'Land Bank of the Philippines'),
                  _buildDetailRow('Account Name', 'Municipality of Baliwag'),
                  _buildDetailRow('Account Number', '0101-2407-03'),
                ]),
                const SizedBox(height: 16),

                // Transaction Details Section
                _buildTransactionSection('Transaction Details', [
                  _buildDetailRow(
                    'Date',
                    dateTimeFormat('yMMMd', DateTime.now()),
                  ),
                  _buildDetailRow('Currency', 'PHP'),
                  _buildDetailRow('Amount to pay', '₱$renewalFee'),
                ]),
                const SizedBox(height: 16),

                // Transaction Breakdown Section
                _buildTransactionSection('Transaction Breakdown', [
                  _buildDetailRow(
                    'Current Balance',
                    '₱${contractDuration * renewalFee}',
                  ),
                  _buildDetailRow('Amount to pay', '₱$renewalFee'),
                  _buildDetailRow('Total', '₱$renewalFee', isTotal: true),
                ]),
                const SizedBox(height: 16),

                // Customer Details Section
                _buildTransactionSection('Customer Details', [
                  _buildDetailRow('Full Name', payerName),
                ]),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close transaction details modal
                // Show transaction summary modal again
                await _showRenewalTransactionSummary(
                  contract,
                  payerName,
                  renewalFee,
                  newExpirationDate,
                  location,
                  contractDuration,
                  totalContractValue,
                );
              },
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(
                  color: const Color(0xFF6B7280),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                // Proceed with Stripe payment (same as balance payment flow)
                await _processStripeRenewalPayment(
                  contract,
                  payerName,
                  renewalFee,
                  newExpirationDate,
                  location,
                  contractDuration,
                  totalContractValue,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(
                  0xFF10B981,
                ), // Green color as in image
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Renew',
                style: GoogleFonts.inter(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTransactionSection(String title, List<Widget> details) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 12),
          ...details,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF6B7280),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
              color: value.startsWith('Php.')
                  ? const Color(0xFF000000) // Black for Php. values
                  : isTotal
                      ? const Color(0xFF10B981)
                      : const Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _processPayment(
    ContractRecord contract,
    String payerName,
    int amount,
  ) async {
    try {
      // Calculate new balance - if payment exceeds balance, set to 0
      final currentBalance = contract.balance ?? 0;
      final newBalance = amount >= currentBalance ? 0 : currentBalance - amount;
      final change = amount > currentBalance ? amount - currentBalance : 0;

      // Update contract balance
      await contract.reference.update(
        createContractRecordData(balance: newBalance),
      );

      // Get the last deceased name from decFullName array
      final decFullNameList = contract.decFullName ?? [];
      final lastDeceasedName =
          decFullNameList.isNotEmpty ? decFullNameList.last.toString() : '';

      // Create transaction record with P2P payment type for proper filtering
      await TransactionsRecord.collection.doc().set({
        ...createTransactionsRecordData(
          name: payerName,
          loc: contract.location,
          paymenttype: 'P2P',
          amount: amount,
          status: 'completed',
          type: contract.type?.toLowerCase() == 'nitche' ? 'nitche' : 'payment',
          remBalance: newBalance.toString(),
          deceased: lastDeceasedName,
          contractId: contract.reference.id,
        ),
        ...mapToFirestore({
          'transaction_date': FieldValue.serverTimestamp(),
        }),
      });

      // Show success modal
      if (mounted) {
        await _showPaymentSuccessModal(amount, newBalance, change);
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error processing payment: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  Future<void> _processStripePayment(
    ContractRecord contract,
    String payerName,
    int amount,
  ) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text('Processing payment...'),
              ],
            ),
          );
        },
      );

      // Stripe is already initialized in initState

      // Create payment intent
      final paymentIntent = await _createPaymentIntent(
        amount: amount,
        currency: 'php',
        contractId: contract.reference.id,
        payerName: payerName,
        location: contract.location,
      );

      // For demo purposes, simulate successful payment
      // In production, this would be the actual Stripe payment confirmation
      await Future.delayed(
        const Duration(milliseconds: 200),
      ); // Simulate payment processing

      final bool paymentSuccess = true; // Simulate successful payment

      if (paymentSuccess) {
        // Close loading dialog
        Navigator.of(context).pop();

        // Calculate new balance - if payment exceeds balance, set to 0
        final currentBalance = contract.balance ?? 0;
        final newBalance =
            amount >= currentBalance ? 0 : currentBalance - amount;
        final change = amount > currentBalance ? amount - currentBalance : 0;

        // Update contract balance
        await contract.reference.update(
          createContractRecordData(balance: newBalance),
        );

        // Get the last deceased name from decFullName array
        final decFullNameList = contract.decFullName ?? [];
        final lastDeceasedName =
            decFullNameList.isNotEmpty ? decFullNameList.last.toString() : '';

        // Create P2P transaction record for proper filtering
        final transactionDocRef = TransactionsRecord.collection.doc();
        await transactionDocRef.set({
          ...createTransactionsRecordData(
            name: payerName,
            loc: contract.location,
            paymenttype: 'Onsite Balance Payment',
            amount: amount,
            status: 'completed',
            type:
                contract.type?.toLowerCase() == 'nitche' ? 'nitche' : 'payment',
            remBalance: newBalance.toString(),
            deceased: lastDeceasedName,
            contractId: contract.reference.id,
            paymentMethod: 'Cash',
          ),
          ...mapToFirestore({
            'transaction_date': FieldValue.serverTimestamp(),
            'stripe_transaction_id': paymentIntent['id'] ?? 'unknown',
          }),
        });

        // Generate and show receipt
        await _generateAndShowReceipt(
          contract: contract,
          payerName: payerName,
          amount: amount,
          newBalance: newBalance ?? 0,
          change: change,
          paymentId: paymentIntent['id'] ?? 'unknown',
          transactionId: transactionDocRef.id,
        );

        // Show success modal
        if (mounted) {
          await _showPaymentSuccessModal(amount, newBalance, change);
        }
      } else {
        // Close loading dialog
        Navigator.of(context).pop();

        // Show payment failed message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Payment failed. Please try again.'),
              backgroundColor: Color(0xFFEF4444),
            ),
          );
        }
      }
    } catch (e) {
      // Close loading dialog if it's open
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error processing Stripe payment: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  Future<Map<String, dynamic>> _createPaymentIntent({
    required int amount,
    required String currency,
    required String contractId,
    required String payerName,
    required String location,
  }) async {
    // In a real implementation, this would call your backend API
    // For now, we'll simulate the payment intent creation

    // Simulate API call to your backend
    await Future.delayed(const Duration(milliseconds: 50));

    // Return mock payment intent data
    return {
      'id': 'pi_mock_${DateTime.now().millisecondsSinceEpoch}',
      'client_secret':
          'pi_mock_${DateTime.now().millisecondsSinceEpoch}_secret',
      'amount': amount * 100, // Convert to cents
      'currency': currency,
      'status': 'requires_payment_method',
      'metadata': {
        'contract_id': contractId,
        'payer_name': payerName,
        'location': location,
      },
    };
  }

  Future<void> _generateAndShowReceipt({
    required ContractRecord contract,
    required String payerName,
    required int amount,
    required int newBalance,
    required int change,
    required String paymentId,
    required String transactionId,
  }) async {
    try {
      // Create receipt data
      final receiptData = {
        'transaction_id': transactionId,
        'receipt_number': 'RCP-${DateTime.now().millisecondsSinceEpoch}',
        'payment_id': paymentId,
        'date': DateTime.now().toIso8601String(),
        'contract_id': contract.reference.id,
        'payer_name': payerName,
        'location': contract.location,
        'contract_type': contract.type,
        'amount_paid': amount,
        'previous_balance': contract.balance,
        'new_balance': newBalance,
        'change': change,
        'payment_method': 'Online Payment',
        'status': 'Completed',
      };

      // Show receipt modal
      await _showReceiptModal(receiptData);
    } catch (e) {
      print('Error generating receipt: $e');
    }
  }

  Future<void> _showReceiptModal(Map<String, dynamic> receiptData) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Payment Receipt',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1F2937),
            ),
          ),
          content: Container(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Receipt Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'BALIWAG CEMETERY',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Contract Payment Receipt',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Receipt Details
                _buildReceiptRow(
                  'Transaction ID',
                  receiptData['transaction_id'],
                ),
                _buildReceiptRow('Contract ID', receiptData['contract_id']),
                _buildReceiptRow(
                  (receiptData['contract_type']?.toString().toLowerCase() ??
                              '') ==
                          'nitche'
                      ? 'Nitche'
                      : 'Location',
                  receiptData['location'],
                ),
                _buildReceiptRow(
                  'Date',
                  _formatReceiptDate(receiptData['date']),
                ),
                _buildReceiptRow('Payer Name', receiptData['payer_name']),
                const Divider(),
                _buildReceiptRow(
                  'Amount Paid',
                  '₱${receiptData['amount_paid']}',
                  isAmount: true,
                ),
                _buildReceiptRow(
                  'Previous Balance',
                  '₱${receiptData['previous_balance']}',
                  isAmount: true,
                ),
                _buildReceiptRow(
                  receiptData['change'] > 0 ? 'Change' : 'New Balance',
                  '₱${receiptData['change'] > 0 ? receiptData['change'] : receiptData['new_balance']}',
                  isAmount: true,
                  isChange: true,
                ),
                const Divider(),
                _buildReceiptRow('Payment Method', 'Cash'),
                _buildReceiptRow(
                  'Status',
                  receiptData['status'],
                  isSuccess: true,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Close',
                style: GoogleFonts.inter(color: const Color(0xFF6B7280)),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await _downloadReceipt(
                  receiptData,
                  contractType: receiptData['contract_type'],
                );
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF18651C),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Download Receipt',
                style: GoogleFonts.inter(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildReceiptRow(
    String label,
    String value, {
    bool isAmount = false,
    bool isSuccess = false,
    bool isChange = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF6B7280),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: isAmount || isSuccess || isChange
                  ? FontWeight.w600
                  : FontWeight.normal,
              color: isSuccess
                  ? const Color(0xFF10B981)
                  : isChange
                      ? const Color(0xFFF59E0B)
                      : const Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }

  String _formatReceiptDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }

  Future<void> _downloadReceipt(
    Map<String, dynamic> receiptData, {
    String? contractType,
  }) async {
    try {
      // Create HTML receipt content for PDF generation
      final receiptContent = '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Payment Receipt</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 20px;
            background-color: white;
        }
        .receipt-container {
            max-width: 400px;
            margin: 0 auto;
            border: 2px solid #1F2937;
            border-radius: 8px;
            padding: 20px;
            background-color: white;
        }
        .header {
            text-align: center;
            border-bottom: 2px solid #1F2937;
            padding-bottom: 15px;
            margin-bottom: 20px;
        }
        .company-name {
            font-size: 18px;
            font-weight: bold;
            color: #1F2937;
            margin-bottom: 5px;
        }
        .receipt-title {
            font-size: 14px;
            color: #6B7280;
        }
        .receipt-details {
            margin-bottom: 20px;
        }
        .detail-row {
            display: flex;
            justify-content: space-between;
            margin-bottom: 8px;
            padding: 4px 0;
        }
        .detail-label {
            font-weight: 500;
            color: #6B7280;
        }
        .detail-value {
            color: #1F2937;
            font-weight: 500;
        }
        .amount {
            color: #059669;
            font-weight: bold;
        }
        .status {
            color: #059669;
            font-weight: bold;
        }
        .divider {
            border-top: 1px solid #D1D5DB;
            margin: 15px 0;
        }
        .footer {
            text-align: center;
            margin-top: 20px;
            padding-top: 15px;
            border-top: 1px solid #D1D5DB;
            color: #6B7280;
            font-size: 12px;
        }
        @media print {
            body { margin: 0; }
            .receipt-container { border: none; box-shadow: none; }
        }
    </style>
</head>
<body>
    <div class="receipt-container">
        <div class="header">
            <div class="company-name">BALIWAG CEMETERY</div>
            <div class="receipt-title">Contract Payment Receipt</div>
        </div>
        
        <div class="receipt-details">
            <div class="detail-row">
                <span class="detail-label">Transaction ID:</span>
                <span class="detail-value">${receiptData['transaction_id']}</span>
            </div>
            <div class="detail-row">
                <span class="detail-label">Contract ID:</span>
                <span class="detail-value">${receiptData['contract_id']}</span>
            </div>
            <div class="detail-row">
                <span class="detail-label">${(receiptData['contract_type']?.toString().toLowerCase() ?? '') == 'nitche' ? 'Nitche' : 'Location'}:</span>
                <span class="detail-value">${receiptData['location']}</span>
            </div>
            <div class="detail-row">
                <span class="detail-label">Date:</span>
                <span class="detail-value">${_formatReceiptDate(receiptData['date'])}</span>
            </div>
            <div class="detail-row">
                <span class="detail-label">Payer Name:</span>
                <span class="detail-value">${receiptData['payer_name']}</span>
            </div>
            
            <div class="divider"></div>
            
            <div class="detail-row">
                <span class="detail-label">Amount Paid:</span>
                <span class="detail-value amount">₱${receiptData['amount_paid']}</span>
            </div>
            <div class="detail-row">
                <span class="detail-label">Previous Balance:</span>
                <span class="detail-value">₱${receiptData['previous_balance']}</span>
            </div>
            <div class="detail-row">
                <span class="detail-label">${receiptData['change'] > 0 ? 'Change:' : 'New Balance:'}</span>
                <span class="detail-value amount">₱${receiptData['change'] > 0 ? receiptData['change'] : receiptData['new_balance']}</span>
            </div>
            
            <div class="divider"></div>
            
            <div class="detail-row">
                <span class="detail-label">Payment Method:</span>
                <span class="detail-value">Cash</span>
            </div>
            <div class="detail-row">
                <span class="detail-label">Status:</span>
                <span class="detail-value status">${receiptData['status']}</span>
            </div>
        </div>
        
        <div class="footer">
            Thank you for your payment!<br>
            BALIWAG CEMETERY
        </div>
    </div>
</body>
</html>
      ''';

      // Create and download as HTML file (can be saved as PDF)
      final bytes = utf8.encode(receiptContent);
      final blob = html.Blob([bytes], 'text/html');
      final url = html.Url.createObjectUrlFromBlob(blob);

      final anchor = html.AnchorElement(href: url)
        ..setAttribute(
          'download',
          'payment_receipt_${receiptData['receipt_number']}.html',
        )
        ..click();

      html.Url.revokeObjectUrl(url);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Receipt downloaded successfully! You can print it as PDF.',
            ),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      print('Error downloading balance payment receipt: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error downloading receipt: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  Future<void> _showContractDetailsModal(ContractRecord contract) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Contract Details',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1F2937),
            ),
          ),
          content: Container(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Contract Information Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Contract Information',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildDetailRow(
                          'Contract ID',
                          contract.reference.id,
                        ),
                        _buildDetailRow('Type', contract.type ?? 'N/A'),
                        _buildDetailRow('OR', _getContractOR(contract)),
                        _buildDetailRow(
                          'Location',
                          _getContractLocation(contract),
                        ),
                        // Only show these fields for Lot contracts, hide for nitche
                        if (contract.type?.toLowerCase() != 'nitche') ...[
                          _buildDetailRow(
                            'Street Address',
                            contract.street ?? 'N/A',
                          ),
                          _buildDetailRow(
                            'Measurement',
                            contract.measurement ?? 'N/A',
                          ),
                          _buildDetailRow(
                            'Status',
                            contract.lotstatus ?? 'N/A',
                          ),
                          _buildDetailRow('Lessee', contract.leessee ?? 'N/A'),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Financial Information Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Financial Information',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildDetailRow(
                          'Initial Fee',
                          'Php. ${contract.initialfee ?? '0'}',
                        ),
                        _buildDetailRow(
                          'Total Contract Balance',
                          'Php. ${contract.balance ?? '0'}',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Date Information Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Date Information',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildDetailRow(
                          'Effective Date',
                          _getEffectiveDate(contract),
                        ),
                        _buildDetailRow(
                          'Expiration Date',
                          _getExpirationDate(contract),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Deceased Details Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Deceased Details',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildDetailRow(
                          'Full Name',
                          _getDeceasedName(contract),
                        ),
                        _buildDetailRow(
                          'Date of Death',
                          _getDateOfDeath(contract),
                        ),
                        _buildDetailRow(
                          'Burial/Internment',
                          _getBurialInternment(contract),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Applicant Details Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Applicant Details',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildDetailRow(
                          'Applicant Name',
                          _getApplicantName(contract),
                        ),
                        _buildDetailRow('TIN', _getApplicantTIN(contract)),
                        _buildDetailRow(
                          'Resident Certificate ( Sedula )',
                          _getApplicantResidentCert(contract),
                        ),
                        _buildDetailRow(
                          'Applicant Address',
                          _getApplicantAddress(contract),
                        ),
                        _buildDetailRow(
                          'Contact Number',
                          _getApplicantContact(contract),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            // Button to view past details
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close current modal
                await _showPastDetailsModal(
                  contract,
                ); // Show past details modal
              },
              child: Text(
                'View Past Details',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF059669),
                ),
              ),
            ),
            // Button to view proof of lease
            if (contract.proofoflease.isNotEmpty)
              TextButton(
                onPressed: () => _showProofOfLeaseModal(contract),
                child: Text(
                  'View Proof of Lease',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF3B82F6),
                  ),
                ),
              ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Close',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Method to show proof of lease modal
  Future<void> _showProofOfLeaseModal(ContractRecord contract) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Proof of Lease',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1F2937),
            ),
          ),
          content: Container(
            width: 500,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Contract Information
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Contract Information',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        'Contract ID',
                        contract.reference.id,
                      ),
                      _buildDetailRow('Type', contract.type ?? 'N/A'),
                      _buildDetailRow(
                        'Location',
                        _getContractLocation(contract),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Proof of Lease Information
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F9FF),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFBAE6FD)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.attach_file_rounded,
                            color: const Color(0xFF0EA5E9),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Proof of Lease Document',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF0C4A6E),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _isValidProofOfLeasePath(contract.proofoflease)
                              ? Colors.white
                              : const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color:
                                _isValidProofOfLeasePath(contract.proofoflease)
                                    ? const Color(0xFFE0F2FE)
                                    : const Color(0xFFEF4444),
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.description_rounded,
                                  color: _isValidProofOfLeasePath(
                                    contract.proofoflease,
                                  )
                                      ? const Color(0xFF0EA5E9)
                                      : const Color(0xFFEF4444),
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            'Lease Document',
                                            style: GoogleFonts.inter(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: const Color(0xFF0C4A6E),
                                            ),
                                          ),
                                          if (!_isValidProofOfLeasePath(
                                            contract.proofoflease,
                                          )) ...[
                                            const SizedBox(width: 8),
                                            Icon(
                                              Icons.warning_rounded,
                                              color: const Color(0xFFEF4444),
                                              size: 16,
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      if (_isValidProofOfLeasePath(
                                        contract.proofoflease,
                                      ))
                                        Text(
                                          contract.proofoflease
                                              .split('/')
                                              .last
                                              .replaceAll(
                                                RegExp(r'_\d+\.'),
                                                '.',
                                              ),
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            color: const Color(0xFF64748B),
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        )
                                      else
                                        Text(
                                          'File path corrupted - needs re-upload',
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            color: const Color(0xFFEF4444),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                if (_isValidProofOfLeasePath(
                                  contract.proofoflease,
                                ))
                                  IconButton(
                                    onPressed: () => _downloadProofOfLease(
                                      contract.proofoflease,
                                    ),
                                    icon: Icon(
                                      Icons.download_rounded,
                                      color: const Color(0xFF0EA5E9),
                                      size: 20,
                                    ),
                                  )
                                else
                                  IconButton(
                                    onPressed: () =>
                                        _cleanupCorruptedProofOfLease(contract),
                                    icon: Icon(
                                      Icons.clean_hands_rounded,
                                      color: const Color(0xFFEF4444),
                                      size: 20,
                                    ),
                                    tooltip: 'Clear corrupted data',
                                  ),
                              ],
                            ),
                            if (!_isValidProofOfLeasePath(
                              contract.proofoflease,
                            )) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF2F2),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: const Color(0xFFFECACA),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: const Color(0xFFEF4444),
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'This file path is corrupted. Click the clean button to remove it and re-upload.',
                                        style: GoogleFonts.inter(
                                          fontSize: 11,
                                          color: const Color(0xFFEF4444),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Close',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Method to download proof of lease document
  Future<void> _downloadProofOfLease(String filePath) async {
    try {
      // Debug: Log the file path being used
      print('DEBUG: Attempting to download file with path: $filePath');

      // Show loading message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 12),
              Text('Preparing download...'),
            ],
          ),
          backgroundColor: const Color(0xFF0EA5E9),
          duration: Duration(seconds: 5),
        ),
      );

      // Check if filePath is empty or null
      if (filePath.isEmpty || filePath == 'null') {
        throw Exception('No proof of lease file available for this contract');
      }

      // Check if filePath contains invalid characters (indicating corrupted data)
      if (filePath.contains('@') ||
          filePath.contains(')') ||
          filePath.contains('(') ||
          !filePath.contains('.') ||
          filePath.length < 10) {
        throw Exception(
          'Proof of lease file path appears to be corrupted. Please contact administrator to re-upload the file.',
        );
      }

      final String fileName =
          filePath.split('/').last.replaceAll(RegExp(r'_\d+\.'), '.');

      // Check if filePath is already a URL (starts with http)
      String downloadUrl;
      if (filePath.startsWith('http')) {
        // Already a URL, use it directly
        downloadUrl = filePath;
        print('DEBUG: Using direct URL: $downloadUrl');
      } else {
        // It's a Firebase Storage path, get the download URL
        print(
          'DEBUG: Getting download URL from Firebase Storage for path: $filePath',
        );
        try {
          final storageRef = FirebaseStorage.instance.ref().child(filePath);

          // First check if the file exists
          try {
            await storageRef.getMetadata();
            print('DEBUG: File exists in Firebase Storage');
          } catch (metadataError) {
            print(
              'DEBUG: File does not exist in Firebase Storage: $metadataError',
            );
            throw Exception(
              'Proof of lease file does not exist in storage. Please re-upload the file.',
            );
          }

          downloadUrl = await storageRef.getDownloadURL();
          print('DEBUG: Successfully got download URL: $downloadUrl');
        } catch (storageError) {
          print('DEBUG: Firebase Storage error: $storageError');
          throw Exception(
            'Failed to get download URL from Firebase Storage: $storageError',
          );
        }
      }

      // Create download link with the proper URL
      html.AnchorElement anchorElement = html.AnchorElement(href: downloadUrl);
      anchorElement.download = fileName;
      anchorElement.target = '_blank';
      anchorElement.click();

      // Show success message
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Download started: $fileName'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      // Hide loading message
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      // Show error message
      print('DEBUG: Download error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error downloading file: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
    }
  }

  String _getDateCreated(ContractRecord contract) {
    if (contract.createdTime != null) {
      return '${contract.createdTime!.month}/${contract.createdTime!.day}/${contract.createdTime!.year}';
    }
    return 'N/A';
  }

  // Utility function to validate proof of lease file paths
  bool _isValidProofOfLeasePath(String? filePath) {
    if (filePath == null || filePath.isEmpty || filePath == 'null') {
      return false;
    }

    // Check for invalid characters
    if (filePath.contains('@') ||
        filePath.contains(')') ||
        filePath.contains('(')) {
      return false;
    }

    // Check if it has a proper file extension
    if (!filePath.contains('.')) {
      return false;
    }

    // Check minimum length
    if (filePath.length < 10) {
      return false;
    }

    return true;
  }

  // Function to clean up corrupted proof of lease data (for admin use)
  Future<void> _cleanupCorruptedProofOfLease(ContractRecord contract) async {
    try {
      // Update the contract to remove corrupted proof of lease data
      await FirebaseFirestore.instance
          .collection('contract')
          .doc(contract.reference.id)
          .update({'proofoflease': null});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Corrupted proof of lease data cleared. Please re-upload the file.',
          ),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 4),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error cleaning up corrupted data: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
    }
  }

  // Show modal with all past applicant and deceased details
  Future<void> _showPastDetailsModal(ContractRecord contract) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Past Applicant & Deceased Details',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1F2937),
            ),
          ),
          content: Container(
            width: 600,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Past Deceased Details Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'All Deceased Details',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (contract.decFullName.isNotEmpty) ...[
                          Text(
                            'Deceased Names:',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF374151),
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...contract.decFullName.asMap().entries.map((entry) {
                            final index = entry.key;
                            final name = entry.value;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: const Color(0xFFE5E7EB),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF059669),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${index + 1}',
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      name,
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        color: const Color(0xFF1F2937),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ] else ...[
                          Text(
                            'No deceased details available',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: const Color(0xFF6B7280),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        if (contract.dateofdeath.isNotEmpty) ...[
                          Text(
                            'Dates of Death:',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF374151),
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...contract.dateofdeath.asMap().entries.map((entry) {
                            final index = entry.key;
                            final date = entry.value;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: const Color(0xFFE5E7EB),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFDC2626),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${index + 1}',
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      '${date.month}/${date.day}/${date.year}',
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        color: const Color(0xFF1F2937),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                        const SizedBox(height: 16),
                        if (contract.burialinternment.isNotEmpty) ...[
                          Text(
                            'Burial/Internment Dates:',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF374151),
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...contract.burialinternment.asMap().entries.map((
                            entry,
                          ) {
                            final index = entry.key;
                            final date = entry.value;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: const Color(0xFFE5E7EB),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF7C3AED),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${index + 1}',
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      '${date.month}/${date.day}/${date.year}',
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        color: const Color(0xFF1F2937),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Past Applicant Details Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'All Applicant Details',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (contract.applicantName.isNotEmpty) ...[
                          Text(
                            'Applicant Names:',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF374151),
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...contract.applicantName.asMap().entries.map((
                            entry,
                          ) {
                            final index = entry.key;
                            final name = entry.value;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: const Color(0xFFE5E7EB),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF059669),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${index + 1}',
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      name,
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        color: const Color(0xFF1F2937),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ] else ...[
                          Text(
                            'No applicant details available',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: const Color(0xFF6B7280),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        if (contract.applcantAddress.isNotEmpty) ...[
                          Text(
                            'Applicant Addresses:',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF374151),
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...contract.applcantAddress.asMap().entries.map((
                            entry,
                          ) {
                            final index = entry.key;
                            final address = entry.value;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: const Color(0xFFE5E7EB),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF3B82F6),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${index + 1}',
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      address,
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        color: const Color(0xFF1F2937),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                        const SizedBox(height: 16),
                        if (contract.applicantContactNumber.isNotEmpty) ...[
                          Text(
                            'Contact Numbers:',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF374151),
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...contract.applicantContactNumber
                              .asMap()
                              .entries
                              .map((entry) {
                            final index = entry.key;
                            final contact = entry.value;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: const Color(0xFFE5E7EB),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF59E0B),
                                      borderRadius: BorderRadius.circular(
                                        12,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${index + 1}',
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      '0${contact.toString()}',
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        color: const Color(0xFF1F2937),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Close',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _getDeceasedName(ContractRecord contract) {
    if (contract.decFullName.isNotEmpty) {
      return contract.decFullName.last; // Show only the last deceased name
    }
    return 'N/A';
  }

  String _getDateOfDeath(ContractRecord contract) {
    if (contract.dateofdeath.isNotEmpty) {
      final lastDate = contract.dateofdeath.last;
      return '${lastDate.month}/${lastDate.day}/${lastDate.year}'; // Show only the last date of death
    }
    return 'N/A';
  }

  String _getBurialInternment(ContractRecord contract) {
    if (contract.burialinternment.isNotEmpty) {
      final lastDate = contract.burialinternment.last;
      return '${lastDate.month}/${lastDate.day}/${lastDate.year}'; // Show only the last burial/internment date
    }
    return 'N/A';
  }

  String _getApplicantName(ContractRecord contract) {
    if (contract.applicantName.isNotEmpty) {
      return contract.applicantName.last; // Show only the last applicant name
    }
    return 'N/A';
  }

  String _getApplicantAddress(ContractRecord contract) {
    if (contract.applcantAddress.isNotEmpty) {
      return contract
          .applcantAddress.last; // Show only the last applicant address
    }
    return 'N/A';
  }

  String _getApplicantContact(ContractRecord contract) {
    if (contract.applicantContactNumber.isNotEmpty) {
      final lastContact = contract.applicantContactNumber.last;
      return '0${lastContact.toString()}'; // Show only the last applicant contact number
    }
    return 'N/A';
  }

  String _getApplicantTIN(ContractRecord contract) {
    if (contract.tin.isNotEmpty) {
      return contract.tin;
    }
    return 'N/A';
  }

  String _getApplicantResidentCert(ContractRecord contract) {
    if (contract.residentCert.isNotEmpty) {
      return contract.residentCert;
    }
    return 'N/A';
  }

  String _getContractOR(ContractRecord contract) {
    if (contract.or.isNotEmpty) {
      return contract.or;
    }
    return 'N/A';
  }

  Future<void> _showEditLeesseeModal(ContractRecord contract) async {
    // Get the last applicant details
    final lastApplicantName =
        contract.applicantName.isNotEmpty ? contract.applicantName.last : '';
    final lastApplicantAddress = contract.applcantAddress.isNotEmpty
        ? contract.applcantAddress.last
        : '';
    final lastApplicantContact = contract.applicantContactNumber.isNotEmpty
        ? '0${contract.applicantContactNumber.last.toString()}'
        : '';

    // Create controllers for the form fields
    final nameController = TextEditingController(text: lastApplicantName);
    final addressController = TextEditingController(text: lastApplicantAddress);
    final contactController = TextEditingController(text: lastApplicantContact);

    // Validation state
    bool isNameValid = false;
    bool isAddressValid = false;
    bool isContactValid = false;

    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: Text(
                'Edit Last Applicant Details',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
              ),
              content: Container(
                width: 500,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Current Last Applicant Details Display
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFFD1D5DB),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Current Last Applicant Details',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1F2937),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildDisplayRow(
                            'Name',
                            lastApplicantName.isNotEmpty
                                ? lastApplicantName
                                : 'No applicant name',
                          ),
                          _buildDisplayRow(
                            'Contact',
                            lastApplicantContact.isNotEmpty
                                ? lastApplicantContact
                                : 'No contact number',
                          ),
                          _buildDisplayRow(
                            'Address',
                            lastApplicantAddress.isNotEmpty
                                ? lastApplicantAddress
                                : 'No address',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Edit Section Header
                    Text(
                      'Edit Applicant Details',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Edit Lessee Button
                    Container(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          Navigator.of(context).pop(); // Close current modal
                          await _showEditLesseeNameModal(contract);
                        },
                        icon: Icon(Icons.edit_rounded, size: 18),
                        label: Text('Edit Lessee Name'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF18651C),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Applicant Name Field
                    _buildEditLeesseeTextField(
                      controller: nameController,
                      label: 'Applicant Name',
                      hint: 'Enter applicant full name',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Applicant name is required';
                        }
                        if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value.trim())) {
                          return 'Name must contain only letters and spaces';
                        }
                        if (value.trim().length < 2 ||
                            value.trim().length > 50) {
                          return 'Name must be 2-50 characters';
                        }
                        return null;
                      },
                      isValid: isNameValid,
                      onChanged: (value) {
                        setModalState(() {
                          isNameValid = value.trim().isNotEmpty &&
                              RegExp(r'^[a-zA-Z\s]+$').hasMatch(value.trim()) &&
                              value.trim().length >= 2 &&
                              value.trim().length <= 50;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Contact Number Field
                    _buildEditLeesseeTextField(
                      controller: contactController,
                      label: 'Mobile Contact Number',
                      hint: 'Enter 11-digit mobile number',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Mobile contact number is required';
                        }
                        if (!RegExp(r'^09\d{9}$').hasMatch(value.trim())) {
                          return 'Mobile contact number must be 11 digits starting with 09';
                        }
                        return null;
                      },
                      isValid: isContactValid,
                      onChanged: (value) {
                        setModalState(() {
                          isContactValid = value.trim().isNotEmpty &&
                              RegExp(r'^09\d{9}$').hasMatch(value.trim());
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Address Field
                    _buildEditLeesseeTextField(
                      controller: addressController,
                      label: 'Residential Address',
                      hint: 'Enter residential address',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Residential address is required';
                        }
                        if (!RegExp(
                          r'^[A-Za-z0-9\s.,#\-]+$',
                        ).hasMatch(value.trim())) {
                          return 'Address contains invalid characters';
                        }
                        if (value.trim().length < 5) {
                          return 'Address must be at least 5 characters';
                        }
                        return null;
                      },
                      isValid: isAddressValid,
                      onChanged: (value) {
                        setModalState(() {
                          isAddressValid = value.trim().isNotEmpty &&
                              RegExp(
                                r'^[A-Za-z0-9\s.,#\-]+$',
                              ).hasMatch(value.trim()) &&
                              value.trim().length >= 5;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF6B7280),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: isNameValid && isAddressValid && isContactValid
                      ? () async {
                          try {
                            // Show loading
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => AlertDialog(
                                content: Row(
                                  children: [
                                    CircularProgressIndicator(),
                                    SizedBox(width: 16),
                                    Text('Updating applicant details...'),
                                  ],
                                ),
                              ),
                            );

                            // Update the contract with new applicant details
                            final updateData = <String, dynamic>{};

                            // Update applicant name (replace last entry)
                            if (contract.applicantName.isNotEmpty) {
                              final updatedNames = List<String>.from(
                                contract.applicantName,
                              );
                              updatedNames[updatedNames.length - 1] =
                                  nameController.text.trim();
                              updateData['applicantName'] = updatedNames;
                            }

                            // Update applicant address (replace last entry)
                            if (contract.applcantAddress.isNotEmpty) {
                              final updatedAddresses = List<String>.from(
                                contract.applcantAddress,
                              );
                              updatedAddresses[updatedAddresses.length - 1] =
                                  addressController.text.trim();
                              updateData['applcantAddress'] = updatedAddresses;
                            }

                            // Update applicant contact (replace last entry)
                            if (contract.applicantContactNumber.isNotEmpty) {
                              final updatedContacts = List<int>.from(
                                contract.applicantContactNumber,
                              );
                              updatedContacts[updatedContacts.length - 1] =
                                  int.tryParse(contactController.text.trim()) ??
                                      0;
                              updateData['applicantContactNumber'] =
                                  updatedContacts;
                            }

                            // Save to Firestore
                            await contract.reference.update(updateData);

                            // Close loading dialog
                            if (Navigator.of(context).canPop()) {
                              Navigator.of(context).pop();
                            }

                            // Close edit modal
                            Navigator.of(context).pop();

                            // Show success message
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Applicant details updated successfully',
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );

                            // Refresh the page
                            setState(() {});
                          } catch (e) {
                            // Close loading dialog
                            if (Navigator.of(context).canPop()) {
                              Navigator.of(context).pop();
                            }

                            // Show error message
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Error updating applicant details: $e',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isNameValid && isAddressValid && isContactValid
                            ? const Color(0xFF18651C)
                            : const Color(0xFFD1D5DB),
                    foregroundColor:
                        isNameValid && isAddressValid && isContactValid
                            ? Colors.white
                            : const Color(0xFF9CA3AF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Save Changes',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildEditLeesseeTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String? Function(String?) validator,
    required bool isValid,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '$label *',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ),
            if (isValid)
              Icon(Icons.check_circle_rounded, color: Colors.green, size: 20),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          onChanged: onChanged,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(color: const Color(0xFF9CA3AF)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isValid ? Colors.transparent : const Color(0xFFD1D5DB),
                width: isValid ? 0 : 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isValid ? Colors.transparent : const Color(0xFFD1D5DB),
                width: isValid ? 0 : 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isValid ? Colors.transparent : const Color(0xFF18651C),
                width: isValid ? 0 : 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            filled: true,
            fillColor: isValid ? const Color(0xFFF0FDF4) : Colors.white,
          ),
          style: GoogleFonts.inter(
            fontSize: 14,
            color: const Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }

  Future<void> _showEditLesseeNameModal(ContractRecord contract) async {
    // Get the current lessee name
    final currentLessee = contract.leessee.isNotEmpty ? contract.leessee : '';

    // Create controller for the form field
    final lesseeController = TextEditingController(text: currentLessee);

    // Validation state - initialize based on current value
    bool isLesseeValid = currentLessee.trim().isNotEmpty &&
        RegExp(r'^[a-zA-Z\s]+$').hasMatch(currentLessee.trim()) &&
        currentLessee.trim().length >= 2 &&
        currentLessee.trim().length <= 50;

    // Error message for real-time validation
    String? lesseeError;

    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: Text(
                'Edit Lessee Name',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
              ),
              content: Container(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Current Lessee Details Display
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFFD1D5DB),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Current Lessee Details',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1F2937),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildDisplayRow(
                            'Leessee:',
                            currentLessee.isNotEmpty
                                ? currentLessee
                                : 'No lessee name',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Edit Section Header
                    Text(
                      'Edit Lessee Name',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Lessee Name Field
                    _buildEditLesseeTextField(
                      controller: lesseeController,
                      label: 'Lessee Name',
                      hint: 'Enter lessee full name',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Lessee name is required';
                        }
                        if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value.trim())) {
                          return 'Name must contain only letters and spaces';
                        }
                        if (value.trim().length < 2 ||
                            value.trim().length > 50) {
                          return 'Name must be 2-50 characters';
                        }
                        return null;
                      },
                      isValid: isLesseeValid,
                      errorText: lesseeError,
                      onChanged: (value) {
                        setModalState(() {
                          final trimmedValue = value.trim();

                          if (trimmedValue.isEmpty) {
                            isLesseeValid = false;
                            lesseeError = 'Lessee name is required';
                          } else if (!RegExp(
                            r'^[a-zA-Z\s]+$',
                          ).hasMatch(trimmedValue)) {
                            isLesseeValid = false;
                            lesseeError =
                                'Name must contain only letters and spaces';
                          } else if (trimmedValue.length < 2) {
                            isLesseeValid = false;
                            lesseeError = 'Name must be at least 2 characters';
                          } else if (trimmedValue.length > 50) {
                            isLesseeValid = false;
                            lesseeError = 'Name must not exceed 50 characters';
                          } else {
                            isLesseeValid = true;
                            lesseeError = null;
                          }
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF6B7280),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: isLesseeValid
                      ? () async {
                          // Final validation before saving
                          final newLesseeName = lesseeController.text.trim();

                          if (newLesseeName.isEmpty) {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  title: Row(
                                    children: [
                                      Icon(
                                        Icons.error_outline,
                                        color: Colors.red,
                                        size: 28,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Validation Error',
                                        style: GoogleFonts.inter(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF1F2937),
                                        ),
                                      ),
                                    ],
                                  ),
                                  content: Text(
                                    'Lessee name cannot be empty or null. Please enter a valid name.',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      color: const Color(0xFF6B7280),
                                    ),
                                  ),
                                  actions: [
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFF18651C,
                                        ),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        'OK',
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                            return;
                          }

                          if (!RegExp(r'^[a-zA-Z\s]+$')
                              .hasMatch(newLesseeName)) {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  title: Row(
                                    children: [
                                      Icon(
                                        Icons.error_outline,
                                        color: Colors.red,
                                        size: 28,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Invalid Format',
                                        style: GoogleFonts.inter(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF1F2937),
                                        ),
                                      ),
                                    ],
                                  ),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'The lessee name format is invalid.',
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF1F2937),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Allowed format:',
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF6B7280),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '• Letters only (A-Z, a-z)\n• Spaces between words\n• Must be 2-50 characters',
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          color: const Color(0xFF6B7280),
                                          height: 1.5,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF3F4F6),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Examples:',
                                              style: GoogleFonts.inter(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: const Color(0xFF1F2937),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '✓ John Doe\n✓ Mary Jane Smith\n✓ Robert Johnson\n✓ Maria Santos',
                                              style: GoogleFonts.inter(
                                                fontSize: 12,
                                                color: const Color(0xFF059669),
                                                height: 1.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFF18651C,
                                        ),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        'OK',
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                            return;
                          }

                          if (newLesseeName.length < 2 ||
                              newLesseeName.length > 50) {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  title: Row(
                                    children: [
                                      Icon(
                                        Icons.error_outline,
                                        color: Colors.red,
                                        size: 28,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Invalid Length',
                                        style: GoogleFonts.inter(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF1F2937),
                                        ),
                                      ),
                                    ],
                                  ),
                                  content: Text(
                                    'Lessee name must be between 2 and 50 characters.',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      color: const Color(0xFF6B7280),
                                    ),
                                  ),
                                  actions: [
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFF18651C,
                                        ),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        'OK',
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                            return;
                          }

                          try {
                            // Show loading
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => AlertDialog(
                                content: Row(
                                  children: [
                                    CircularProgressIndicator(),
                                    SizedBox(width: 16),
                                    Text('Updating lessee name...'),
                                  ],
                                ),
                              ),
                            );

                            // Update the contract with new lessee name
                            await contract.reference.update({
                              'leessee': newLesseeName,
                            });

                            // Close loading dialog
                            if (Navigator.of(context).canPop()) {
                              Navigator.of(context).pop();
                            }

                            // Close edit modal
                            Navigator.of(context).pop();

                            // Show success message
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Lessee name updated successfully',
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );

                            // Refresh the page
                            setState(() {});
                          } catch (e) {
                            // Close loading dialog
                            if (Navigator.of(context).canPop()) {
                              Navigator.of(context).pop();
                            }

                            // Show error message
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error updating lessee name: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isLesseeValid
                        ? const Color(0xFF18651C)
                        : const Color(0xFFD1D5DB),
                    foregroundColor:
                        isLesseeValid ? Colors.white : const Color(0xFF9CA3AF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Save Changes',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildEditLesseeTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String? Function(String?) validator,
    required bool isValid,
    required String? errorText,
    required Function(String) onChanged,
  }) {
    final hasError = errorText != null && errorText.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '$label *',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ),
            if (isValid)
              Icon(Icons.check_circle_rounded, color: Colors.green, size: 20),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          onChanged: onChanged,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(color: const Color(0xFF9CA3AF)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: hasError
                    ? Colors.red
                    : (isValid ? Colors.transparent : const Color(0xFFD1D5DB)),
                width: hasError ? 1 : (isValid ? 0 : 1),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: hasError
                    ? Colors.red
                    : (isValid ? Colors.transparent : const Color(0xFFD1D5DB)),
                width: hasError ? 1 : (isValid ? 0 : 1),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: hasError
                    ? Colors.red
                    : (isValid ? Colors.transparent : const Color(0xFF18651C)),
                width: hasError ? 2 : (isValid ? 0 : 2),
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            filled: true,
            fillColor: hasError
                ? const Color(0xFFFEF2F2)
                : (isValid ? const Color(0xFFF0FDF4) : Colors.white),
          ),
          style: GoogleFonts.inter(
            fontSize: 14,
            color: const Color(0xFF1F2937),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.error_outline,
                size: 16,
                color: Colors.red,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  errorText,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.red,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Future<void> _showEditApplicantModal(ContractRecord contract) async {
    // Get the last applicant details
    final lastApplicantName =
        contract.applicantName.isNotEmpty ? contract.applicantName.last : '';
    final lastApplicantAddress = contract.applcantAddress.isNotEmpty
        ? contract.applcantAddress.last
        : '';
    final lastApplicantContact = contract.applicantContactNumber.isNotEmpty
        ? '0${contract.applicantContactNumber.last.toString()}'
        : '';

    // Create controllers for the form fields
    final nameController = TextEditingController(text: lastApplicantName);
    final addressController = TextEditingController(text: lastApplicantAddress);
    final contactController = TextEditingController(text: lastApplicantContact);

    // Validation state - initialize as valid if fields already have data
    bool isNameValid = lastApplicantName.trim().isNotEmpty &&
        RegExp(r'^[a-zA-Z\s]+$').hasMatch(lastApplicantName.trim()) &&
        lastApplicantName.trim().length >= 2 &&
        lastApplicantName.trim().length <= 50;
    bool isAddressValid = lastApplicantAddress.trim().isNotEmpty &&
        RegExp(
          r'^[A-Za-z0-9\s.,#\-]+$',
        ).hasMatch(lastApplicantAddress.trim()) &&
        lastApplicantAddress.trim().length >= 5;
    bool isContactValid = lastApplicantContact.trim().isNotEmpty &&
        RegExp(r'^09\d{9}$').hasMatch(lastApplicantContact.trim());

    // Error messages for real-time validation
    String? nameError;
    String? addressError;
    String? contactError;

    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: Text(
                'Edit Applicant Details',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
              ),
              content: Container(
                width: 500,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Current Last Applicant Details Display
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFFD1D5DB),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Current Applicant Details',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1F2937),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildDisplayRow(
                            'Name',
                            lastApplicantName.isNotEmpty
                                ? lastApplicantName
                                : 'No applicant name',
                          ),
                          _buildDisplayRow(
                            'Contact',
                            lastApplicantContact.isNotEmpty
                                ? lastApplicantContact
                                : 'No contact number',
                          ),
                          _buildDisplayRow(
                            'Address',
                            lastApplicantAddress.isNotEmpty
                                ? lastApplicantAddress
                                : 'No address',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Edit Section Header
                    Text(
                      'Edit Applicant Details',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Applicant Name Field
                    _buildEditApplicantTextField(
                      controller: nameController,
                      label: 'Applicant Name',
                      hint: 'Enter applicant full name',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Applicant name is required';
                        }
                        if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value.trim())) {
                          return 'Name must contain only letters and spaces';
                        }
                        if (value.trim().length < 2 ||
                            value.trim().length > 50) {
                          return 'Name must be 2-50 characters';
                        }
                        return null;
                      },
                      isValid: isNameValid,
                      errorText: nameError,
                      onChanged: (value) {
                        setModalState(() {
                          final trimmed = value.trim();
                          if (trimmed.isEmpty) {
                            isNameValid = false;
                            nameError = 'Applicant name is required';
                          } else if (!RegExp(
                            r'^[a-zA-Z\s]+$',
                          ).hasMatch(trimmed)) {
                            isNameValid = false;
                            nameError =
                                'Name must contain only letters and spaces';
                          } else if (trimmed.length < 2) {
                            isNameValid = false;
                            nameError = 'Name must be at least 2 characters';
                          } else if (trimmed.length > 50) {
                            isNameValid = false;
                            nameError = 'Name must not exceed 50 characters';
                          } else {
                            isNameValid = true;
                            nameError = null;
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Contact Number Field
                    _buildEditApplicantTextField(
                      controller: contactController,
                      label: 'Mobile Contact Number',
                      hint: 'Enter 11-digit mobile number',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Mobile contact number is required';
                        }
                        if (!RegExp(r'^09\d{9}$').hasMatch(value.trim())) {
                          return 'Mobile contact number must be 11 digits starting with 09';
                        }
                        return null;
                      },
                      isValid: isContactValid,
                      errorText: contactError,
                      onChanged: (value) {
                        setModalState(() {
                          final trimmed = value.trim();
                          if (trimmed.isEmpty) {
                            isContactValid = false;
                            contactError = 'Mobile contact number is required';
                          } else if (!RegExp(r'^09\d{9}$').hasMatch(trimmed)) {
                            isContactValid = false;
                            contactError =
                                'Must be 11 digits starting with 09 (e.g., 09123456789)';
                          } else {
                            isContactValid = true;
                            contactError = null;
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Address Field
                    _buildEditApplicantTextField(
                      controller: addressController,
                      label: 'Residential Address',
                      hint: 'Enter residential address',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Residential address is required';
                        }
                        if (!RegExp(
                          r'^[A-Za-z0-9\s.,#\-]+$',
                        ).hasMatch(value.trim())) {
                          return 'Address contains invalid characters';
                        }
                        if (value.trim().length < 5) {
                          return 'Address must be at least 5 characters';
                        }
                        return null;
                      },
                      isValid: isAddressValid,
                      errorText: addressError,
                      onChanged: (value) {
                        setModalState(() {
                          final trimmed = value.trim();
                          if (trimmed.isEmpty) {
                            isAddressValid = false;
                            addressError = 'Residential address is required';
                          } else if (!RegExp(
                            r'^[A-Za-z0-9\s.,#\-]+$',
                          ).hasMatch(trimmed)) {
                            isAddressValid = false;
                            addressError =
                                'Only letters, numbers, spaces, and .,#- are allowed';
                          } else if (trimmed.length < 5) {
                            isAddressValid = false;
                            addressError =
                                'Address must be at least 5 characters';
                          } else {
                            isAddressValid = true;
                            addressError = null;
                          }
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF6B7280),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: isNameValid && isAddressValid && isContactValid
                      ? () async {
                          try {
                            // Validate contact number uniqueness first
                            final isContactUnique =
                                await _validateEditApplicantContactNumberUniqueness(
                              nameController.text.trim(),
                              contactController.text.trim(),
                            );

                            if (!isContactUnique) {
                              print(
                                  'Contact number uniqueness validation failed!');
                              return; // Stop update if contact number is not unique
                            }

                            // Show loading
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => AlertDialog(
                                content: Row(
                                  children: [
                                    CircularProgressIndicator(),
                                    SizedBox(width: 16),
                                    Text('Updating applicant details...'),
                                  ],
                                ),
                              ),
                            );

                            // Update the contract with new applicant details
                            final updateData = <String, dynamic>{};

                            // Update applicant name (replace last entry)
                            if (contract.applicantName.isNotEmpty) {
                              final updatedNames = List<String>.from(
                                contract.applicantName,
                              );
                              updatedNames[updatedNames.length - 1] =
                                  nameController.text.trim();
                              updateData['applicantName'] = updatedNames;
                            }

                            // Update applicant address (replace last entry)
                            if (contract.applcantAddress.isNotEmpty) {
                              final updatedAddresses = List<String>.from(
                                contract.applcantAddress,
                              );
                              updatedAddresses[updatedAddresses.length - 1] =
                                  addressController.text.trim();
                              updateData['applcantAddress'] = updatedAddresses;
                            }

                            // Update applicant contact (replace last entry)
                            if (contract.applicantContactNumber.isNotEmpty) {
                              final updatedContacts = List<int>.from(
                                contract.applicantContactNumber,
                              );
                              updatedContacts[updatedContacts.length - 1] =
                                  int.tryParse(contactController.text.trim()) ??
                                      0;
                              updateData['applicantContactNumber'] =
                                  updatedContacts;
                            }

                            // Save to Firestore
                            await contract.reference.update(updateData);

                            // Close loading dialog
                            if (Navigator.of(context).canPop()) {
                              Navigator.of(context).pop();
                            }

                            // Close edit modal
                            Navigator.of(context).pop();

                            // Show success message
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Applicant details updated successfully',
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );

                            // Refresh the page
                            setState(() {});
                          } catch (e) {
                            // Close loading dialog
                            if (Navigator.of(context).canPop()) {
                              Navigator.of(context).pop();
                            }

                            // Show error message
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Error updating applicant details: $e',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isNameValid && isAddressValid && isContactValid
                            ? const Color(0xFF18651C)
                            : const Color(0xFFD1D5DB),
                    foregroundColor:
                        isNameValid && isAddressValid && isContactValid
                            ? Colors.white
                            : const Color(0xFF9CA3AF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Save Changes',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildEditApplicantTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String? Function(String?) validator,
    required bool isValid,
    required Function(String) onChanged,
    String? errorText,
  }) {
    // Determine if field has been touched (has content)
    final hasTouched = controller.text.isNotEmpty;
    final showError = hasTouched && !isValid && errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '$label *',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ),
            if (isValid)
              Icon(Icons.check_circle_rounded, color: Colors.green, size: 20),
            if (showError)
              Icon(Icons.error_outline, color: Colors.red, size: 20),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          onChanged: onChanged,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(color: const Color(0xFF9CA3AF)),
            errorText: showError ? errorText : null,
            errorStyle: GoogleFonts.inter(fontSize: 12, color: Colors.red),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: showError
                    ? Colors.red
                    : (isValid ? Colors.transparent : const Color(0xFFD1D5DB)),
                width: showError ? 1 : (isValid ? 0 : 1),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: showError
                    ? Colors.red
                    : (isValid ? Colors.transparent : const Color(0xFFD1D5DB)),
                width: showError ? 1 : (isValid ? 0 : 1),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: showError
                    ? Colors.red
                    : (isValid ? Colors.transparent : const Color(0xFF18651C)),
                width: showError ? 2 : (isValid ? 0 : 2),
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            filled: true,
            fillColor: showError
                ? const Color(0xFFFEF2F2)
                : (isValid ? const Color(0xFFF0FDF4) : Colors.white),
          ),
          style: GoogleFonts.inter(
            fontSize: 14,
            color: const Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }

  Widget _buildDisplayRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF6B7280),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF1F2937),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Validate contact number uniqueness across different applicants for edit applicant details
  Future<bool> _validateEditApplicantContactNumberUniqueness(
    String applicantName,
    String contactNumber,
  ) async {
    if (contactNumber.isEmpty || applicantName.isEmpty) {
      return true; // Skip if empty (handled by other validation)
    }

    try {
      // Convert contact number to integer for querying
      final contactNumberInt = int.tryParse(contactNumber);
      if (contactNumberInt == null) {
        return true; // Skip if invalid format
      }

      // Query Firebase for contracts with this contact number
      final querySnapshot = await FirebaseFirestore.instance
          .collection('contract')
          .where('applicantContactNumber', arrayContains: contactNumberInt)
          .get();

      // Check if any contract with this contact number belongs to a different applicant
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final applicantNames = data['applicantName'] as List<dynamic>?;

        if (applicantNames != null && applicantNames.isNotEmpty) {
          // Check if any name in the list doesn't match current applicant
          for (var name in applicantNames) {
            final existingName = name.toString().trim().toLowerCase();
            final currentName = applicantName.toLowerCase();

            if (existingName != currentName) {
              // Contact number is used by a different applicant
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    title: Row(
                      children: [
                        Icon(
                          Icons.warning_rounded,
                          color: const Color(0xFFEF4444),
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Contact Number Already Used',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1F2937),
                            ),
                          ),
                        ),
                      ],
                    ),
                    content: Text(
                      'This contact number ($contactNumber) is already registered to a different applicant: "${name}".\n\nPlease use a different contact number or verify the applicant name.',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          'OK',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF18651C),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
              return false;
            }
          }
        }
      }

      // Contact number is either not used or used by the same applicant
      return true;
    } catch (e) {
      print('Error validating contact number uniqueness: $e');
      // Allow saving if there's an error (don't block user)
      return true;
    }
  }

  Future<void> _showRenewContractModal(ContractRecord contract) async {
    // Reset renewal date and calculations
    _model.renewalExpirationDate = null;
    _model.contractDurationController?.clear();
    _model.totalContractValueController?.clear();

    // Clear payer name controller for fresh input
    _model.payerNameController?.clear();
    _model.payerNameError = null;

    // Set a default expiration date based on current contract expiration (5 years from current expiration)
    final currentExpiration = contract.dateofexpiration ?? DateTime.now();
    _model.renewalExpirationDate = DateTime(
      currentExpiration.year + 5,
      currentExpiration.month,
      currentExpiration.day,
    );

    // Calculate initial values based on current contract expiration
    final int currentYear = currentExpiration.year;
    final int expirationYear = _model.renewalExpirationDate!.year;
    final int duration = expirationYear - currentYear;

    if (duration > 0) {
      _model.contractDurationController?.text = duration.toString();

      // Calculate total contract value: (duration × renewal fee) - renewal fee
      final double renewalFee = double.tryParse(contract.amount ?? '0') ?? 0.0;
      final double totalContractValue = (duration * renewalFee) - renewalFee;

      _model.totalContractValueController?.text =
          totalContractValue.round().toString();

      print(
        'DEBUG: Initial calculation - Duration: $duration, Renewal Fee: $renewalFee, Total: ${totalContractValue.round()}',
      );
    }

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Renew Contract',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
              ),
              content: Container(
                width: 500,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Contract Information Section
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Contract Information',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1F2937),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Contract ID:',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: const Color(0xFF6B7280),
                                  ),
                                ),
                                Text(
                                  '${contract.reference.id}',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF1F2937),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  contract.type.toLowerCase() == 'nitche'
                                      ? 'Niche #:'
                                      : 'Location:',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF6B7280),
                                  ),
                                ),
                                Text(
                                  '${contract.location}',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF1F2937),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Current Expiration:',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: const Color(0xFF6B7280),
                                  ),
                                ),
                                Text(
                                  '${contract.dateofexpiration != null ? '${contract.dateofexpiration!.month}/${contract.dateofexpiration!.day}/${contract.dateofexpiration!.year}' : 'N/A'}',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF1F2937),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Current Balance:',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: const Color(0xFF6B7280),
                                  ),
                                ),
                                Text(
                                  'Php. ${contract.balance}',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF000000),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Contract Terms & Financial Details Section
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.description_rounded,
                                  color: const Color(0xFF059669),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Contract Terms & Financial Details',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF1F2937),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Payer Name Field
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Payer Name*',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF1F2937),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _model.payerNameController,
                                  focusNode: _model.payerNameFocusNode,
                                  autofocus: false,
                                  obscureText: false,
                                  onChanged: (value) {
                                    setState(() {
                                      // Real-time validation for payer name
                                      if (value.trim().isEmpty) {
                                        _model.payerNameError =
                                            'Payer name is required';
                                      } else if (!RegExp(
                                        r'^[a-zA-Z\s]+$',
                                      ).hasMatch(value)) {
                                        _model.payerNameError =
                                            'Only letters and spaces are allowed';
                                      } else if (value.trim().length < 2) {
                                        _model.payerNameError =
                                            'Name must be at least 2 characters';
                                      } else {
                                        _model.payerNameError = null;
                                      }
                                    });
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'Enter payer name',
                                    hintStyle: GoogleFonts.inter(
                                      fontSize: 14,
                                      color: const Color(0xFF9CA3AF),
                                    ),
                                    errorText: _model.payerNameError,
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: _model.payerNameError != null
                                            ? const Color(0xFFEF4444)
                                            : const Color(0xFFD1D5DB),
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: _model.payerNameError != null
                                            ? const Color(0xFFEF4444)
                                            : const Color(0xFF18651C),
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                        color: Color(0xFFEF4444),
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                        color: Color(0xFFEF4444),
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                  ),
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: const Color(0xFF1F2937),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Payer name is required';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Location (read-only)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Assigned Location',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF1F2937),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF3F4F6),
                                    border: Border.all(
                                      color: const Color(0xFFD1D5DB),
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    contract.location,
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      color: const Color(0xFF6B7280),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // New Effective Date (Current Timestamp)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'New Effective Date',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF1F2937),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF3F4F6),
                                    border: Border.all(
                                      color: const Color(0xFFD1D5DB),
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.access_time_rounded,
                                        size: 16,
                                        color: const Color(0xFF6B7280),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Will be set to current timestamp when renewal is confirmed',
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          color: const Color(0xFF6B7280),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Renewal Fee and Expiration Date Row
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Renewal Fee (₱)*',
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF1F2937),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF9FAFB),
                                          border: Border.all(
                                            color: const Color(0xFFD1D5DB),
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          '₱${contract.amount ?? 0}',
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            color: const Color(0xFF6B7280),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'New Expiration Date*',
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF1F2937),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      InkWell(
                                        onTap: () async {
                                          // Get current contract expiration date for dynamic date range
                                          final currentExpiration =
                                              contract.dateofexpiration ??
                                                  DateTime.now();
                                          // Set minDate to new expiration date (current + 5 years)
                                          // This disables all years before the new expiration year
                                          final minDate = DateTime(
                                            currentExpiration.year + 5,
                                            currentExpiration.month,
                                            currentExpiration.day,
                                          );
                                          // Remove limit - allow any future date selection
                                          final maxDate = DateTime(2100);

                                          final DateTime? pickedDate =
                                              await showDatePicker(
                                            context: context,
                                            initialDate:
                                                _model.renewalExpirationDate ??
                                                    minDate,
                                            firstDate: minDate,
                                            lastDate: maxDate,
                                            builder: (context, child) {
                                              return Theme(
                                                data:
                                                    Theme.of(context).copyWith(
                                                  colorScheme:
                                                      const ColorScheme.light(
                                                    primary: Color(
                                                      0xFF18651C,
                                                    ),
                                                    onPrimary: Colors.white,
                                                    surface: Colors.white,
                                                    onSurface: Color(
                                                      0xFF1F2937,
                                                    ),
                                                  ),
                                                ),
                                                child: child!,
                                              );
                                            },
                                          );
                                          if (pickedDate != null &&
                                              pickedDate !=
                                                  _model
                                                      .renewalExpirationDate) {
                                            setState(() {
                                              _model.renewalExpirationDate =
                                                  pickedDate;

                                              // Calculate new values directly based on current contract expiration
                                              final currentExpiration =
                                                  contract.dateofexpiration ??
                                                      DateTime.now();
                                              final int currentYear =
                                                  currentExpiration.year;
                                              final int expirationYear =
                                                  pickedDate.year;
                                              final int duration =
                                                  expirationYear - currentYear;

                                              if (duration > 0) {
                                                _model
                                                    .contractDurationController
                                                    ?.text = duration.toString();

                                                // Calculate total contract value: (duration × renewal fee) - renewal fee
                                                final double renewalFee =
                                                    double.tryParse(
                                                          contract.amount ??
                                                              '0',
                                                        ) ??
                                                        0.0;
                                                final double
                                                    totalContractValue =
                                                    (duration * renewalFee) -
                                                        renewalFee;

                                                _model.totalContractValueController
                                                        ?.text =
                                                    totalContractValue
                                                        .round()
                                                        .toString();

                                                print(
                                                  'DEBUG: Date picker calculation - Duration: $duration, Renewal Fee: $renewalFee, Total: ${totalContractValue.round()}',
                                                );
                                              }
                                            });
                                          }
                                        },
                                        child: Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                            horizontal: 16,
                                          ),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: const Color(0xFFD1D5DB),
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.calendar_today_rounded,
                                                color: const Color(0xFF6B7280),
                                                size: 20,
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Text(
                                                  _model.renewalExpirationDate !=
                                                          null
                                                      ? dateTimeFormat(
                                                          'M/d/y',
                                                          _model
                                                              .renewalExpirationDate!,
                                                        )
                                                      : 'Select date',
                                                  style: GoogleFonts.inter(
                                                    fontSize: 14,
                                                    color:
                                                        _model.renewalExpirationDate !=
                                                                null
                                                            ? const Color(
                                                                0xFF1F2937,
                                                              )
                                                            : const Color(
                                                                0xFF6B7280,
                                                              ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Auto-calculated fields row
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Contract Duration (Years)',
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF1F2937),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                          horizontal: 16,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF3F4F6),
                                          border: Border.all(
                                            color: const Color(0xFFD1D5DB),
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          _model.contractDurationController
                                                  ?.text ??
                                              'Auto-calculated',
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            color: const Color(0xFF6B7280),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Total Contract Value (₱)',
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF1F2937),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                          horizontal: 16,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF3F4F6),
                                          border: Border.all(
                                            color: const Color(0xFFD1D5DB),
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          _model.totalContractValueController
                                                      ?.text.isNotEmpty ==
                                                  true
                                              ? '₱${_model.totalContractValueController?.text}'
                                              : 'Auto-calculated',
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            color: const Color(0xFF6B7280),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Renewal Details:',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1F2937),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '• New effective date will be set to current timestamp (when renewal happens)',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                            Text(
                              '• Contract will be extended to the selected date',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.inter(color: const Color(0xFF6B7280)),
                  ),
                ),
                ElevatedButton(
                  onPressed: _model.renewalExpirationDate != null &&
                          (_model.payerNameController?.text.trim().isNotEmpty ??
                              false) &&
                          _model.payerNameError == null
                      ? () async {
                          // Get renewal details for transaction summary
                          final renewalFee =
                              double.tryParse(contract.amount ?? '0') ?? 0.0;
                          final payerName = (_model.payerNameController?.text
                                      .trim()
                                      .isNotEmpty ??
                                  false)
                              ? _model.payerNameController!.text.trim()
                              : contract.leessee ?? 'Contract Renewal';
                          final newExpirationDate =
                              _model.renewalExpirationDate!;

                          // Close Renew Contract modal first
                          Navigator.of(context).pop();
                          // Show transaction summary before renewal
                          final location = contract.location;
                          final contractDuration = int.tryParse(
                                _model.contractDurationController?.text ?? '0',
                              ) ??
                              0;
                          final totalContractValue = int.tryParse(
                                _model.totalContractValueController?.text
                                        .replaceAll('₱', '')
                                        .replaceAll(',', '') ??
                                    '0',
                              ) ??
                              0;
                          await _showRenewalTransactionSummary(
                            contract,
                            payerName,
                            renewalFee.round(),
                            newExpirationDate,
                            location,
                            contractDuration,
                            totalContractValue,
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF18651C),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Renew Contract',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showContractNotificationModal() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Contract Notification',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1F2937),
            ),
          ),
          content: Container(
            width: 500,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Notification Options Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.notifications_active_rounded,
                            color: const Color(0xFF059669),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Notification',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1F2937),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Notification Type Selection
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Expiration Reminder Option
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              border: Border.all(
                                color: const Color(0xFFE5E7EB),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.schedule_rounded,
                                  color: const Color(0xFF059669),
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Expiration Reminder',
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF1F2937),
                                        ),
                                      ),
                                      Text(
                                        'Send notifications for contracts expiring soon',
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          color: const Color(0xFF6B7280),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: const Color(0xFF6B7280),
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Payment Reminder Option
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              border: Border.all(
                                color: const Color(0xFFE5E7EB),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.payment_rounded,
                                  color: const Color(0xFF059669),
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Payment Reminder',
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF1F2937),
                                        ),
                                      ),
                                      Text(
                                        'Send notifications for outstanding balances',
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          color: const Color(0xFF6B7280),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: const Color(0xFF6B7280),
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Renewal Notice Option
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              border: Border.all(
                                color: const Color(0xFFE5E7EB),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.refresh_rounded,
                                  color: const Color(0xFF059669),
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Renewal Notice',
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF1F2937),
                                        ),
                                      ),
                                      Text(
                                        'Send notifications for contract renewals',
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          color: const Color(0xFF6B7280),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: const Color(0xFF6B7280),
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Info Section
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Notification Info:',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '• Notifications will be sent to contract lessees',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                      Text(
                        '• You can customize notification settings',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Close',
                style: GoogleFonts.inter(color: const Color(0xFF6B7280)),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                // Implement notification sending logic
                await _sendContractNotifications();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF18651C),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Send Notifications',
                style: GoogleFonts.inter(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _sendContractNotifications() async {
    try {
      // Get contracts expiring in 1 month
      final contractsExpiringSoon = await _getContractsExpiringInOneMonth();

      if (contractsExpiringSoon.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No contracts expiring in the next month'),
              backgroundColor: Color(0xFF6B7280),
            ),
          );
        }
        return;
      }

      // Get all users from the users collection
      final usersQuery = await UsersRecord.collection.get();

      // Update each user's notification settings with specific contract info
      final batch = FirebaseFirestore.instance.batch();

      for (final userDoc in usersQuery.docs) {
        batch.update(userDoc.reference, {
          'notifTrue': true,
          'notification':
              '${contractsExpiringSoon.length} contract(s) expiring in 1 month. Check contract details for more information.',
          'notificationDate': DateTime.now().toIso8601String(),
        });
      }

      // Commit the batch update
      await batch.commit();

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Contract expiration notifications sent to ${usersQuery.docs.length} users for ${contractsExpiringSoon.length} contracts',
            ),
            backgroundColor: const Color(0xFF059669),
          ),
        );
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending notifications: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  // Get contracts expiring in exactly 1 month
  Future<List<ContractRecord>> _getContractsExpiringInOneMonth() async {
    try {
      final now = DateTime.now();
      final oneMonthFromNow = DateTime(now.year, now.month + 1, now.day);
      final oneMonthFromNowEnd = DateTime(
        now.year,
        now.month + 1,
        now.day,
        23,
        59,
        59,
      );

      print(
        'Checking contracts expiring between $oneMonthFromNow and $oneMonthFromNowEnd',
      );

      final contracts = await queryContractRecordOnce(
        queryBuilder: (contractRecord) {
          return contractRecord
              .where(
                'dateofexpiration',
                isGreaterThanOrEqualTo: oneMonthFromNow,
              )
              .where(
                'dateofexpiration',
                isLessThanOrEqualTo: oneMonthFromNowEnd,
              )
              .where('contractstatus', isEqualTo: 'active');
        },
      );

      print('Found ${contracts.length} contracts expiring in 1 month');
      return contracts;
    } catch (e) {
      print('Error getting contracts expiring in 1 month: $e');
      return [];
    }
  }

  Future<void> _updateContractForRenewal(
    ContractRecord contract,
    DateTime newExpirationDate,
    int totalContractValue,
    int renewalFee,
    int contractDuration,
  ) async {
    try {
      // Update contract with new dates and calculated balance
      await contract.reference.update(
        createContractRecordData(
          dateEffective:
              DateTime.now(), // Set effective date to current timestamp
          dateofexpiration: newExpirationDate, // Set new expiration date
          balance:
              totalContractValue, // Update balance with new total contract value
          totalContraBalance:
              totalContractValue.toDouble(), // Update total contract balance
          initialfee:
              renewalFee.toDouble(), // Update initial fee with renewal fee
          years: contractDuration
              .toString(), // Update years with calculated duration
          stringEffectivedate: contract.dateofexpiration?.toString() ??
              '', // String effective date
          stringExpirationdate:
              newExpirationDate.toString(), // String expiration date
        ),
      );

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Contract renewed successfully!\nNew expiration: ${newExpirationDate.month}/${newExpirationDate.day}/${newExpirationDate.year}\nRenewal fee: ₱$renewalFee\nNew balance: ₱$totalContractValue',
            ),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating contract: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  Future<void> _processContractRenewal(ContractRecord contract) async {
    try {
      if (_model.renewalExpirationDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a new expiration date'),
            backgroundColor: Color(0xFFEF4444),
          ),
        );
        return;
      }

      // Use contract amount as renewal fee
      final double renewalFee = double.tryParse(contract.amount ?? '0') ?? 0.0;
      if (renewalFee <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Contract amount is invalid for renewal'),
            backgroundColor: Color(0xFFEF4444),
          ),
        );
        return;
      }

      // Calculate new contract duration and total contract value based on current contract expiration
      final currentExpiration = contract.dateofexpiration ?? DateTime.now();
      final int currentYear = currentExpiration.year;
      final int expirationYear = _model.renewalExpirationDate!.year;
      final int duration = expirationYear - currentYear;

      if (duration <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Expiration date must be in the future'),
            backgroundColor: Color(0xFFEF4444),
          ),
        );
        return;
      }

      // Calculate new total contract value: (duration × renewal fee) - renewal fee
      final double newTotalContractValue = (duration * renewalFee) - renewalFee;

      // Update contract with new dates and calculated balance
      // New effective date = current timestamp (when renewal happens)
      // New expiration date = selected date
      // New balance = calculated total contract value
      // New initial fee = renewal fee
      // New years = calculated duration
      // Update string date fields for consistency
      await contract.reference.update(
        createContractRecordData(
          dateEffective:
              DateTime.now(), // Set effective date to current timestamp
          dateofexpiration:
              _model.renewalExpirationDate, // Set new expiration date
          balance: newTotalContractValue
              .round(), // Update balance with new total contract value
          totalContraBalance:
              newTotalContractValue, // Update total contract balance
          initialfee: renewalFee, // Update initial fee with renewal fee
          years: duration.toString(), // Update years with calculated duration
          stringEffectivedate: contract.dateofexpiration?.toString() ??
              '', // String effective date
          stringExpirationdate: _model.renewalExpirationDate?.toString() ??
              '', // String expiration date
        ),
      );

      // Get the last deceased name from decFullName array
      final decFullNameList = contract.decFullName ?? [];
      final lastDeceasedName =
          decFullNameList.isNotEmpty ? decFullNameList.last.toString() : '';

      // Create transaction record for contract renewal with P2P payment type
      await TransactionsRecord.collection.doc().set({
        ...createTransactionsRecordData(
          name: contract.leessee ?? 'Contract Renewal',
          loc: contract.location,
          paymenttype: 'P2P',
          amount: renewalFee.round(),
          status: 'completed',
          type: 'renewal',
          remBalance: newTotalContractValue.round().toString(),
          deceased: lastDeceasedName,
          contractId: contract.reference.id,
        ),
        ...mapToFirestore({
          'transaction_date': FieldValue.serverTimestamp(),
        }),
      });

      // Show success message with new balance information
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Contract renewed successfully!\nNew expiration: ${_model.renewalExpirationDate!.month}/${_model.renewalExpirationDate!.day}/${_model.renewalExpirationDate!.year}\nRenewal fee: ₱${renewalFee}\nNew balance: ₱${newTotalContractValue.round()}',
            ),
            backgroundColor: const Color(0xFF10B981),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error renewing contract: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  Future<void> _processStripeRenewalPayment(
    ContractRecord contract,
    String payerName,
    int renewalFee,
    DateTime newExpirationDate,
    String location,
    int contractDuration,
    int totalContractValue,
  ) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text('Processing renewal payment...'),
              ],
            ),
          );
        },
      );

      // Create payment intent
      final paymentIntent = await _createPaymentIntent(
        amount: renewalFee,
        payerName: payerName,
        location: contract.location,
        contractId: contract.reference.id,
        currency: 'php',
      );

      // For demo purposes, simulate successful payment
      await Future.delayed(
        const Duration(milliseconds: 200),
      ); // Simulate payment processing

      final bool paymentSuccess = true; // Simulate successful payment

      if (paymentSuccess) {
        // Close loading dialog
        Navigator.of(context).pop();

        // Update contract with new expiration date and balance
        await contract.reference.update(
          createContractRecordData(
            dateEffective:
                DateTime.now(), // Set effective date to current timestamp
            dateofexpiration: newExpirationDate, // Set new expiration date
            balance:
                totalContractValue, // Update balance with new total contract value
          ),
        );

        // Get the last deceased name from decFullName array
        final decFullNameList = contract.decFullName ?? [];
        final lastDeceasedName =
            decFullNameList.isNotEmpty ? decFullNameList.last.toString() : '';

        // Create transaction record with Stripe payment type
        final transactionDocRef = TransactionsRecord.collection.doc();
        await transactionDocRef.set({
          ...createTransactionsRecordData(
            name: payerName,
            loc: contract.location,
            paymenttype: 'Onsite Contract Renew Downpayment',
            amount: renewalFee,
            status: 'completed',
            type: contract.type?.toLowerCase() == 'nitche' ? 'nitche' : 'Lot',
            remBalance: totalContractValue.toString(),
            deceased: lastDeceasedName,
            contractId: contract.reference.id,
            paymentMethod: 'Cash',
          ),
          ...mapToFirestore({
            'transaction_date': FieldValue.serverTimestamp(),
            'stripe_transaction_id': paymentIntent['id'] ?? 'unknown',
          }),
        });

        // Generate and show renewal receipt (same as payment balance flow)
        await _generateAndShowRenewalReceipt(
          contract: contract,
          payerName: payerName,
          renewalFee: renewalFee,
          newExpirationDate: newExpirationDate,
          location: location,
          contractDuration: contractDuration,
          totalContractValue: totalContractValue,
          paymentId: paymentIntent['id'] ?? 'unknown',
          transactionId: transactionDocRef.id,
        );

        // Show success modal
        if (mounted) {
          await _showRenewalSuccessModal(
            renewalFee.toString(),
            newExpirationDate,
            totalContractValue.toString(),
          );
        }
      } else {
        // Close loading dialog
        Navigator.of(context).pop();

        // Show payment failed message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Renewal payment failed. Please try again.'),
              backgroundColor: Color(0xFFEF4444),
            ),
          );
        }
      }
    } catch (e) {
      // Close loading dialog if it's open
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error processing renewal payment: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  Future<void> _processRenewalPayment(
    ContractRecord contract,
    String payerName,
    int renewalFee,
    DateTime newExpirationDate,
    String location,
    int contractDuration,
    int totalContractValue,
  ) async {
    print('DEBUG: Starting renewal payment process');
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text('Processing renewal payment...'),
              ],
            ),
          );
        },
      );

      // Stripe is already initialized in initState

      // Create payment intent
      final paymentIntent = await _createPaymentIntent(
        amount: renewalFee,
        currency: 'php',
        contractId: contract.reference.id,
        payerName: payerName,
        location: contract.location,
      );

      // For demo purposes, simulate successful payment
      await Future.delayed(
        const Duration(milliseconds: 25),
      ); // Simulate payment processing

      final bool paymentSuccess = true; // Simulate successful payment

      if (paymentSuccess) {
        // Close loading dialog if it's still open
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }

        // Update contract with new expiration date and balance
        await contract.reference.update(
          createContractRecordData(
            dateEffective:
                DateTime.now(), // Set effective date to current timestamp
            dateofexpiration: newExpirationDate, // Set new expiration date
            balance:
                totalContractValue, // Update balance with new total contract value
          ),
        );

        // Get the last deceased name from decFullName array
        final decFullNameList = contract.decFullName ?? [];
        final lastDeceasedName =
            decFullNameList.isNotEmpty ? decFullNameList.last.toString() : '';

        // Create transaction record with Stripe payment type
        final transactionDocRef = TransactionsRecord.collection.doc();
        await transactionDocRef.set({
          ...createTransactionsRecordData(
            name: payerName,
            loc: contract.location,
            paymenttype: 'Onsite Contract Renew Downpayment',
            amount: renewalFee,
            status: 'completed',
            type: contract.type?.toLowerCase() == 'nitche' ? 'nitche' : 'Lot',
            remBalance: totalContractValue.toString(),
            deceased: lastDeceasedName,
            contractId: contract.reference.id,
            paymentMethod: 'Cash',
          ),
          ...mapToFirestore({
            'transaction_date': FieldValue.serverTimestamp(),
            'stripe_transaction_id': paymentIntent['id'] ?? 'unknown',
          }),
        });

        // Generate and show renewal receipt (same as payment balance flow)
        await _generateAndShowRenewalReceipt(
          contract: contract,
          payerName: payerName,
          renewalFee: renewalFee,
          newExpirationDate: newExpirationDate,
          location: location,
          contractDuration: contractDuration,
          totalContractValue: totalContractValue,
          paymentId: paymentIntent['id'] ?? 'unknown',
          transactionId: transactionDocRef.id,
        );

        // Show success modal
        if (mounted) {
          await _showRenewalSuccessModal(
            renewalFee.toString(),
            newExpirationDate,
            totalContractValue.toString(),
          );

          // Refresh the page to show updated data
          setState(() {});
        }
      } else {
        // Close loading dialog if it's still open
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }

        // Show payment failed message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Renewal payment failed. Please try again.'),
              backgroundColor: Color(0xFFEF4444),
            ),
          );
        }
      }
    } catch (e) {
      // Close loading dialog if it's open
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error processing renewal payment: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  Future<void> _generateAndShowRenewalReceipt({
    required ContractRecord contract,
    required String payerName,
    required int renewalFee,
    required DateTime newExpirationDate,
    required String location,
    required int contractDuration,
    required int totalContractValue,
    required String paymentId,
    required String transactionId,
  }) async {
    try {
      // Create receipt data (same pattern as payment balance)
      final receiptData = {
        'transaction_id': transactionId,
        'receipt_number': 'REN-${DateTime.now().millisecondsSinceEpoch}',
        'payment_id': paymentId,
        'date': DateTime.now().toIso8601String(),
        'contract_id': contract.reference.id,
        'payer_name': payerName,
        'location': location,
        'contract_type': contract.type,
        'amount_paid': renewalFee,
        'contract_duration': contractDuration,
        'new_expiration_date': newExpirationDate.toIso8601String(),
        'total_contract_value': totalContractValue,
        'payment_method': 'Online Payment',
        'status': 'Completed',
      };

      // Show renewal receipt modal (same as payment balance)
      await _showRenewalReceiptModal(receiptData);
    } catch (e) {
      print('Error generating renewal receipt: $e');
    }
  }

  Future<void> _showRenewalReceiptModal(
    Map<String, dynamic> receiptData,
  ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Contract Renewal Receipt',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1F2937),
            ),
          ),
          content: Container(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Receipt Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'BALIWAG CEMETERY',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Contract Renewal Receipt',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Receipt Details
                _buildReceiptRow(
                  'Transaction ID',
                  receiptData['transaction_id'],
                ),
                _buildReceiptRow('Contract ID', receiptData['contract_id']),
                _buildReceiptRow(
                  (receiptData['contract_type']?.toString().toLowerCase() ??
                              '') ==
                          'nitche'
                      ? 'Nitche'
                      : 'Location',
                  receiptData['location'],
                ),
                _buildReceiptRow(
                  'Date',
                  _formatReceiptDate(receiptData['date']),
                ),
                const Divider(),
                _buildReceiptRow(
                  'Renewal Fee',
                  '₱${receiptData['amount_paid']}',
                  isAmount: true,
                ),
                _buildReceiptRow(
                  'Contract Duration',
                  '${receiptData['contract_duration']} years',
                ),
                _buildReceiptRow(
                  'New Expiration Date',
                  _formatReceiptDate(receiptData['new_expiration_date']),
                ),
                _buildReceiptRow(
                  'Total Contract Value',
                  '₱${receiptData['total_contract_value']}',
                  isAmount: true,
                ),
                const Divider(),
                _buildReceiptRow('Payment Method', 'Cash'),
                _buildReceiptRow(
                  'Status',
                  receiptData['status'],
                  isSuccess: true,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Close',
                style: GoogleFonts.inter(color: const Color(0xFF6B7280)),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await _downloadRenewalReceipt(
                  transactionId: receiptData['transaction_id'],
                  paymentId: receiptData['payment_id'],
                  payerName: receiptData['payer_name'],
                  location: receiptData['location'],
                  renewalFee: receiptData['amount_paid'],
                  contractDuration: receiptData['contract_duration'],
                  newExpirationDate: DateTime.parse(
                    receiptData['new_expiration_date'],
                  ),
                  totalContractValue: receiptData['total_contract_value'],
                  contractId: receiptData['contract_id'],
                  contractType: receiptData['contract_type'],
                );
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF18651C),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Download Receipt',
                style: GoogleFonts.inter(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showRenewalReceipt({
    required ContractRecord contract,
    required String payerName,
    required int renewalFee,
    required DateTime newExpirationDate,
    required String location,
    required int contractDuration,
    required int totalContractValue,
    required String paymentId,
    required String transactionId,
  }) async {
    if (!mounted) return;

    try {
      return showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext dialogContext) {
          return PopScope(
            canPop: true, // Allow closing with back button
            child: AlertDialog(
              title: Text(
                'Contract Renewal Receipt',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
              ),
              content: Container(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Receipt Header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Text(
                            'BALIWAG CEMETERY',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1F2937),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Contract Renewal Receipt',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Receipt Details
                    _buildReceiptRow('Transaction ID', transactionId),
                    _buildReceiptRow('Payment ID', paymentId),
                    _buildReceiptRow(
                      'Date',
                      dateTimeFormat('yMMMd', DateTime.now()),
                    ),
                    _buildReceiptRow(
                      'Contract ID',
                      contract.reference.id,
                    ),
                    _buildReceiptRow('Payer Name', payerName),
                    _buildReceiptRow('Location', location),
                    const Divider(),
                    _buildReceiptRow(
                      'Renewal Fee',
                      '₱$renewalFee',
                      isAmount: true,
                    ),
                    _buildReceiptRow(
                      'Contract Duration',
                      '$contractDuration years',
                    ),
                    _buildReceiptRow(
                      'New Expiration Date',
                      dateTimeFormat('yMMMd', newExpirationDate),
                    ),
                    _buildReceiptRow(
                      'Total Contract Value',
                      '₱$totalContractValue',
                      isAmount: true,
                    ),
                    const Divider(),
                    _buildReceiptRow('Payment Method', 'Online Payment'),
                    _buildReceiptRow('Status', 'Completed', isSuccess: true),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    try {
                      Navigator.of(dialogContext).pop();
                    } catch (e) {
                      print('Error closing receipt modal: $e');
                      // Fallback: try to close with main context
                      if (mounted) {
                        Navigator.of(context).pop();
                      }
                    }
                  },
                  child: Text(
                    'Close',
                    style: GoogleFonts.inter(color: const Color(0xFF6B7280)),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await _downloadRenewalReceipt(
                        transactionId: transactionId,
                        paymentId: paymentId,
                        payerName: payerName,
                        location: location,
                        renewalFee: renewalFee,
                        contractDuration: contractDuration,
                        newExpirationDate: newExpirationDate,
                        totalContractValue: totalContractValue,
                        contractId: contract.reference.id,
                        contractType: contract.type,
                      );
                    } catch (e) {
                      print('Error in download button: $e');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF18651C),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Download Receipt',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      print('Error showing renewal receipt: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error showing receipt: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  Future<void> _downloadRenewalReceipt({
    required String transactionId,
    required String paymentId,
    required String payerName,
    required String location,
    required int renewalFee,
    required int contractDuration,
    required DateTime newExpirationDate,
    required int totalContractValue,
    required String contractId,
    String? contractType,
  }) async {
    print('DEBUG: Starting download receipt process');
    try {
      // Create HTML receipt content for PDF generation
      final receiptContent = '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Contract Renewal Receipt</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 20px;
            background-color: white;
        }
        .receipt-container {
            max-width: 400px;
            margin: 0 auto;
            border: 2px solid #1F2937;
            border-radius: 8px;
            padding: 20px;
            background-color: white;
        }
        .header {
            text-align: center;
            border-bottom: 2px solid #1F2937;
            padding-bottom: 15px;
            margin-bottom: 20px;
        }
        .company-name {
            font-size: 18px;
            font-weight: bold;
            color: #1F2937;
            margin-bottom: 5px;
        }
        .receipt-title {
            font-size: 14px;
            color: #6B7280;
        }
        .receipt-details {
            margin-bottom: 20px;
        }
        .detail-row {
            display: flex;
            justify-content: space-between;
            margin-bottom: 8px;
            padding: 4px 0;
        }
        .detail-label {
            font-weight: 500;
            color: #6B7280;
        }
        .detail-value {
            color: #1F2937;
            font-weight: 500;
        }
        .amount {
            color: #059669;
            font-weight: bold;
        }
        .status {
            color: #059669;
            font-weight: bold;
        }
        .divider {
            border-top: 1px solid #D1D5DB;
            margin: 15px 0;
        }
        .footer {
            text-align: center;
            margin-top: 20px;
            padding-top: 15px;
            border-top: 1px solid #D1D5DB;
            color: #6B7280;
            font-size: 12px;
        }
        @media print {
            body { margin: 0; }
            .receipt-container { border: none; box-shadow: none; }
        }
    </style>
</head>
<body>
    <div class="receipt-container">
        <div class="header">
            <div class="company-name">BALIWAG CEMETERY</div>
            <div class="receipt-title">Contract Renewal Receipt</div>
        </div>
        
        <div class="receipt-details">
            <div class="detail-row">
                <span class="detail-label">Transaction ID:</span>
                <span class="detail-value">$transactionId</span>
            </div>
            <div class="detail-row">
                <span class="detail-label">Contract ID:</span>
                <span class="detail-value">$contractId</span>
            </div>
            <div class="detail-row">
                <span class="detail-label">${(contractType?.toString().toLowerCase() ?? '') == 'nitche' ? 'Nitche' : 'Location'}:</span>
                <span class="detail-value">$location</span>
            </div>
            <div class="detail-row">
                <span class="detail-label">Date:</span>
                <span class="detail-value">${dateTimeFormat('yMMMd', DateTime.now())}</span>
            </div>
            <div class="detail-row">
                <span class="detail-label">Payer Name:</span>
                <span class="detail-value">$payerName</span>
            </div>
            
            <div class="divider"></div>
            
            <div class="detail-row">
                <span class="detail-label">Renewal Fee:</span>
                <span class="detail-value amount">₱$renewalFee</span>
            </div>
            <div class="detail-row">
                <span class="detail-label">Contract Duration:</span>
                <span class="detail-value">$contractDuration years</span>
            </div>
            <div class="detail-row">
                <span class="detail-label">New Expiration Date:</span>
                <span class="detail-value">${dateTimeFormat('yMMMd', newExpirationDate)}</span>
            </div>
            <div class="detail-row">
                <span class="detail-label">Total Contract Value:</span>
                <span class="detail-value amount">₱$totalContractValue</span>
            </div>
            
            <div class="divider"></div>
            
            <div class="detail-row">
                <span class="detail-label">Payment Method:</span>
                <span class="detail-value">Cash</span>
            </div>
            <div class="detail-row">
                <span class="detail-label">Status:</span>
                <span class="detail-value status">Completed</span>
            </div>
        </div>
        
        <div class="footer">
            Thank you for your payment!<br>
            BALIWAG CEMETERY
        </div>
    </div>
</body>
</html>
      ''';

      // Create and download as HTML file (can be saved as PDF)
      print('DEBUG: Creating receipt content');
      final bytes = utf8.encode(receiptContent);
      final blob = html.Blob([bytes], 'text/html');
      final url = html.Url.createObjectUrlFromBlob(blob);

      print('DEBUG: Creating download link');
      final anchor = html.AnchorElement(href: url)
        ..setAttribute(
          'download',
          'contract_renewal_receipt_${DateTime.now().millisecondsSinceEpoch}.html',
        )
        ..click();

      html.Url.revokeObjectUrl(url);
      print('DEBUG: Download completed');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Receipt downloaded successfully! You can print it as PDF.',
            ),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      print('Error downloading renewal receipt: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error downloading renewal receipt: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  Widget _buildContractActions(ContractRecord contract) {
    return PopupMenuButton<String>(
      onSelected: (String value) async {
        switch (value) {
          case 'view':
            // View contract details
            await _showContractDetailsModal(contract);
            break;
          case 'editLeessee':
            // Edit leessee (only for Lot contracts)
            await _showEditLesseeNameModal(contract);
            break;
          case 'editApplicant':
            // Edit applicant details (for Lot and Nitche contracts)
            await _showEditApplicantModal(contract);
            break;
          case 'payBalance':
            // Show pay balance modal
            await _showPayBalanceModal(contract);
            break;
          case 'renew':
            // Show renew contract modal
            await _showRenewContractModal(contract);
            break;
        }
      },
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<String>(
          value: 'view',
          child: Row(
            children: [
              Icon(
                Icons.visibility_rounded,
                color: DashboardTheme.secondary,
                size: 18,
              ),
              const SizedBox(width: 12),
              Text('View Details'),
            ],
          ),
        ),
        // Show Edit Leessee only for Lot contracts
        if (contract.type.toLowerCase() == 'lot')
          PopupMenuItem<String>(
            value: 'editLeessee',
            child: Row(
              children: [
                Icon(
                  Icons.edit_rounded,
                  color: DashboardTheme.secondary,
                  size: 18,
                ),
                const SizedBox(width: 12),
                Text('Edit Leessee'),
              ],
            ),
          ),
        // Show Edit Applicant for Lot and Nitche contracts
        if (contract.type.toLowerCase() == 'lot' ||
            contract.type.toLowerCase() == 'nitche')
          PopupMenuItem<String>(
            value: 'editApplicant',
            enabled: contract.applicantName.isNotEmpty &&
                contract.applicantName.last.trim().isNotEmpty &&
                contract.applcantAddress.isNotEmpty &&
                contract.applcantAddress.last.trim().isNotEmpty &&
                contract.applicantContactNumber.isNotEmpty &&
                contract.applicantContactNumber.last != 0,
            child: Row(
              children: [
                Icon(
                  Icons.person_rounded,
                  color: contract.applicantName.isNotEmpty &&
                          contract.applicantName.last.trim().isNotEmpty &&
                          contract.applcantAddress.isNotEmpty &&
                          contract.applcantAddress.last.trim().isNotEmpty &&
                          contract.applicantContactNumber.isNotEmpty &&
                          contract.applicantContactNumber.last != 0
                      ? DashboardTheme.primary
                      : Colors.grey,
                  size: 18,
                ),
                const SizedBox(width: 12),
                Text(
                  'Edit Applicant Details',
                  style: TextStyle(
                    color: contract.applicantName.isNotEmpty &&
                            contract.applicantName.last.trim().isNotEmpty &&
                            contract.applcantAddress.isNotEmpty &&
                            contract.applcantAddress.last.trim().isNotEmpty &&
                            contract.applicantContactNumber.isNotEmpty &&
                            contract.applicantContactNumber.last != 0
                        ? null
                        : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        PopupMenuItem<String>(
          value: 'payBalance',
          enabled: (contract.balance ?? 0) > 0,
          child: Row(
            children: [
              Icon(
                Icons.payment_rounded,
                color: (contract.balance ?? 0) > 0
                    ? DashboardTheme.success
                    : Colors.grey,
                size: 18,
              ),
              const SizedBox(width: 12),
              Text(
                'Pay Balance',
                style: TextStyle(
                  color: (contract.balance ?? 0) > 0 ? null : Colors.grey,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'renew',
          enabled: (contract.balance ?? 0) == 0,
          child: Row(
            children: [
              Icon(
                Icons.refresh_rounded,
                color: (contract.balance ?? 0) == 0
                    ? DashboardTheme.primary
                    : Colors.grey,
                size: 18,
              ),
              const SizedBox(width: 12),
              Text(
                'Renew Contract',
                style: TextStyle(
                  color: (contract.balance ?? 0) == 0 ? null : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB), // Match table row color
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xFFE5E7EB), // Match table divider color
            width: 1,
          ),
        ),
        child: Icon(
          Icons.more_vert_rounded,
          color: const Color(0xFF374151), // Match table text color
          size: 18,
        ),
      ),
    );
  }

  // Helper method to build contract status badges
  Widget _buildContractStatusBadge(String status, DateTime? dateOfExpiration) {
    // Determine if contract is ongoing or expired
    final now = DateTime.now();
    // Add 1 day buffer to handle timezone issues
    final bufferDate = now.subtract(Duration(days: 1));
    final isOngoing =
        dateOfExpiration != null && bufferDate.isBefore(dateOfExpiration);
    final isExpired = dateOfExpiration != null && now.isAfter(dateOfExpiration);

    // Format the status text
    String statusText = 'Active';
    Color statusColor = const Color(0xFF10B981); // Green for active

    if (dateOfExpiration != null) {
      if (isOngoing) {
        statusText = 'Active';
        statusColor = const Color(0xFF10B981); // Green
      } else if (isExpired) {
        statusText = 'Expired';
        statusColor = const Color(0xFFEF4444); // Red
      }
    }

    return Container(
      constraints: const BoxConstraints(minWidth: 120, maxWidth: 200),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Status indicator dot
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              statusText,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  // Method to add new nitche directly to contract collection
  Future<void> _addNewNitche() async {
    try {
      // Show confirmation dialog
      final bool confirmed = await showDialog<bool>(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: Row(
                  children: [
                    Icon(
                      Icons.help_outline_rounded,
                      color: const Color(0xFF8B5CF6),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Confirm Nitche Creation',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                  ],
                ),
                content: Text(
                  'Are you sure you want to create a new nitche?\n\nThis will add a new nitche to the system with default settings.',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Confirm',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              );
            },
          ) ??
          false;

      if (!confirmed) return;

      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text('Adding new nitche...'),
              ],
            ),
          );
        },
      );

      // Get the next available nitche ID
      final existingContracts = await queryContractRecord(
        queryBuilder: (query) => query.where('type', isEqualTo: 'nitche'),
      ).first;

      int nextNitcheId = 1;
      if (existingContracts.isNotEmpty) {
        final maxId = existingContracts
            .map((c) => c.nitcheid)
            .reduce((a, b) => a > b ? a : b);
        nextNitcheId = maxId + 1;
      }

      // Create new contract record data
      final newContractData = createContractRecordData(
        nitcheid: nextNitcheId,
        nitcheidString: nextNitcheId.toString(),
        type: 'nitche',
        status: 'available',
        amount: '1000',
        location: nextNitcheId.toString(),
        dateadded: DateTime.now(),
        leessee: null, // leessee must be null for nitche contracts
        // dateofexpiration is intentionally null as per backend configuration
      );

      // Add to Firestore
      await FirebaseFirestore.instance
          .collection('contract')
          .add(newContractData);

      // Close loading dialog
      Navigator.of(context).pop();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Nitche $nextNitcheId added successfully!'),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Refresh the data
      setState(() {});
    } catch (e) {
      // Close loading dialog
      Navigator.of(context).pop();

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding nitche: $e'),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // Method to show update price dialog
  Future<void> _showUpdatePriceDialog() async {
    final TextEditingController priceController = TextEditingController();

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(
                Icons.trending_up_rounded,
                color: const Color(0xFF8B5CF6),
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Update All Nitche Prices',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Info Text
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFF59E0B), width: 1),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: const Color(0xFFF59E0B),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'This will update the price for ALL niches. Ongoing contracts will continue with their original terms.',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: const Color(0xFF92400E),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Price Input
              TextFormField(
                controller: priceController,
                decoration: InputDecoration(
                  labelText: 'New Price for All Niches (₱)',
                  hintText: 'Enter new price',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '₱',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(color: const Color(0xFF6B7280)),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final newPrice = priceController.text.trim();

                if (newPrice.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a valid price'),
                      backgroundColor: Color(0xFFEF4444),
                    ),
                  );
                  return;
                }

                Navigator.of(context).pop();
                await _updateAllNitchePrices(newPrice);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Update All Prices',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Method to update all nitche prices in the backend
  Future<void> _updateAllNitchePrices(String newPrice) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text('Updating all nitche prices...'),
              ],
            ),
          );
        },
      );

      // Find all contract documents with type 'nitche'
      final contractQuery = await FirebaseFirestore.instance
          .collection('contract')
          .where('type', isEqualTo: 'nitche')
          .get();

      if (contractQuery.docs.isEmpty) {
        Navigator.of(context).pop(); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No nitche contracts found'),
            backgroundColor: Color(0xFFEF4444),
          ),
        );
        return;
      }

      // Update the amount field for all found contracts
      final batch = FirebaseFirestore.instance.batch();
      int updatedCount = 0;

      for (final doc in contractQuery.docs) {
        batch.update(doc.reference, {'amount': newPrice});
        updatedCount++;
      }

      // Commit all updates in a single batch
      await batch.commit();

      // Close loading dialog
      Navigator.of(context).pop();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Successfully updated $updatedCount nitche prices to ₱$newPrice!',
          ),
          backgroundColor: Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Refresh the data
      setState(() {});
    } catch (e) {
      // Close loading dialog
      Navigator.of(context).pop();

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating nitche prices: $e'),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // Method to download contract list as PDF
  Future<void> _downloadContractListPDF({
    List<ContractRecord>? contractData,
  }) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text('Generating PDF report...'),
              ],
            ),
          );
        },
      );

      // Use the passed data or create empty list as fallback
      final List<ContractRecord> currentData = contractData ?? [];

      // Generate PDF content
      final pdfContent = await _generateContractPDFContent(currentData);

      // Create and download PDF
      await _createAndDownloadPDF(pdfContent, currentData.length);

      // Close loading dialog
      Navigator.of(context).pop();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Contract report generated successfully! ${currentData.length} contracts included.',
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      // Close loading dialog
      Navigator.of(context).pop();

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating PDF: $e'),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // Method to generate contract PDF content
  Future<String> _generateContractPDFContent(
    List<ContractRecord> contractList,
  ) async {
    final StringBuffer content = StringBuffer();
    final logoBase64 = await _getLogoBase64();

    // Header
    content.writeln('''
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>Nitche List Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .header { text-align: center; margin-bottom: 30px; border-bottom: 2px solid #18651C; padding-bottom: 20px; }
        .title { color: #18651C; font-size: 24px; font-weight: bold; margin-bottom: 10px; }
        .subtitle { color: #666; font-size: 16px; margin-bottom: 20px; }
        .info { background: #f8f9fa; padding: 15px; border-radius: 8px; margin-bottom: 20px; }
        .info-row { display: flex; justify-content: space-between; margin-bottom: 10px; }
        .info-label { font-weight: bold; color: #18651C; }
        .info-value { color: #333; }
        table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        th, td { border: 1px solid #ddd; padding: 12px; text-align: left; }
        th { background-color: #18651C; color: white; font-weight: bold; }
        tr:nth-child(even) { background-color: #f2f2f2; }
        .status-addable { color: #10B981; font-weight: bold; }
        .status-unaddable { color: #EF4444; font-weight: bold; }
        .footer { margin-top: 30px; text-align: center; color: #666; font-size: 12px; }
    </style>
</head>
<body>
    <div class="header">
        <div class="logo-container">
            <img src="data:image/png;base64,$logoBase64" alt="Logo" style="width: 80px; height: 80px; border-radius: 10px; margin-bottom: 15px;">
        </div>
        <div class="title">BALIWAG PUBLIC CEMETERY</div>
        <div class="subtitle">Contract Management Report</div>
        <div class="subtitle">Management System</div>
    </div>
    
    <div class="info">
        <div class="info-row">
            <span class="info-label">Report Date:</span>
            <span class="info-value">${DateTime.now().toString().split('.')[0]}</span>
        </div>
        <div class="info-row">
            <span class="info-label">Total Contracts (Future Expiration):</span>
            <span class="info-value">${contractList.length}</span>
        </div>
        <div class="info-row">
            <span class="info-label">Filter Applied:</span>
            <span class="info-value">Active Contract</span>
        </div>
        <div class="info-row">
            <span class="info-label">Search Term:</span>
            <span class="info-value">${_model.textController.text.isNotEmpty ? _model.textController.text : 'None'}</span>
        </div>
    </div>
    
    <table>
        <thead>
            <tr>
                <th>Contract ID</th>
                <th>Location</th>
                <th>Effective Date</th>
                <th>Expiration Date</th>
                <th>Status</th>
                <th>Balance</th>
                <th>Type</th>
            </tr>
        </thead>
        <tbody>
''');

    // Table rows
    for (final contract in contractList) {
      final now = DateTime.now();
      final isOngoing = contract.dateofexpiration != null &&
          now.isBefore(contract.dateofexpiration!);
      final statusClass = isOngoing ? 'status-addable' : 'status-unaddable';
      final statusText = isOngoing ? 'Active' : 'Expired';

      // Use the same mapping methods for consistency
      final contractNumber = _getContractNumber(contract);
      final location = _getContractLocation(contract);
      final effectiveText = _getEffectiveDate(contract);
      final expirationText = _getExpirationDate(contract);
      final balance = _getContractBalance(contract);

      content.writeln('''
            <tr>
                <td>$contractNumber</td>
                <td>$location</td>
                <td>$effectiveText</td>
                <td>$expirationText</td>
                <td class="$statusClass">$statusText</td>
                <td>$balance</td>
                <td>${contract.type}</td>
            </tr>
''');
    }

    // Footer
    content.writeln('''
        </tbody>
    </table>
    
    <div class="footer">
        <p>Generated on ${DateTime.now().toString().split('.')[0]}</p>
        <p>Baliwag City Cemetery Management System</p>
    </div>
</body>
</html>
''');

    return content.toString();
  }

  // Method to get logo as base64 string for PDF
  Future<String> _getLogoBase64() async {
    return await LogoUtils.getLogoBase64();
  }

  // Method to create and download PDF
  Future<void> _createAndDownloadPDF(
    String htmlContent,
    int nitcheCount,
  ) async {
    try {
      // For web platform, create a downloadable HTML file that can be converted to PDF
      // This approach works well for Flutter web applications

      // Create the HTML content as a downloadable file
      final bytes = utf8.encode(htmlContent);
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);

      // Create download link with timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', 'contract_management_report_$timestamp.html')
        ..click();

      // Clean up
      html.Url.revokeObjectUrl(url);
    } catch (e) {
      // Fallback: show error message
      throw Exception('Failed to create downloadable file: $e');
    }
  }

  // Show payment success modal
  Future<void> _showPaymentSuccessModal(
    int amount,
    int newBalance,
    int change,
  ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                'Payment Successful',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          content: Container(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF10B981),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Payment Details',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF10B981),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Amount Paid:',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                          Text(
                            '₱$amount',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1F2937),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'New Balance:',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                          Text(
                            '₱$newBalance',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF10B981),
                            ),
                          ),
                        ],
                      ),
                      if (change > 0) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Change:',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                            Text(
                              '₱$change',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF059669),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Your payment has been processed successfully. The transaction has been recorded and your balance has been updated.',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Continue',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Modal for adding past contract data
  Future<void> _showAddPastContractModal(BuildContext context) async {
    final TextEditingController contractIdController = TextEditingController();
    final TextEditingController locationController = TextEditingController();
    final TextEditingController orController = TextEditingController();
    final TextEditingController applicantNameController = TextEditingController();
    final TextEditingController applicantAddressController = TextEditingController();
    final TextEditingController applicantContactController = TextEditingController();
    final TextEditingController amountController = TextEditingController();
    final TextEditingController initialFeeController = TextEditingController();
    final TextEditingController tinController = TextEditingController();
    final TextEditingController residentCertController = TextEditingController();
    final TextEditingController documentIssueLocationController = TextEditingController();
    
    // Lot-specific controllers
    final TextEditingController blockLotController = TextEditingController();
    final TextEditingController lesseeController = TextEditingController();
    final TextEditingController streetController = TextEditingController();
    final TextEditingController measurementController = TextEditingController();
    final TextEditingController balanceController = TextEditingController();
    final TextEditingController yearsDurationController = TextEditingController();
    
    DateTime? effectiveDate;
    DateTime? expirationDate;
    DateTime? documentIssueDate;
    String? selectedContractType = 'nitche';
    String? selectedLotStatus;
    String? proofOfLeasePath;
    List<DeceasedEntry> deceasedEntries = [DeceasedEntry()];

    // Validation functions
    String? validateRequired(String? value, String fieldName) {
      if (value == null || value.trim().isEmpty) {
        return '$fieldName is required';
      }
      return null;
    }

    String? validateApplicantName(String? value) {
      if (value == null || value.trim().isEmpty) {
        return 'Applicant Full Name is required';
      }
      final trimmedValue = value.trim();
      if (trimmedValue.length < 2) {
        return 'Name must be at least 2 characters long';
      }
      if (trimmedValue.length > 50) {
        return 'Name must not exceed 50 characters';
      }
      final nameRegex = RegExp(r'^[a-zA-Z\s]+$');
      if (!nameRegex.hasMatch(trimmedValue)) {
        return 'Name can only contain letters and spaces';
      }
      return null;
    }

    String? validateContactNumber(String? value) {
      if (value == null || value.trim().isEmpty) {
        return 'Mobile Contact Number is required';
      }
      if (!RegExp(r'^09\d{9}$').hasMatch(value.trim())) {
        return 'Mobile Contact Number must be 11 digits starting with 09';
      }
      return null;
    }

    String? validateAddress(String? value) {
      if (value == null || value.trim().isEmpty) {
        return 'Residential Address is required';
      }
      final trimmedValue = value.trim();
      if (trimmedValue.length < 5) {
        return 'Address must be at least 5 characters long';
      }
      final addressRegex = RegExp(r'^[A-Za-z0-9\s.,#\-]+$');
      if (!addressRegex.hasMatch(trimmedValue)) {
        return 'Address can only contain letters, numbers, spaces, commas, periods, #, and hyphens';
      }
      return null;
    }

    String? validateAmount(String? value) {
      if (value == null || value.trim().isEmpty) {
        return 'Amount is required';
      }
      final amount = double.tryParse(value);
      if (amount == null || amount <= 0) {
        return 'Amount must be a positive number';
      }
      return null;
    }

    Color getBorderColor(String? text, String? Function(String?)? validator) {
      if (text == null || text.isEmpty) return Colors.grey.shade300;
      if (validator != null && validator(text) != null) return Colors.red.shade400;
      return const Color(0xFF10B981);
    }

    double getBorderWidth(String? text, String? Function(String?)? validator) {
      if (text == null || text.isEmpty) return 1;
      if (validator != null && validator(text) != null) return 2;
      return 2;
    }

    // Lot-specific validation functions
    String? validateBlockLot(String? value) {
      if (value == null || value.trim().isEmpty) {
        return 'Block-Lot is required';
      }
      if (!RegExp(r'^[A-Z]\d+-L\d+$').hasMatch(value.trim())) {
        return 'Format should be: Letter-Number-L-Number (e.g., B1-L1)';
      }
      return null;
    }

    String? validateLessee(String? value) {
      if (value == null || value.trim().isEmpty) {
        return 'Lessee name is required';
      }
      final trimmedValue = value.trim();
      if (trimmedValue.length < 2) {
        return 'Name must be at least 2 characters long';
      }
      if (trimmedValue.length > 50) {
        return 'Name must not exceed 50 characters';
      }
      final nameRegex = RegExp(r'^[a-zA-Z\s]+$');
      if (!nameRegex.hasMatch(trimmedValue)) {
        return 'Name can only contain letters and spaces';
      }
      return null;
    }

    String? validateStreet(String? value) {
      if (value == null || value.trim().isEmpty) {
        return 'Street is required';
      }
      final trimmedValue = value.trim();
      if (trimmedValue.length < 3) {
        return 'Street address must be at least 3 characters long';
      }
      final streetRegex = RegExp(
          r'^[A-Za-z0-9\s.,\-#]+(?:St\.?|Street|Ave\.?|Avenue|Rd\.?|Road|Ext\.?|Extension)?$');
      if (!streetRegex.hasMatch(trimmedValue)) {
        return 'Invalid street address format';
      }
      return null;
    }

    String? validateMeasurement(String? value) {
      if (value == null || value.trim().isEmpty) {
        return 'Measurement is required';
      }
      if (!RegExp(r'^\d+x\d+$').hasMatch(value.trim())) {
        return 'Format should be: NumberxNumber (e.g., 3x5)';
      }
      return null;
    }

    // Function to calculate years duration
    int? calculateYearsDuration(DateTime? expirationDate) {
      if (expirationDate == null) return null;
      final now = DateTime.now();
      final difference = expirationDate.difference(now);
      return (difference.inDays / 365).ceil();
    }

    // Function to calculate balance
    void calculateBalance() {
      final years = calculateYearsDuration(expirationDate);
      final initialFee = double.tryParse(initialFeeController.text);
      
      if (years != null && initialFee != null && years > 0) {
        final balance = (years * initialFee) - initialFee;
        balanceController.text = balance.toStringAsFixed(0);
        yearsDurationController.text = years.toString();
      }
    }

    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(
                    Icons.add_circle_outline_rounded,
                    color: const Color(0xFF3B82F6),
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Add Past Contract',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
              content: Container(
                width: 600,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Enter the details of the past contract',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // CONTRACT DETAILS SECTION
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          border: Border.all(
                            color: Colors.grey.shade200,
                            width: 1,
                          ),
                        ),
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF3B82F6).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.description_rounded,
                                    color: const Color(0xFF3B82F6),
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Contract Details',
                                  style: GoogleFonts.inter(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1F2937),
                                    letterSpacing: -0.3,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Contract Type Dropdown
                            Text(
                              'Contract Type *',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1F2937),
                              ),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: selectedContractType,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: const Color(0xFFE5E7EB)),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              items: [
                                DropdownMenuItem(value: 'nitche', child: Text('Nitche')),
                                DropdownMenuItem(value: 'lot', child: Text('Lot')),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  selectedContractType = value;
                                });
                              },
                            ),
                            const SizedBox(height: 16),

                            // LOT-SPECIFIC FIELDS (shown only when type is 'lot')
                            if (selectedContractType == 'lot') ...[
                              // Block-Lot
                              _buildValidatedTextField(
                                label: 'Block-Lot *',
                                controller: blockLotController,
                                hint: 'e.g., B1-L1',
                                validator: validateBlockLot,
                                getBorderColor: getBorderColor,
                                getBorderWidth: getBorderWidth,
                                setState: setState,
                              ),

                              // Lessee Name
                              _buildValidatedTextField(
                                label: 'Lessee Name *',
                                controller: lesseeController,
                                hint: 'Enter lessee name',
                                validator: validateLessee,
                                getBorderColor: getBorderColor,
                                getBorderWidth: getBorderWidth,
                                setState: setState,
                              ),

                              // Street
                              _buildValidatedTextField(
                                label: 'Street *',
                                controller: streetController,
                                hint: 'Enter street address',
                                validator: validateStreet,
                                getBorderColor: getBorderColor,
                                getBorderWidth: getBorderWidth,
                                setState: setState,
                              ),

                              // Measurement
                              _buildValidatedTextField(
                                label: 'Measurement *',
                                controller: measurementController,
                                hint: 'e.g., 3x5',
                                validator: validateMeasurement,
                                getBorderColor: getBorderColor,
                                getBorderWidth: getBorderWidth,
                                setState: setState,
                              ),

                              // Status Dropdown
                              Text(
                                'Status *',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1F2937),
                                ),
                              ),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<String>(
                                value: selectedLotStatus,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: const Color(0xFFE5E7EB)),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                ),
                                hint: Text('Select status'),
                                items: [
                                  DropdownMenuItem(value: 'available', child: Text('Available')),
                                  DropdownMenuItem(value: 'occupied', child: Text('Occupied')),
                                  DropdownMenuItem(value: 'reserved', child: Text('Reserved')),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    selectedLotStatus = value;
                                  });
                                },
                              ),
                              const SizedBox(height: 16),
                            ],

                            // Contract ID
                            _buildValidatedTextField(
                              label: 'Contract ID',
                              controller: contractIdController,
                              hint: 'Enter contract ID',
                              keyboardType: TextInputType.number,
                              getBorderColor: getBorderColor,
                              getBorderWidth: getBorderWidth,
                              setState: setState,
                            ),

                            // Location (only show for nitche)
                            if (selectedContractType != 'lot')
                              _buildValidatedTextField(
                                label: 'Location *',
                                controller: locationController,
                                hint: 'Enter location',
                                validator: (val) => validateRequired(val, 'Location'),
                                getBorderColor: getBorderColor,
                                getBorderWidth: getBorderWidth,
                                setState: setState,
                              ),

                            // OR Number
                            _buildValidatedTextField(
                              label: 'OR Number',
                              controller: orController,
                              hint: 'Enter OR number',
                              getBorderColor: getBorderColor,
                              getBorderWidth: getBorderWidth,
                              setState: setState,
                            ),

                            // Amount
                            _buildValidatedTextField(
                              label: 'Amount *',
                              controller: amountController,
                              hint: 'Enter amount',
                              validator: validateAmount,
                              keyboardType: TextInputType.number,
                              getBorderColor: getBorderColor,
                              getBorderWidth: getBorderWidth,
                              setState: setState,
                            ),

                            // Initial Fee
                            _buildValidatedTextField(
                              label: 'Initial Fee',
                              controller: initialFeeController,
                              hint: 'Enter initial fee',
                              validator: validateAmount,
                              keyboardType: TextInputType.number,
                              getBorderColor: getBorderColor,
                              getBorderWidth: getBorderWidth,
                              setState: setState,
                            ),

                            // Effective Date
                            Text(
                              'Effective Date',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1F2937),
                              ),
                            ),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: () async {
                                final DateTime? picked = await showDatePicker(
                                  context: context,
                                  initialDate: effectiveDate ?? DateTime.now(),
                                  firstDate: DateTime(1900),
                                  lastDate: DateTime.now(),
                                );
                                if (picked != null) {
                                  setState(() {
                                    effectiveDate = picked;
                                  });
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: const Color(0xFFE5E7EB)),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      effectiveDate != null
                                          ? DateFormat('MMM dd, yyyy').format(effectiveDate!)
                                          : 'Select date',
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        color: effectiveDate != null
                                            ? const Color(0xFF1F2937)
                                            : const Color(0xFF9CA3AF),
                                      ),
                                    ),
                                    Icon(
                                      Icons.calendar_today_rounded,
                                      size: 18,
                                      color: const Color(0xFF6B7280),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Expiration Date
                            Text(
                              'Expiration Date',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1F2937),
                              ),
                            ),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: () async {
                                final DateTime? picked = await showDatePicker(
                                  context: context,
                                  initialDate: expirationDate ?? DateTime.now(),
                                  firstDate: DateTime(1900),
                                  lastDate: DateTime(2100),
                                );
                                if (picked != null) {
                                  setState(() {
                                    expirationDate = picked;
                                    // Auto-calculate balance for Lot contracts
                                    if (selectedContractType == 'lot') {
                                      calculateBalance();
                                    }
                                  });
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: const Color(0xFFE5E7EB)),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      expirationDate != null
                                          ? DateFormat('MMM dd, yyyy').format(expirationDate!)
                                          : 'Select date',
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        color: expirationDate != null
                                            ? const Color(0xFF1F2937)
                                            : const Color(0xFF9CA3AF),
                                      ),
                                    ),
                                    Icon(
                                      Icons.calendar_today_rounded,
                                      size: 18,
                                      color: const Color(0xFF6B7280),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // LOT-SPECIFIC FINANCIAL FIELDS
                            if (selectedContractType == 'lot') ...[
                              const SizedBox(height: 16),
                              
                              // Initial Contract Fee
                              _buildValidatedTextField(
                                label: 'Initial Contract Fee (₱) *',
                                controller: initialFeeController,
                                hint: 'Enter initial fee',
                                keyboardType: TextInputType.number,
                                validator: validateAmount,
                                getBorderColor: getBorderColor,
                                getBorderWidth: getBorderWidth,
                                setState: setState,
                                onChanged: (value) {
                                  if (selectedContractType == 'lot') {
                                    calculateBalance();
                                  }
                                },
                              ),

                              // Years Duration (Read-only, auto-calculated)
                              Text(
                                'Contract Duration (Years)',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1F2937),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  border: Border.all(color: const Color(0xFFE5E7EB)),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_month_rounded,
                                      size: 18,
                                      color: Colors.grey.shade600,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      yearsDurationController.text.isEmpty
                                          ? 'Auto-calculated'
                                          : '${yearsDurationController.text} years',
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        color: yearsDurationController.text.isEmpty
                                            ? const Color(0xFF9CA3AF)
                                            : const Color(0xFF1F2937),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Total Balance (Read-only, auto-calculated)
                              Text(
                                'Total Balance (₱)',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1F2937),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  border: Border.all(color: const Color(0xFFE5E7EB)),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.account_balance_wallet_rounded,
                                      size: 18,
                                      color: Colors.grey.shade600,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      balanceController.text.isEmpty
                                          ? 'Auto-calculated'
                                          : '₱${balanceController.text}',
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: balanceController.text.isEmpty
                                            ? const Color(0xFF9CA3AF)
                                            : const Color(0xFF10B981),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // REQUIRED DOCUMENTATION SECTION
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          border: Border.all(
                            color: Colors.grey.shade200,
                            width: 1,
                          ),
                        ),
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEF4444).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.description_outlined,
                                    color: const Color(0xFFEF4444),
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Required Documentation',
                                  style: GoogleFonts.inter(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1F2937),
                                    letterSpacing: -0.3,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Resident Certificate Number
                            _buildValidatedTextField(
                              label: 'Resident Certificate Number',
                              controller: residentCertController,
                              hint: 'Enter certificate number',
                              getBorderColor: getBorderColor,
                              getBorderWidth: getBorderWidth,
                              setState: setState,
                            ),

                            // TIN Number
                            _buildValidatedTextField(
                              label: 'Tax Identification Number (TIN)',
                              controller: tinController,
                              hint: 'xxx - xxx - xxx - xxx',
                              getBorderColor: getBorderColor,
                              getBorderWidth: getBorderWidth,
                              setState: setState,
                            ),

                            // Document Issue Date
                            Text(
                              'Document Issue Date',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1F2937),
                              ),
                            ),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: () async {
                                final DateTime? picked = await showDatePicker(
                                  context: context,
                                  initialDate: documentIssueDate ?? DateTime.now(),
                                  firstDate: DateTime(1900),
                                  lastDate: DateTime.now(),
                                );
                                if (picked != null) {
                                  setState(() {
                                    documentIssueDate = picked;
                                  });
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: const Color(0xFFE5E7EB)),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      documentIssueDate != null
                                          ? DateFormat('MMM dd, yyyy').format(documentIssueDate!)
                                          : 'Select date',
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        color: documentIssueDate != null
                                            ? const Color(0xFF1F2937)
                                            : const Color(0xFF9CA3AF),
                                      ),
                                    ),
                                    Icon(
                                      Icons.calendar_today_rounded,
                                      size: 18,
                                      color: const Color(0xFF6B7280),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Document Issue Location
                            _buildValidatedTextField(
                              label: 'Document Issue Location',
                              controller: documentIssueLocationController,
                              hint: 'Enter issue location',
                              getBorderColor: getBorderColor,
                              getBorderWidth: getBorderWidth,
                              setState: setState,
                            ),

                            // Proof of Lease
                            Text(
                              'Proof of Lease',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF374151),
                              ),
                            ),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: () async {
                                try {
                                  final selectedFile = await selectFile(
                                    storageFolderPath: 'proof_of_lease',
                                    allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
                                  );
                                  
                                  if (selectedFile != null) {
                                    // Upload file to Firebase Storage
                                    final downloadUrl = await uploadData(
                                      selectedFile.storagePath,
                                      selectedFile.bytes,
                                    );
                                    
                                    if (downloadUrl != null) {
                                      setState(() {
                                        proofOfLeasePath = downloadUrl;
                                      });
                                      
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('File uploaded successfully!'),
                                          backgroundColor: const Color(0xFF10B981),
                                        ),
                                      );
                                    }
                                  }
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error uploading file: $e'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                    color: proofOfLeasePath != null
                                        ? const Color(0xFF10B981)
                                        : const Color(0xFFE5E7EB),
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      proofOfLeasePath != null
                                          ? Icons.check_circle_rounded
                                          : Icons.upload_file_rounded,
                                      color: proofOfLeasePath != null
                                          ? const Color(0xFF10B981)
                                          : const Color(0xFF6B7280),
                                      size: 24,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        proofOfLeasePath != null
                                            ? 'Document uploaded'
                                            : 'Upload lease document',
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          color: proofOfLeasePath != null
                                              ? const Color(0xFF10B981)
                                              : const Color(0xFF6B7280),
                                          fontWeight: proofOfLeasePath != null
                                              ? FontWeight.w600
                                              : FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                    if (proofOfLeasePath != null)
                                      IconButton(
                                        icon: Icon(
                                          Icons.close_rounded,
                                          color: Colors.red.shade400,
                                          size: 20,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            proofOfLeasePath = null;
                                          });
                                        },
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // APPLICANT DETAILS SECTION
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          border: Border.all(
                            color: Colors.grey.shade200,
                            width: 1,
                          ),
                        ),
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF8B5CF6).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.person_outline_rounded,
                                    color: const Color(0xFF8B5CF6),
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Applicant Details',
                                  style: GoogleFonts.inter(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1F2937),
                                    letterSpacing: -0.3,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Applicant Name
                            _buildValidatedTextField(
                              label: 'Applicant Name *',
                              controller: applicantNameController,
                              hint: 'Enter full name',
                              validator: validateApplicantName,
                              getBorderColor: getBorderColor,
                              getBorderWidth: getBorderWidth,
                              setState: setState,
                            ),

                            // Applicant Address
                            _buildValidatedTextField(
                              label: 'Applicant Address *',
                              controller: applicantAddressController,
                              hint: 'Enter residential address',
                              validator: validateAddress,
                              getBorderColor: getBorderColor,
                              getBorderWidth: getBorderWidth,
                              setState: setState,
                            ),

                            // Applicant Contact
                            _buildValidatedTextField(
                              label: 'Mobile Contact Number *',
                              controller: applicantContactController,
                              hint: '09XXXXXXXXX',
                              validator: validateContactNumber,
                              keyboardType: TextInputType.phone,
                              getBorderColor: getBorderColor,
                              getBorderWidth: getBorderWidth,
                              setState: setState,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // DECEASED DETAILS SECTION
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          border: Border.all(
                            color: Colors.grey.shade200,
                            width: 1,
                          ),
                        ),
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF10B981).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.favorite_rounded,
                                    color: const Color(0xFF10B981),
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Deceased Details',
                                  style: GoogleFonts.inter(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1F2937),
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const Spacer(),
                                TextButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      deceasedEntries.add(DeceasedEntry());
                                    });
                                  },
                                  icon: Icon(
                                    Icons.add_circle_outline_rounded,
                                    color: const Color(0xFF10B981),
                                    size: 18,
                                  ),
                                  label: Text(
                                    'Add Another Deceased',
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF10B981),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Dynamic deceased entries
                            ...deceasedEntries.asMap().entries.map((entry) {
                              final int index = entry.key;
                              final DeceasedEntry deceasedEntry = entry.value;

                              return Column(
                                children: [
                                  // Header row with remove button for additional entries
                                  if (index > 0) ...[
                                    Row(
                                      children: [
                                        Text(
                                          'Deceased ${index + 1}',
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF6B7280),
                                          ),
                                        ),
                                        const Spacer(),
                                        IconButton(
                                          onPressed: () {
                                            setState(() {
                                              final entryToRemove = deceasedEntries[index];
                                              deceasedEntries.removeAt(index);
                                              entryToRemove.dispose();
                                            });
                                          },
                                          icon: Icon(
                                            Icons.remove_circle_outline_rounded,
                                            color: const Color(0xFFEF4444),
                                            size: 20,
                                          ),
                                          tooltip: 'Remove this deceased person',
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                  ],

                                  // Deceased Name
                                  _buildValidatedTextField(
                                    label: 'Deceased Name',
                                    controller: deceasedEntry.nameController,
                                    hint: 'Enter deceased name',
                                    validator: validateApplicantName,
                                    getBorderColor: getBorderColor,
                                    getBorderWidth: getBorderWidth,
                                    setState: setState,
                                  ),

                                  // Date of Death and Date of Burial in a Row
                                  Row(
                                    children: [
                                      // Date of Death
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Date of Death',
                                              style: GoogleFonts.inter(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: const Color(0xFF1F2937),
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            InkWell(
                                              onTap: () async {
                                                final DateTime? picked = await showDatePicker(
                                                  context: context,
                                                  initialDate: deceasedEntry.deathDate ?? DateTime.now(),
                                                  firstDate: DateTime(1900),
                                                  lastDate: DateTime.now(),
                                                );
                                                if (picked != null) {
                                                  setState(() {
                                                    deceasedEntry.deathDate = picked;
                                                  });
                                                }
                                              },
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 16,
                                                  vertical: 12,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  border: Border.all(color: const Color(0xFFE5E7EB)),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        deceasedEntry.deathDate != null
                                                            ? DateFormat('MMM dd, yyyy').format(deceasedEntry.deathDate!)
                                                            : 'Select date',
                                                        style: GoogleFonts.inter(
                                                          fontSize: 14,
                                                          color: deceasedEntry.deathDate != null
                                                              ? const Color(0xFF1F2937)
                                                              : const Color(0xFF9CA3AF),
                                                        ),
                                                      ),
                                                    ),
                                                    Icon(
                                                      Icons.calendar_today_rounded,
                                                      size: 18,
                                                      color: const Color(0xFF6B7280),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      
                                      // Date of Burial
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Date of Burial',
                                              style: GoogleFonts.inter(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: const Color(0xFF1F2937),
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            InkWell(
                                              onTap: () async {
                                                final DateTime? picked = await showDatePicker(
                                                  context: context,
                                                  initialDate: deceasedEntry.burialDate ?? DateTime.now(),
                                                  firstDate: DateTime(1900),
                                                  lastDate: DateTime.now(),
                                                );
                                                if (picked != null) {
                                                  setState(() {
                                                    deceasedEntry.burialDate = picked;
                                                  });
                                                }
                                              },
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 16,
                                                  vertical: 12,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  border: Border.all(color: const Color(0xFFE5E7EB)),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        deceasedEntry.burialDate != null
                                                            ? DateFormat('MMM dd, yyyy').format(deceasedEntry.burialDate!)
                                                            : 'Select date',
                                                        style: GoogleFonts.inter(
                                                          fontSize: 14,
                                                          color: deceasedEntry.burialDate != null
                                                              ? const Color(0xFF1F2937)
                                                              : const Color(0xFF9CA3AF),
                                                        ),
                                                      ),
                                                    ),
                                                    Icon(
                                                      Icons.calendar_today_rounded,
                                                      size: 18,
                                                      color: const Color(0xFF6B7280),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  
                                  // Add spacing between entries
                                  if (index < deceasedEntries.length - 1) ...[
                                    const SizedBox(height: 24),
                                    Divider(color: Colors.grey.shade200),
                                    const SizedBox(height: 24),
                                  ],
                                ],
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // Comprehensive validation
                    List<String> errors = [];
                    
                    // Check required fields
                    if (locationController.text.trim().isEmpty) {
                      errors.add('Location is required');
                    }
                    if (applicantNameController.text.trim().isEmpty) {
                      errors.add('Applicant Name is required');
                    }
                    if (applicantAddressController.text.trim().isEmpty) {
                      errors.add('Applicant Address is required');
                    }
                    if (applicantContactController.text.trim().isEmpty) {
                      errors.add('Mobile Contact Number is required');
                    }
                    if (amountController.text.trim().isEmpty) {
                      errors.add('Amount is required');
                    }
                    
                    // Validate formats
                    final nameError = validateApplicantName(applicantNameController.text);
                    if (nameError != null) errors.add(nameError);
                    
                    final addressError = validateAddress(applicantAddressController.text);
                    if (addressError != null) errors.add(addressError);
                    
                    final contactError = validateContactNumber(applicantContactController.text);
                    if (contactError != null) errors.add(contactError);
                    
                    final amountError = validateAmount(amountController.text);
                    if (amountError != null) errors.add(amountError);
                    
                    if (initialFeeController.text.trim().isNotEmpty) {
                      final feeError = validateAmount(initialFeeController.text);
                      if (feeError != null) errors.add('Initial Fee: $feeError');
                    }
                    
                    // Show validation errors if any
                    if (errors.isNotEmpty) {
                      showDialog(
                        context: context,
                        builder: (BuildContext ctx) {
                          return AlertDialog(
                            title: Row(
                              children: [
                                Icon(
                                  Icons.error_rounded,
                                  color: const Color(0xFFEF4444),
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Validation Errors',
                                  style: GoogleFonts.inter(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF1F2937),
                                  ),
                                ),
                              ],
                            ),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Please correct the following errors:',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ...errors.map((error) => Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Icon(
                                            Icons.circle,
                                            size: 6,
                                            color: const Color(0xFFEF4444),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              error,
                                              style: GoogleFonts.inter(
                                                fontSize: 14,
                                                color: const Color(0xFF1F2937),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(),
                                child: Text(
                                  'OK',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF1E40AF),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                      return;
                    }

                    try {
                      // Create base contract data
                      Map<String, dynamic> contractData = {
                        'type': selectedContractType,
                        'timestamp': DateTime.now(),
                        'dateadded': DateTime.now(),
                        'contractstatus': 'active',
                      };

                      // Add type-specific fields
                      if (selectedContractType == 'lot') {
                        // Lot-specific fields
                        if (blockLotController.text.trim().isNotEmpty) {
                          contractData['Location'] = blockLotController.text.trim();
                          contractData['lotLoccation'] = blockLotController.text.trim();
                        }
                        if (lesseeController.text.trim().isNotEmpty) {
                          contractData['leessee'] = lesseeController.text.trim();
                        }
                        if (streetController.text.trim().isNotEmpty) {
                          contractData['street'] = streetController.text.trim();
                        }
                        if (measurementController.text.trim().isNotEmpty) {
                          contractData['measurement'] = measurementController.text.trim();
                        }
                        if (selectedLotStatus != null) {
                          contractData['lotstatus'] = selectedLotStatus;
                          contractData['status'] = 'available'; // Default status
                        }
                        if (balanceController.text.trim().isNotEmpty) {
                          final balance = int.tryParse(balanceController.text.trim());
                          if (balance != null) {
                            contractData['balance'] = balance;
                          }
                        }
                      } else {
                        // Nitche-specific fields
                        if (locationController.text.trim().isNotEmpty) {
                          contractData['Location'] = locationController.text.trim();
                        }
                      }
                      
                      // Common amount field
                      if (amountController.text.trim().isNotEmpty) {
                        contractData['amount'] = amountController.text.trim();
                      }

                      // Add optional fields
                      if (contractIdController.text.trim().isNotEmpty) {
                        final contractId = int.tryParse(contractIdController.text.trim());
                        if (contractId != null) {
                          contractData['contractID'] = contractId;
                          contractData['contractidString'] = contractIdController.text.trim();
                        }
                      }
                      
                      if (orController.text.trim().isNotEmpty) {
                        contractData['OR'] = orController.text.trim();
                      }
                      
                      if (tinController.text.trim().isNotEmpty) {
                        contractData['TIN'] = tinController.text.trim();
                      }
                      
                      if (residentCertController.text.trim().isNotEmpty) {
                        contractData['ResidentCert'] = residentCertController.text.trim();
                      }
                      
                      if (documentIssueDate != null) {
                        contractData['dateIssued'] = documentIssueDate;
                      }
                      
                      if (documentIssueLocationController.text.trim().isNotEmpty) {
                        contractData['placeIssued'] = documentIssueLocationController.text.trim();
                      }
                      
                      if (proofOfLeasePath != null && proofOfLeasePath!.isNotEmpty) {
                        contractData['proofoflease'] = proofOfLeasePath;
                      }
                      
                      if (applicantNameController.text.trim().isNotEmpty) {
                        contractData['applicantName'] = [applicantNameController.text.trim()];
                      }
                      
                      if (applicantAddressController.text.trim().isNotEmpty) {
                        contractData['applcantAddress'] = [applicantAddressController.text.trim()];
                      }
                      
                      if (applicantContactController.text.trim().isNotEmpty) {
                        final contactNumber = int.tryParse(applicantContactController.text.trim());
                        if (contactNumber != null) {
                          contractData['applicantContactNumber'] = [contactNumber];
                        }
                      }
                      
                      // Handle multiple deceased entries
                      final deceasedNames = deceasedEntries
                          .map((entry) => entry.nameController.text)
                          .where((name) => name.isNotEmpty)
                          .toList();
                      if (deceasedNames.isNotEmpty) {
                        contractData['decFullName'] = deceasedNames;
                      }
                      
                      final deathDates = deceasedEntries
                          .where((entry) => entry.deathDate != null)
                          .map((entry) => entry.deathDate!)
                          .toList();
                      if (deathDates.isNotEmpty) {
                        contractData['dateofdeath'] = deathDates;
                      }
                      
                      final burialDates = deceasedEntries
                          .where((entry) => entry.burialDate != null)
                          .map((entry) => entry.burialDate!)
                          .toList();
                      if (burialDates.isNotEmpty) {
                        contractData['burialinternment'] = burialDates;
                      }
                      
                      if (initialFeeController.text.trim().isNotEmpty) {
                        final initialFee = double.tryParse(initialFeeController.text.trim());
                        if (initialFee != null) {
                          contractData['initialfee'] = initialFee;
                        }
                      }
                      
                      if (effectiveDate != null) {
                        contractData['dateEffective'] = effectiveDate;
                      }
                      
                      if (expirationDate != null) {
                        contractData['dateofexpiration'] = expirationDate;
                      }

                      // Add to Firestore
                      await ContractRecord.collection.add(contractData);

                      Navigator.of(context).pop();

                      // Show success message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Past contract added successfully'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } catch (e) {
                      print('Error adding past contract: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error adding contract: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Add Contract',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Helper method to build text fields for the modal
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF9CA3AF),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: const Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: const Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: const Color(0xFF3B82F6), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          style: GoogleFonts.inter(
            fontSize: 14,
            color: const Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // Helper method to build validated text fields with visual feedback
  Widget _buildValidatedTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    required Color Function(String?, String? Function(String?)?) getBorderColor,
    required double Function(String?, String? Function(String?)?) getBorderWidth,
    required void Function(void Function()) setState,
    void Function(String)? onChanged,
  }) {
    final hasError = validator != null && controller.text.isNotEmpty && validator(controller.text) != null;
    final isValid = validator != null && controller.text.isNotEmpty && validator(controller.text) == null;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ),
            // Green check icon when format is correct
            if (isValid)
              Icon(
                Icons.check_circle_rounded,
                color: const Color(0xFF10B981),
                size: 20,
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          onChanged: (value) {
            setState(() {}); // Rebuild to show validation state
            if (onChanged != null) {
              onChanged(value);
            }
          },
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF9CA3AF),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: getBorderColor(controller.text, validator),
                width: getBorderWidth(controller.text, validator),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: getBorderColor(controller.text, validator),
                width: getBorderWidth(controller.text, validator),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: hasError 
                    ? Colors.red.shade400 
                    : (isValid ? const Color(0xFF10B981) : const Color(0xFF3B82F6)),
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          style: GoogleFonts.inter(
            fontSize: 14,
            color: const Color(0xFF1F2937),
          ),
        ),
        // Show error message if validation fails
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              validator!(controller.text)!,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.red.shade600,
              ),
            ),
          ),
        const SizedBox(height: 16),
      ],
    );
  }
}
