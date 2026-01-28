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
import '/custom_code/actions/index.dart' as actions;
import '/admin_side/shared/expired_contracts.dart';
import 'dart:ui';
import 'dart:convert';
import 'dart:html' as html;
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'burial_lots_list_model.dart';
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

  // Method to apply filters
  List<ContractRecord> _applyFilters(List<ContractRecord> allLotsList) {
    return allLotsList.where((contract) {
      // Apply search filter
      if (_model.textController?.text.isNotEmpty == true) {
        final searchText = _model.textController!.text.toLowerCase().trim();
        final location = contract.location?.toLowerCase() ?? '';
        final leessee = contract.leessee?.toLowerCase() ?? '';
        final street = contract.street?.toLowerCase() ?? '';
        final measurement = contract.measurement?.toLowerCase() ?? '';
        final contractID = contract.contractID?.toString().toLowerCase() ?? '';

        // Search in multiple fields with improved matching
        bool matchesSearch = location.contains(searchText) ||
            leessee.contains(searchText) ||
            street.contains(searchText) ||
            measurement.contains(searchText) ||
            contractID.contains(searchText);

        if (!matchesSearch) return false;
      }

      // Apply status filter
      if (_model.statusFilter != null && _model.statusFilter != 'all') {
        final lotStatus = _getLotStatus(contract.dateofexpiration);
        if (_model.statusFilter == 'available') {
          return lotStatus.toLowerCase() == 'available';
        } else if (_model.statusFilter == 'occupied') {
          return lotStatus.toLowerCase() == 'active';
        }
      }

      return true;
    }).toList();
  }

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

    // On page load action: process expired contracts and create vaults
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await processExpiredContracts();
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

        // Apply filters (search and status)
        List<ContractRecord> lotsListContractRecordList =
            _applyFilters(allLotsList);

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
                                style: GoogleFonts.inter(
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
                                        onChanged: (value) {
                                          setState(() {
                                            // Trigger filter update when search text changes
                                          });
                                        },
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
                                      // Record Count and Status Filter
                                      Row(
                                        children: [
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
                                          SizedBox(width: 16),
                                          // Status Filter
                                          PopupMenuButton<String>(
                                            onSelected: (String value) {
                                              setState(() {
                                                _model.statusFilter = value;
                                              });
                                            },
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 8),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFF8FAFC),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                  color:
                                                      const Color(0xFFE5E7EB),
                                                  width: 1,
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.filter_list_rounded,
                                                    color:
                                                        const Color(0xFF6B7280),
                                                    size: 18,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    _model.statusFilter ==
                                                            'available'
                                                        ? 'Expired'
                                                        : _model.statusFilter ==
                                                                'occupied'
                                                            ? 'Active'
                                                            : 'All Status',
                                                    style: GoogleFonts.inter(
                                                      fontSize: 14,
                                                      color: const Color(
                                                          0xFF6B7280),
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Icon(
                                                    Icons
                                                        .keyboard_arrow_down_rounded,
                                                    color:
                                                        const Color(0xFF6B7280),
                                                    size: 18,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            itemBuilder:
                                                (BuildContext context) => [
                                              PopupMenuItem<String>(
                                                value: 'all',
                                                child: Text(
                                                  'All Status',
                                                  style: GoogleFonts.inter(
                                                    fontSize: 14,
                                                    color:
                                                        const Color(0xFF6B7280),
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                              PopupMenuItem<String>(
                                                value: 'available',
                                                child: Text(
                                                  'Expired',
                                                  style: GoogleFonts.inter(
                                                    fontSize: 14,
                                                    color:
                                                        const Color(0xFF6B7280),
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                              PopupMenuItem<String>(
                                                value: 'occupied',
                                                child: Text(
                                                  'Active',
                                                  style: GoogleFonts.inter(
                                                    fontSize: 14,
                                                    color:
                                                        const Color(0xFF059669),
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
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
                                          'Lessee', Icons.person_rounded),
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
                                              Icon(
                                                Icons.assignment_rounded,
                                                color: const Color(0xFF18651C),
                                                size: 18,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Type',
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
                                          child: _buildLotStatusBadge(
                                              contract.lotstatus ??
                                                  'available'),
                                        ),
                                        _buildDataCell(
                                          child: Text(
                                            'Php. ${contract.amount ?? '0'}',
                                            style: GoogleFonts.inter(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: const Color(0xFF000000),
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
                                                case 'renew_contract':
                                                  _showRenewContractModal(
                                                      context, contract);
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
                                                enabled: _isContractActive(
                                                    contract.dateofexpiration),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons.person_add_rounded,
                                                      size: 16,
                                                      color: _isContractActive(
                                                              contract
                                                                  .dateofexpiration)
                                                          ? FlutterFlowTheme.of(
                                                                  context)
                                                              .primary
                                                          : Colors.grey,
                                                    ),
                                                    SizedBox(width: 8),
                                                    Text(
                                                      'Add Deceased',
                                                      style: GoogleFonts.inter(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: _isContractActive(
                                                                contract
                                                                    .dateofexpiration)
                                                            ? Color(0xFF1F2937)
                                                            : Colors.grey,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              // Show renew contract option if dateofexpiration is null
                                              if (contract.dateofexpiration ==
                                                  null)
                                                PopupMenuItem<String>(
                                                  value: 'renew_contract',
                                                  enabled: true,
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        Icons.autorenew_rounded,
                                                        size: 16,
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                      ),
                                                      SizedBox(width: 8),
                                                      Text(
                                                        'Renew Contract',
                                                        style:
                                                            GoogleFonts.inter(
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
    int notificationCount = 0,
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
              if (notificationCount > 0) ...[
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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

  // Helper method to build lot status badges
  Widget _buildLotStatusBadge(String lotStatus) {
    return Container(
      constraints: const BoxConstraints(
        minWidth: 100,
        maxWidth: 150,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _getLotStatusBackgroundColor(lotStatus),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getLotStatusBorderColor(lotStatus),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Status indicator dot
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: _getLotStatusColor(lotStatus),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              _formatLotStatus(lotStatus),
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: _getLotStatusTextColor(lotStatus),
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

  // Helper method to get lot status color
  Color _getLotStatusColor(String lotStatus) {
    switch (lotStatus.toLowerCase()) {
      case 'available':
        return const Color(0xFF6B7280); // Gray for available
      case 'with nitche':
        return const Color(0xFF059669); // Green for with nitche
      case 'with mausoleum':
        return const Color(0xFF0EA5E9); // Blue for with mausoleum
      case 'occupied':
        return const Color(0xFFEF4444); // Red for occupied
      default:
        return const Color(0xFF9CA3AF); // Default gray
    }
  }

  // Helper method to get lot status background color
  Color _getLotStatusBackgroundColor(String lotStatus) {
    switch (lotStatus.toLowerCase()) {
      case 'available':
        return const Color(0xFFF9FAFB); // Light gray background
      case 'with nitche':
        return const Color(0xFFF0FDF4); // Light green background
      case 'with mausoleum':
        return const Color(0xFFF0F9FF); // Light blue background
      case 'occupied':
        return const Color(0xFFFEF2F2); // Light red background
      default:
        return const Color(0xFFF8FAFC); // Default light background
    }
  }

  // Helper method to get lot status border color
  Color _getLotStatusBorderColor(String lotStatus) {
    switch (lotStatus.toLowerCase()) {
      case 'available':
        return const Color(0xFFE5E7EB); // Gray border
      case 'with nitche':
        return const Color(0xFFBBF7D0); // Light green border
      case 'with mausoleum':
        return const Color(0xFFBAE6FD); // Light blue border
      case 'occupied':
        return const Color(0xFFFECACA); // Light red border
      default:
        return const Color(0xFFE5E7EB); // Default gray border
    }
  }

  // Helper method to get lot status text color
  Color _getLotStatusTextColor(String lotStatus) {
    switch (lotStatus.toLowerCase()) {
      case 'available':
        return const Color(0xFF6B7280); // Gray text
      case 'with nitche':
        return const Color(0xFF047857); // Dark green text
      case 'with mausoleum':
        return const Color(0xFF0284C7); // Dark blue text
      case 'occupied':
        return const Color(0xFFDC2626); // Dark red text
      default:
        return const Color(0xFF374151); // Default dark text
    }
  }

  // Helper method to format lot status text
  String _formatLotStatus(String lotStatus) {
    switch (lotStatus.toLowerCase()) {
      case 'available':
        return 'Available';
      case 'with nitche':
        return 'With Nitche';
      case 'with mausoleum':
        return 'With Mausoleum';
      case 'occupied':
        return 'Occupied';
      default:
        return lotStatus.isNotEmpty
            ? '${lotStatus[0].toUpperCase()}${lotStatus.substring(1).toLowerCase()}'
            : 'Unknown';
    }
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
                <th>Lessee</th>
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
                <td>Php. ${contract.amount ?? '0'}</td>
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

  // Helper method to check if contract is active (not expired)
  bool _isContractActive(DateTime? dateOfExpiration) {
    if (dateOfExpiration == null) {
      return false; // No expiration date means no active contract
    }

    final now = DateTime.now();
    return now.isBefore(
        dateOfExpiration); // Contract is active if current date is before expiration
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
                  hintText: 'Enter new price (minimum ₱1,500)',
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
                  helperText: 'Minimum price: ₱1,500',
                  helperStyle: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a price';
                  }
                  final priceValue = double.tryParse(value.trim());
                  if (priceValue == null) {
                    return 'Please enter a valid number';
                  }
                  if (priceValue < 1500) {
                    return 'Minimum price must be at least ₱1,500';
                  }
                  return null;
                },
                autovalidateMode: AutovalidateMode.onUserInteraction,
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

                // Validation: Check if price is empty or null
                if (newPrice.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a valid price'),
                      backgroundColor: Color(0xFFEF4444),
                    ),
                  );
                  return;
                }

                // Validation: Check if price is a valid number
                final priceValue = double.tryParse(newPrice);
                if (priceValue == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a valid number'),
                      backgroundColor: Color(0xFFEF4444),
                    ),
                  );
                  return;
                }

                // Validation: Check minimum value of 1500
                if (priceValue < 1500) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Minimum price must be at least ₱1,500'),
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
      // Additional validation before processing
      if (newPrice.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Price cannot be empty'),
            backgroundColor: Color(0xFFEF4444),
          ),
        );
        return;
      }

      final priceValue = double.tryParse(newPrice.trim());
      if (priceValue == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid price format'),
            backgroundColor: Color(0xFFEF4444),
          ),
        );
        return;
      }

      if (priceValue < 1500) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Price must be at least ₱1,500'),
            backgroundColor: Color(0xFFEF4444),
          ),
        );
        return;
      }

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
    final TextEditingController streetController = TextEditingController();
    final TextEditingController measurementController = TextEditingController();
    final TextEditingController residentCertController =
        TextEditingController();
    final TextEditingController tinController = TextEditingController();
    final TextEditingController placeIssuedController = TextEditingController();
    DateTime? _selectedIssueDate;
    String? selectedStatus;

    // Set default values using current contract
    renewalYearsController.text = '1';
    newAmountController.text = contract.amount ?? '0';
    lesseeController.text = contract.leessee ?? '';
    orNumberController.text = _generateORNumber();
    issueDateController.text = dateTimeFormat('yMMMd', DateTime.now());
    streetController.text = contract.street ?? '';
    measurementController.text = contract.measurement ?? '';
    residentCertController.text = contract.residentCert ?? '';
    tinController.text = contract.tin ?? '';
    placeIssuedController.text = contract.placeIssued ?? 'Baliwag';
    selectedStatus = contract.lotstatus;
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
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: 700,
            constraints: BoxConstraints(maxHeight: 700),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header Section - Following Manage Columns style
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Renew Contract',
                              style: GoogleFonts.inter(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1F2937),
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Extend the contract period and update the amount',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                color: const Color(0xFF6B7280),
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
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
                ),

                // Content Section - Two-column layout like Manage Columns
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Section: Current Contract Details
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Section Title
                                Text(
                                  'Current Contract Details',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF1F2937),
                                    letterSpacing: -0.2,
                                  ),
                                ),
                                const SizedBox(height: 8),

                                // Contract Details Card
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: const Color(0xFFE5E7EB),
                                      width: 1,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      // Basic Information
                                      _buildInfoRow(
                                          'Contract ID:',
                                          contract.contractID?.toString() ??
                                              'N/A'),
                                      const SizedBox(height: 4),
                                      _buildInfoRow(
                                          'Type:', contract.type ?? 'N/A'),
                                      const SizedBox(height: 4),
                                      _buildInfoRow(
                                          'Status:', contract.status ?? 'N/A'),
                                      const SizedBox(height: 4),
                                      _buildInfoRow('Contract Status:',
                                          contract.contractstatus ?? 'N/A'),
                                      const SizedBox(height: 8),

                                      // Location Information
                                      _buildInfoRow('Location:',
                                          contract.location ?? 'N/A'),
                                      const SizedBox(height: 4),
                                      _buildInfoRow('Tomb Location:',
                                          contract.tombLocation ?? 'N/A'),
                                      const SizedBox(height: 4),
                                      _buildInfoRow(
                                          'Street:', contract.street ?? 'N/A'),
                                      const SizedBox(height: 4),
                                      _buildInfoRow('Measurement:',
                                          contract.measurement ?? 'N/A'),
                                      const SizedBox(height: 8),

                                      // Lessee Information
                                      _buildInfoRow(
                                          'Lessee:', contract.leessee ?? 'N/A'),
                                      const SizedBox(height: 4),
                                      _buildInfoRow('Latest Address:',
                                          contract.latestAddress ?? 'N/A'),
                                      const SizedBox(height: 4),
                                      _buildInfoRow('Lessee Contact No:',
                                          contract.leesseContactNo ?? 'N/A'),
                                      const SizedBox(height: 4),
                                      _buildInfoRow(
                                          'Latest Contact Num:',
                                          contract.latestContNum?.toString() ??
                                              'N/A'),
                                      const SizedBox(height: 8),

                                      // Financial Information
                                      _buildInfoRow('Amount:',
                                          'Php. ${contract.amount ?? '0'}'),
                                      const SizedBox(height: 4),
                                      _buildInfoRow('Initial Fee:',
                                          'Php. ${contract.initialfee?.toString() ?? '0'}'),
                                      const SizedBox(height: 4),
                                      _buildInfoRow('Balance:',
                                          'Php. ${contract.balance?.toString() ?? '0'}'),
                                      const SizedBox(height: 4),
                                      _buildInfoRow('Total Contract Balance:',
                                          'Php. ${contract.totalContraBalance?.toString() ?? '0'}'),
                                      const SizedBox(height: 4),
                                      _buildInfoRow(
                                          'OR Number:', contract.or ?? 'N/A'),
                                      const SizedBox(height: 4),
                                      _buildInfoRow(
                                          'TIN:', contract.tin ?? 'N/A'),
                                      const SizedBox(height: 4),
                                      _buildInfoRow('Resident Cert:',
                                          contract.residentCert ?? 'N/A'),
                                      const SizedBox(height: 8),

                                      // Date Information
                                      _buildInfoRow(
                                          'Date Effective:',
                                          contract.dateEffective != null
                                              ? dateTimeFormat('yMMMd',
                                                  contract.dateEffective!)
                                              : 'N/A'),
                                      const SizedBox(height: 4),
                                      _buildInfoRow(
                                          'Date Issued:',
                                          contract.dateIssued != null
                                              ? dateTimeFormat(
                                                  'yMMMd', contract.dateIssued!)
                                              : 'N/A'),
                                      const SizedBox(height: 4),
                                      _buildInfoRow(
                                          'Date Added:',
                                          contract.dateadded != null
                                              ? dateTimeFormat(
                                                  'yMMMd', contract.dateadded!)
                                              : 'N/A'),
                                      const SizedBox(height: 4),
                                      _buildInfoRow(
                                          'Date of Expiration:',
                                          contract.dateofexpiration != null
                                              ? dateTimeFormat('yMMMd',
                                                  contract.dateofexpiration!)
                                              : 'N/A'),
                                      const SizedBox(height: 4),
                                      _buildInfoRow('Place Issued:',
                                          contract.placeIssued ?? 'N/A'),
                                      const SizedBox(height: 8),

                                      // Nitche Information (if applicable)
                                      if (contract.type == 'nitche') ...[
                                        _buildInfoRow(
                                            'Nitche ID:',
                                            contract.nitcheid?.toString() ??
                                                'N/A'),
                                        const SizedBox(height: 4),
                                        _buildInfoRow('Nitche ID String:',
                                            contract.nitcheidString ?? 'N/A'),
                                        const SizedBox(height: 4),
                                        _buildInfoRow(
                                            'Years:', contract.years ?? 'N/A'),
                                        const SizedBox(height: 8),
                                      ],

                                      // Applicant Information (Arrays)
                                      if (contract
                                          .applicantName.isNotEmpty) ...[
                                        _buildInfoRow('Applicant Names:',
                                            contract.applicantName.join(', ')),
                                        const SizedBox(height: 4),
                                      ],
                                      if (contract.applicantContactNumber
                                          .isNotEmpty) ...[
                                        _buildInfoRow(
                                            'Applicant Contact Numbers:',
                                            contract.applicantContactNumber
                                                .join(', ')),
                                        const SizedBox(height: 4),
                                      ],
                                      if (contract
                                          .applcantAddress.isNotEmpty) ...[
                                        _buildInfoRow(
                                            'Applicant Addresses:',
                                            contract.applcantAddress
                                                .join(', ')),
                                        const SizedBox(height: 4),
                                      ],

                                      // Deceased Information (Arrays)
                                      if (contract.decFullName.isNotEmpty) ...[
                                        _buildInfoRow('Deceased Names:',
                                            contract.decFullName.join(', ')),
                                        const SizedBox(height: 4),
                                      ],
                                      if (contract.dateofdeath.isNotEmpty) ...[
                                        _buildInfoRow(
                                            'Date of Death:',
                                            contract.dateofdeath
                                                .map((date) => dateTimeFormat(
                                                    'yMMMd', date))
                                                .join(', ')),
                                        const SizedBox(height: 4),
                                      ],
                                      if (contract
                                          .burialinternment.isNotEmpty) ...[
                                        _buildInfoRow(
                                            'Burial/Internment:',
                                            contract.burialinternment
                                                .map((date) => dateTimeFormat(
                                                    'yMMMd', date))
                                                .join(', ')),
                                        const SizedBox(height: 4),
                                      ],

                                      // Additional Information
                                      _buildInfoRow('Latest Deceased:',
                                          contract.latestDeceased ?? 'N/A'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Right Section: Renewal Details
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(left: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Section Title
                                Text(
                                  'Renewal Details',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF1F2937),
                                    letterSpacing: -0.2,
                                  ),
                                ),
                                const SizedBox(height: 8),

                                // Renewal Form Card
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: const Color(0xFFE5E7EB),
                                      width: 1,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Renewal Period Field
                                      Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 8),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Renewal Period (Years)*',
                                              style: GoogleFonts.inter(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: const Color(0xFF374151),
                                                letterSpacing: 0.2,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            SizedBox(
                                              height: 40,
                                              child: TextFormField(
                                                controller:
                                                    renewalYearsController,
                                                decoration: InputDecoration(
                                                  hintText:
                                                      'Enter number of years',
                                                  prefixIcon: const Icon(
                                                    Icons
                                                        .calendar_today_rounded,
                                                    color: Color(0xFF6B7280),
                                                    size: 18,
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    borderSide:
                                                        const BorderSide(
                                                            color: Color(
                                                                0xFFD1D5DB)),
                                                  ),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    borderSide:
                                                        const BorderSide(
                                                            color: Color(
                                                                0xFFD1D5DB)),
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    borderSide: BorderSide(
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary),
                                                  ),
                                                  filled: true,
                                                  fillColor:
                                                      const Color(0xFFF9FAFB),
                                                  contentPadding:
                                                      const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 16,
                                                          vertical: 12),
                                                ),
                                                keyboardType:
                                                    TextInputType.number,
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return 'Please enter renewal period';
                                                  }
                                                  if (int.tryParse(value) ==
                                                          null ||
                                                      int.parse(value) <= 0) {
                                                    return 'Please enter a valid number of years';
                                                  }
                                                  return null;
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // New Amount Field
                                      Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 8),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'New Amount (₱)*',
                                              style: GoogleFonts.inter(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: const Color(0xFF374151),
                                                letterSpacing: 0.2,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            SizedBox(
                                              height: 40,
                                              child: TextFormField(
                                                controller: newAmountController,
                                                decoration: InputDecoration(
                                                  hintText: 'Enter new amount',
                                                  prefixIcon: const Icon(
                                                    Icons.attach_money_rounded,
                                                    color: Color(0xFF6B7280),
                                                    size: 18,
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    borderSide:
                                                        const BorderSide(
                                                            color: Color(
                                                                0xFFD1D5DB)),
                                                  ),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    borderSide:
                                                        const BorderSide(
                                                            color: Color(
                                                                0xFFD1D5DB)),
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    borderSide: BorderSide(
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary),
                                                  ),
                                                  filled: true,
                                                  fillColor:
                                                      const Color(0xFFF9FAFB),
                                                  contentPadding:
                                                      const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 16,
                                                          vertical: 12),
                                                ),
                                                keyboardType:
                                                    TextInputType.number,
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return 'Please enter new amount';
                                                  }
                                                  if (double.tryParse(value) ==
                                                          null ||
                                                      double.parse(value) < 0) {
                                                    return 'Please enter a valid amount';
                                                  }
                                                  return null;
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Lessee Field
                                      Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 8),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Lessee Name*',
                                              style: GoogleFonts.inter(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: const Color(0xFF374151),
                                                letterSpacing: 0.2,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            SizedBox(
                                              height: 40,
                                              child: TextFormField(
                                                controller: lesseeController,
                                                decoration: InputDecoration(
                                                  hintText: 'Enter lessee name',
                                                  prefixIcon: const Icon(
                                                    Icons.person_rounded,
                                                    color: Color(0xFF6B7280),
                                                    size: 18,
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    borderSide:
                                                        const BorderSide(
                                                            color: Color(
                                                                0xFFD1D5DB)),
                                                  ),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    borderSide:
                                                        const BorderSide(
                                                            color: Color(
                                                                0xFFD1D5DB)),
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    borderSide: BorderSide(
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary),
                                                  ),
                                                  filled: true,
                                                  fillColor:
                                                      const Color(0xFFF9FAFB),
                                                  contentPadding:
                                                      const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 16,
                                                          vertical: 12),
                                                ),
                                                keyboardType:
                                                    TextInputType.text,
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return 'Please enter lessee name';
                                                  }
                                                  return null;
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // OR Number Field (Auto-generated)
                                      Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 8),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'OR Number*',
                                              style: GoogleFonts.inter(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: const Color(0xFF374151),
                                                letterSpacing: 0.2,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Container(
                                              height: 40,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 12),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFF3F4F6),
                                                border: Border.all(
                                                    color:
                                                        const Color(0xFFD1D5DB),
                                                    width: 1),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Row(
                                                children: [
                                                  const Icon(
                                                    Icons.receipt_rounded,
                                                    color: Color(0xFF6B7280),
                                                    size: 18,
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: Text(
                                                      orNumberController.text,
                                                      style: GoogleFonts.inter(
                                                        fontSize: 14,
                                                        color: const Color(
                                                            0xFF374151),
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                  IconButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        orNumberController
                                                                .text =
                                                            _generateORNumber();
                                                      });
                                                    },
                                                    icon: const Icon(
                                                      Icons.refresh_rounded,
                                                      color: Color(0xFF6B7280),
                                                      size: 18,
                                                    ),
                                                    tooltip:
                                                        'Generate new OR number',
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Document Issue Date Field
                                      Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 8),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Document Issue Date*',
                                              style: GoogleFonts.inter(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: const Color(0xFF374151),
                                                letterSpacing: 0.2,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            SizedBox(
                                              height: 40,
                                              child: TextFormField(
                                                controller: issueDateController,
                                                decoration: InputDecoration(
                                                  hintText: 'Select issue date',
                                                  prefixIcon: const Icon(
                                                    Icons
                                                        .calendar_month_rounded,
                                                    color: Color(0xFF6B7280),
                                                    size: 18,
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    borderSide:
                                                        const BorderSide(
                                                            color: Color(
                                                                0xFFD1D5DB)),
                                                  ),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    borderSide:
                                                        const BorderSide(
                                                            color: Color(
                                                                0xFFD1D5DB)),
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    borderSide: BorderSide(
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary),
                                                  ),
                                                  filled: true,
                                                  fillColor:
                                                      const Color(0xFFF9FAFB),
                                                  contentPadding:
                                                      const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 16,
                                                          vertical: 12),
                                                ),
                                                readOnly: true,
                                                onTap: () async {
                                                  final DateTime? pickedDate =
                                                      await showDatePicker(
                                                    context: context,
                                                    initialDate: DateTime.now(),
                                                    firstDate: DateTime.now()
                                                        .subtract(
                                                            const Duration(
                                                                days: 365)),
                                                    lastDate: DateTime.now()
                                                        .add(const Duration(
                                                            days: 365)),
                                                  );
                                                  if (pickedDate != null) {
                                                    issueDateController.text =
                                                        dateTimeFormat('yMMMd',
                                                            pickedDate);
                                                    _selectedIssueDate =
                                                        pickedDate;
                                                  }
                                                },
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return 'Please select issue date';
                                                  }
                                                  return null;
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Auto-calculated New Expiration Date
                                      Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 8),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'New Expiration Date',
                                              style: GoogleFonts.inter(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: const Color(0xFF374151),
                                                letterSpacing: 0.2,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            GestureDetector(
                                              onTap: () async {
                                                final DateTime? picked =
                                                    await showDatePicker(
                                                  context: context,
                                                  initialDate:
                                                      _newExpirationDate ??
                                                          DateTime.now().add(
                                                              const Duration(
                                                                  days: 365)),
                                                  firstDate: DateTime.now(),
                                                  lastDate: DateTime.now().add(
                                                      const Duration(
                                                          days:
                                                              3650)), // 10 years max
                                                );
                                                if (picked != null) {
                                                  setState(() {
                                                    _newExpirationDate = picked;
                                                    // Calculate total balance when date changes
                                                    final newAmount =
                                                        double.tryParse(
                                                                newAmountController
                                                                    .text) ??
                                                            0.0;
                                                    _calculatedTotalBalance =
                                                        _calculateTotalBalance(
                                                            picked, newAmount);
                                                  });
                                                }
                                              },
                                              child: Container(
                                                height: 40,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16,
                                                        vertical: 12),
                                                decoration: BoxDecoration(
                                                  color:
                                                      const Color(0xFFF3F4F6),
                                                  border: Border.all(
                                                      color: const Color(
                                                          0xFFD1D5DB),
                                                      width: 1),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.event_rounded,
                                                      color: Color(0xFF6B7280),
                                                      size: 18,
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Expanded(
                                                      child: Text(
                                                        _newExpirationDate !=
                                                                null
                                                            ? dateTimeFormat(
                                                                'yMMMd',
                                                                _newExpirationDate!)
                                                            : _calculateNewExpirationDate(
                                                                contract
                                                                    .dateofexpiration,
                                                                int.tryParse(
                                                                        renewalYearsController
                                                                            .text) ??
                                                                    0,
                                                              ),
                                                        style:
                                                            GoogleFonts.inter(
                                                          fontSize: 14,
                                                          color: const Color(
                                                              0xFF374151),
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                    const Icon(
                                                      Icons
                                                          .calendar_today_rounded,
                                                      color: Color(0xFF6B7280),
                                                      size: 18,
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
                                        margin:
                                            const EdgeInsets.only(bottom: 8),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Total Balance (₱)',
                                              style: GoogleFonts.inter(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: const Color(0xFF374151),
                                                letterSpacing: 0.2,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Container(
                                              height: 40,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 12),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFF3F4F6),
                                                border: Border.all(
                                                    color:
                                                        const Color(0xFFD1D5DB),
                                                    width: 1),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Row(
                                                children: [
                                                  const Icon(
                                                    Icons.calculate_rounded,
                                                    color: Color(0xFF6B7280),
                                                    size: 18,
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: Text(
                                                      _calculatedTotalBalance !=
                                                              null
                                                          ? '₱${_calculatedTotalBalance!.toStringAsFixed(2)}'
                                                          : '₱0.00',
                                                      style: GoogleFonts.inter(
                                                        fontSize: 14,
                                                        color: const Color(
                                                            0xFF374151),
                                                        fontWeight:
                                                            FontWeight.w500,
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
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Footer Actions - Following Manage Columns style
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Left side - Reset option (if needed)
                      TextButton(
                        onPressed: () {
                          renewalYearsController.text = '1';
                          newAmountController.text = contract.amount ?? '0';
                          lesseeController.text = contract.leessee ?? '';
                          orNumberController.text = _generateORNumber();
                          issueDateController.text =
                              dateTimeFormat('yMMMd', DateTime.now());
                          _selectedIssueDate = DateTime.now();
                        },
                        child: Text(
                          'Reset to Default',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                      ),

                      // Right side - Action buttons
                      Row(
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
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

                              // Show confirmation dialog before processing renewal
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
                                          color: FlutterFlowTheme.of(context)
                                              .primary,
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                  color:
                                                      const Color(0xFFE5E7EB),
                                                  width: 1),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                _buildConfirmationRow(
                                                    'Location:',
                                                    contract.location ?? 'N/A'),
                                                const SizedBox(height: 12),
                                                _buildConfirmationRow(
                                                    'Lessee:', lesseeName),
                                                const SizedBox(height: 12),
                                                _buildConfirmationRow(
                                                    'Renewal Period:',
                                                    '$renewalYears years'),
                                                const SizedBox(height: 12),
                                                _buildConfirmationRow(
                                                    'New Amount:',
                                                    '₱$newAmount'),
                                                const SizedBox(height: 12),
                                                _buildConfirmationRow(
                                                    'OR Number:', orNumber),
                                                const SizedBox(height: 12),
                                                _buildConfirmationRow(
                                                    'Issue Date:',
                                                    dateTimeFormat(
                                                        'yMMMd', issueDate)),
                                                const SizedBox(height: 12),
                                                _buildConfirmationRow(
                                                  'New Expiration:',
                                                  dateTimeFormat(
                                                    'yMMMd',
                                                    DateTime(
                                                      (contract.dateofexpiration ??
                                                                  DateTime
                                                                      .now())
                                                              .year +
                                                          renewalYears,
                                                      (contract.dateofexpiration ??
                                                              DateTime.now())
                                                          .month,
                                                      (contract.dateofexpiration ??
                                                              DateTime.now())
                                                          .day,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 12),
                                                _buildConfirmationRow(
                                                  'Total Balance:',
                                                  '₱${_calculatedTotalBalance?.toStringAsFixed(2) ?? '0.00'}',
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(false),
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
                                        onPressed: () =>
                                            Navigator.of(context).pop(true),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              FlutterFlowTheme.of(context)
                                                  .primary,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 24, vertical: 12),
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

                              // Process renewal
                              await _processContractRenewal(
                                  contract,
                                  selectedNitche,
                                  renewalYears,
                                  newAmount,
                                  lesseeName,
                                  orNumber,
                                  issueDate,
                                  streetController.text.trim(),
                                  measurementController.text.trim(),
                                  selectedStatus ?? 'with nitche',
                                  residentCertController.text.trim(),
                                  tinController.text.trim(),
                                  placeIssuedController.text.trim());
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(
                                  0xFFF97316), // Orange like Manage Columns
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
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
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper method to build text fields for renewal modal
  Widget _buildRenewalTextField({
    required TextEditingController? controller,
    required String labelText,
    required String hintText,
    required IconData prefixIcon,
    bool isReadOnly = false,
    String? Function(BuildContext, String?)? validator,
    VoidCallback? onTap,
    TextInputType keyboardType = TextInputType.text,
    Function(String)? onChanged,
    StateSetter? setModalState,
  }) {
    // Check if field has value and format is correct
    final hasValue = controller?.text.isNotEmpty == true;
    final validationError = hasValue && validator != null
        ? validator(context, controller?.text)
        : null;
    final isFormatCorrect = hasValue && validationError == null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: RichText(
                text: TextSpan(
                  text: labelText.contains('*')
                      ? labelText.replaceAll('*', ' ')
                      : labelText,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF374151),
                  ),
                  children: labelText.contains('*')
                      ? [
                          TextSpan(
                            text: '*',
                            style: TextStyle(color: Colors.red),
                          ),
                        ]
                      : [],
                ),
              ),
            ),
            if (isFormatCorrect)
              Icon(
                Icons.check_circle_rounded,
                color: const Color(0xFF10B981),
                size: 20,
              ),
          ],
        ),
        // Real-time validation error display (copied from Lotform)
        if (validator != null && hasValue)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: validationError != null ? 20 : 0,
            child: validationError != null
                ? Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      validationError,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.red.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        SizedBox(height: 6),
        Container(
          height: 40,
          child: TextFormField(
            controller: controller,
            readOnly: isReadOnly,
            onTap: onTap,
            onChanged: (value) {
              // Trigger validation on every keystroke (copied from Lotform)
              if (onChanged != null) onChanged(value);
              if (setModalState != null) {
                setModalState(() {}); // Rebuild modal to show validation errors
              }
            },
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: GoogleFonts.inter(
                fontSize: 14,
                color: Color(0xFF9CA3AF),
              ),
              prefixIcon: Icon(
                prefixIcon,
                color: Color(0xFF6B7280),
                size: 20,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(
                  color: validationError != null
                      ? const Color(0xFFEF4444)
                      : isFormatCorrect
                          ? Colors.transparent
                          : Color(0xFFD1D5DB),
                  width: isFormatCorrect ? 0 : 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(
                  color: validationError != null
                      ? const Color(0xFFEF4444)
                      : isFormatCorrect
                          ? Colors.transparent
                          : Color(0xFFD1D5DB),
                  width: isFormatCorrect ? 0 : 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(
                  color: validationError != null
                      ? const Color(0xFFEF4444)
                      : isFormatCorrect
                          ? Colors.transparent
                          : Color(0xFF3B82F6),
                  width: isFormatCorrect ? 0 : 1,
                ),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            validator:
                validator != null ? (value) => validator(context, value) : null,
          ),
        ),
      ],
    );
  }

  // Format validation functions for renew contract modal
  String? _validateBlockLotFormat(BuildContext context, String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Block-Lot is required';
    }
    final trimmedValue = value.trim();
    if (!RegExp(r'^[A-Z]\d+-L\d+$').hasMatch(trimmedValue)) {
      return 'Format should be: Letter-Number (e.g., B1-L1)';
    }
    return null;
  }

  String? _validateNameLessee(BuildContext context, String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name/Lessee is required';
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
      return 'Name can only contain letters (uppercase or lowercase) and spaces';
    }
    return null;
  }

  String? _validateStreet(BuildContext context, String? value) {
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
      return 'Street address can only contain letters, numbers, spaces, commas, periods, #, hyphens, and common street suffixes (St, Street, Ave, Avenue, Rd, Road, Ext, Extension)';
    }
    return null;
  }

  String? _validateMeasurement(BuildContext context, String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Measurement is required';
    }
    final trimmedValue = value.trim();
    final regExp = RegExp(r'^(\d+)x(\d+)$');
    if (!regExp.hasMatch(trimmedValue)) {
      return 'Format should be: NumberxNumber (e.g., 3x1)';
    }
    final match = regExp.firstMatch(trimmedValue);
    if (match != null) {
      final width = int.tryParse(match.group(1) ?? '0') ?? 0;
      final height = int.tryParse(match.group(2) ?? '0') ?? 0;
      if (width < 1 || height < 2) {
        return 'Minimum measurement is 1x2';
      }
    }
    return null;
  }

  String? _validateAmount(BuildContext context, String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Amount is required';
    }
    final trimmedValue = value.trim();
    final amount = double.tryParse(trimmedValue);
    if (amount == null || amount <= 0) {
      return 'Please enter a valid amount greater than 0';
    }
    return null;
  }

  // Required document validation functions removed

  // Comprehensive validation to check all fields for null/empty values in renew contract modal
  bool _validateRenewContractFields(
      TextEditingController blocklotController,
      TextEditingController ownerController,
      TextEditingController streetController,
      TextEditingController measurementController,
      TextEditingController amountController,
      DateTime? selectedExpirationDate,
      String? selectedStatus,
      BuildContext context) {
    List<String> emptyFields = [];

    // Check basic information fields
    if (blocklotController.text.trim().isEmpty) {
      emptyFields.add('Block-Lot');
    }
    if (ownerController.text.trim().isEmpty) {
      emptyFields.add('Name/Lessee');
    }
    if (streetController.text.trim().isEmpty) {
      emptyFields.add('Street');
    }
    if (measurementController.text.trim().isEmpty) {
      emptyFields.add('Measurement');
    }
    if (selectedStatus == null || selectedStatus.trim().isEmpty) {
      emptyFields.add('Status');
    }

    // Check contract details fields
    if (amountController.text.trim().isEmpty) {
      emptyFields.add('Initial Contract Fee');
    }
    if (selectedExpirationDate == null) {
      emptyFields.add('Date of Expiration');
    }

    // Required documentation section removed

    // If there are empty fields, show error dialog
    if (emptyFields.isNotEmpty) {
      _showRenewValidationErrorDialog(emptyFields, context);
      return false;
    }

    return true;
  }

  // Comprehensive format validation for renew contract modal
  bool _validateAllRenewFieldFormats(
      TextEditingController blocklotController,
      TextEditingController ownerController,
      TextEditingController streetController,
      TextEditingController measurementController,
      TextEditingController amountController,
      DateTime? selectedExpirationDate,
      String? selectedStatus,
      BuildContext context) {
    List<String> formatErrors = [];

    // Check format for each field
    final blockLotError =
        _validateBlockLotFormat(context, blocklotController.text);
    if (blockLotError != null) formatErrors.add(blockLotError);

    final nameLesseeError = _validateNameLessee(context, ownerController.text);
    if (nameLesseeError != null) formatErrors.add(nameLesseeError);

    final streetError = _validateStreet(context, streetController.text);
    if (streetError != null) formatErrors.add(streetError);

    final measurementError =
        _validateMeasurement(context, measurementController.text);
    if (measurementError != null) formatErrors.add(measurementError);

    final amountError = _validateAmount(context, amountController.text);
    if (amountError != null) formatErrors.add(amountError);

    // Required documentation format validation removed

    // Check if expiration date is in the future
    if (selectedExpirationDate != null &&
        selectedExpirationDate.isBefore(DateTime.now())) {
      formatErrors.add('Date of Expiration must be in the future');
    }

    // Document issue date validation removed

    // If there are format errors, show error dialog
    if (formatErrors.isNotEmpty) {
      _showRenewFormatErrorDialog(formatErrors, context);
      return false;
    }

    return true;
  }

  // Show format error dialog with list of format errors for renew contract
  void _showRenewFormatErrorDialog(
      List<String> formatErrors, BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
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
                'Format Validation Errors',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Please correct the following format errors:',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 16),
              ...formatErrors
                  .map((error) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
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
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
              ),
              child: Text(
                'OK',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Show validation error dialog with list of empty fields for renew contract
  void _showRenewValidationErrorDialog(
      List<String> emptyFields, BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
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
                'Required Fields Missing',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Please fill in the following required fields:',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 16),
              ...emptyFields
                  .map((field) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Icon(
                              Icons.circle,
                              size: 6,
                              color: const Color(0xFFEF4444),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                field,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
              ),
              child: Text(
                'OK',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Method to show renew contract modal
  Future<void> _showRenewContractModal(
      BuildContext context, ContractRecord contract) async {
    // Form controllers - matching newAddBurialLocation fields
    final TextEditingController blocklotController =
        TextEditingController(text: contract.location ?? '');
    final TextEditingController ownerController =
        TextEditingController(text: contract.leessee ?? '');
    final TextEditingController streetController =
        TextEditingController(text: contract.street ?? '');
    final TextEditingController measurementController =
        TextEditingController(text: contract.measurement ?? '');
    final TextEditingController amountController =
        TextEditingController(text: contract.amount ?? '1500');
    final TextEditingController yearsController = TextEditingController();
    final TextEditingController balanceController = TextEditingController();
    final TextEditingController expirationController = TextEditingController();
    // Required document controllers removed

    // Status and date variables
    String? selectedStatus = (contract.lotstatus == 'with nitche' ||
            contract.lotstatus == 'with mausoleum')
        ? contract.lotstatus
        : null; // Only set if it's a valid dropdown option
    DateTime? selectedExpirationDate = contract.dateofexpiration;
    // selectedIssueDate removed

    // File upload variable removed

    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Container(
                width: 800,
                constraints: BoxConstraints(maxHeight: 700),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.description_outlined,
                            color: Color(0xFF10B981),
                            size: 24,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Contract Renewal Form',
                              style: GoogleFonts.inter(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: Icon(
                              Icons.close,
                              color: Color(0xFF6B7280),
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Content - Scrollable
                    Flexible(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Selected Contract Section
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Color(0xFFECF9FF),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Color(0xFF3B82F6)),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: Color(0xFF3B82F6),
                                    size: 20,
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Selected Contract: ${contract.location ?? 'N/A'}',
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF1E40AF),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 24),

                            // Basic Information Section
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Color(0xFFE5E7EB)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on_rounded,
                                        color: Color(0xFF1E40AF),
                                        size: 20,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Basic Information',
                                        style: GoogleFonts.inter(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF1F2937),
                                        ),
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: 16),

                                  // First row: Block-Lot, Name/Lessee, Street (3 columns)
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: _buildRenewalTextField(
                                          controller: blocklotController,
                                          labelText: 'Block-Lot*',
                                          hintText: 'eg. B1-L1',
                                          prefixIcon: Icons.grid_on_rounded,
                                          validator: _validateBlockLotFormat,
                                          setModalState: setState,
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: _buildRenewalTextField(
                                          controller: ownerController,
                                          labelText: 'Name/Lessee*',
                                          hintText: 'Enter name or lessee',
                                          prefixIcon: Icons.person_rounded,
                                          validator: _validateNameLessee,
                                          setModalState: setState,
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: _buildRenewalTextField(
                                          controller: streetController,
                                          labelText: 'Street*',
                                          hintText: 'Enter street address',
                                          prefixIcon: Icons.home_rounded,
                                          validator: _validateStreet,
                                          setModalState: setState,
                                        ),
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: 16),

                                  // Second row: Measurement and Status dropdown
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: _buildRenewalTextField(
                                          controller: measurementController,
                                          labelText: 'Measurement*',
                                          hintText: 'Enter lot measurement',
                                          prefixIcon: Icons.straighten_rounded,
                                          validator: _validateMeasurement,
                                          setModalState: setState,
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Container(
                                          margin:
                                              const EdgeInsets.only(bottom: 24),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: RichText(
                                                      text: TextSpan(
                                                        text: 'Status',
                                                        style:
                                                            GoogleFonts.inter(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color:
                                                              Color(0xFF374151),
                                                        ),
                                                        children: [
                                                          TextSpan(
                                                            text: ' *',
                                                            style: TextStyle(
                                                              color: Color(
                                                                  0xFFEF4444),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  if (selectedStatus != null &&
                                                      selectedStatus!
                                                          .isNotEmpty)
                                                    Icon(
                                                      Icons
                                                          .check_circle_rounded,
                                                      color: const Color(
                                                          0xFF10B981),
                                                      size: 20,
                                                    ),
                                                ],
                                              ),
                                              SizedBox(height: 8),
                                              Container(
                                                height: 48,
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: selectedStatus !=
                                                                  null &&
                                                              selectedStatus!
                                                                  .isNotEmpty
                                                          ? Colors.transparent
                                                          : Color(0xFFD1D5DB),
                                                      width: selectedStatus !=
                                                                  null &&
                                                              selectedStatus!
                                                                  .isNotEmpty
                                                          ? 0
                                                          : 1),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: DropdownButtonFormField<
                                                    String>(
                                                  value: selectedStatus,
                                                  decoration: InputDecoration(
                                                    hintText:
                                                        'Select status...',
                                                    hintStyle:
                                                        GoogleFonts.inter(
                                                      fontSize: 14,
                                                      color: Color(0xFF9CA3AF),
                                                    ),
                                                    prefixIcon: Icon(
                                                      Icons
                                                          .info_outline_rounded,
                                                      color: Color(0xFF6B7280),
                                                      size: 20,
                                                    ),
                                                    border: InputBorder.none,
                                                    contentPadding:
                                                        EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 14,
                                                    ),
                                                  ),
                                                  items: [
                                                    'with nitche',
                                                    'with mausoleum'
                                                  ].map((String value) {
                                                    return DropdownMenuItem<
                                                        String>(
                                                      value: value,
                                                      child: Text(
                                                        value,
                                                        style:
                                                            GoogleFonts.inter(
                                                          fontSize: 14,
                                                          color:
                                                              Color(0xFF1F2937),
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    );
                                                  }).toList(),
                                                  onChanged:
                                                      (String? newValue) {
                                                    selectedStatus = newValue;
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                          child:
                                              Container()), // Empty space for balance
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 24),

                            // Contract Details Section
                            Container(
                              width: double.infinity,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.description_rounded,
                                        color: Color(0xFFF59E0B),
                                        size: 20,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Contract Details',
                                        style: GoogleFonts.inter(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF1F2937),
                                        ),
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: 16),

                                  // First row: Amount and Expiration Date
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildRenewalTextField(
                                          controller: amountController,
                                          labelText:
                                              'Initial Contract Fee (₱)*',
                                          hintText: 'Enter amount',
                                          prefixIcon: Icons
                                              .account_balance_wallet_rounded,
                                          keyboardType: TextInputType.number,
                                          validator: _validateAmount,
                                          setModalState: setState,
                                          onChanged: (value) async {
                                            // Recalculate balance when amount changes - same logic as newAddBurialLocation
                                            if (selectedExpirationDate !=
                                                    null &&
                                                value.isNotEmpty) {
                                              try {
                                                final int yearsDuration =
                                                    await actions.yearsDuration(
                                                        selectedExpirationDate!);
                                                final double initialFee =
                                                    double.tryParse(value) ??
                                                        0.0;

                                                // Calculate total contract value: (duration × initial fee) - initial fee
                                                final int totalBalance =
                                                    ((yearsDuration *
                                                                initialFee) -
                                                            initialFee)
                                                        .toInt();

                                                // Update the controllers with calculated values
                                                setState(() {
                                                  yearsController.text =
                                                      yearsDuration.toString();
                                                  balanceController.text =
                                                      totalBalance.toString();
                                                });
                                              } catch (e) {
                                                print(
                                                    'Error calculating balance: $e');
                                                // Set default values if calculation fails
                                                setState(() {
                                                  yearsController.text = '0';
                                                  balanceController.text = '0';
                                                });
                                              }
                                            }
                                          },
                                        ),
                                      ),
                                      SizedBox(width: 16),
                                      Expanded(
                                        child: _buildRenewalTextField(
                                          controller: expirationController,
                                          labelText: 'Date of Expiration*',
                                          hintText: 'Select expiration date',
                                          prefixIcon:
                                              Icons.calendar_today_rounded,
                                          isReadOnly: true,
                                          setModalState: setState,
                                          onTap: () async {
                                            final DateTime? picked =
                                                await showDatePicker(
                                              context: context,
                                              initialDate:
                                                  selectedExpirationDate ??
                                                      DateTime.now().add(Duration(
                                                          days:
                                                              1825)), // 5 years
                                              firstDate: DateTime.now().add(
                                                  Duration(
                                                      days:
                                                          1825)), // 5 years from now
                                              lastDate: DateTime(2100),
                                            );
                                            if (picked != null) {
                                              selectedExpirationDate = picked;
                                              expirationController.text =
                                                  dateTimeFormat('yMd', picked);

                                              // Calculate years duration and total balance - same logic as newAddBurialLocation
                                              try {
                                                final int yearsDuration =
                                                    await actions
                                                        .yearsDuration(picked);
                                                final double initialFee =
                                                    double.tryParse(
                                                            amountController
                                                                .text
                                                                .trim()) ??
                                                        0.0;

                                                // Calculate total contract value: (duration × initial fee) - initial fee
                                                final int totalBalance =
                                                    ((yearsDuration *
                                                                initialFee) -
                                                            initialFee)
                                                        .toInt();

                                                // Update the controllers with calculated values
                                                setState(() {
                                                  yearsController.text =
                                                      yearsDuration.toString();
                                                  balanceController.text =
                                                      totalBalance.toString();
                                                });
                                              } catch (e) {
                                                print(
                                                    'Error calculating balance: $e');
                                                // Set default values if calculation fails
                                                setState(() {
                                                  yearsController.text = '0';
                                                  balanceController.text = '0';
                                                });
                                              }
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: 16),

                                  // Second row: Years Duration and Total Balance
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildRenewalTextField(
                                          controller: yearsController,
                                          labelText:
                                              'Contract Duration (Years)',
                                          hintText: 'Auto-calculated',
                                          prefixIcon: Icons.schedule_rounded,
                                          isReadOnly: true,
                                          setModalState: setState,
                                        ),
                                      ),
                                      SizedBox(width: 16),
                                      Expanded(
                                        child: _buildRenewalTextField(
                                          controller: balanceController,
                                          labelText: 'Total Balance (₱)',
                                          hintText: 'Auto-calculated',
                                          prefixIcon: Icons.calculate_rounded,
                                          isReadOnly: true,
                                          setModalState: setState,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),

                    // Footer
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                        border: Border(
                          top: BorderSide(color: Color(0xFFE5E7EB)),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
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
                              // First check for null/empty fields before form validation
                              if (!_validateRenewContractFields(
                                  blocklotController,
                                  ownerController,
                                  streetController,
                                  measurementController,
                                  amountController,
                                  selectedExpirationDate,
                                  selectedStatus,
                                  context)) {
                                return; // Stop if validation fails
                              }

                              // Then check for format validation
                              if (!_validateAllRenewFieldFormats(
                                  blocklotController,
                                  ownerController,
                                  streetController,
                                  measurementController,
                                  amountController,
                                  selectedExpirationDate,
                                  selectedStatus,
                                  context)) {
                                return; // Stop if format validation fails
                              }

                              // Show confirmation dialog before renewal
                              final bool? confirmed = await showDialog<bool>(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text(
                                      'Confirm Contract Renewal',
                                      style: GoogleFonts.inter(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF1F2937),
                                      ),
                                    ),
                                    content: Text(
                                      'Are you sure you want to renew this contract? This action will update the contract details and cannot be undone.',
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(false),
                                        child: Text(
                                          'Cancel',
                                          style: GoogleFonts.inter(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(true),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFF10B981),
                                          foregroundColor: Colors.white,
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

                              if (confirmed != true) return;

                              // Implement contract renewal logic here
                              try {
                                // Update existing contract - SAME STRUCTURE as newAddBurialLocation
                                // Get next available contract ID from database
                                final newContractId = await FFAppState()
                                    .getNextAvailableContractId();

                                await contract.reference.update({
                                  ...createContractRecordData(
                                    leessee: ownerController.text.trim(),
                                    street: streetController.text.trim(),
                                    measurement:
                                        measurementController.text.trim(),
                                    type: 'Lot',
                                    lotLoccation:
                                        blocklotController.text.trim(),
                                    location: blocklotController.text.trim(),
                                    contractID:
                                        newContractId, // Use incremented contract ID for renewal
                                    amount: amountController.text.trim(),
                                    lotstatus: selectedStatus ?? 'with nitche',
                                    dateofexpiration: selectedExpirationDate,
                                    contractstatus: 'active',
                                    status: 'available',
                                    initialfee: double.tryParse(
                                        amountController.text.trim()),
                                    balance: int.tryParse(
                                            balanceController.text.trim()) ??
                                        0,
                                    // Required documentation fields removed
                                    years: yearsController.text.trim(),
                                    dateadded: contract.dateadded ??
                                        DateTime
                                            .now(), // Keep original or set now
                                    dateEffective: DateTime
                                        .now(), // Set to current timestamp
                                    registered: 'yes',
                                  ),
                                });

                                // Create transaction record for successful renewal
                                await FirebaseFirestore.instance
                                    .collection('transactions')
                                    .add(createTransactionsRecordData(
                                      uID: contract.reference.id,
                                      transactionDate: DateTime.now(),
                                      name: ownerController.text.trim(),
                                      status: 'completed',
                                      loc: blocklotController.text.trim(),
                                      paymentMethod: 'Cash',
                                      remBalance: '0',
                                      type: 'renewal',
                                      isClicked: false,
                                      email: '',
                                      address: streetController.text.trim(),
                                      stringtransactiondate:
                                          DateTime.now().toString(),
                                      amount: int.tryParse(
                                              amountController.text.trim()) ??
                                          0,
                                      loctype: 'Lot',
                                      paymenttype:
                                          'Onsite Contract Renew Downpayment',
                                      tld: '',
                                      deceased: '',
                                      contractId: contract.reference
                                          .id, // Use document ID instead of contractID field
                                    ));

                                // Don't increment contract ID since we're updating existing contract

                                Navigator.of(context).pop();

                                // Show success modal
                                _showRenewalSuccessModal(context);
                              } catch (e) {
                                // Show error message
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Error submitting contract renewal: $e'),
                                    backgroundColor: Color(0xFFEF4444),
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF10B981),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                            ),
                            child: Text(
                              'Renew Contract',
                              style: GoogleFonts.inter(
                                fontSize: 14,
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
                                      lastDate: DateTime(2100),
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
                                  'Resident Certificate*',
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
    String? selectedLotStatus = contract.lotstatus;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
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
                        final trimmedValue = value.trim();
                        final regExp = RegExp(r'^(\d+)x(\d+)$');
                        if (!regExp.hasMatch(trimmedValue)) {
                          return 'Format should be: NumberxNumber (e.g., 3x5)';
                        }
                        final match = regExp.firstMatch(trimmedValue);
                        if (match != null) {
                          final width = int.tryParse(match.group(1) ?? '0') ?? 0;
                          final height = int.tryParse(match.group(2) ?? '0') ?? 0;
                          if (width < 1 || height < 2) {
                            return 'Minimum measurement is 1x2';
                          }
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
                    SizedBox(height: 16),

                    // Lot Status dropdown
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lot Type *',
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
                          child: DropdownButtonFormField<String>(
                            value: selectedLotStatus,
                            decoration: InputDecoration(
                              hintText: 'Select lot type',
                              hintStyle: TextStyle(
                                color: Color(0xFF9CA3AF),
                                fontSize: 14,
                              ),
                              prefixIcon: Icon(Icons.assignment_rounded,
                                  size: 20, color: Color(0xFF6B7280)),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(16),
                            ),
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Color(0xFF1F2937),
                            ),
                            items: [
                              'available',
                              'with nitche',
                              'with mausoleum',
                              'occupied'
                            ].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(_formatLotStatus(value)),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedLotStatus = newValue;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Lot type is required';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
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
                      selectedLotStatus ?? 'available',
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
        });
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
    String lotStatus,
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
        'lotstatus': lotStatus,
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
      // Get next available contract ID from database
      await FFAppState().getNextAvailableContractId();

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
      DateTime issueDate,
      String street,
      String measurement,
      String status,
      String residentCert,
      String tin,
      String placeIssued) async {
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

      // Update contract in Firestore with all form fields
      await contract.reference.update({
        // Basic contract information
        'amount': newAmount.toString(),
        'dateofexpiration': newExpiration,
        'leessee': lesseeName,
        'street': street,
        'measurement': measurement,
        'lotstatus': status, // This stores 'with nitche' or 'with mausoleum'

        // Documentation fields
        'OR': orNumber,
        'ResidentCert': residentCert,
        'TIN': tin,
        'placeIssued': placeIssued,
        'dateIssued': issueDate,

        // Contract status
        'contractstatus': 'active',
        'status': 'active',

        // Additional fields
        'lastUpdated': DateTime.now(),
        'timestamp': DateTime.now(),
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

  // Method to show renewal success modal
  void _showRenewalSuccessModal(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Success Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF10B981),
                    size: 48,
                  ),
                ),
                const SizedBox(height: 24),

                // Success Title
                Text(
                  'Contract Renewal Submitted!',
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1F2937),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                // Success Message
                Text(
                  'Your contract renewal has been successfully submitted and is now being processed.',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: const Color(0xFF6B7280),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Action Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      setState(() {}); // Refresh the data
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Continue',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
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
}
