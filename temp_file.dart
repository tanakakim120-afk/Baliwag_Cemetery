import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_data_table.dart';
import '/custom_code/logo_utils.dart';
import '/custom_code/dashboard_theme.dart';
import '/custom_code/actions/auto_create_vault_records.dart';
import 'dart:ui';
import 'dart:convert';
import 'dart:html' as html;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
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

    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();

    // Add listener to text controller for real-time search
    _model.textController!.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      // Run vault creation in background without blocking UI
      _runVaultCreationInBackground();
      safeSetState(() {});
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  // Run vault creation in background without blocking UI
  void _runVaultCreationInBackground() {
    // Use Future.microtask to run in background
    Future.microtask(() async {
      try {
        // Add a small delay to ensure UI is fully loaded first
        await Future.delayed(Duration(milliseconds: 500));

        // Only run if widget is still mounted
        if (mounted) {
          await autoCreateVaultRecords();
          print('Auto vault creation completed in background');
        }
      } catch (e) {
        print('Error during background vault creation: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return StreamBuilder<List<ContractRecord>>(
      stream: queryContractRecord(
        queryBuilder: (contractRecord) {
          print('Querying active contracts...');
          final now = DateTime.now();
          return contractRecord
              .where('type', isEqualTo: 'nitche')
              .where('dateofexpiration', isGreaterThan: now);
        },
      ),
      builder: (context, snapshot) {
        // Debug: Print snapshot information
        print(
            'Snapshot state: hasData=${snapshot.hasData}, hasError=${snapshot.hasError}, error=${snapshot.error}');

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
                    'Loading Contract Data...',
                    style: DashboardTheme.bodyText,
                  ),
                ],
              ),
            ),
          );
        }
        List<ContractRecord> allNitcheList = snapshot.data!;

        // Debug: Print the data we're getting
        print('Total contracts found: ${allNitcheList.length}');
        for (var contract in allNitcheList) {
          print(
              'Contract: type=${contract.type}, nitcheid=${contract.nitcheid}, status=${contract.status}, contractID=${contract.contractID}');
        }

        // Additional debug: Check if our specific nitche is in the list
        final nitche5 = allNitcheList.where((c) => c.nitcheid == 5).toList();
        print('Nitche 5 found: ${nitche5.length}');
        if (nitche5.isNotEmpty) {
          final contract = nitche5.first;
          print(
              'Nitche 5 details: type=${contract.type}, nitcheid=${contract.nitcheid}, status=${contract.status}, contractID=${contract.contractID}');
        }

        // Debug: Check if any contracts are being filtered out by status
        final availableContracts = allNitcheList
            .where((c) => c.status.toLowerCase() != 'unaddable')
            .toList();
        final unavailableContracts = allNitcheList
            .where((c) => c.status.toLowerCase() == 'unaddable')
            .toList();
        print(
            'Available contracts: ${availableContracts.length}, Unavailable contracts: ${unavailableContracts.length}');

        // Debug: Check for contracts with type != 'nitche'
        final nonNitcheContracts =
            allNitcheList.where((c) => c.type != 'nitche').toList();
        print('Non-nitche contracts found: ${nonNitcheContracts.length}');
        if (nonNitcheContracts.isNotEmpty) {
          for (var contract in nonNitcheContracts) {
            print(
                'Non-nitche contract: type=${contract.type}, nitcheid=${contract.nitcheid}');
          }
        }

        // Filter the data based on search text and date filters
        List<ContractRecord> nitcheListContractRecordList =
            allNitcheList.where((contract) {
          // Apply date range filter
          bool passesDateFilter = true;
          if (_model.startDate != null || _model.endDate != null) {
            final contractDate = contract.dateEffective;
            if (contractDate != null) {
              if (_model.startDate != null &&
                  contractDate.isBefore(_model.startDate!)) {
                passesDateFilter = false;
              }
              if (_model.endDate != null &&
                  contractDate
                      .isAfter(_model.endDate!.add(Duration(days: 1)))) {
                passesDateFilter = false;
              }
            } else {
              passesDateFilter =
                  false; // No date means it doesn't pass the filter
            }
          }

          if (!passesDateFilter) return false;

          // Then apply search filter
          if (_model.textController?.text.isNotEmpty == true) {
            final searchText = _model.textController!.text.toLowerCase();
            final nicheId = contract.nitcheid.toString().toLowerCase();
            final nicheIdString = contract.nitcheidString.toLowerCase();
            final status = contract.status.toLowerCase();
            final amount = contract.amount ?? '0';

            // Search in multiple fields
            bool matchesSearch = nicheId.contains(searchText) ||
                nicheIdString.contains(searchText) ||
                status.contains(searchText) ||
                amount.contains(searchText);

            // Search based on contract status
            if (searchText == 'addable' || searchText == 'occupied') {
              final now = DateTime.now();
              final isOngoing = contract.dateofexpiration != null &&
                  now.isBefore(contract.dateofexpiration!);

              if (searchText == 'addable') {
                matchesSearch = !isOngoing; // Not ongoing = available
              } else if (searchText == 'occupied') {
                matchesSearch = isOngoing; // Ongoing = occupied
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
                          padding:
                              EdgeInsets.all(DashboardTheme.sectionSpacing),
                          child: Column(
                            children: [
                              // Logo Container with gradient and shadow
                              Container(
                                width: 160,
                                height: 160,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                      DashboardTheme.cardRadius),
                                  boxShadow: [
                                    BoxShadow(
                                      color: DashboardTheme.primary
                                          .withOpacity(0.1),
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
                                'BALIWAG CITY CEMETERY',
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
                                vertical: 8),
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
                                    height: DashboardTheme.containerPadding),

                                // Action Section
                                _buildSectionTitle('Action'),
                                SizedBox(height: DashboardTheme.elementSpacing),
                                _buildNavItem(
                                  icon: Icons.description_rounded,
                                  title: 'Manage Contract',
                                  isActive: true,
                                  onTap: () =>
                                      context.pushNamed('ManageContract'),
                                ),
                                _buildNavItem(
                                  icon: Icons.circle,
                                  title: 'Apartment Niche',
                                  onTap: () =>
                                      context.pushNamed('ApartmentList'),
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
                                  onTap: () => context.pushNamed('VaultList'),
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
                                    height: DashboardTheme.containerPadding),

                                // Logout Button
                                Container(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: () async {
                                      await FirebaseAuth.instance.signOut();
                                      context.goNamed('login');
                                    },
                                    icon: Icon(Icons.logout_rounded,
                                        color: Colors.white, size: 20),
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
                                          vertical: 16),
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
                      borderRadius:
                          BorderRadius.only(topLeft: Radius.circular(0)),
                    ),
                    child: Column(
                      children: [
                        // Enhanced Header Section
                        Container(
                          padding: const EdgeInsets.all(
                              DashboardTheme.containerPadding),
                          decoration: DashboardTheme.headerDecoration,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title and Description with enhanced styling
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Manage Contract',
                                    style: DashboardTheme.pageTitle,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'View and manage active contracts only',
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      color: const Color(0xFF6B7280),
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(
                                  height: DashboardTheme.containerPadding),

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
                                              'Search contracts by number, location, status...',
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
                                      width: DashboardTheme.sectionSpacing),

                                  // Start Date Filter
                                  Container(
                                    height: 48,
                                    width: 140,
                                    decoration:
                                        DashboardTheme.searchBarDecoration,
                                    child: InkWell(
                                      onTap: () async {
                                        final DateTime? picked =
                                            await showDatePicker(
                                          context: context,
                                          initialDate: _model.startDate ??
                                              DateTime.now(),
                                          firstDate: DateTime(2020),
                                          lastDate: DateTime(2030),
                                        );
                                        if (picked != null &&
                                            picked != _model.startDate) {
                                          setState(() {
                                            _model.startDate = picked;
                                          });
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 12),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.calendar_today_rounded,
                                              color: DashboardTheme.secondary,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                _model.startDate != null
                                                    ? dateTimeFormat('M/d/y',
                                                        _model.startDate!)
                                                    : 'Start Date',
                                                style: _model.startDate != null
                                                    ? DashboardTheme.inputText
                                                    : DashboardTheme.caption
                                                        .copyWith(
                                                        color: const Color(
                                                            0xFF9CA3AF),
                                                      ),
                                              ),
                                            ),
                                            if (_model.startDate != null)
                                              IconButton(
                                                onPressed: () {
                                                  setState(() {
                                                    _model.startDate = null;
                                                  });
                                                },
                                                icon: Icon(
                                                  Icons.clear_rounded,
                                                  color:
                                                      DashboardTheme.secondary,
                                                  size: 16,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 12),

                                  // End Date Filter
                                  Container(
                                    height: 48,
                                    width: 140,
                                    decoration:
                                        DashboardTheme.searchBarDecoration,
                                    child: InkWell(
                                      onTap: () async {
                                        final DateTime? picked =
                                            await showDatePicker(
                                          context: context,
                                          initialDate:
                                              _model.endDate ?? DateTime.now(),
                                          firstDate: DateTime(2020),
                                          lastDate: DateTime(2030),
                                        );
                                        if (picked != null &&
                                            picked != _model.endDate) {
                                          setState(() {
                                            _model.endDate = picked;
                                          });
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 12),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.calendar_today_rounded,
                                              color: DashboardTheme.secondary,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                _model.endDate != null
                                                    ? dateTimeFormat('M/d/y',
                                                        _model.endDate!)
                                                    : 'End Date',
                                                style: _model.endDate != null
                                                    ? DashboardTheme.inputText
                                                    : DashboardTheme.caption
                                                        .copyWith(
                                                        color: const Color(
                                                            0xFF9CA3AF),
                                                      ),
                                              ),
                                            ),
                                            if (_model.endDate != null)
                                              IconButton(
                                                onPressed: () {
                                                  setState(() {
                                                    _model.endDate = null;
                                                  });
                                                },
                                                icon: Icon(
                                                  Icons.clear_rounded,
                                                  color:
                                                      DashboardTheme.secondary,
                                                  size: 16,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(
                                      width: DashboardTheme.sectionSpacing),

                                  // Action Button
                                  _buildActionButton(
                                    onPressed: () async {
                                      // Download PDF functionality
                                      await _downloadNitcheListPDF(
                                          nitcheData: allNitcheList);
                                    },
                                    icon: Icons.download_rounded,
                                    label: 'Download PDF',
                                    isPrimary: true, // Blue like dashboard
                                  ),
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
                                DashboardTheme.sectionSpacing),
                            decoration: DashboardTheme.mainContainerDecoration,
                            child: Column(
                              children: [
                                // Filter Summary Header
                                Container(
                                  padding: const EdgeInsets.all(
                                      DashboardTheme.sectionSpacing),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(
                                          DashboardTheme.mainRadius),
                                      topRight: Radius.circular(
                                          DashboardTheme.mainRadius),
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
                                                            vertical: 6),
                                                    decoration: BoxDecoration(
                                                      color: DashboardTheme
                                                          .primary
                                                          .withOpacity(0.1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              16),
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
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Record Count
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: DashboardTheme.primary
                                              .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          '${nitcheListContractRecordList.length} of ${allNitcheList.length} records',
                                          style:
                                              DashboardTheme.inputText.copyWith(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: DashboardTheme.primary,
                                          ),
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
                                    data: nitcheListContractRecordList,
                                    columnsBuilder: (onSortChanged) => [
                                      _buildDataColumn('# Contract no.',
                                          Icons.numbers_rounded),
                                      _buildDataColumn(
                                          'Lessee', Icons.person_rounded),
                                      _buildDataColumn('Location',
                                          Icons.location_on_rounded),
                                      _buildDataColumn('Effective',
                                          Icons.calendar_today_rounded),
                                      _buildDataColumn(
                                          'Expiration', Icons.event_rounded),
                                      _buildDataColumn(
                                          'Status', Icons.info_rounded),
                                      _buildDataColumn('Balance',
                                          Icons.account_balance_wallet_rounded),
                                      _buildDataColumn(
                                          'Action', Icons.visibility_rounded),
                                    ],
                                    dataRowBuilder: (contract, contractIndex,
                                            selected, onSelectChanged) =>
                                        DataRow(
                                      color: MaterialStateProperty.all(
                                        contractIndex % 2 == 0
                                            ? const Color(0xFFF9FAFB)
                                            : Colors.white,
                                      ),
                                      cells: [
                                        _buildDataCell(
                                          child: Text(
                                            contract.contractID.toString(),
                                            style: GoogleFonts.inter(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: const Color(0xFF1F2937),
                                            ),
                                          ),
                                        ),
                                        _buildDataCell(
                                          child: Text(
                                            contract.applicantName
                                                        ?.isNotEmpty ==
                                                    true
                                                ? contract.applicantName!.first
                                                : '',
                                            style: GoogleFonts.inter(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: const Color(0xFF1F2937),
                                            ),
                                          ),
                                        ),
                                        _buildDataCell(
                                          child: Text(
                                            contract.tombLocation ?? 'N/A',
                                            style: GoogleFonts.inter(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: const Color(0xFF1F2937),
                                            ),
                                          ),
                                        ),
                                        _buildDataCell(
                                          child: Text(
                                            contract.dateEffective != null
                                                ? dateTimeFormat('M/d/y h:mm a',
                                                    contract.dateEffective!)
                                                : '',
                                            style: GoogleFonts.inter(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: const Color(0xFF1F2937),
                                            ),
                                          ),
                                        ),
                                        _buildDataCell(
                                          child: Text(
                                            contract.dateofexpiration != null
                                                ? dateTimeFormat('M/d/y h:mm a',
                                                    contract.dateofexpiration!)
                                                : '',
                                            style: GoogleFonts.inter(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: const Color(0xFF1F2937),
                                            ),
                                          ),
                                        ),
                                        _buildDataCell(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: (contract.contractstatus ==
                                                          'active' ||
                                                      contract.status ==
                                                          'active')
                                                  ? const Color(0xFF4CAF50)
                                                  : const Color(0xFFF44336),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              contract.contractstatus ??
                                                  contract.status ??
                                                  'Active',
                                              style: GoogleFonts.inter(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                        _buildDataCell(
                                          child: Text(
                                            'P${contract.balance?.toString() ?? '0'}',
                                            style: GoogleFonts.inter(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: const Color(0xFF374151),
                                            ),
                                          ),
                                        ),
                                        _buildDataCell(
                                          child: InkWell(
                                            onTap: () async {
                                              await showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return ContractDetailsModal(
                                                    contract: contract,
                                                  );
                                                },
                                              );
                                            },
                                            child: Icon(
                                              Icons.visibility,
                                              color: const Color(0xFF6B7280),
                                              size: 20,
                                            ),
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
                                    horizontalDividerColor:
                                        const Color(0xFFE5E7EB),
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
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DashboardTheme.inputRadius),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 16), // Standardized height
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

  // Helper method to build status badges
  Widget _buildStatusBadge(String status, DateTime? dateOfExpiration) {
    // Determine if contract is ongoing or expired
    final now = DateTime.now();
    final isOngoing =
        dateOfExpiration != null && now.isBefore(dateOfExpiration);
    final isExpired = dateOfExpiration != null && now.isAfter(dateOfExpiration);

    // Format the status text
    String statusText = 'Addable';

    if (dateOfExpiration != null) {
      final month = dateOfExpiration.month.toString().padLeft(2, '0');
      final day = dateOfExpiration.day.toString().padLeft(2, '0');
      final year = dateOfExpiration.year.toString();

      if (isOngoing) {
        statusText = 'Occupied until $month/$day/$year';
      } else if (isExpired) {
        statusText = 'Available (Expired: $month/$day/$year)';
      }
    }

    return Container(
      constraints: const BoxConstraints(
        minWidth: 120,
        maxWidth: 200,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Subtle status indicator dot
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color:
                  isOngoing ? const Color(0xFF059669) : const Color(0xFF9CA3AF),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              statusText,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF374151),
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
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
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                ),
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
                  border: Border.all(
                    color: const Color(0xFFF59E0B),
                    width: 1,
                  ),
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                style: GoogleFonts.inter(
                  color: const Color(0xFF6B7280),
                ),
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
              'Successfully updated $updatedCount nitche prices to ₱$newPrice!'),
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

  // Method to download nitche list as PDF
  Future<void> _downloadNitcheListPDF(
      {List<ContractRecord>? nitcheData}) async {
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
      final List<ContractRecord> currentData = nitcheData ?? [];

      // Generate PDF content
      final pdfContent = await _generatePDFContent(currentData);

      // Create and download PDF
      await _createAndDownloadPDF(pdfContent, currentData.length);

      // Close loading dialog
      Navigator.of(context).pop();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'PDF report generated successfully! ${currentData.length} niches included.'),
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

  // Method to generate PDF content
  Future<String> _generatePDFContent(List<ContractRecord> nitcheList) async {
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
            <span class="info-label">Total Niches:</span>
            <span class="info-value">${nitcheList.length}</span>
        </div>

        <div class="info-row">
            <span class="info-label">Search Term:</span>
            <span class="info-value">${_model.textController.text.isNotEmpty ? _model.textController.text : 'None'}</span>
        </div>
    </div>
    
    <table>
        <thead>
            <tr>
                <th>Niche No.</th>
                <th>Initial Fee</th>
                <th>Status</th>
                <th>Expiration Date</th>
                <th>Type</th>
            </tr>
        </thead>
        <tbody>
''');

    // Table rows
    for (final contract in nitcheList) {
      final statusClass = contract.status.toLowerCase() == 'addable'
          ? 'status-addable'
          : 'status-unaddable';
      final expirationText = contract.dateofexpiration != null
          ? '${contract.dateofexpiration!.month.toString().padLeft(2, '0')}/${contract.dateofexpiration!.day.toString().padLeft(2, '0')}/${contract.dateofexpiration!.year}'
          : 'N/A';

      content.writeln('''
            <tr>
                <td>${contract.nitcheid}</td>
                <td>₱ ${contract.amount ?? '0'}</td>
                <td class="$statusClass">${contract.status}</td>
                <td>$expirationText</td>
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
      String htmlContent, int nitcheCount) async {
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
        ..setAttribute('download', 'nitche_list_report_$timestamp.html')
        ..click();

      // Clean up
      html.Url.revokeObjectUrl(url);
    } catch (e) {
      // Fallback: show error message
      throw Exception('Failed to create downloadable file: $e');
    }
  }
}

class ContractDetailsModal extends StatefulWidget {
  final ContractRecord contract;

  const ContractDetailsModal({super.key, required this.contract});

  @override
  State<ContractDetailsModal> createState() => _ContractDetailsModalState();
}

class _ContractDetailsModalState extends State<ContractDetailsModal>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                border: Border(
                  bottom: BorderSide(
                    color: const Color(0xFFE5E7EB),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Contract Details',
                            style: GoogleFonts.inter(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1F2937),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(0, 4, 0, 0),
                            child: Text(
                              'View comprehensive information for contract #${widget.contract.contractID}',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Color(0xFF6B7280),
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                  // Tab Bar
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(0, 16, 0, 0),
                    child: TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      labelColor: const Color(0xFF3B82F6),
                      unselectedLabelColor: const Color(0xFF6B7280),
                      indicatorColor: const Color(0xFF3B82F6),
                      indicatorWeight: 3,
                      tabs: const [
                        Tab(text: 'Overview'),
                        Tab(text: 'Financial'),
                        Tab(text: 'Applicants'),
                        Tab(text: 'Deceased'),
                        Tab(text: 'Details'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(),
                  _buildFinancialTab(),
                  _buildApplicantsTab(),
                  _buildDeceasedTab(),
                  _buildDetailsTab(),
                ],
              ),
            ),
            // Footer
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                border: Border(
                  top: BorderSide(
                    color: const Color(0xFFE5E7EB),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(24, 24, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Contract Status Section
          Container(
            width: double.infinity,
            padding: EdgeInsetsDirectional.fromSTEB(16, 16, 16, 16),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFF4CAF50).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: const Color(0xFF4CAF50),
                  size: 24,
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Contract Status',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                      Text(
                        widget.contract.contractstatus ?? 'Active',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: const Color(0xFF4CAF50),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(0, 24, 0, 0),
            child: Container(
              width: double.infinity,
              padding: EdgeInsetsDirectional.fromSTEB(16, 16, 16, 16),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFF3B82F6).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: const Color(0xFF3B82F6),
                        size: 24,
                      ),
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
                        child: Text(
                          'Basic Information',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(0, 16, 0, 0),
                    child: Column(
                      children: [
                        _buildInfoRow('Contract ID',
                            widget.contract.contractID.toString()),
                        _buildInfoRow('Type', widget.contract.type ?? 'N/A'),
                        _buildInfoRow(
                            'Status', widget.contract.status ?? 'N/A'),
                        _buildInfoRow(
                            'Location', widget.contract.location ?? 'N/A'),

                        // Conditional fields based on contract type
                        if (widget.contract.type?.toLowerCase() == 'lot') ...[
                          // For Lot contracts: show Measurement, Street Address, and Lotstatus
                          _buildInfoRow('Measurement',
                              widget.contract.measurement ?? 'N/A'),
                          _buildInfoRow('Street Address',
                              widget.contract.latestAddress ?? 'N/A'),
                          _buildInfoRow('Lot Status',
                              widget.contract.lotstatus ?? 'N/A'),
                        ] else if (widget.contract.type?.toLowerCase() ==
                            'nitche') ...[
                          // For Nitche contracts: show only Amount (using balance field)
                          _buildInfoRow(
                              'Amount', 'P${widget.contract.balance?.toString() ?? '0'}'),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(0, 8, 0, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1F2937),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialTab() {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(24, 24, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Financial Information',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1F2937),
            ),
          ),
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(0, 16, 0, 0),
            child: Column(
              children: [
                _buildInfoRow('Balance',
                    'P${widget.contract.balance?.toString() ?? '0'}'),
                _buildInfoRow('OR Number', widget.contract.or ?? 'N/A'),
                _buildInfoRow('TIN', widget.contract.tin ?? 'N/A'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicantsTab() {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(24, 24, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Applicant Information',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1F2937),
            ),
          ),
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(0, 16, 0, 0),
            child: Column(
              children: [
                if (widget.contract.applicantName.isNotEmpty)
                  _buildInfoRow('Applicant Name',
                      widget.contract.applicantName.join(', ')),
                if (widget.contract.applicantContactNumber.isNotEmpty)
                  _buildInfoRow('Contact Number',
                      widget.contract.applicantContactNumber.join(', ')),
                if (widget.contract.applcantAddress.isNotEmpty)
                  _buildInfoRow('Address',
                      widget.contract.applcantAddress.join(', ')),
                _buildInfoRow('Latest Address',
                    widget.contract.latestAddress ?? 'N/A'),
                _buildInfoRow('Latest Contact',
                    widget.contract.latestContNum?.toString() ?? 'N/A'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeceasedTab() {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(24, 24, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Deceased Information',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1F2937),
            ),
          ),
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(0, 16, 0, 0),
            child: Column(
              children: [
                if (widget.contract.decFullName.isNotEmpty)
                  _buildInfoRow('Deceased Name',
                      widget.contract.decFullName.join(', ')),
                if (widget.contract.dateofdeath.isNotEmpty)
                  _buildInfoRow('Date of Death',
                      widget.contract.dateofdeath
                          .map((date) => dateTimeFormat('yMd', date))
                          .join(', ')),
                if (widget.contract.burialinternment.isNotEmpty)
                  _buildInfoRow('Burial/Internment',
                      widget.contract.burialinternment
                          .map((date) => dateTimeFormat('yMd', date))
                          .join(', ')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsTab() {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(24, 24, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Additional Details',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1F2937),
            ),
          ),
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(0, 16, 0, 0),
            child: Column(
              children: [
                _buildInfoRow(
                    'Measurement', widget.contract.measurement ?? 'N/A'),
                _buildInfoRow(
                    'Effective Date',
                    widget.contract.dateEffective != null
                        ? dateTimeFormat('yMd', widget.contract.dateEffective!)
                        : 'N/A'),
                _buildInfoRow(
                    'Expiration Date',
                    widget.contract.dateofexpiration != null
                        ? dateTimeFormat(
                            'yMd', widget.contract.dateofexpiration!)
                        : 'N/A'),
                _buildInfoRow(
                    'Years', widget.contract.years?.toString() ?? 'N/A'),
                _buildInfoRow(
                    'Date Added',
                    widget.contract.dateadded != null
                        ? dateTimeFormat('yMd', widget.contract.dateadded!)
                        : 'N/A'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
