import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/flutter_flow_data_table.dart';
import '/custom_code/logo_utils.dart';
import '/flutter_flow/custom_functions.dart';
import 'dart:ui';
import 'dart:convert';
import 'dart:html' as html;
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'burial_lots_list_model.dart';
import 'renewal_modal.dart';
export 'burial_lots_list_model.dart';

class BurialLotsListWidget extends StatefulWidget {
  const BurialLotsListWidget({super.key});

  static String routeName = 'burialLotsList';
  static String routePath = '/burialLotsList';

  @override
  State<BurialLotsListWidget> createState() => _BurialLotsListWidgetState();
}

class _BurialLotsListWidgetState extends State<BurialLotsListWidget> {
  late BurialLotsListModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Variable to store manually selected expiration date
  DateTime? _newExpirationDate;

  // Variable to store calculated total balance
  double? _calculatedTotalBalance;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => BurialLotsListModel());

    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();

    // Add listener to text controller for real-time search
    _model.textController!.addListener(() {
      if (mounted) {
        setState(() {});
        // Debug: Print search text to verify listener is working
        print('Search text changed: "${_model.textController!.text}"');
      }
    });

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      safeSetState(() {});
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return StreamBuilder<List<ContractRecord>>(
      stream: queryContractRecord(
        queryBuilder: (contractRecord) => contractRecord.where(
          'type',
          isEqualTo: 'Lot',
        ),
      ),
      builder: (context, snapshot) {
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
                        const Color(0xFF3B82F6),
                      ),
                      strokeWidth: 3.0,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Loading Burial Lots Data...',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        List<ContractRecord> allLotsList = snapshot.data!;

        // Filter the data based on search text only (show ALL lots regardless of status)
        List<ContractRecord> lotsListContractRecordList =
            allLotsList.where((contract) {
          // Apply search filter only - no status filtering
          if (_model.textController?.text.isNotEmpty == true) {
            final searchText = _model.textController!.text.toLowerCase().trim();
            final location = contract.location?.toLowerCase() ?? '';
            final leessee = contract.leessee?.toLowerCase() ?? '';
            final street = contract.street?.toLowerCase() ?? '';
            final measurement = contract.measurement?.toLowerCase() ?? '';
            final contractID =
                contract.contractID?.toString().toLowerCase() ?? '';

            // Search in multiple fields with improved matching
            bool matchesSearch = location.contains(searchText) ||
                leessee.contains(searchText) ||
                street.contains(searchText) ||
                measurement.contains(searchText) ||
                contractID.contains(searchText);

            // Debug: Print search results for verification
            if (searchText.isNotEmpty) {
              print('Searching for: "$searchText"');
              print(
                  'Contract ${contract.contractID}: location="$location", leessee="$leessee", street="$street", measurement="$measurement", status="${contract.status}"');
              print('Match result: $matchesSearch');
            }

            return matchesSearch;
          }

          // Show all lots regardless of status
          return true;
        }).toList();

        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Scaffold(
            key: scaffoldKey,
            backgroundColor: const Color(0xFFF8FAFC),
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
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0x08000000),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Logo and Title Section
                        Container(
                          padding: EdgeInsets.all(24),
                          child: Column(
                            children: [
                              // Logo Container with gradient and shadow
                              Container(
                                width: 160,
                                height: 160,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 12,
                                      offset: Offset(0, 4),
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
                                style: GoogleFonts.rubik(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1F2937),
                                  letterSpacing: 0.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),

                        Divider(height: 1, color: Color(0xFFE5E7EB)),

                        // Navigation Section
                        Expanded(
                          child: SingleChildScrollView(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 24),

                                // Platform Navigation Section
                                _buildSectionTitle('Platform Navigation'),
                                SizedBox(height: 12),
                                _buildNavItem(
                                  icon: Icons.dashboard_rounded,
                                  title: 'Dashboard',
                                  onTap: () => context.pushNamed('dashboard'),
                                ),

                                SizedBox(height: 32),

                                // Action Section
                                _buildSectionTitle('Action'),
                                SizedBox(height: 12),
                                _buildNavItem(
                                  icon: Icons.description_rounded,
                                  title: 'Manage Contract',
                                  onTap: () =>
                                      context.pushNamed('ManageContract'),
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
                                  isActive: true,
                                  onTap: () {},
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

                                const SizedBox(height: 32),

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
                                      padding:
                                          EdgeInsets.symmetric(vertical: 16),
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
                    decoration: const BoxDecoration(
                      color: Color(0xFFF8FAFC),
                      borderRadius:
                          BorderRadius.only(topLeft: Radius.circular(0)),
                    ),
                    child: Column(
                      children: [
                        // Enhanced Header Section
                        Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0x0A000000),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title and Description with enhanced styling
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Cemetery Lots',
                                          style: GoogleFonts.inter(
                                            fontSize: 28,
                                            fontWeight: FontWeight.w800,
                                            color: const Color(0xFF1F2937),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'View and manage all burial lots and their availability status',
                                          style: GoogleFonts.inter(
                                            fontSize: 16,
                                            color: const Color(0xFF6B7280),
                                            height: 1.4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 32),

                              // Enhanced Search and Actions Row
                              Row(
                                children: [
                                  // Enhanced Search Bar
                                  Expanded(
                                    child: Container(
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF9FAFB),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: const Color(0xFFE5E7EB),
                                          width: 2,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0x0A000000),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: TextFormField(
                                        controller: _model.textController,
                                        obscureText: false,
                                        decoration: InputDecoration(
                                          hintText: 'Search',
                                          hintStyle: const TextStyle(
                                            color: Color(0xFF9CA3AF),
                                            fontSize: 14,
                                          ),
                                          border: InputBorder.none,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
                                          prefixIcon: const Icon(
                                            Icons.search_rounded,
                                            color: Color(0xFF6B7280),
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
                                                  icon: const Icon(
                                                    Icons.clear_rounded,
                                                    color: Color(0xFF6B7280),
                                                    size: 20,
                                                  ),
                                                )
                                              : null,
                                        ),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF1F2937),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 24),

                                  // Enhanced Action Buttons
                                  _buildActionButton(
                                    onPressed: () async {
                                      // Add Lot functionality
                                      context.pushNamed('newAddBurialLocation');
                                    },
                                    icon: Icons.add_rounded,
                                    label: 'Create Plot',
                                    isPrimary: true, // Primary action
                                  ),
                                  const SizedBox(width: 12),

                                  _buildActionButton(
                                    onPressed: () async {
                                      // Update Price functionality
                                      await _showUpdatePriceDialog();
                                    },
                                    icon: Icons.trending_up_rounded,
                                    label: 'Update Price',
                                    isPrimary: false, // Secondary action
                                  ),
                                  const SizedBox(width: 12),

                                  _buildActionButton(
                                    onPressed: () async {
                                      // Download PDF functionality
                                      await _downloadLotsListPDF(
                                          lotsData: allLotsList);
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

                        const SizedBox(height: 24),

                        // Enhanced Data Table Section
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0x0A000000),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                // Filter Summary Header
                                Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                      topRight: Radius.circular(12),
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
                                              style: GoogleFonts.inter(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF1F2937),
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
                                                      color: Color(0xFF3B82F6)
                                                          .withOpacity(0.1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              16),
                                                    ),
                                                    child: Text(
                                                      'Search: "${_model.textController!.text}"',
                                                      style: GoogleFonts.inter(
                                                        fontSize: 12,
                                                        color:
                                                            Color(0xFF3B82F6),
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
                                          color: Color(0xFF18651C)
                                              .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          '${lotsListContractRecordList.length} of ${allLotsList.length} records',
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF18651C),
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
                                    data: lotsListContractRecordList,
                                    columnsBuilder: (onSortChanged) => [
                                      _buildDataColumn(
                                          'Blk-Lot', Icons.location_on_rounded),
                                      _buildDataColumn(
                                          'Leessee', Icons.person_rounded),
                                      _buildDataColumn(
                                          'Street', Icons.home_rounded),
                                      _buildDataColumn('Measurement',
                                          Icons.straighten_rounded),
                                      _buildDataColumn(
                                          'Status', Icons.info_rounded),
                                      DataColumn2(
                                        label: Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 20, horizontal: 16),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                'Initial Fee',
                                                style: GoogleFonts.inter(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w700,
                                                  color:
                                                      const Color(0xFF1F2937),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      DataColumn2(
                                        label: Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 20, horizontal: 16),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                'Actions',
                                                style: GoogleFonts.inter(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w700,
                                                  color:
                                                      const Color(0xFF1F2937),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
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
                                            contract.location ?? 'N/A',
                                            style: GoogleFonts.inter(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: const Color(0xFF1F2937),
                                            ),
                                          ),
                                        ),
                                        _buildDataCell(
                                          child: Text(
                                            contract.leessee ?? 'N/A',
                                            style: GoogleFonts.inter(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: const Color(0xFF6B7280),
                                            ),
                                          ),
                                        ),
                                        _buildDataCell(
                                          child: Text(
                                            contract.street ?? 'N/A',
                                            style: GoogleFonts.inter(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: const Color(0xFF6B7280),
                                            ),
                                          ),
                                        ),
                                        _buildDataCell(
                                          child: Text(
                                            contract.measurement ?? 'N/A',
                                            style: GoogleFonts.inter(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: const Color(0xFF6B7280),
                                            ),
                                          ),
                                        ),
                                        _buildDataCell(
                                          child: _buildStatusBadge(
                                              _getLotStatus(
                                                  contract.dateofexpiration),
                                              contract.dateofexpiration),
                                        ),
                                        _buildDataCell(
                                          child: Text(
                                            '₱${contract.amount ?? '0'}',
                                            style: GoogleFonts.inter(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: const Color(0xFF374151),
                                            ),
                                          ),
                                        ),
                                        _buildDataCell(
                                          child: PopupMenuButton<String>(
                                            icon: Icon(
                                              Icons.more_vert_rounded,
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primary,
                                              size: 20,
                                            ),
                                            onSelected: (value) {
                                              switch (value) {
                                                case 'add_deceased':
                                                  // Navigate to add deceased form
                                                  context.pushNamed(
                                                    'Lotform',
                                                    queryParameters: {
                                                      'id': serializeParam(
                                                        contract.reference,
                                                        ParamType
                                                            .DocumentReference,
                                                      ),
                                                      'lotLocation':
                                                          serializeParam(
                                                        contract.location ?? '',
                                                        ParamType.String,
                                                      ),
                                                      'lotAmount':
                                                          serializeParam(
                                                        double.tryParse(contract
                                                                    .amount ??
                                                                '0') ??
                                                            0.0,
                                                        ParamType.double,
                                                      ),
                                                    }.withoutNulls,
                                                  );
                                                  break;
                                                case 'renewal':
                                                  _showRenewalDialog(context,
                                                      contract, contract);
                                                  break;
                                                case 'edit':
                                                  _showEditLotDialog(
                                                      context, contract);
                                                  break;
                                                default:
                                                  break;
                                              }
                                            },
                                            itemBuilder:
                                                (BuildContext context) => [
                                              PopupMenuItem<String>(
                                                value: 'add_deceased',
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons.person_add_rounded,
                                                      size: 16,
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primary,
                                                    ),
                                                    SizedBox(width: 8),
                                                    Text(
                                                      'Add Deceased',
                                                      style: GoogleFonts.inter(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color:
                                                            Color(0xFF1F2937),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              PopupMenuItem<String>(
                                                value: 'renewal',
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons.refresh_rounded,
                                                      size: 16,
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primary,
                                                    ),
                                                    SizedBox(width: 8),
                                                    Text(
                                                      'Renew Contract',
                                                      style: GoogleFonts.inter(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color:
                                                            Color(0xFF1F2937),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              PopupMenuItem<String>(
                                                value: 'edit',
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons.edit_rounded,
                                                      size: 16,
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primary,
                                                    ),
                                                    SizedBox(width: 8),
                                                    Text(
                                                      'Edit',
                                                      style: GoogleFonts.inter(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color:
                                                            Color(0xFF1F2937),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
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
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF6B7280),
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
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 16), // Standardized height
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF18651C) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isActive ? Colors.white : const Color(0xFF6B7280),
                size: 22,
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isActive ? Colors.white : const Color(0xFF374151),
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: const Color(0xFF18651C),
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1F2937),
              ),
            ),
          ],
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

  // Helper method to get status color
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return const Color(0xFF059669); // Green for active
      case 'available':
        return const Color(0xFF6B7280); // Gray for available
      default:
        return const Color(0xFF9CA3AF); // Default gray
    }
  }

  // Helper method to build status badges
  Widget _buildStatusBadge(String status, DateTime? dateOfExpiration) {
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
              color: _getStatusColor(status),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              dateOfExpiration != null && status.toLowerCase() != 'available'
                  ? '$status until ${_formatDate(dateOfExpiration)}'
                  : status,
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

  // Method to download lots list as PDF
  Future<void> _downloadLotsListPDF({List<ContractRecord>? lotsData}) async {
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
      final List<ContractRecord> currentData = lotsData ?? [];

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
              'PDF report generated successfully! ${currentData.length} lots included.'),
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
  Future<String> _generatePDFContent(List<ContractRecord> lotsList) async {
    final StringBuffer content = StringBuffer();
    final logoBase64 = await _getLogoBase64();

    // Header
    content.writeln('''
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>Burial Lots List Report</title>
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
        .status-active { color: #10B981; font-weight: bold; }
        .status-inactive { color: #EF4444; font-weight: bold; }
        .footer { margin-top: 30px; text-align: center; color: #666; font-size: 12px; }
    </style>
</head>
<body>
    <div class="header">
        <div class="logo-container">
            <img src="data:image/png;base64,$logoBase64" alt="Logo" style="width: 80px; height: 80px; border-radius: 10px; margin-bottom: 15px;">
        </div>
        <div class="title">BALIWAG PUBLIC CEMETERY</div>
        <div class="subtitle">Burial Lots List Report</div>
        <div class="subtitle">Management System</div>
    </div>
    
    <div class="info">
        <div class="info-row">
            <span class="info-label">Report Date:</span>
            <span class="info-value">${DateTime.now().toString().split('.')[0]}</span>
        </div>
        <div class="info-row">
            <span class="info-label">Total Lots:</span>
            <span class="info-value">${lotsList.length}</span>
        </div>
        <div class="info-row">
            <span class="info-label">Search Term:</span>
            <span class="info-value">${_model.textController.text.isNotEmpty ? _model.textController.text : 'None'}</span>
        </div>
    </div>
    
    <table>
        <thead>
            <tr>
                <th>Blk-Lot</th>
                <th>Leessee</th>
                <th>Street</th>
                <th>Measurement</th>
                <th>Status</th>
                <th>Initial Fee</th>
            </tr>
        </thead>
        <tbody>
''');

    // Table rows
    for (final contract in lotsList) {
      final statusClass = contract.contractstatus?.toLowerCase() == 'active'
          ? 'status-active'
          : 'status-inactive';

      content.writeln('''
            <tr>
                <td>${contract.location ?? 'N/A'}</td>
                <td>${contract.leessee ?? 'N/A'}</td>
                <td>${contract.street ?? 'N/A'}</td>
                <td>${contract.measurement ?? 'N/A'}</td>
                <td class="$statusClass">${contract.contractstatus ?? 'N/A'}</td>
                <td>₱ ${contract.amount ?? '0'}</td>
            </tr>
''');
    }

    // Footer
    content.writeln('''
        </tbody>
    </table>
    
    <div class="footer">
        <p>Generated on ${DateTime.now().toString().split('.')[0]}</p>
        <p>Baliwag Public Cemetery Management System</p>
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

  // Helper method to format date for display
  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$month/$day/$year';
  }

  // Method to get lot status based on expiration date
  String _getLotStatus(DateTime? dateOfExpiration) {
    if (dateOfExpiration == null) {
      return 'Available'; // No expiration date means no active contract
    }

    final now = DateTime.now();
    if (now.isBefore(dateOfExpiration)) {
      return 'Active';
    } else {
      return 'Available'; // Expired contracts become available
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
                'Update All Lot Prices',
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
                        'This will update the price for ALL lots. Ongoing contracts will continue with their original terms.',
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
                  labelText: 'New Price for All Lots (₱)',
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
                await _updateAllLotPrices(newPrice);
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

  // Method to update all lot prices in the backend
  Future<void> _updateAllLotPrices(String newPrice) async {
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
                Text('Updating all lot prices...'),
              ],
            ),
          );
        },
      );

      // Find all contract documents with type 'Lot'
      final contractQuery = await FirebaseFirestore.instance
          .collection('contract')
          .where('type', isEqualTo: 'Lot')
          .get();

      if (contractQuery.docs.isEmpty) {
        Navigator.of(context).pop(); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No lot contracts found'),
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
              'Successfully updated $updatedCount lot prices to ₱$newPrice!'),
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
          content: Text('Error updating lot prices: $e'),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // Method to create and download PDF
  Future<void> _createAndDownloadPDF(String htmlContent, int lotsCount) async {
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
        ..setAttribute('download', 'burial_lots_report_$timestamp.html')
        ..click();

      // Clean up
      html.Url.revokeObjectUrl(url);
    } catch (e) {
      // Fallback: show error message
      throw Exception('Failed to create downloadable file: $e');
    }
  }

  // Helper method to calculate new expiration date
  String _calculateNewExpirationDate(
      DateTime? currentExpiration, int renewalYears) {
    if (currentExpiration == null || renewalYears <= 0) {
      return 'Enter renewal period';
    }

    final newExpiration = DateTime(
      currentExpiration.year + renewalYears,
      currentExpiration.month,
      currentExpiration.day,
    );

    return dateTimeFormat('yMMMd', newExpiration);
  }

  // Helper method to calculate total balance for renewal
  double _calculateTotalBalance(DateTime? newExpirationDate, double newAmount) {
    if (newExpirationDate == null) return 0.0;

    final now = DateTime.now();
    final yearsDifference = newExpirationDate.difference(now).inDays / 365.25;

    if (yearsDifference <= 0) return 0.0;

    // Calculate total contract value: (duration × new amount) - new amount
    // This follows the same logic as the lot creation form
    final duration = yearsDifference.ceil(); // Round up to nearest year
    return (duration * newAmount) - newAmount;
  }

  // Method to show renewal dialog
  Future<void> _showRenewalDialog(BuildContext context, ContractRecord contract,
      ContractRecord selectedNitche) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return RenewalModal(
          contract: contract,
          selectedNitche: selectedNitche,
          onRenewal: (contract, selectedNitche, renewalYears, newAmount, lesseeName, orNumber, issueDate) {
            // UI Demo - no backend processing
            print('UI Demo: Contract renewal would be processed here');
          },
          generateORNumber: _generateORNumber,
        );
      },
    );
  }

  // Method to show reburial nitche modal
    // Reset the manually selected expiration date and calculated balance
    setState(() {
      _newExpirationDate = null;
      _calculatedTotalBalance = null;
    });

    final TextEditingController renewalYearsController =
        TextEditingController();
    final TextEditingController newAmountController = TextEditingController();
    final TextEditingController lesseeController = TextEditingController();
    final TextEditingController orNumberController = TextEditingController();
    final TextEditingController issueDateController = TextEditingController();
    DateTime? _selectedIssueDate;

    // Set default values using current contract
    renewalYearsController.text = '1';
    newAmountController.text = contract.amount ?? '0';
    lesseeController.text = contract.leessee ?? '';
    orNumberController.text = _generateORNumber();
    issueDateController.text = dateTimeFormat('yMMMd', DateTime.now());
    _selectedIssueDate = DateTime.now();

    // Calculate initial balance based on default values
    final initialAmount = double.tryParse(contract.amount ?? '0') ?? 0.0;
    final initialExpiration =
        DateTime.now().add(const Duration(days: 365)); // 1 year from now
    _calculatedTotalBalance =
        _calculateTotalBalance(initialExpiration, initialAmount);

    // Add listener to update expiration date display and balance
    renewalYearsController.addListener(() {
      // Trigger rebuild to update the calculated expiration date
      if (context.mounted) {
        (context as Element).markNeedsBuild();
      }

      // Update balance calculation if we have a manually selected expiration date
      if (_newExpirationDate != null) {
        setState(() {
          final newAmount = double.tryParse(newAmountController.text) ?? 0.0;
          _calculatedTotalBalance =
              _calculateTotalBalance(_newExpirationDate, newAmount);
        });
      }
    });

    // Add listener to update balance when amount changes
    newAmountController.addListener(() {
      if (_newExpirationDate != null && context.mounted) {
        setState(() {
          final newAmount = double.tryParse(newAmountController.text) ?? 0.0;
          _calculatedTotalBalance =
              _calculateTotalBalance(_newExpirationDate, newAmount);
        });
      }
    });

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
            width: 480,
            constraints: BoxConstraints(maxHeight: 650),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header Section - Clean and minimal like the image
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 20, 20, 16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Renew Contract',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1F2937),
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.close,
                          color: Color(0xFF9CA3AF),
                          size: 20,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 24,
                          minHeight: 24,
                        ),
                      ),
                    ],
                  ),
                ),

                // Content Section - Single column layout like the image
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Current Contract Info - Compact display
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
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
                                'Current Contract: ${contract.location ?? 'N/A'}',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF374151),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Lessee: ${contract.leessee ?? 'N/A'} • Amount: ₱${contract.amount ?? '0'} • Expires: ${contract.dateofexpiration != null ? dateTimeFormat('yMMMd', contract.dateofexpiration!) : 'N/A'}',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Renewal Period Field
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Renewal period (years)',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF374151),
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: renewalYearsController,
                                decoration: InputDecoration(
                                  hintText: 'Enter number of years',
                                  hintStyle: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: const Color(0xFF9CA3AF),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFD1D5DB),
                                      width: 1,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFD1D5DB),
                                      width: 1,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF3B82F6),
                                      width: 1,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: const Color(0xFF374151),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // New Amount Field
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'New amount (₱)',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF374151),
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: newAmountController,
                                decoration: InputDecoration(
                                  hintText: 'Enter new amount',
                                  hintStyle: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: const Color(0xFF9CA3AF),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFD1D5DB),
                                      width: 1,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFD1D5DB),
                                      width: 1,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF3B82F6),
                                      width: 1,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: const Color(0xFF374151),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Lessee Field
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Lessee name',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF374151),
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: lesseeController,
                                decoration: InputDecoration(
                                  hintText: 'Enter lessee name',
                                  hintStyle: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: const Color(0xFF9CA3AF),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFD1D5DB),
                                      width: 1,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFD1D5DB),
                                      width: 1,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF3B82F6),
                                      width: 1,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                ),
                                keyboardType: TextInputType.text,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: const Color(0xFF374151),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // OR Number Field (Auto-generated)
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'OR number',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF374151),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF9FAFB),
                                  border: Border.all(
                                    color: const Color(0xFFD1D5DB),
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        orNumberController.text,
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          color: const Color(0xFF374151),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          orNumberController.text =
                                              _generateORNumber();
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        child: const Icon(
                                          Icons.refresh,
                                          color: Color(0xFF6B7280),
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Document Issue Date Field
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Document issue date',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF374151),
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: issueDateController,
                                decoration: InputDecoration(
                                  hintText: 'Select issue date',
                                  hintStyle: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: const Color(0xFF9CA3AF),
                                  ),
                                  suffixIcon: const Icon(
                                    Icons.calendar_today,
                                    color: Color(0xFF6B7280),
                                    size: 16,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFD1D5DB),
                                      width: 1,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFD1D5DB),
                                      width: 1,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF3B82F6),
                                      width: 1,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                ),
                                readOnly: true,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: const Color(0xFF374151),
                                ),
                                onTap: () async {
                                  final DateTime? pickedDate =
                                      await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime.now()
                                        .subtract(const Duration(days: 365)),
                                    lastDate: DateTime.now()
                                        .add(const Duration(days: 365)),
                                  );
                                  if (pickedDate != null) {
                                    issueDateController.text =
                                        dateTimeFormat('yMMMd', pickedDate);
                                    _selectedIssueDate = pickedDate;
                                  }
                                },
                              ),
                            ],
                          ),
                        ),

                        // Auto-calculated New Expiration Date
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'New expiration date',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF374151),
                                ),
                              ),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: () async {
                                  final DateTime? picked = await showDatePicker(
                                    context: context,
                                    initialDate: _newExpirationDate ??
                                        DateTime.now()
                                            .add(const Duration(days: 365)),
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime.now()
                                        .add(const Duration(days: 3650)),
                                  );
                                  if (picked != null) {
                                    setState(() {
                                      _newExpirationDate = picked;
                                      final newAmount =
                                          double.tryParse(
                                                  newAmountController.text) ??
                                              0.0;
                                      _calculatedTotalBalance =
                                          _calculateTotalBalance(
                                              picked, newAmount);
                                    });
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF9FAFB),
                                    border: Border.all(
                                      color: const Color(0xFFD1D5DB),
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          _newExpirationDate != null
                                              ? dateTimeFormat(
                                                  'yMMMd', _newExpirationDate!)
                                              : _calculateNewExpirationDate(
                                                  contract.dateofexpiration,
                                                  int.tryParse(
                                                          renewalYearsController
                                                              .text) ??
                                                      0,
                                                ),
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            color: const Color(0xFF374151),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      const Icon(
                                        Icons.calendar_today,
                                        color: Color(0xFF6B7280),
                                        size: 16,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Total Balance Field (Auto-calculated)
                        Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total balance (₱)',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF374151),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF9FAFB),
                                  border: Border.all(
                                    color: const Color(0xFFD1D5DB),
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _calculatedTotalBalance != null
                                            ? '₱${_calculatedTotalBalance!.toStringAsFixed(2)}'
                                            : '₱0.00',
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          color: const Color(0xFF374151),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Footer Actions - Clean and minimal like the image
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                    border: Border(
                      top: BorderSide(
                        color: Color(0xFFF3F4F6),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                            onPressed: () async {
                              // Comprehensive validation like create plot form
                              bool isValid = true;
                              String errorMessage = '';

                              // Check Renewal Period
                              if (renewalYearsController.text.trim().isEmpty) {
                                errorMessage = 'Renewal period is required';
                                isValid = false;
                              } else if (int.tryParse(
                                      renewalYearsController.text) ==
                                  null) {
                                errorMessage =
                                    'Renewal period must be a valid number';
                                isValid = false;
                              } else if (int.parse(
                                      renewalYearsController.text) <=
                                  0) {
                                errorMessage =
                                    'Renewal period must be greater than 0';
                                isValid = false;
                              }

                              // Check New Amount
                              if (newAmountController.text.trim().isEmpty) {
                                errorMessage = 'New amount is required';
                                isValid = false;
                              } else if (double.tryParse(
                                      newAmountController.text) ==
                                  null) {
                                errorMessage =
                                    'New amount must be a valid number';
                                isValid = false;
                              } else if (double.parse(
                                      newAmountController.text) <=
                                  0) {
                                errorMessage =
                                    'New amount must be greater than 0';
                                isValid = false;
                              }

                              // Check Lessee Name
                              if (lesseeController.text.trim().isEmpty) {
                                errorMessage = 'Lessee name is required';
                                isValid = false;
                              }

                              // Check Issue Date
                              if (_selectedIssueDate == null) {
                                errorMessage =
                                    'Document issue date is required';
                                isValid = false;
                              }

                              if (!isValid) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(errorMessage),
                                    backgroundColor: const Color(0xFFEF4444),
                                    duration: const Duration(seconds: 3),
                                  ),
                                );
                                return;
                              }

                              final renewalYears =
                                  int.parse(renewalYearsController.text);
                              final newAmount =
                                  double.parse(newAmountController.text);
                              final lesseeName = lesseeController.text.trim();
                              final orNumber = orNumberController.text.trim();
                              final issueDate = _selectedIssueDate!;

                              // Close dialog
                              Navigator.of(context).pop();

                              // Process renewal
                              await _processContractRenewal(
                                  contract,
                                  selectedNitche,
                                  renewalYears,
                                  newAmount,
                                  lesseeName,
                                  orNumber,
                                  issueDate);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3B82F6),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              'Save',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
          },
        );
      },
    );
  }

  // Method to show reburial nitche modal
  Future<void> _showReburialNitcheModal(
      BuildContext context, ContractRecord contract) async {
    // Deceased details controllers
    TextEditingController deceasedNameController = TextEditingController();
    TextEditingController deceasedDateOfDeathController =
        TextEditingController();
    TextEditingController deceasedDateOfBurialController =
        TextEditingController();

    // Applicant details controllers
    TextEditingController applicantNameController = TextEditingController();
    TextEditingController applicantPhoneController = TextEditingController();
    TextEditingController applicantAddressController = TextEditingController();
    TextEditingController renewalAmountController = TextEditingController(
        text: contract.amount.isNotEmpty ? contract.amount : '');

    TextEditingController referenceNumberController =
        TextEditingController(text: _generateORNumber());
    TextEditingController totalBalanceController = TextEditingController();
    TextEditingController totalYearsController = TextEditingController();
    TextEditingController dateOfExpirationController = TextEditingController();
    TextEditingController dateIssuedController =
        TextEditingController(text: dateTimeFormat('yMMMd', DateTime.now()));
    TextEditingController tinController = TextEditingController(
        text: contract.tin.isNotEmpty ? contract.tin : '');
    TextEditingController residentCertController = TextEditingController(
        text: contract.residentCert.isNotEmpty ? contract.residentCert : '');
    TextEditingController placeIssuedController = TextEditingController(
        text:
            contract.placeIssued.isNotEmpty ? contract.placeIssued : 'Baliwag');

    String selectedTab = 'Contract';
    String selectedRenewalPeriod = '5 Years';
    DateTime? newExpirationDate;
    DateTime? dateIssued = DateTime.now();
    int? calculatedTotalBalance;
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    // Recalculate total balance when amount changes
    Future<void> recalculateTotalBalance() async {
      if (renewalAmountController.text.isNotEmpty &&
          selectedRenewalPeriod.isNotEmpty &&
          newExpirationDate != null) {
        // Calculate total years using the same logic as NitchecontractFormCopy
        final int currentYear = DateTime.now().year;
        final int expirationYear = newExpirationDate!.year;
        final int duration = expirationYear - currentYear;

        if (duration > 0) {
          print('Debug: Duration calculated: $duration');
          setState(() {
            totalYearsController.text = duration.toString();
          });

          // Calculate total contract value: (duration × initial fee) - initial fee
          if (renewalAmountController.text.isNotEmpty) {
            final double initialFee =
                double.tryParse(renewalAmountController.text) ?? 0.0;
            final double totalContractValue =
                (duration * initialFee) - initialFee;

            calculatedTotalBalance = totalContractValue.toInt();
            setState(() {
              totalBalanceController.text =
                  calculatedTotalBalance?.toString() ?? '0';
            });
          }
        }
      }
    }

    // Helper method to calculate years and balance
    void _calculateYearsAndBalance() {
      if (newExpirationDate != null) {
        // Calculate total years using the same logic as NitchecontractFormCopy
        final int currentYear = DateTime.now().year;
        final int expirationYear = newExpirationDate!.year;
        final int duration = expirationYear - currentYear;

        if (duration > 0) {
          totalYearsController.text = duration.toString();

          // Calculate total contract value: (duration × initial fee) - initial fee
          if (renewalAmountController.text.isNotEmpty) {
            final double initialFee =
                double.tryParse(renewalAmountController.text) ?? 0.0;
            final double totalContractValue =
                (duration * initialFee) - initialFee;

            calculatedTotalBalance = totalContractValue.toInt();
            setState(() {
              totalBalanceController.text =
                  calculatedTotalBalance?.toString() ?? '0';
            });
          }
        }
      }
    }

    // Initialize default values
    if (newExpirationDate == null) {
      // Set default expiration date to 5 years from now
      DateTime defaultExpiration = DateTime(
        DateTime.now().year + 5,
        DateTime.now().month,
        DateTime.now().day,
      );

      newExpirationDate = defaultExpiration;
      dateOfExpirationController.text =
          dateTimeFormat('yMMMd', defaultExpiration);

      // Calculate total years using the same logic as NitchecontractFormCopy
      final int currentYear = DateTime.now().year;
      final int expirationYear = defaultExpiration.year;
      final int duration = expirationYear - currentYear;

      if (duration > 0) {
        totalYearsController.text = duration.toString();

        // Calculate total contract value: (duration × initial fee) - initial fee
        if (renewalAmountController.text.isNotEmpty) {
          final double initialFee =
              double.tryParse(renewalAmountController.text) ?? 0.0;
          final double totalContractValue =
              (duration * initialFee) - initialFee;

          calculatedTotalBalance = totalContractValue.toInt();
          setState(() {
            totalBalanceController.text =
                calculatedTotalBalance?.toString() ?? '0';
          });
        }
      }
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.9,
                padding: EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Reburial',
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            // Dispose controllers
                            deceasedNameController.dispose();
                            deceasedDateOfDeathController.dispose();
                            deceasedDateOfBurialController.dispose();
                            applicantNameController.dispose();
                            applicantPhoneController.dispose();
                            applicantAddressController.dispose();
                            renewalAmountController.dispose();
                            referenceNumberController.dispose();
                            totalBalanceController.dispose();
                            totalYearsController.dispose();
                            dateOfExpirationController.dispose();
                            dateIssuedController.dispose();
                            tinController.dispose();
                            residentCertController.dispose();
                            placeIssuedController.dispose();
                            Navigator.of(context).pop();
                          },
                          icon: Icon(Icons.close, color: Color(0xFF6B7280)),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),

                    // Tabs
                    Row(
                      children: [
                        _buildTab('Contract', selectedTab == 'Contract', () {
                          setState(() {
                            selectedTab = 'Contract';
                          });
                        }),
                        SizedBox(width: 24),
                        _buildTab('Applicant', selectedTab == 'Applicant', () {
                          setState(() {
                            selectedTab = 'Applicant';
                          });
                        }),
                        SizedBox(width: 24),
                        _buildTab('Deceased (Optional)',
                            selectedTab == 'Deceased (Optional)', () {
                          setState(() {
                            selectedTab = 'Deceased (Optional)';
                          });
                        }),
                      ],
                    ),
                    SizedBox(height: 24),

                    // Tab Content
                    Expanded(
                      child: SingleChildScrollView(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (selectedTab == 'Contract') ...[
                                // Contract Terms & Financial Details Section
                                Text(
                                  'Contract Terms & Financial Details',
                                  style: GoogleFonts.inter(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1F2937),
                                  ),
                                ),
                                SizedBox(height: 16),
                                // Date Issued Field
                                GestureDetector(
                                  onTap: () async {
                                    final DateTime? picked =
                                        await showDatePicker(
                                      context: context,
                                      initialDate: dateIssued ?? DateTime.now(),
                                      firstDate: DateTime(2020),
                                      lastDate: DateTime.now(),
                                    );
                                    if (picked != null &&
                                        picked != dateIssued) {
                                      setState(() {
                                        dateIssued = picked;
                                        dateIssuedController.text =
                                            dateTimeFormat('yMMMd', picked);
                                      });
                                    }
                                  },
                                  child: AbsorbPointer(
                                    child: _buildFormField(
                                      'Date Issued*',
                                      dateIssuedController,
                                      'Select date issued',
                                      readOnly: true,
                                      prefixIcon: Icon(Icons.calendar_today),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 16),
                                _buildFormFieldWithListener(
                                  'Initial Contract Fee (₱)*',
                                  renewalAmountController,
                                  'Enter initial contract fee',
                                  keyboardType: TextInputType.number,
                                  prefixIcon:
                                      Icon(Icons.currency_exchange_rounded),
                                  onChanged: (value) {
                                    recalculateTotalBalance();
                                  },
                                ),
                                SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildFormField(
                                        'Contract Duration (Years)*',
                                        totalYearsController,
                                        'Auto-calculated',
                                        readOnly: true,
                                      ),
                                    ),
                                    SizedBox(width: 16),
                                    Expanded(
                                      child: _buildFormField(
                                        'Total Contract Value (₱)*',
                                        totalBalanceController,
                                        'Auto-calculated',
                                        readOnly: true,
                                        prefixIcon: Icon(
                                            Icons.currency_exchange_rounded),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16),
                                // Date of Expiration Field
                                GestureDetector(
                                  onTap: () async {
                                    final DateTime? picked =
                                        await showDatePicker(
                                      context: context,
                                      initialDate: newExpirationDate ??
                                          DateTime.now()
                                              .add(Duration(days: 365 * 5)),
                                      firstDate: DateTime.now()
                                          .add(Duration(days: 365 * 5)),
                                      lastDate: DateTime.now()
                                          .add(Duration(days: 365 * 50)),
                                    );
                                    if (picked != null &&
                                        picked != newExpirationDate) {
                                      setState(() {
                                        newExpirationDate = picked;
                                        dateOfExpirationController.text =
                                            dateTimeFormat('yMMMd', picked);
                                        _calculateYearsAndBalance();
                                      });
                                    }
                                  },
                                  child: AbsorbPointer(
                                    child: _buildFormField(
                                      'Date of Expiration*',
                                      dateOfExpirationController,
                                      'Select expiration date',
                                      readOnly: true,
                                      prefixIcon: Icon(Icons.calendar_today),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 16),
                                _buildFormField(
                                  'Contract Duration',
                                  TextEditingController(
                                      text: selectedRenewalPeriod),
                                  'Select duration',
                                  readOnly: true,
                                  suffixIcon: DropdownButton<String>(
                                    value: selectedRenewalPeriod,
                                    onChanged: (String? newValue) {
                                      if (newValue != null) {
                                        setState(() {
                                          selectedRenewalPeriod = newValue;
                                          // Extract years from the selected period
                                          final years = int.tryParse(
                                                  newValue.split(' ')[0]) ??
                                              5;
                                          newExpirationDate = DateTime(
                                            DateTime.now().year + years,
                                            DateTime.now().month,
                                            DateTime.now().day,
                                          );
                                          dateOfExpirationController.text =
                                              dateTimeFormat(
                                                  'yMMMd', newExpirationDate!);

                                          // Calculate total years using the same logic as NitchecontractFormCopy
                                          final int currentYear =
                                              DateTime.now().year;
                                          final int expirationYear =
                                              newExpirationDate!.year;
                                          final int duration =
                                              expirationYear - currentYear;

                                          if (duration > 0) {
                                            print(
                                                'Debug: Duration calculated in dropdown: $duration');
                                            setState(() {
                                              totalYearsController.text =
                                                  duration.toString();
                                            });

                                            // Calculate total contract value: (duration × initial fee) - initial fee
                                            if (renewalAmountController
                                                .text.isNotEmpty) {
                                              final double initialFee =
                                                  double.tryParse(
                                                          renewalAmountController
                                                              .text) ??
                                                      0.0;
                                              final double totalContractValue =
                                                  (duration * initialFee) -
                                                      initialFee;

                                              calculatedTotalBalance =
                                                  totalContractValue.toInt();
                                              setState(() {
                                                totalBalanceController.text =
                                                    calculatedTotalBalance
                                                            ?.toString() ??
                                                        '0';
                                              });
                                            }
                                          }
                                        });
                                      }
                                    },
                                    items: List.generate(46, (index) {
                                      final years = index + 5;
                                      return DropdownMenuItem<String>(
                                        value: '$years Years',
                                        child: Text('$years Years'),
                                      );
                                    }),
                                  ),
                                ),
                                SizedBox(height: 16),
                                _buildFormField(
                                  'Payment Method',
                                  TextEditingController(text: 'Cash'),
                                  'Payment method',
                                  readOnly: true,
                                  suffixIcon: DropdownButton<String>(
                                    value: 'Cash',
                                    onChanged: (String? newValue) {
                                      // Only Cash is allowed
                                    },
                                    items: ['Cash'].map((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ] else if (selectedTab == 'Applicant') ...[
                                _buildFormField(
                                  'Applicant Name*',
                                  applicantNameController,
                                  'Enter full name',
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter applicant name';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 16),
                                _buildFormField(
                                  'Phone Number*',
                                  applicantPhoneController,
                                  'Enter phone number',
                                  keyboardType: TextInputType.phone,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter phone number';
                                    }
                                    if (!RegExp(r'^[0-9+\-\s()]+$')
                                        .hasMatch(value)) {
                                      return 'Please enter a valid phone number';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 16),
                                _buildFormField(
                                  'Address*',
                                  applicantAddressController,
                                  'Enter address',
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter address';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 16),
                                _buildFormField(
                                  'TIN*',
                                  tinController,
                                  'Enter TIN',
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter TIN';
                                    }
                                    if (!RegExp(r'^\d{3}-\d{3}-\d{3}-\d{3}$')
                                        .hasMatch(value)) {
                                      return 'Please enter TIN in format: 000-000-000-000';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 16),
                                _buildFormField(
                                  'Resident Certificate ( Community Tax Certificate / Sedula )*',
                                  residentCertController,
                                  'Enter resident certificate',
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter resident certificate';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 16),
                                _buildFormField(
                                  'Place Issued*',
                                  placeIssuedController,
                                  'Enter place issued',
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter place issued';
                                    }
                                    return null;
                                  },
                                ),
                              ] else if (selectedTab ==
                                  'Deceased (Optional)') ...[
                                Container(
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.yellow.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: Colors.yellow.shade200),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.info_outline,
                                          color: Colors.yellow.shade700),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          'Deceased information is optional for reburial. You can leave these fields empty if not available.',
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            color: Colors.yellow.shade700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 16),
                                _buildFormField(
                                  'Deceased Name',
                                  deceasedNameController,
                                  'Enter deceased name (optional)',
                                ),
                                SizedBox(height: 16),
                                GestureDetector(
                                  onTap: () async {
                                    final DateTime? picked =
                                        await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(1900),
                                      lastDate: DateTime.now(),
                                    );
                                    if (picked != null) {
                                      deceasedDateOfDeathController.text =
                                          dateTimeFormat('yMMMd', picked);
                                    }
                                  },
                                  child: AbsorbPointer(
                                    child: _buildFormField(
                                      'Date of Death',
                                      deceasedDateOfDeathController,
                                      'Select date of death (optional)',
                                      readOnly: true,
                                      prefixIcon: Icon(Icons.calendar_today),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 16),
                                GestureDetector(
                                  onTap: () async {
                                    final DateTime? picked =
                                        await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(1900),
                                      lastDate: DateTime.now(),
                                    );
                                    if (picked != null) {
                                      deceasedDateOfBurialController.text =
                                          dateTimeFormat('yMMMd', picked);
                                    }
                                  },
                                  child: AbsorbPointer(
                                    child: _buildFormField(
                                      'Date of Burial/Internment',
                                      deceasedDateOfBurialController,
                                      'Select date of burial (optional)',
                                      readOnly: true,
                                      prefixIcon: Icon(Icons.calendar_today),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Footer
                    SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            // Dispose controllers
                            deceasedNameController.dispose();
                            deceasedDateOfDeathController.dispose();
                            deceasedDateOfBurialController.dispose();
                            applicantNameController.dispose();
                            applicantPhoneController.dispose();
                            applicantAddressController.dispose();
                            renewalAmountController.dispose();
                            referenceNumberController.dispose();
                            totalBalanceController.dispose();
                            totalYearsController.dispose();
                            dateOfExpirationController.dispose();
                            dateIssuedController.dispose();
                            tinController.dispose();
                            residentCertController.dispose();
                            placeIssuedController.dispose();
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () async {
                            // Validate form before proceeding
                            if (_formKey.currentState!.validate()) {
                              await _executeReburialContract(
                                contract,
                                renewalAmountController.text,
                                newExpirationDate,
                                selectedRenewalPeriod,
                                '', // Empty string for notes since field is removed
                                deceasedNameController.text,
                                deceasedDateOfDeathController.text,
                                deceasedDateOfBurialController.text,
                                applicantNameController.text,
                                '', // Empty string for email since field is removed
                                applicantPhoneController.text,
                                applicantAddressController.text,
                                tinController.text,
                                residentCertController.text,
                                placeIssuedController.text,
                                dateIssued,
                                referenceNumberController.text,
                                totalBalanceController.text,
                              );
                              // Dispose controllers
                              deceasedNameController.dispose();
                              deceasedDateOfDeathController.dispose();
                              deceasedDateOfBurialController.dispose();
                              applicantNameController.dispose();
                              applicantPhoneController.dispose();
                              applicantAddressController.dispose();
                              renewalAmountController.dispose();
                              referenceNumberController.dispose();
                              totalBalanceController.dispose();
                              totalYearsController.dispose();
                              dateOfExpirationController.dispose();
                              dateIssuedController.dispose();
                              tinController.dispose();
                              residentCertController.dispose();
                              placeIssuedController.dispose();
                              Navigator.of(context).pop();
                            } else {
                              // Show validation error message
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Please fill in all required fields'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF1F2937),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Create Contract',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Helper method to build tabs
  Widget _buildTab(String title, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? Color(0xFF1F2937) : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            color: isActive ? Color(0xFF1F2937) : Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }

  // Helper method to build form fields
  Widget _buildFormField(
    String label,
    TextEditingController controller,
    String hintText, {
    bool readOnly = false,
    TextInputType? keyboardType,
    Widget? prefixIcon,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF374151),
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Color(0xFFD1D5DB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Color(0xFFD1D5DB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Color(0xFF1F2937), width: 2),
            ),
            filled: true,
            fillColor: readOnly ? Color(0xFFF9FAFB) : Colors.white,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  // Helper method to build form fields with listener
  Widget _buildFormFieldWithListener(
    String label,
    TextEditingController controller,
    String hintText, {
    TextInputType? keyboardType,
    Widget? prefixIcon,
    Widget? suffixIcon,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF374151),
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Color(0xFFD1D5DB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Color(0xFFD1D5DB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Color(0xFF1F2937), width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  // Method to show edit lot dialog
  Future<void> _showEditLotDialog(
      BuildContext context, ContractRecord contract) async {
    final formKey = GlobalKey<FormState>();
    final measurementController = TextEditingController(
        text: contract.measurement.isNotEmpty ? contract.measurement : '');
    final streetController = TextEditingController(
        text: contract.street.isNotEmpty ? contract.street : '');

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.edit_rounded,
                color: FlutterFlowTheme.of(context).primary,
                size: 24,
              ),
              SizedBox(width: 12),
              Text(
                'Edit Lot Details',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          content: Container(
            width: 500,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Location (read-only)
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xFFF0F9FF),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Color(0xFF0EA5E9),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          color: Color(0xFF0EA5E9),
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Location: ${contract.location.isNotEmpty ? contract.location : 'N/A'}',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0EA5E9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),

                  // Editable fields
                  _buildEditField(
                    label: 'Measurement *',
                    controller: measurementController,
                    hintText: 'Enter measurement (e.g., 3x1)',
                    prefixIcon: Icons.straighten_rounded,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Measurement is required';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  _buildEditField(
                    label: 'Street *',
                    controller: streetController,
                    hintText: 'Enter street name',
                    prefixIcon: Icons.location_on_rounded,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Street is required';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                measurementController.dispose();
                streetController.dispose();
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6B7280),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  await _updateLotDetails(
                    context,
                    contract,
                    measurementController.text,
                    streetController.text,
                  );
                  measurementController.dispose();
                  streetController.dispose();
                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: FlutterFlowTheme.of(context).primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Save Changes',
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

  // Helper method to build edit fields
  Widget _buildEditField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF374151),
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Color(0xFFE5E7EB),
              width: 1,
            ),
          ),
          child: TextFormField(
            controller: controller,
            validator: validator,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 14,
              ),
              prefixIcon: Icon(prefixIcon, size: 20, color: Color(0xFF6B7280)),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Color(0xFF1F2937),
            ),
          ),
        ),
      ],
    );
  }

  // Method to update lot details in Firestore
  Future<void> _updateLotDetails(
    BuildContext context,
    ContractRecord contract,
    String measurement,
    String street,
  ) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text('Updating lot details...'),
              ],
            ),
          );
        },
      );

      // Update the contract document
      await contract.reference.update({
        'measurement': measurement,
        'street': street,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      // Close loading dialog
      Navigator.of(context).pop();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lot details updated successfully!'),
          backgroundColor: Color(0xFF16A34A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );

      // Refresh the data
      setState(() {});
    } catch (e) {
      // Close loading dialog if it's still open
      Navigator.of(context).pop();

      print('Error updating lot details: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating lot details: $e'),
          backgroundColor: Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  // Method to execute reburial contract
  Future<void> _executeReburialContract(
    ContractRecord contract,
    String renewalAmount,
    DateTime? newExpirationDate,
    String renewalPeriod,
    String notes,
    String deceasedName,
    String deceasedDateOfDeath,
    String deceasedDateOfBurial,
    String applicantName,
    String applicantEmail,
    String applicantPhone,
    String applicantAddress,
    String tin,
    String residentCert,
    String placeIssued,
    DateTime? dateIssued,
    String referenceNumber,
    String totalBalance,
  ) async {
    try {
      // Get next contract ID
      FFAppState().getNextContractId();

      // Create the contract record
      await contract.reference.update({
        ...createContractRecordData(
          tombLocation: contract.location,
          amount: renewalAmount,
          or: referenceNumber,
          tin: tin,
          residentCert: residentCert,
          placeIssued: placeIssued,
          dateIssued: dateIssued ?? DateTime.now(),
          location: contract.location,
          contractID: FFAppState().contractid,
          contractidString: FFAppState().contractid.toString(),
          type: contract.type,
          leessee: applicantName,
          dateEffective: contract.dateofexpiration ?? DateTime.now(),
          status: 'unaddable',
          dateofexpiration: newExpirationDate,
          contractstatus: 'active',
          initialfee: double.tryParse(renewalAmount),
          balance: int.tryParse(totalBalance),
          measurement: contract.measurement,
          street: contract.street,
        ),
        ...mapToFirestore({
          'applicantName': FieldValue.arrayUnion([applicantName]),
          'applcantAddress': FieldValue.arrayUnion([applicantAddress]),
          'applicantContactNumber':
              FieldValue.arrayUnion([int.tryParse(applicantPhone) ?? 0]),
          'decFullName': FieldValue.arrayUnion([deceasedName]),
          'burialinternment': FieldValue.arrayUnion(
              [DateTime.tryParse(deceasedDateOfBurial) ?? DateTime.now()]),
          'dateofdeath': FieldValue.arrayUnion(
              [DateTime.tryParse(deceasedDateOfDeath) ?? DateTime.now()]),
          'TIN': tin,
          'ResidentCert': residentCert,
          'placeIssued': placeIssued,
          'dateIssued': dateIssued ?? DateTime.now(),
          'OR': referenceNumber,
          'email': applicantEmail,
          'phoneNumber': applicantPhone,
        }),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Reburial contract created successfully for $renewalPeriod'),
          backgroundColor: Color(0xFF16A34A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    } catch (e) {
      print('Error creating reburial contract: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating reburial contract: $e'),
          backgroundColor: Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  // Helper method to build info rows in renewal dialog
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build confirmation rows in the confirmation dialog
  Widget _buildConfirmationRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF374151),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF6B7280),
            ),
          ),
        ),
      ],
    );
  }

  // Helper method to generate OR number using current app state
  String _generateORNumber() {
    // Use FFAppState().qrcode if available, otherwise generate fallback
    final qrcode = context.read<FFAppState>().qrcode;
    if (qrcode.isNotEmpty) {
      return qrcode;
    }

    // Fallback: Generate OR number using timestamp (similar to nitche form)
    return 'OR-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
  }

  // Method to process contract renewal
  Future<void> _processContractRenewal(
      ContractRecord contract,
      ContractRecord selectedNitche,
      int renewalYears,
      double newAmount,
      String lesseeName,
      String orNumber,
      DateTime issueDate) async {
    // Show confirmation dialog first
    bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(
                Icons.help_outline_rounded,
                color: FlutterFlowTheme.of(context).primary,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Confirm Contract Renewal',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          content: Container(
            width: 450,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Are you sure you want to renew this contract with the following details?',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 20),

                // Contract Details
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: const Color(0xFFE5E7EB), width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildConfirmationRow(
                          'Location:', contract.location ?? 'N/A'),
                      const SizedBox(height: 12),
                      _buildConfirmationRow('Lessee:', lesseeName),
                      const SizedBox(height: 12),
                      _buildConfirmationRow(
                          'Renewal Period:', '$renewalYears years'),
                      const SizedBox(height: 12),
                      _buildConfirmationRow('New Amount:', '₱$newAmount'),
                      const SizedBox(height: 12),
                      _buildConfirmationRow('OR Number:', orNumber),
                      const SizedBox(height: 12),
                      _buildConfirmationRow(
                          'Issue Date:', dateTimeFormat('yMMMd', issueDate)),
                      const SizedBox(height: 12),
                      _buildConfirmationRow(
                          'New Expiration:',
                          dateTimeFormat(
                              'yMMMd',
                              DateTime(
                                (contract.dateofexpiration ?? DateTime.now())
                                        .year +
                                    renewalYears,
                                (contract.dateofexpiration ?? DateTime.now())
                                    .month,
                                (contract.dateofexpiration ?? DateTime.now())
                                    .day,
                              ))),
                      const SizedBox(height: 12),
                      _buildConfirmationRow('Total Balance:',
                          '₱${_calculatedTotalBalance?.toStringAsFixed(2) ?? '0.00'}'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: FlutterFlowTheme.of(context).primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(
                'Confirm Renewal',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );

    // If user cancels, return early
    if (confirmed != true) {
      return;
    }

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
                Text('Processing contract renewal...'),
              ],
            ),
          );
        },
      );

      // Use manually selected expiration date if available, otherwise calculate from renewal years
      final newExpiration = _newExpirationDate ??
          DateTime(
            (contract.dateofexpiration ?? DateTime.now()).year + renewalYears,
            (contract.dateofexpiration ?? DateTime.now()).month,
            (contract.dateofexpiration ?? DateTime.now()).day,
          );

      // Update contract in Firestore
      await contract.reference.update({
        'amount': newAmount.toString(),
        'dateofexpiration': newExpiration,
        'leessee': lesseeName,
        'orNumber': orNumber,
        'dateAdded': issueDate,
        'contractstatus': 'Active',
        'status': 'Active',
      });

      // Close loading dialog
      Navigator.of(context).pop();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Contract renewed successfully! New expiration date: ${dateTimeFormat('yMMMd', newExpiration)}',
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
          content: Text('Error renewing contract: $e'),
          backgroundColor: Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
