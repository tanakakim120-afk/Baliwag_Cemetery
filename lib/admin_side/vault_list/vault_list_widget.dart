/*
 * ========================================
 * VAULT LIST WIDGET - CLEANED VERSION
 * ========================================
 * 
 * Main Features:
 * - Display and manage vault records
 * - Search and filter functionality with caching
 * - Assign vaults to niches or lots
 * - Multiple deceased entries support
 * - Document verification and upload
 * - PDF export functionality
 * - Real-time updates from Firestore
 * 
 * Performance Optimizations:
 * - Cached vault data (no reload on search)
 * - Cached niche/lot dialog data
 * - Smart text change detection
 * 
 * Backend Integration:
 * - Firestore: VaultRecord, ContractRecord collections
 * - Firebase Storage: Document uploads
 * - Firebase Auth: User authentication
 * 
 * ========================================
 */

// Core Flutter imports
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

// Package imports
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

// Backend imports
import '/backend/backend.dart';
import '/backend/firebase_storage/storage.dart';

// Flutter Flow imports
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_data_table.dart';
import '/flutter_flow/upload_data.dart';

// Custom code imports
import '/custom_code/dashboard_theme.dart';

// Local imports
import 'vault_list_model.dart';
import '/admin_side/shared/deceased_entry.dart';
import '/admin_side/shared/document_verification_service.dart';
import '/admin_side/shared/expired_contracts.dart';

export 'vault_list_model.dart';

class VaultListWidget extends StatefulWidget {
  const VaultListWidget({super.key});

  static String routeName = 'VaultList';
  static String routePath = '/vaultList';

  @override
  State<VaultListWidget> createState() => _VaultListWidgetState();
}

class _VaultListWidgetState extends State<VaultListWidget> {
  late VaultListModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  int _refreshKey = 0;

  // Cache for dialog data to prevent unnecessary reloads
  Future<List<ContractRecord>>? _cachedNitches;
  Future<List<ContractRecord>>? _cachedLots;

  // Cache for main vault data
  Future<List<VaultRecord>>? _cachedVaultData;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => VaultListModel());

    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();

    // Add listener to text controller for real-time search with debouncing
    _model.textController!.addListener(() {
      if (mounted) {
        // Use a timer to debounce the search to prevent excessive rebuilds
        _model.searchTimer?.cancel();
        _model.searchTimer = Timer(Duration(milliseconds: 300), () {
          if (mounted) {
            setState(() {});
          }
        });
      }
    });

    // Initialize vault data cache
    _cachedVaultData = queryVaultRecordOnce();

    // On page load action: process expired contracts and create vaults
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await processExpiredContracts();
      safeSetState(() {});
    });
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  // ==================== HELPER DIALOG METHODS ====================

  // Helper: show a blocking loading modal with a message
  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(message)),
            ],
          ),
        );
      },
    );
  }

  // Helper: show an info/result modal
  Future<void> _showMessageDialog(String title, String message) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Don't watch FFAppState to prevent unnecessary rebuilds from unrelated state changes
    // Use direct FFAppState() calls when needed instead

    // Refresh cache if _refreshKey changed
    if (_cachedVaultData == null) {
      _cachedVaultData = queryVaultRecordOnce();
    }

    return FutureBuilder<List<VaultRecord>>(
      future: _cachedVaultData,
      key: ValueKey(_refreshKey),
      builder: (context, snapshot) {
        // Handle error state
        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 24),
                  Text(
                    'Error loading vault data: ${snapshot.error}',
                    style: DashboardTheme.bodyText,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        // Customize what your widget looks like when it's loading.
        if (snapshot.connectionState == ConnectionState.waiting ||
            !snapshot.hasData) {
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
                    'Loading Vault Data...',
                    style: DashboardTheme.bodyText,
                  ),
                ],
              ),
            ),
          );
        }

        // Handle empty data
        List<VaultRecord> allVaultList = snapshot.data ?? [];

        // Filter the data based on search text and date range
        List<VaultRecord> vaultRecordList = allVaultList.where((vault) {
          // Apply text search filter
          if (_model.textController?.text.isNotEmpty == true) {
            final searchText = _model.textController!.text.toLowerCase().trim();

            final vaultId = vault.reference.id;
            final deceasedName = vault.deceasedname.isNotEmpty
                ? vault.deceasedname.last.toLowerCase()
                : '';
            final applicantName = vault.applicantname.isNotEmpty
                ? vault.applicantname.last.toLowerCase()
                : '';
            final applicantAddress = vault.applicantaddress.isNotEmpty
                ? vault.applicantaddress.last.toLowerCase()
                : '';

            // Search in multiple fields
            bool matchesSearch = vaultId.toLowerCase().contains(searchText) ||
                deceasedName.contains(searchText) ||
                applicantName.contains(searchText) ||
                applicantAddress.contains(searchText);

            if (!matchesSearch) return false;
          }

          // Apply date filter based on timestamp
          if (_model.startDate != null || _model.endDate != null) {
            DateTime? vaultDate = vault.timestamp;

            if (vaultDate != null) {
              // Apply start date filter
              if (_model.startDate != null &&
                  vaultDate.isBefore(_model.startDate!)) {
                return false;
              }

              // Apply end date filter
              if (_model.endDate != null &&
                  vaultDate.isAfter(_model.endDate!)) {
                return false;
              }
            } else {
              // If no valid date found and filters are applied, exclude the vault
              return false;
            }
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
                          color: const Color(0x1A000000),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
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
                                      color: Color(0xFF18651C).withOpacity(0.1),
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
                                  icon: Icons.assignment_rounded,
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
                                  onTap: () =>
                                      context.pushNamed('burialLotsList'),
                                ),
                                _buildNavItem(
                                  icon: Icons.inventory_2_rounded,
                                  title: 'Vault',
                                  isActive: true,
                                  onTap: () {
                                    FFAppState().clearVaultNotification();
                                  },
                                  notificationCount: FFAppState().newVaultCount,
                                ),
                                _buildNavItem(
                                  icon: Icons.people_rounded,
                                  title: 'User Management',
                                  onTap: () => context.pushNamed('userlist'),
                                ),
                                _buildNavItem(
                                  icon: Icons.payment_rounded,
                                  title: 'Transaction',
                                  onTap: () => context.pushNamed('transaction'),
                                ),
                                _buildNavItem(
                                  icon: Icons.verified_user_rounded,
                                  title: 'Audit Trail',
                                  onTap: () => context.pushNamed('audit'),
                                ),
                                _buildNavItem(
                                  icon: Icons.record_voice_over_rounded,
                                  title: 'Visitor Log',
                                  onTap: () => context.pushNamed('visitorLog'),
                                ),

                                SizedBox(height: 32),

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
                              bottomLeft: Radius.circular(24),
                              bottomRight: Radius.circular(24),
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
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Vault Records',
                                    style: GoogleFonts.inter(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF1F2937),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'View and manage all deceased records in the vault',
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      color: const Color(0xFF6B7280),
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 32),

                              // Actions Row
                              Row(
                                children: [
                                  // Search Bar
                                  Expanded(
                                    child: Container(
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: const Color(0xFFE5E7EB),
                                          width: 1,
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
                                        focusNode: _model.textFieldFocusNode,
                                        obscureText: false,
                                        decoration: InputDecoration(
                                          hintText:
                                              'Search by vault ID, name, applicant name, address...',
                                          hintStyle: const TextStyle(
                                            color: Color(0xFF9CA3AF),
                                            fontSize: 14,
                                          ),
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
                                                    setState(() {});
                                                  },
                                                  icon: const Icon(
                                                    Icons.clear_rounded,
                                                    color: Color(0xFF6B7280),
                                                    size: 20,
                                                  ),
                                                )
                                              : null,
                                          border: InputBorder.none,
                                        ),
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          color: const Color(0xFF1F2937),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),

                                  // Date Filters
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: const Color(0xFFE5E7EB),
                                        width: 1,
                                      ),
                                    ),
                                    child: InkWell(
                                      onTap: () async {
                                        final DateTime? picked =
                                            await showDatePicker(
                                          context: context,
                                          initialDate: _model.startDate ??
                                              DateTime.now().subtract(
                                                  const Duration(days: 30)),
                                          firstDate: DateTime(2020),
                                          lastDate: DateTime.now(),
                                        );
                                        if (picked != null) {
                                          setState(() {
                                            _model.startDate = picked;
                                          });
                                        }
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 12),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.calendar_today_rounded,
                                              color: const Color(0xFF6B7280),
                                              size: 18,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              _model.startDate != null
                                                  ? '${_model.startDate!.day}/${_model.startDate!.month}/${_model.startDate!.year}'
                                                  : 'Start Date',
                                              style: GoogleFonts.inter(
                                                fontSize: 14,
                                                color: _model.startDate != null
                                                    ? const Color(0xFF1F2937)
                                                    : const Color(0xFF9CA3AF),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: const Color(0xFFE5E7EB),
                                        width: 1,
                                      ),
                                    ),
                                    child: InkWell(
                                      onTap: () async {
                                        final DateTime? picked =
                                            await showDatePicker(
                                          context: context,
                                          initialDate:
                                              _model.endDate ?? DateTime.now(),
                                          firstDate: DateTime(2020),
                                          lastDate: DateTime.now(),
                                        );
                                        if (picked != null) {
                                          setState(() {
                                            _model.endDate = picked;
                                          });
                                        }
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 12),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.calendar_today_rounded,
                                              color: const Color(0xFF6B7280),
                                              size: 18,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              _model.endDate != null
                                                  ? '${_model.endDate!.day}/${_model.endDate!.month}/${_model.endDate!.year}'
                                                  : 'End Date',
                                              style: GoogleFonts.inter(
                                                fontSize: 14,
                                                color: _model.endDate != null
                                                    ? const Color(0xFF1F2937)
                                                    : const Color(0xFF9CA3AF),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),

                                  // Clear Date Filters Button
                                  if (_model.startDate != null ||
                                      _model.endDate != null)
                                    Container(
                                      child: TextButton.icon(
                                        onPressed: () {
                                          setState(() {
                                            _model.startDate = null;
                                            _model.endDate = null;
                                          });
                                        },
                                        icon: Icon(
                                          Icons.clear_rounded,
                                          color: const Color(0xFFEF4444),
                                          size: 18,
                                        ),
                                        label: Text(
                                          'Clear Dates',
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            color: const Color(0xFFEF4444),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),

                                  const SizedBox(width: 16),

                                  // Download PDF Button
                                  Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF3B82F6),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: const Color(0xFF3B82F6),
                                        width: 1,
                                      ),
                                    ),
                                    child: InkWell(
                                      onTap: () {
                                        _downloadVaultPDF(allVaultList);
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 12),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.download_rounded,
                                              color: Colors.white,
                                              size: 18,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Download PDF',
                                              style: GoogleFonts.inter(
                                                fontSize: 14,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
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
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0x0A000000),
                                  blurRadius: 24,
                                  offset: const Offset(0, 8),
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
                                      topLeft: Radius.circular(24),
                                      topRight: Radius.circular(24),
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
                                                if (_model.startDate != null)
                                                  Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 12,
                                                            vertical: 6),
                                                    decoration: BoxDecoration(
                                                      color: Color(0xFF10B981)
                                                          .withOpacity(0.1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              16),
                                                    ),
                                                    child: Text(
                                                      'From: ${_model.startDate!.day}/${_model.startDate!.month}/${_model.startDate!.year}',
                                                      style: GoogleFonts.inter(
                                                        fontSize: 12,
                                                        color:
                                                            Color(0xFF10B981),
                                                      ),
                                                    ),
                                                  ),
                                                if (_model.endDate != null)
                                                  Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 12,
                                                            vertical: 6),
                                                    decoration: BoxDecoration(
                                                      color: Color(0xFF10B981)
                                                          .withOpacity(0.1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              16),
                                                    ),
                                                    child: Text(
                                                      'To: ${_model.endDate!.day}/${_model.endDate!.month}/${_model.endDate!.year}',
                                                      style: GoogleFonts.inter(
                                                        fontSize: 12,
                                                        color:
                                                            Color(0xFF10B981),
                                                      ),
                                                    ),
                                                  ),
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
                                          '${vaultRecordList.length} of ${allVaultList.length} records',
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
                                  child: FlutterFlowDataTable<VaultRecord>(
                                    controller:
                                        _model.paginatedDataTableController1,
                                    data: vaultRecordList,
                                    columnsBuilder: (onSortChanged) => [
                                      DataColumn2(
                                        label: Container(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 12, horizontal: 12),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.numbers_rounded,
                                                color: DashboardTheme.primary,
                                                size: 16,
                                              ),
                                              SizedBox(width: 6),
                                              Text(
                                                'Vault ID',
                                                style: GoogleFonts.inter(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xFF1F2937),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      DataColumn2(
                                        label: Container(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 12, horizontal: 12),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.person_rounded,
                                                color: DashboardTheme.primary,
                                                size: 16,
                                              ),
                                              SizedBox(width: 6),
                                              Text(
                                                'Name',
                                                style: GoogleFonts.inter(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xFF1F2937),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      DataColumn2(
                                        label: Container(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 12, horizontal: 12),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.event_rounded,
                                                color: DashboardTheme.primary,
                                                size: 16,
                                              ),
                                              SizedBox(width: 6),
                                              Text(
                                                'Death Date',
                                                style: GoogleFonts.inter(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xFF1F2937),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      DataColumn2(
                                        label: Container(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 12, horizontal: 12),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.church_rounded,
                                                color: DashboardTheme.primary,
                                                size: 16,
                                              ),
                                              SizedBox(width: 6),
                                              Text(
                                                'Internment',
                                                style: GoogleFonts.inter(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xFF1F2937),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      DataColumn2(
                                        label: Container(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 12, horizontal: 12),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.people_rounded,
                                                color: DashboardTheme.primary,
                                                size: 16,
                                              ),
                                              SizedBox(width: 6),
                                              Text(
                                                'Applicant',
                                                style: GoogleFonts.inter(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xFF1F2937),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      DataColumn2(
                                        label: Container(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 12, horizontal: 12),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.location_on_rounded,
                                                color: DashboardTheme.primary,
                                                size: 16,
                                              ),
                                              SizedBox(width: 6),
                                              Text(
                                                'Address',
                                                style: GoogleFonts.inter(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xFF1F2937),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      DataColumn2(
                                        label: Container(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 12, horizontal: 12),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.phone_rounded,
                                                color: DashboardTheme.primary,
                                                size: 16,
                                              ),
                                              SizedBox(width: 6),
                                              Text(
                                                'Contact',
                                                style: GoogleFonts.inter(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xFF1F2937),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      DataColumn2(
                                        label: Container(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 12, horizontal: 12),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.info_rounded,
                                                color: DashboardTheme.primary,
                                                size: 16,
                                              ),
                                              SizedBox(width: 6),
                                              Text(
                                                'Status',
                                                style: GoogleFonts.inter(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xFF1F2937),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      DataColumn2(
                                        label: Container(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 12, horizontal: 12),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.build_rounded,
                                                color: DashboardTheme.primary,
                                                size: 16,
                                              ),
                                              SizedBox(width: 6),
                                              Text(
                                                'Reburial',
                                                style: GoogleFonts.inter(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xFF1F2937),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                    dataRowBuilder: (vault, vaultIndex,
                                            selected, onSelectChanged) =>
                                        DataRow(
                                      color: WidgetStateProperty.all(
                                        vaultIndex % 2 == 0
                                            ? Color(0xFFF9FAFB)
                                            : Colors.white,
                                      ),
                                      cells: [
                                        // Vault ID
                                        DataCell(Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 12),
                                          child: Text(
                                            vault.reference.id,
                                            style: GoogleFonts.inter(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: DashboardTheme.primary,
                                            ),
                                          ),
                                        )),
                                        // Deceased Name
                                        DataCell(Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 12),
                                          child: Text(
                                            vault.deceasedname.isNotEmpty
                                                ? vault.deceasedname.last
                                                : 'N/A',
                                            style: GoogleFonts.inter(
                                              fontSize: 12,
                                              color:
                                                  vault.deceasedname.isNotEmpty
                                                      ? Color(0xFF1F2937)
                                                      : Color(0xFF9CA3AF),
                                            ),
                                          ),
                                        )),
                                        // Date of Death
                                        DataCell(Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 12),
                                          child: Text(
                                            vault.deceaseddateofdeath.isNotEmpty
                                                ? '${vault.deceaseddateofdeath.last.day}/${vault.deceaseddateofdeath.last.month}/${vault.deceaseddateofdeath.last.year}'
                                                : 'N/A',
                                            style: GoogleFonts.inter(
                                              fontSize: 12,
                                              color: Color(0xFF1F2937),
                                            ),
                                          ),
                                        )),
                                        // Burial Internment
                                        DataCell(Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 12),
                                          child: Text(
                                            vault.deceasedburialinterment
                                                    .isNotEmpty
                                                ? '${vault.deceasedburialinterment.last.day}/${vault.deceasedburialinterment.last.month}/${vault.deceasedburialinterment.last.year}'
                                                : 'N/A',
                                            style: GoogleFonts.inter(
                                              fontSize: 12,
                                              color: Color(0xFF1F2937),
                                            ),
                                          ),
                                        )),
                                        // Applicant Name
                                        DataCell(Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 12),
                                          child: Text(
                                            vault.applicantname.isNotEmpty
                                                ? vault.applicantname.last
                                                : 'N/A',
                                            style: GoogleFonts.inter(
                                              fontSize: 12,
                                              color:
                                                  vault.applicantname.isNotEmpty
                                                      ? Color(0xFF1F2937)
                                                      : Color(0xFF9CA3AF),
                                            ),
                                          ),
                                        )),
                                        // Applicant Address
                                        DataCell(Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 12),
                                          child: Text(
                                            vault.applicantaddress.isNotEmpty
                                                ? vault.applicantaddress.last
                                                : 'N/A',
                                            style: GoogleFonts.inter(
                                              fontSize: 12,
                                              color: vault.applicantaddress
                                                      .isNotEmpty
                                                  ? Color(0xFF1F2937)
                                                  : Color(0xFF9CA3AF),
                                            ),
                                          ),
                                        )),
                                        // Applicant Number
                                        DataCell(Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 12),
                                          child: Text(
                                            vault.applicantcontactnumber
                                                    .isNotEmpty
                                                ? '0${vault.applicantcontactnumber.last.toString()}'
                                                : 'N/A',
                                            style: GoogleFonts.inter(
                                              fontSize: 12,
                                              color: vault
                                                      .applicantcontactnumber
                                                      .isNotEmpty
                                                  ? Color(0xFF1F2937)
                                                  : Color(0xFF9CA3AF),
                                            ),
                                          ),
                                        )),
                                        // Status
                                        DataCell(
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: Color(0xFFFEF3C7),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(
                                                color: Color(0xFFF59E0B),
                                                width: 1,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.pending_rounded,
                                                  size: 16,
                                                  color: Color(0xFFF59E0B),
                                                ),
                                                SizedBox(width: 6),
                                                Text(
                                                  'Available',
                                                  style: GoogleFonts.inter(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    color: Color(0xFFF59E0B),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        // Actions
                                        DataCell(
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              // Nitche Button
                                              ElevatedButton(
                                                onPressed: () {
                                                  _showNitcheList(
                                                      context, vault);
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      DashboardTheme.primary,
                                                  foregroundColor: Colors.white,
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 8),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6),
                                                  ),
                                                ),
                                                child: Text('Nitche'),
                                              ),
                                              SizedBox(width: 6),
                                              // Plot Button
                                              ElevatedButton(
                                                onPressed: () {
                                                  _showLotList(context, vault);
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Color(0xFF16A34A),
                                                  foregroundColor: Colors.white,
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 8),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6),
                                                  ),
                                                ),
                                                child: Text('Plot'),
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
                                    columnSpacing: 16.0,
                                    headingRowColor: Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(24),
                                    addHorizontalDivider: true,
                                    addTopAndBottomDivider: false,
                                    hideDefaultHorizontalDivider: true,
                                    horizontalDividerColor: Color(0xFFE5E7EB),
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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

  // Method to show available nitche locations with search
  void _showNitcheList(BuildContext context, VaultRecord vault) {
    TextEditingController searchController = TextEditingController();
    String searchQuery = '';

    // Cache the nitche data when dialog opens
    _cachedNitches ??= _getAvailableNitches();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(
                    Icons.view_compact_rounded,
                    color: DashboardTheme.primary,
                    size: 24,
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Available Nitche Locations',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
              content: Container(
                width: 450,
                height: 400,
                child: Column(
                  children: [
                    // Search Bar
                    Container(
                      margin: EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Color(0xFFE5E7EB),
                          width: 1,
                        ),
                      ),
                      child: TextFormField(
                        controller: searchController,
                        decoration: InputDecoration(
                          hintText:
                              'Search by nitche ID, location, or price...',
                          hintStyle: TextStyle(
                            color: Color(0xFF9CA3AF),
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: Color(0xFF6B7280),
                            size: 20,
                          ),
                          suffixIcon: searchController.text.isNotEmpty
                              ? IconButton(
                                  onPressed: () {
                                    searchController.clear();
                                    searchQuery = '';
                                    setState(() {});
                                  },
                                  icon: Icon(
                                    Icons.clear_rounded,
                                    color: Color(0xFF6B7280),
                                    size: 18,
                                  ),
                                )
                              : null,
                        ),
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF1F2937),
                        ),
                        onChanged: (value) {
                          searchQuery = value.toLowerCase();
                          setState(() {}); // Triggers rebuild to filter list
                        },
                      ),
                    ),
                    // Nitche List
                    Expanded(
                      child: FutureBuilder<List<ContractRecord>>(
                        future: _cachedNitches,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      DashboardTheme.primary,
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Loading available nitches...',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    size: 48,
                                    color: Color(0xFF6B7280),
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'No available nitche locations found',
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          final allNitches = snapshot.data!;

                          // Filter nitches based on search query
                          final filteredNitches = allNitches.where((nitche) {
                            if (searchQuery.isEmpty) return true;

                            final nitcheId = nitche.nitcheidString.isNotEmpty
                                ? nitche.nitcheidString.toLowerCase()
                                : nitche.nitcheid.toString();
                            final location = nitche.location.toLowerCase();
                            final amount = nitche.amount.toLowerCase();

                            return nitcheId.contains(searchQuery) ||
                                location.contains(searchQuery) ||
                                amount.contains(searchQuery);
                          }).toList();

                          if (filteredNitches.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.search_off_rounded,
                                    size: 48,
                                    color: Color(0xFF6B7280),
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'No nitches found matching "$searchQuery"',
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Try a different search term',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      color: Color(0xFF9CA3AF),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return ListView.builder(
                            itemCount: filteredNitches.length,
                            itemBuilder: (context, index) {
                              final contract = filteredNitches[index];
                              return Container(
                                margin: EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Color(0xFFE5E7EB),
                                    width: 1,
                                  ),
                                ),
                                child: ListTile(
                                  leading: Icon(
                                    Icons.view_compact_rounded,
                                    color: DashboardTheme.primary,
                                  ),
                                  title: Text(
                                    'Nitche ${contract.location.isNotEmpty ? contract.location : 'N/A'}',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (contract.amount.isNotEmpty)
                                        Text(
                                          'Price: ₱${contract.amount}',
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            color: Color(0xFF10B981),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                    ],
                                  ),
                                  trailing: ElevatedButton(
                                    onPressed: () {
                                      searchController.dispose();
                                      Navigator.of(context).pop();
                                      _showContractRenewalModal(
                                          context, vault, contract);
                                    },
                                    child: Text('Select'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: DashboardTheme.primary,
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    searchController.dispose();
                    Navigator.of(context).pop();
                  },
                  child: Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Method to show available lot locations (lots without contracts) with search
  void _showLotList(BuildContext context, VaultRecord vault) {
    TextEditingController searchController = TextEditingController();
    String searchQuery = '';

    // Cache the lot data when dialog opens
    _cachedLots ??= _getAvailableLots();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(
                    Icons.add_location_alt_rounded,
                    color: DashboardTheme.primary,
                    size: 24,
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Active Lot Contracts',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
              content: Container(
                width: 450,
                height: 400,
                child: Column(
                  children: [
                    // Search Bar
                    Container(
                      margin: EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Color(0xFFE5E7EB),
                          width: 1,
                        ),
                      ),
                      child: TextFormField(
                        controller: searchController,
                        decoration: InputDecoration(
                          hintText: 'Search by location, price, or size...',
                          hintStyle: TextStyle(
                            color: Color(0xFF9CA3AF),
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: Color(0xFF6B7280),
                            size: 20,
                          ),
                          suffixIcon: searchController.text.isNotEmpty
                              ? IconButton(
                                  onPressed: () {
                                    searchController.clear();
                                    searchQuery = '';
                                    setState(() {});
                                  },
                                  icon: Icon(
                                    Icons.clear_rounded,
                                    color: Color(0xFF6B7280),
                                    size: 18,
                                  ),
                                )
                              : null,
                        ),
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF1F2937),
                        ),
                        onChanged: (value) {
                          searchQuery = value.toLowerCase();
                          setState(() {}); // Triggers rebuild to filter list
                        },
                      ),
                    ),
                    // Lot List
                    Expanded(
                      child: FutureBuilder<List<ContractRecord>>(
                        future: _cachedLots,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      DashboardTheme.primary,
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Loading available lots...',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    size: 48,
                                    color: Color(0xFF6B7280),
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'No active lot contracts found',
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          final allLots = snapshot.data!;

                          // Filter lots based on search query
                          final filteredLots = allLots.where((lot) {
                            if (searchQuery.isEmpty) return true;

                            final location = lot.location.toLowerCase();
                            final amount = lot.amount.toLowerCase();
                            final measurement = lot.measurement.toLowerCase();

                            return location.contains(searchQuery) ||
                                amount.contains(searchQuery) ||
                                measurement.contains(searchQuery);
                          }).toList();

                          if (filteredLots.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.search_off_rounded,
                                    size: 48,
                                    color: Color(0xFF6B7280),
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'No lots found matching "$searchQuery"',
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Try a different search term',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      color: Color(0xFF9CA3AF),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return ListView.builder(
                            itemCount: filteredLots.length,
                            itemBuilder: (context, index) {
                              final lot = filteredLots[index];
                              return Container(
                                margin: EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Color(0xFFE5E7EB),
                                    width: 1,
                                  ),
                                ),
                                child: ListTile(
                                  leading: Icon(
                                    Icons.add_location_alt_rounded,
                                    color: DashboardTheme.primary,
                                  ),
                                  title: Text(
                                    'Lot ${lot.location.isNotEmpty ? lot.location : 'N/A'}',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Location: ${lot.location.isNotEmpty ? lot.location : 'N/A'}',
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          color: Color(0xFF6B7280),
                                        ),
                                      ),
                                      if (lot.amount.isNotEmpty)
                                        Text(
                                          'Price: ₱${lot.amount}',
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            color: Color(0xFF10B981),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      if (lot.measurement.isNotEmpty)
                                        Text(
                                          'Size: ${lot.measurement}',
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            color: Color(0xFF6B7280),
                                          ),
                                        ),
                                    ],
                                  ),
                                  trailing: ElevatedButton(
                                    onPressed: () {
                                      searchController.dispose();
                                      Navigator.of(context).pop();
                                      _showLotVerificationModal(
                                          context, vault, lot);
                                    },
                                    child: Text('Select'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: DashboardTheme.primary,
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    searchController.dispose();
                    Navigator.of(context).pop();
                  },
                  child: Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Method to show lot verification modal
  void _showLotVerificationModal(
      BuildContext context, VaultRecord vault, ContractRecord lot) {
    final formKey = GlobalKey<FormState>();
    final applicantNameController = TextEditingController();
    final applicantAddressController = TextEditingController();
    final applicantContactController = TextEditingController();
    final orNumberController = TextEditingController(
      text: FFAppState().qrcode.isNotEmpty
          ? FFAppState().qrcode
          : 'QR-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
    );
    final tinController = TextEditingController();
    final residentCertController = TextEditingController();

    // File upload state
    String? proofOfLeasePath;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(
                    Icons.verified_user_rounded,
                    color: DashboardTheme.primary,
                    size: 24,
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Lot Assignment Verification',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
              content: Container(
                width: 600,
                height: 700,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Selected Lot Details
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Color(0xFFF0F9FF),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Color(0xFF0EA5E9),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Selected Lot Details',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF0C4A6E),
                                ),
                              ),
                              SizedBox(height: 12),
                              Text(
                                'Location: ${lot.location.isNotEmpty ? lot.location : 'N/A'}',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: Color(0xFF0C4A6E),
                                ),
                              ),
                              if (lot.measurement.isNotEmpty)
                                Padding(
                                  padding: EdgeInsets.only(top: 8),
                                  child: Text(
                                    'Size: ${lot.measurement}',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      color: Color(0xFF0C4A6E),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),

                        // Deceased Details
                        Text(
                          'Deceased Details',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Color(0xFFF8F9FA),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Color(0xFFE9ECEF),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Name: ${vault.deceasedname.isNotEmpty ? vault.deceasedname.first : 'N/A'}',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: Color(0xFF1F2937),
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Date of Death: ${vault.deceaseddateofdeath.isNotEmpty ? DateFormat('MM/dd/yyyy').format(vault.deceaseddateofdeath.last) : 'N/A'}',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: Color(0xFF1F2937),
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Date of Burial: ${vault.deceasedburialinterment.isNotEmpty ? DateFormat('MM/dd/yyyy').format(vault.deceasedburialinterment.last) : 'N/A'}',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: Color(0xFF1F2937),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),

                        // Application Form Section
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Color(0xFFE2E8F0),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.person_rounded,
                                    color: DashboardTheme.primary,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Application Form',
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1F2937),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              _buildFormFieldWithListener(
                                'Applicant Name *',
                                applicantNameController,
                                'Enter applicant full name',
                                prefixIcon: Icons.person_rounded,
                                setModalState: setState,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Applicant name is required';
                                  }
                                  if (!RegExp(r'^[a-zA-Z\s]+$')
                                      .hasMatch(value.trim())) {
                                    return 'Name can only contain letters and spaces';
                                  }
                                  if (value.trim().length < 2) {
                                    return 'Name must be at least 2 characters';
                                  }
                                  if (value.trim().length > 50) {
                                    return 'Name must not exceed 50 characters';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 16),
                              _buildFormFieldWithListener(
                                'Applicant Address *',
                                applicantAddressController,
                                'Enter complete address',
                                prefixIcon: Icons.location_on_rounded,
                                maxLines: 2,
                                setModalState: setState,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Address is required';
                                  }
                                  if (!RegExp(r'^[A-Za-z0-9\s.,#\-]+$')
                                      .hasMatch(value.trim())) {
                                    return 'Address contains invalid characters';
                                  }
                                  if (value.trim().length < 5) {
                                    return 'Address must be at least 5 characters';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 16),
                              _buildFormFieldWithListener(
                                'Mobile Contact Number*',
                                applicantContactController,
                                'Enter 11-digit mobile number',
                                prefixIcon: Icons.phone_rounded,
                                keyboardType: TextInputType.phone,
                                setModalState: setState,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Mobile Contact Number is required';
                                  }
                                  if (!RegExp(r'^09\d{9}$').hasMatch(value)) {
                                    return 'Mobile Contact Number must be 11 digits starting with 09';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),

                        // Document Details Section
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Color(0xFFF0F9FF),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Color(0xFFBAE6FD),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.description_rounded,
                                    color: Color(0xFF0EA5E9),
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Document Details',
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1F2937),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildFormFieldWithListener(
                                      'OR Number',
                                      orNumberController,
                                      'Enter official receipt number',
                                      prefixIcon: Icons.receipt_rounded,
                                      enabled: false,
                                      setModalState: setState,
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: _buildFormFieldWithListener(
                                      'TIN',
                                      tinController,
                                      'Enter TIN in format: xxx - xxx - xxx - xxx',
                                      prefixIcon: Icons.badge_rounded,
                                      setModalState: setState,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'TIN number is required';
                                        }
                                        if (!RegExp(
                                                r'^\d{3}\s*-\s*\d{3}\s*-\s*\d{3}\s*-\s*\d{3}$')
                                            .hasMatch(value.trim())) {
                                          return 'TIN Number must be in format: xxx - xxx - xxx - xxx';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              _buildFormFieldWithListener(
                                'Resident Certificate (Community Tax Certificate / Sedula)',
                                residentCertController,
                                'Enter resident certificate number',
                                prefixIcon: Icons.verified_user_rounded,
                                setModalState: setState,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Resident Certificate is required';
                                  }
                                  if (!RegExp(r'^\d{8,11}$')
                                      .hasMatch(value.trim())) {
                                    return 'Resident Certificate must be 8-11 digits';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 16),
                              _buildFileUploadField(
                                labelText: 'Proof of Lease*',
                                hintText: 'Upload lease document',
                                onUpload: () async {
                                  try {
                                    // Show loading modal
                                    _showLoadingDialog('Selecting file...');

                                    // Select file using file picker
                                    final selectedFile = await selectFile(
                                      storageFolderPath: 'proof_of_lease',
                                      allowedExtensions: [
                                        'pdf',
                                        'doc',
                                        'docx',
                                        'jpg',
                                        'jpeg',
                                        'png'
                                      ],
                                    );

                                    if (selectedFile != null) {
                                      // Switch to verification loading modal
                                      if (Navigator.of(context).canPop()) {
                                        Navigator.of(context).pop();
                                      }
                                      _showLoadingDialog(
                                          'Verifying document authenticity...');

                                      // Get file name from storage path and determine MIME type
                                      final fileName = selectedFile.storagePath
                                          .split('/')
                                          .last;
                                      final mimeType =
                                          _getMimeTypeFromFileName(fileName);

                                      // Verify document authenticity
                                      final verificationResult =
                                          await DocumentVerificationService
                                              .verifyDocument(
                                        documentBytes: selectedFile.bytes,
                                        fileName: fileName,
                                        mimeType: mimeType,
                                      );

                                      // Show verification results
                                      if (!verificationResult.isValid) {
                                        // Always close loading dialog first
                                        if (Navigator.of(context).canPop()) {
                                          Navigator.of(context).pop();
                                        }
                                        await _showVerificationDialog(
                                            verificationResult, selectedFile,
                                            onUploadComplete: (downloadUrl) {
                                          setState(() {
                                            proofOfLeasePath = downloadUrl;
                                          });
                                        });
                                        return;
                                      }

                                      // Switch to upload loading modal
                                      if (Navigator.of(context).canPop()) {
                                        Navigator.of(context).pop();
                                      }
                                      _showLoadingDialog(
                                          'Uploading verified file to storage...');

                                      // Actually upload the file to Firebase Storage
                                      final downloadUrl = await uploadData(
                                          selectedFile.storagePath,
                                          selectedFile.bytes);

                                      if (downloadUrl != null) {
                                        setState(() {
                                          proofOfLeasePath = downloadUrl;
                                        });

                                        // Close loading and show success modal
                                        if (Navigator.of(context).canPop()) {
                                          Navigator.of(context).pop();
                                        }
                                        await _showMessageDialog(
                                          'Upload Complete',
                                          'Proof of lease verified and uploaded successfully.\nConfidence: ${(verificationResult.confidence * 100).toStringAsFixed(0)}%',
                                        );
                                      } else {
                                        // Upload failed
                                        if (Navigator.of(context).canPop()) {
                                          Navigator.of(context).pop();
                                        }
                                        await _showMessageDialog(
                                          'Upload Failed',
                                          'Failed to upload file to storage.',
                                        );
                                      }
                                    } else {
                                      // Close loading if open
                                      if (Navigator.of(context).canPop()) {
                                        Navigator.of(context).pop();
                                      }
                                    }
                                  } catch (e) {
                                    // Close loading and show error modal
                                    if (Navigator.of(context).canPop()) {
                                      Navigator.of(context).pop();
                                    }
                                    await _showMessageDialog(
                                        'Error', 'Error uploading file: $e');
                                  }
                                },
                                uploadedFile: proofOfLeasePath,
                                onRemove: () async {
                                  setState(() {
                                    proofOfLeasePath = null;
                                  });

                                  await showDialog(
                                    context: context,
                                    builder: (BuildContext dialogContext) =>
                                        AlertDialog(
                                      title: const Text('Notice'),
                                      content:
                                          const Text('Proof of lease removed!'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                          child: const Text('OK'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),

                        // Applicant Details
                        Text(
                          'Applicant Details',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Color(0xFFF8F9FA),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Color(0xFFE9ECEF),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Name: ${vault.applicantname.isNotEmpty ? vault.applicantname.first : 'N/A'}',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: Color(0xFF1F2937),
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Phone: ${vault.applicantcontactnumber.isNotEmpty ? '0${vault.applicantcontactnumber.first.toString()}' : 'N/A'}',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: Color(0xFF1F2937),
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Address: ${vault.applicantaddress.isNotEmpty ? vault.applicantaddress.first : 'N/A'}',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: Color(0xFF1F2937),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),

                        // Information Notice
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Color(0xFFF59E0B),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                color: Color(0xFFF59E0B),
                                size: 20,
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'This will assign the deceased to the selected active lot contract. The vault data will be transferred to the existing contract location.',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF92400E),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    print('Cancel button clicked');
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // Validate form first
                    if (!formKey.currentState!.validate()) {
                      await showDialog(
                        context: context,
                        builder: (BuildContext dialogContext) => AlertDialog(
                          title: const Text('Validation Error'),
                          content: const Text(
                              'Please fill in all required fields correctly'),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.of(dialogContext).pop(),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                      return;
                    }

                    // Step 1: Check for empty required fields
                    final emptyFields = _validateRequiredFieldsLotAssignment(
                      applicantNameController,
                      applicantAddressController,
                      applicantContactController,
                      orNumberController,
                      tinController,
                      residentCertController,
                      proofOfLeasePath,
                    );
                    if (emptyFields.isNotEmpty) {
                      _showEmptyFieldsDialogLotAssignment(emptyFields);
                      return;
                    }

                    // Step 2: Check field format validation
                    final formatErrors =
                        await _validateAllFieldFormatsLotAssignment(
                      applicantNameController,
                      applicantAddressController,
                      applicantContactController,
                      tinController,
                      residentCertController,
                    );
                    if (formatErrors.isNotEmpty) {
                      _showFormatErrorDialogLotAssignment(formatErrors);
                      return;
                    }

                    // Step 2.5: Validate contact number uniqueness
                    final isContactUnique =
                        await _validateContactNumberUniquenessForLot(
                      applicantNameController,
                      applicantContactController,
                    );
                    if (!isContactUnique) {
                      print('Contact number uniqueness validation failed!');
                      return; // Stop submission if contact number is not unique
                    }

                    // Show confirmation dialog
                    final bool? confirmed = await showDialog<bool>(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Confirm Lot Assignment',
                              style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1F2937))),
                          content: Text(
                              'Are you sure you want to assign Lot ${lot.location.isNotEmpty ? lot.location : 'N/A'} to the vault record?',
                              style: GoogleFonts.inter(
                                  fontSize: 14, color: Color(0xFF6B7280))),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: Text('Cancel',
                                  style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF6B7280))),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: DashboardTheme.primary,
                                  foregroundColor: Colors.white),
                              child: Text('Confirm',
                                  style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600)),
                            ),
                          ],
                        );
                      },
                    );

                    if (confirmed == true) {
                      print('=== CONFIRM BUTTON CLICKED ===');
                      print('Button pressed at: ${DateTime.now()}');
                      print('Vault: ${vault.reference.id}');
                      print('Lot: ${lot.reference.id}');

                      // Show loading indicator (no OK button, just loading)
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            content: Row(
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(width: 16),
                                Text('Processing lot assignment...'),
                              ],
                            ),
                          );
                        },
                      );

                      try {
                        _executeLotAssignment(
                            context,
                            vault,
                            lot,
                            applicantNameController.text.trim(),
                            applicantAddressController.text.trim(),
                            applicantContactController.text.trim(),
                            orNumberController.text.trim(),
                            tinController.text.trim(),
                            residentCertController.text.trim(),
                            proofOfLeasePath);

                        // Close loading dialog
                        Navigator.of(context).pop();
                      } catch (e) {
                        // Close loading dialog
                        Navigator.of(context).pop();

                        // Show error message
                        await showDialog(
                          context: context,
                          builder: (BuildContext dialogContext) => AlertDialog(
                            title: const Text('Error'),
                            content: Text(
                                'Error processing lot assignment: ${e.toString()}'),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(dialogContext).pop(),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      }
                    } else {
                      // User cancelled the confirmation
                      print('Lot assignment cancelled by user');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DashboardTheme.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Confirm Lot Assignment',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
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

  // Method to execute lot assignment
  void _executeLotAssignment(
      BuildContext context,
      VaultRecord vault,
      ContractRecord lot,
      String applicantName,
      String applicantAddress,
      String applicantContact,
      String orNumber,
      String tin,
      String residentCert,
      String? proofOfLease) async {
    try {
      print('Starting lot assignment...');
      print('Vault ID: ${vault.reference.id}');
      print('Lot ID: ${lot.reference.id}');
      print('Vault deceased name: ${vault.deceasedname}');
      print('Vault applicant name: ${vault.applicantname}');
      print('Form applicant name: $applicantName');
      print('Form applicant address: $applicantAddress');
      print('Form applicant contact: $applicantContact');
      print('Form OR number: $orNumber');
      print('Form TIN: $tin');
      print('Form resident cert: $residentCert');
      print('Form proof of lease: $proofOfLease');

      // Get current contract data to merge with vault data
      final currentContract = await lot.reference.get();
      final currentData = currentContract.data() as Map<String, dynamic>;

      print('Current contract decFullName: ${currentData['decFullName']}');
      print('Current contract applicantName: ${currentData['applicantName']}');
      print('Vault deceased name to add: ${vault.deceasedname}');
      print('Vault applicant name to add: ${vault.applicantname}');

      // Merge vault data with existing contract arrays
      final updatedData = <String, dynamic>{
        // Deceased details - add to existing arrays
        'decFullName': [
          ...(currentData['decFullName'] as List<dynamic>? ?? []),
          ...vault.deceasedname,
        ],
        'dateofdeath': [
          ...(currentData['dateofdeath'] as List<dynamic>? ?? []),
          ...vault.deceaseddateofdeath,
        ],
        'burialinternment': [
          ...(currentData['burialinternment'] as List<dynamic>? ?? []),
          ...vault.deceasedburialinterment,
        ],

        // Applicant details - use form data instead of vault data
        'applicantName': [
          ...(currentData['applicantName'] as List<dynamic>? ?? []),
          applicantName.trim(),
        ],
        'applicantContactNumber': [
          ...(currentData['applicantContactNumber'] as List<dynamic>? ?? []),
          // Convert contact number from string to int (remove leading '0' and convert)
          int.tryParse(applicantContact.replaceFirst('0', '')) ?? 0,
        ],
        'applcantAddress': [
          ...(currentData['applcantAddress'] as List<dynamic>? ?? []),
          applicantAddress.trim(),
        ],

        // Document details
        'OR': orNumber.trim(),
        'TIN': tin.trim(),
        'ResidentCert': residentCert.trim(),
        'proofoflease': proofOfLease ?? '',

        // Update contract status and dates
        'dateadded': DateTime.now(),
        'status': 'occupied',
        'dateEffective': DateTime.now(), // Set effective date to now
      };

      print('Final merged decFullName: ${updatedData['decFullName']}');
      print('Final merged applicantName: ${updatedData['applicantName']}');
      print(
          'Final merged applicantAddress: ${updatedData['applicantAddress']}');
      print(
          'Final merged applicantContactNumber: ${updatedData['applicantContactNumber']}');

      // Update the existing lot contract with merged data
      await lot.reference.update(updatedData);

      print('Lot contract updated successfully');

      // Delete the vault record after successful transfer
      await vault.reference.delete();

      print('Vault record deleted successfully after transfer');

      // Close the verification modal first
      Navigator.of(context).pop();

      // Show success modal
      await showDialog(
        context: context,
        builder: (BuildContext dialogContext) => AlertDialog(
          title: const Text('Success'),
          content: Text('Lot ${lot.location} has been successfully assigned!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                // Refresh the vault list and clear cache
                setState(() {
                  _refreshKey++;
                  _cachedVaultData = null;
                  _cachedNitches = null;
                  _cachedLots = null;
                });
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );

      // Show success popup notification
      print('About to show success popup...');

      print('Simple dialog called');
    } catch (e) {
      print('Error in lot assignment: $e');
      // Show error message modal
      await showDialog(
        context: context,
        builder: (BuildContext dialogContext) => AlertDialog(
          title: const Text('Error'),
          content: Text('Error assigning lot: ${e.toString()}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  // ==================== PDF EXPORT METHODS ====================

  // Method to download vault records as PDF
  void _downloadVaultPDF(List<VaultRecord> allVaultList) async {
    try {
      // Get the filtered vault records based on date range only
      final filteredVaults = allVaultList.where((vault) {
        // Apply date filter based on timestamp
        if (_model.startDate != null || _model.endDate != null) {
          DateTime? vaultDate = vault.timestamp;

          if (vaultDate != null) {
            // Apply start date filter
            if (_model.startDate != null &&
                vaultDate.isBefore(_model.startDate!)) {
              return false;
            }

            // Apply end date filter
            if (_model.endDate != null && vaultDate.isAfter(_model.endDate!)) {
              return false;
            }
          } else {
            // If no valid date found and filters are applied, exclude the vault
            return false;
          }
        }

        return true;
      }).toList();

      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                ),
                SizedBox(width: 16),
                Text(
                  'Generating PDF...',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
          );
        },
      );

      // Generate PDF content
      final pdfContent = _generateVaultPDFContent(filteredVaults);

      // Close loading dialog
      Navigator.of(context).pop();

      // Show success modal
      await showDialog(
        context: context,
        builder: (BuildContext dialogContext) => AlertDialog(
          title: const Text('Success'),
          content: Text(
              'PDF generated successfully! ${filteredVaults.length} vault records exported.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );

      print('PDF Content Generated:');
      print(pdfContent);
    } catch (e) {
      // Close loading dialog if open
      Navigator.of(context).pop();

      print('Error generating PDF: $e');
      await showDialog(
        context: context,
        builder: (BuildContext dialogContext) => AlertDialog(
          title: const Text('Error'),
          content: Text('Error generating PDF: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  // Method to generate PDF content
  String _generateVaultPDFContent(List<VaultRecord> vaults) {
    final buffer = StringBuffer();

    buffer.writeln('VAULT RECORDS REPORT');
    buffer.writeln('Baliwag Public Cemetery');
    buffer.writeln(
        'Generated on: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}');
    buffer.writeln('Total Records: ${vaults.length}');
    buffer.writeln('');
    buffer.writeln('=' * 80);
    buffer.writeln('');

    for (int i = 0; i < vaults.length; i++) {
      final vault = vaults[i];
      buffer.writeln('VAULT RECORD #${i + 1}');
      buffer.writeln('Vault ID: ${vault.reference.id}');

      // Deceased Details - All entries
      buffer.writeln('DECEASED DETAILS:');
      if (vault.deceasedname.isNotEmpty) {
        for (int j = 0; j < vault.deceasedname.length; j++) {
          buffer.writeln('  Name ${j + 1}: ${vault.deceasedname[j]}');
          if (j < vault.deceaseddateofdeath.length) {
            final deathDate = vault.deceaseddateofdeath[j];
            buffer.writeln(
                '  Date of Death ${j + 1}: ${deathDate.day}/${deathDate.month}/${deathDate.year}');
          }
          if (j < vault.deceasedburialinterment.length) {
            final burialDate = vault.deceasedburialinterment[j];
            buffer.writeln(
                '  Burial/Internment ${j + 1}: ${burialDate.day}/${burialDate.month}/${burialDate.year}');
          }
          if (j < vault.deceasedname.length - 1) {
            buffer.writeln('  ---');
          }
        }
      } else {
        buffer.writeln('  No deceased details available');
      }

      // Applicant Details - All entries
      buffer.writeln('APPLICANT DETAILS:');
      if (vault.applicantname.isNotEmpty) {
        for (int j = 0; j < vault.applicantname.length; j++) {
          buffer.writeln('  Name ${j + 1}: ${vault.applicantname[j]}');
          if (j < vault.applicantaddress.length) {
            buffer.writeln('  Address ${j + 1}: ${vault.applicantaddress[j]}');
          }
          if (j < vault.applicantcontactnumber.length) {
            buffer.writeln(
                '  Contact ${j + 1}: 0${vault.applicantcontactnumber[j]}');
          }
          if (j < vault.applicantname.length - 1) {
            buffer.writeln('  ---');
          }
        }
      } else {
        buffer.writeln('  No applicant details available');
      }

      buffer.writeln('Status: ${vault.status}');
      buffer.writeln(
          'Date Added: ${vault.timestamp != null ? '${vault.timestamp!.day}/${vault.timestamp!.month}/${vault.timestamp!.year}' : 'N/A'}');
      buffer.writeln('');
      buffer.writeln('-' * 40);
      buffer.writeln('');
    }

    return buffer.toString();
  }

  // Method to show nitche selection form modal
  void _showContractRenewalModal(
      BuildContext context, VaultRecord vault, ContractRecord contract) {
    final formKey = GlobalKey<FormState>();
    final applicantNameController = TextEditingController();
    final applicantAddressController = TextEditingController();
    final applicantContactController = TextEditingController();
    final relationshipController = TextEditingController();
    final orNumberController = TextEditingController(
      text: FFAppState().qrcode.isNotEmpty
          ? FFAppState().qrcode
          : 'QR-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
    );
    final tinController = TextEditingController();
    final residentCertController = TextEditingController();
    final placeIssuedController = TextEditingController(text: 'Baliwag');
    final dateIssuedController =
        TextEditingController(text: dateTimeFormat("yMMMd", DateTime.now()));
    final amountController = TextEditingController(text: contract.amount);
    final locationController = TextEditingController(text: contract.location);
    final nitcheIdController = TextEditingController(
        text: contract.nitcheidString.isNotEmpty
            ? contract.nitcheidString
            : contract.nitcheid.toString());

    // Financial fields
    final totalYearsController = TextEditingController();
    final totalContractValueController = TextEditingController();

    // Date pickers
    DateTime? dateIssued;
    DateTime? dateOfExpiration;

    // Proof of lease upload
    String? proofOfLeasePath;

    // Multiple deceased entries support
    List<DeceasedEntry> deceasedEntries = [DeceasedEntry()];

    // Capture widget's setState for use after dialogs close
    final widgetSetState = setState;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(
                    Icons.assignment_rounded,
                    color: DashboardTheme.primary,
                    size: 24,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Nitche Selection Form',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ),
                ],
              ),
              content: Container(
                width: 600,
                height: 500,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Selected Nitche Info
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
                                Icons.info_outline,
                                color: Color(0xFF0EA5E9),
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Selected Nitche: ${locationController.text}',
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF0EA5E9),
                                      ),
                                    ),
                                    Text(
                                      'Price: ₱${amountController.text}',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: Color(0xFF0369A1),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),

                        // Applicant Information Section
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Color(0xFFE2E8F0),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.person_rounded,
                                    color: DashboardTheme.primary,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Applicant Information',
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1F2937),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              _buildFormFieldWithListener(
                                'Applicant Name *',
                                applicantNameController,
                                'Enter applicant full name',
                                prefixIcon: Icons.person_rounded,
                                setModalState: setState,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Applicant name is required';
                                  }
                                  if (!RegExp(r'^[a-zA-Z\s]+$')
                                      .hasMatch(value.trim())) {
                                    return 'Name can only contain letters and spaces';
                                  }
                                  if (value.trim().length < 2) {
                                    return 'Name must be at least 2 characters';
                                  }
                                  if (value.trim().length > 50) {
                                    return 'Name must not exceed 50 characters';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 16),
                              _buildFormFieldWithListener(
                                'Applicant Address *',
                                applicantAddressController,
                                'Enter complete address',
                                prefixIcon: Icons.location_on_rounded,
                                maxLines: 2,
                                setModalState: setState,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Address is required';
                                  }
                                  if (!RegExp(r'^[A-Za-z0-9\s.,#\-]+$')
                                      .hasMatch(value.trim())) {
                                    return 'Address contains invalid characters';
                                  }
                                  if (value.trim().length < 5) {
                                    return 'Address must be at least 5 characters';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 16),
                              _buildFormFieldWithListener(
                                'Mobile Contact Number*',
                                applicantContactController,
                                'Enter 11-digit mobile number',
                                prefixIcon: Icons.phone_rounded,
                                keyboardType: TextInputType.phone,
                                setModalState: setState,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Mobile Contact Number is required';
                                  }
                                  if (!RegExp(r'^09\d{9}$').hasMatch(value)) {
                                    return 'Mobile Contact Number must be 11 digits starting with 09';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),

                        // Deceased Information Section
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Color(0xFFFEF7F7),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Color(0xFFFECACA),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.person_outline_rounded,
                                    color: Color(0xFFDC2626),
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Deceased Information (Optional)',
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1F2937),
                                    ),
                                  ),
                                  Spacer(),
                                  TextButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        deceasedEntries.add(DeceasedEntry());
                                      });
                                    },
                                    icon: Icon(
                                      Icons.add_circle_outline_rounded,
                                      color: const Color(0xFF3B82F6),
                                      size: 18,
                                    ),
                                    label: Text(
                                      'Add Another Deceased',
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFF3B82F6),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),

                              // Dynamic deceased entries
                              ...deceasedEntries.asMap().entries.map((entry) {
                                final int index = entry.key;
                                final DeceasedEntry deceasedEntry = entry.value;

                                return Column(
                                  children: [
                                    // Header row with remove button for additional entries
                                    if (index > 0)
                                      Row(
                                        children: [
                                          Text(
                                            'Deceased ${index + 1}',
                                            style: GoogleFonts.inter(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF1F2937),
                                            ),
                                          ),
                                          const Spacer(),
                                          IconButton(
                                            onPressed: () {
                                              setState(() {
                                                final entryToRemove =
                                                    deceasedEntries[index];
                                                deceasedEntries.removeAt(index);
                                                entryToRemove.dispose();
                                              });
                                            },
                                            icon: Icon(
                                              Icons
                                                  .remove_circle_outline_rounded,
                                              color: Color(0xFFEF4444),
                                              size: 20,
                                            ),
                                            tooltip:
                                                'Remove Deceased ${index + 1}',
                                          ),
                                        ],
                                      ),

                                    // Deceased entry fields
                                    _buildFormFieldWithListener(
                                      'Deceased Name',
                                      deceasedEntry.nameController,
                                      'Enter deceased full name (optional)',
                                      prefixIcon: Icons.person_outline_rounded,
                                      setModalState: setState,
                                      validator: (value) {
                                        if (value != null && value.isNotEmpty) {
                                          if (!RegExp(r'^[a-zA-Z\s]+$')
                                              .hasMatch(value.trim())) {
                                            return 'Name can only contain letters and spaces';
                                          }
                                          if (value.trim().length < 2) {
                                            return 'Name must be at least 2 characters';
                                          }
                                          if (value.trim().length > 50) {
                                            return 'Name must not exceed 50 characters';
                                          }
                                        }
                                        return null;
                                      },
                                    ),
                                    SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildDateField(
                                            label: 'Date of Death',
                                            hintText:
                                                'Select date of death (optional)',
                                            selectedDate:
                                                deceasedEntry.deathDate,
                                            onDateSelected: (picked) {
                                              setState(() {
                                                deceasedEntry.deathDate =
                                                    picked;
                                              });
                                            },
                                            firstDate: DateTime(1900),
                                            lastDate: DateTime.now(),
                                            prefixIcon: Icons.event_rounded,
                                          ),
                                        ),
                                        SizedBox(width: 16),
                                        Expanded(
                                          child: _buildDateField(
                                            label: 'Date of Burial',
                                            hintText:
                                                'Select date of burial (optional)',
                                            selectedDate:
                                                deceasedEntry.burialDate,
                                            onDateSelected: (picked) {
                                              setState(() {
                                                deceasedEntry.burialDate =
                                                    picked;
                                              });
                                            },
                                            firstDate: DateTime.now(),
                                            lastDate: DateTime(2100),
                                            prefixIcon: Icons.event_rounded,
                                          ),
                                        ),
                                      ],
                                    ),
                                    // Spacing between entries
                                    if (index < deceasedEntries.length - 1)
                                      const SizedBox(height: 24),
                                  ],
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),

                        // Financial Details Section
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Color(0xFFF0FDF4),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Color(0xFFBBF7D0),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.account_balance_wallet_rounded,
                                    color: Color(0xFF059669),
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Financial Details',
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1F2937),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildFormFieldWithListener(
                                      'Initial Contract Fee (₱)',
                                      amountController,
                                      'Set the initial fee amount',
                                      prefixIcon:
                                          Icons.account_balance_wallet_rounded,
                                      keyboardType: TextInputType.number,
                                      setModalState: setState,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Amount is required';
                                        }
                                        if (double.tryParse(value) == null) {
                                          return 'Amount must be a valid number';
                                        }
                                        if (double.parse(value) <= 0) {
                                          return 'Amount must be greater than 0';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: _buildFormFieldWithListener(
                                      'Contract Duration (Years)',
                                      totalYearsController,
                                      'Auto-calculated',
                                      prefixIcon: Icons.schedule_rounded,
                                      readOnly: true,
                                      setModalState: setState,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              _buildFormFieldWithListener(
                                'Total Contract Value (₱)',
                                totalContractValueController,
                                'Auto-calculated: (Duration × Initial Fee) - Initial Fee',
                                prefixIcon:
                                    Icons.account_balance_wallet_rounded,
                                readOnly: true,
                                setModalState: setState,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),

                        // Document Details Section
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Color(0xFFF0F9FF),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Color(0xFFBAE6FD),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.description_rounded,
                                    color: Color(0xFF0EA5E9),
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Document Details',
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1F2937),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildFormFieldWithListener(
                                      'OR Number',
                                      orNumberController,
                                      'Enter official receipt number',
                                      prefixIcon: Icons.receipt_rounded,
                                      enabled: false,
                                      setModalState: setState,
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: _buildFormFieldWithListener(
                                      'TIN',
                                      tinController,
                                      'Enter TIN in format: xxx - xxx - xxx - xxx',
                                      prefixIcon: Icons.badge_rounded,
                                      setModalState: setState,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'TIN number is required';
                                        }
                                        if (!RegExp(
                                                r'^\d{3}\s*-\s*\d{3}\s*-\s*\d{3}\s*-\s*\d{3}$')
                                            .hasMatch(value.trim())) {
                                          return 'TIN Number must be in format: xxx - xxx - xxx - xxx';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              _buildFormFieldWithListener(
                                'Resident Certificate ( Community Tax Certificate / Sedula )',
                                residentCertController,
                                'Enter resident certificate number',
                                prefixIcon: Icons.verified_user_rounded,
                                setModalState: setState,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Resident Certificate is required';
                                  }
                                  if (!RegExp(r'^\d{8,11}$')
                                      .hasMatch(value.trim())) {
                                    return 'Resident Certificate must be 8-11 digits';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 16),
                              _buildFileUploadField(
                                labelText: 'Proof of Lease*',
                                hintText: 'Upload lease document',
                                onUpload: () async {
                                  try {
                                    // Show loading modal
                                    _showLoadingDialog('Selecting file...');

                                    // Select file using file picker
                                    final selectedFile = await selectFile(
                                      storageFolderPath: 'proof_of_lease',
                                      allowedExtensions: [
                                        'pdf',
                                        'doc',
                                        'docx',
                                        'jpg',
                                        'jpeg',
                                        'png'
                                      ],
                                    );

                                    if (selectedFile != null) {
                                      // Switch to verification loading modal
                                      if (Navigator.of(context).canPop()) {
                                        Navigator.of(context).pop();
                                      }
                                      _showLoadingDialog(
                                          'Verifying document authenticity...');

                                      // Get file name from storage path and determine MIME type
                                      final fileName = selectedFile.storagePath
                                          .split('/')
                                          .last;
                                      final mimeType =
                                          _getMimeTypeFromFileName(fileName);

                                      // Verify document authenticity
                                      final verificationResult =
                                          await DocumentVerificationService
                                              .verifyDocument(
                                        documentBytes: selectedFile.bytes,
                                        fileName: fileName,
                                        mimeType: mimeType,
                                      );

                                      // Show verification results
                                      if (!verificationResult.isValid) {
                                        // Always close loading dialog first
                                        if (Navigator.of(context).canPop()) {
                                          Navigator.of(context).pop();
                                        }
                                        await _showVerificationDialog(
                                            verificationResult, selectedFile,
                                            onUploadComplete: (downloadUrl) {
                                          setState(() {
                                            proofOfLeasePath = downloadUrl;
                                          });
                                        });
                                        return;
                                      }

                                      // Switch to upload loading modal
                                      if (Navigator.of(context).canPop()) {
                                        Navigator.of(context).pop();
                                      }
                                      _showLoadingDialog(
                                          'Uploading verified file to storage...');

                                      // Actually upload the file to Firebase Storage
                                      final downloadUrl = await uploadData(
                                          selectedFile.storagePath,
                                          selectedFile.bytes);

                                      if (downloadUrl != null) {
                                        setState(() {
                                          proofOfLeasePath = downloadUrl;
                                        });

                                        // Close loading and show success modal
                                        if (Navigator.of(context).canPop()) {
                                          Navigator.of(context).pop();
                                        }
                                        await _showMessageDialog(
                                          'Upload Complete',
                                          'Proof of lease verified and uploaded successfully.\nConfidence: ${(verificationResult.confidence * 100).toStringAsFixed(0)}%',
                                        );
                                      } else {
                                        // Upload failed
                                        if (Navigator.of(context).canPop()) {
                                          Navigator.of(context).pop();
                                        }
                                        await _showMessageDialog(
                                          'Upload Failed',
                                          'Failed to upload file to storage.',
                                        );
                                      }
                                    } else {
                                      // Close loading if open
                                      if (Navigator.of(context).canPop()) {
                                        Navigator.of(context).pop();
                                      }
                                    }
                                  } catch (e) {
                                    // Close loading and show error modal
                                    if (Navigator.of(context).canPop()) {
                                      Navigator.of(context).pop();
                                    }
                                    await _showMessageDialog(
                                        'Error', 'Error uploading file: $e');
                                  }
                                },
                                uploadedFile: proofOfLeasePath,
                                onRemove: () async {
                                  setState(() {
                                    proofOfLeasePath = null;
                                  });

                                  await showDialog(
                                    context: context,
                                    builder: (BuildContext dialogContext) =>
                                        AlertDialog(
                                      title: const Text('Notice'),
                                      content:
                                          const Text('Proof of lease removed!'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                          child: const Text('OK'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildFormFieldWithListener(
                                      'Place Issued',
                                      placeIssuedController,
                                      'Enter place where certificate was issued',
                                      prefixIcon: Icons.location_city_rounded,
                                      setModalState: setState,
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: _buildFormFieldWithListener(
                                      'Date Issued',
                                      dateIssuedController,
                                      'Select date issued',
                                      prefixIcon: Icons.calendar_today_rounded,
                                      readOnly: true,
                                      setModalState: setState,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Date of Expiration',
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFF374151),
                                          ),
                                        ),
                                      ),
                                      if (dateOfExpiration != null)
                                        Icon(
                                          Icons.check_circle_rounded,
                                          color: Colors.green,
                                          size: 18,
                                        ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  InkWell(
                                    onTap: () async {
                                      final DateTime? picked =
                                          await showDatePicker(
                                        context: context,
                                        initialDate: dateOfExpiration ??
                                            DateTime.now()
                                                .add(Duration(days: 365 * 5)),
                                        firstDate: DateTime.now().add(Duration(
                                            days: 365 * 5)), // 5 years from now
                                        lastDate: DateTime(2100),
                                        builder: (context, child) {
                                          return Theme(
                                            data: Theme.of(context).copyWith(
                                              colorScheme: ColorScheme.light(
                                                primary: DashboardTheme.primary,
                                                onPrimary: Colors.white,
                                                surface: Colors.white,
                                                onSurface: Color(0xFF1F2937),
                                              ),
                                            ),
                                            child: child!,
                                          );
                                        },
                                      );
                                      if (picked != null) {
                                        setState(() {
                                          dateOfExpiration = picked;
                                          _updateFinancialCalculations(
                                            dateOfExpiration,
                                            amountController,
                                            totalYearsController,
                                            totalContractValueController,
                                          );
                                        });
                                      }
                                    },
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: dateOfExpiration != null
                                              ? Colors.transparent
                                              : Color(0xFFE5E7EB),
                                          width:
                                              dateOfExpiration != null ? 0 : 1,
                                        ),
                                      ),
                                      child: TextFormField(
                                        readOnly: true,
                                        enabled: false,
                                        decoration: InputDecoration(
                                          hintText:
                                              'Select contract expiration date',
                                          hintStyle: TextStyle(
                                            color: Color(0xFF9CA3AF),
                                            fontSize: 14,
                                          ),
                                          prefixIcon: Icon(
                                              Icons.event_available_rounded,
                                              size: 20),
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.all(16),
                                          disabledBorder: InputBorder.none,
                                          enabledBorder: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                        ),
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          color: Color(0xFF1F2937),
                                        ),
                                        controller: TextEditingController(
                                          text: dateOfExpiration != null
                                              ? dateTimeFormat(
                                                  "yMMMd", dateOfExpiration)
                                              : '',
                                        ),
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
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    applicantNameController.dispose();
                    applicantAddressController.dispose();
                    applicantContactController.dispose();
                    relationshipController.dispose();
                    orNumberController.dispose();
                    tinController.dispose();
                    residentCertController.dispose();
                    placeIssuedController.dispose();
                    dateIssuedController.dispose();
                    amountController.dispose();
                    totalYearsController.dispose();
                    totalContractValueController.dispose();
                    locationController.dispose();
                    nitcheIdController.dispose();
                    // Dispose deceased entries
                    for (final entry in deceasedEntries) {
                      entry.dispose();
                    }
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.inter(
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      // Step 1: Check for null/empty required fields
                      final emptyFields = _validateRequiredFields(
                        applicantNameController,
                        applicantAddressController,
                        applicantContactController,
                        amountController,
                        tinController,
                        residentCertController,
                        proofOfLeasePath,
                      );
                      if (emptyFields.isNotEmpty) {
                        _showValidationErrorDialog(emptyFields);
                        return;
                      }

                      // Step 2: Check all field formats before proceeding
                      final formatErrors = await _validateAllFieldFormats(
                        applicantNameController,
                        applicantAddressController,
                        applicantContactController,
                        amountController,
                        tinController,
                        residentCertController,
                        deceasedEntries,
                      );
                      if (formatErrors.isNotEmpty) {
                        _showFormatErrorDialog(formatErrors);
                        return;
                      }

                      // Step 2.5: Validate contact number uniqueness
                      final isContactUnique =
                          await _validateContactNumberUniquenessForNitche(
                        applicantNameController,
                        applicantContactController,
                      );
                      if (!isContactUnique) {
                        print('Contact number uniqueness validation failed!');
                        return; // Stop submission if contact number is not unique
                      }

                      // Step 3: All validations passed - Show confirmation dialog
                      final bool? confirmed = await showDialog<bool>(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Confirm Nitche Assignment',
                                style: GoogleFonts.inter(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1F2937))),
                            content: Text(
                                'Are you sure you want to assign Nitche ${locationController.text} to the vault record?',
                                style: GoogleFonts.inter(
                                    fontSize: 14, color: Color(0xFF6B7280))),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: Text('Cancel',
                                    style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF6B7280))),
                              ),
                              ElevatedButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: DashboardTheme.primary,
                                    foregroundColor: Colors.white),
                                child: Text('Confirm',
                                    style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600)),
                              ),
                            ],
                          );
                        },
                      );

                      if (confirmed == true) {
                        // Show loading indicator
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              content: Row(
                                children: [
                                  CircularProgressIndicator(),
                                  SizedBox(width: 16),
                                  Text('Processing nitche assignment...'),
                                ],
                              ),
                            );
                          },
                        );

                        try {
                          // Get the contract document reference
                          final contractRef = contract.reference;

                          // Generate new contract ID using database sync
                          final newContractId =
                              await FFAppState().getNextAvailableContractId();

                          // Get current contract data to merge with vault data
                          final currentContract =
                              await contract.reference.get();
                          final currentData =
                              currentContract.data() as Map<String, dynamic>;

                          // Merge vault data with form data and existing contract arrays
                          final updatedData = <String, dynamic>{
                            // Deceased details - add to existing arrays
                            'decFullName': [
                              ...(currentData['decFullName']
                                      as List<dynamic>? ??
                                  []),
                              ...vault.deceasedname,
                              // Add new deceased names from form
                              ...deceasedEntries
                                  .map((entry) => entry.nameController.text)
                                  .where((name) => name.isNotEmpty),
                            ],
                            'dateofdeath': [
                              ...(currentData['dateofdeath']
                                      as List<dynamic>? ??
                                  []),
                              ...vault.deceaseddateofdeath,
                              // Add new death dates from form
                              ...deceasedEntries
                                  .where((entry) => entry.deathDate != null)
                                  .map((entry) => entry.deathDate!),
                            ],
                            'burialinternment': [
                              ...(currentData['burialinternment']
                                      as List<dynamic>? ??
                                  []),
                              ...vault.deceasedburialinterment,
                              // Add new burial dates from form
                              ...deceasedEntries
                                  .where((entry) => entry.burialDate != null)
                                  .map((entry) => entry.burialDate!),
                            ],

                            // Applicant details - add to existing arrays
                            'applicantName': [
                              ...(currentData['applicantName']
                                      as List<dynamic>? ??
                                  []),
                              ...vault.applicantname,
                              applicantNameController.text,
                            ],
                            'applicantContactNumber': [
                              ...(currentData['applicantContactNumber']
                                      as List<dynamic>? ??
                                  []),
                              ...vault.applicantcontactnumber,
                              int.tryParse(applicantContactController.text),
                            ],
                            'applcantAddress': [
                              ...(currentData['applcantAddress']
                                      as List<dynamic>? ??
                                  []),
                              ...vault.applicantaddress,
                              applicantAddressController.text,
                            ],

                            // Update contract with form data
                            ...createContractRecordData(
                              tombLocation: locationController.text,
                              amount: amountController.text,
                              or: orNumberController.text,
                              tin: tinController.text,
                              residentCert: residentCertController.text,
                              placeIssued: placeIssuedController.text,
                              dateIssued: dateIssued ?? DateTime.now(),
                              proofoflease: proofOfLeasePath ??
                                  '', // Image Path - proof of lease file path
                              location: locationController.text,
                              contractID: newContractId,
                              contractidString: newContractId.toString(),
                              type: 'nitche',
                              leessee: null,
                              dateEffective: DateTime.now(),
                              status: 'occupied',
                              dateofexpiration: dateOfExpiration ??
                                  DateTime.now().add(Duration(days: 365 * 5)),
                              contractstatus: 'active',
                              initialfee:
                                  double.tryParse(amountController.text),
                              balance: int.tryParse(
                                  totalContractValueController.text),
                              totalContraBalance: double.tryParse(
                                  totalContractValueController.text),
                              nitcheid: contract.nitcheid,
                              nitcheidString: contract.nitcheidString,
                            ),
                            ...mapToFirestore({
                              'latestAddress': applicantAddressController.text,
                              'latestContNum': newContractId,
                              if (deceasedEntries.isNotEmpty &&
                                  deceasedEntries
                                      .first.nameController.text.isNotEmpty)
                                'latestDeceased':
                                    deceasedEntries.first.nameController.text,
                            }),

                            // Update contract status and dates
                            'dateadded': DateTime.now(),
                            'dateEffective': DateTime.now(),
                          };

                          // Update the existing nitche contract with merged data
                          await contractRef.update(updatedData);

                          // Delete the vault record after successful transfer
                          await vault.reference.delete();

                          // Close loading dialog
                          Navigator.of(context).pop();

                          // Close form dialog
                          Navigator.of(context).pop();

                          // Show success modal
                          await showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext dialogContext) =>
                                AlertDialog(
                              title: const Text('Success'),
                              content: Text(
                                  'Nitche ${locationController.text} has been successfully assigned!'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(dialogContext).pop(true);
                                  },
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );

                          // Refresh the vault list after dialog is closed and clear cache
                          if (mounted) {
                            widgetSetState(() {
                              _refreshKey++;
                              _cachedVaultData = null;
                              _cachedNitches = null;
                              _cachedLots = null;
                            });
                          }

                          // Dispose controllers
                          applicantNameController.dispose();
                          applicantAddressController.dispose();
                          applicantContactController.dispose();
                          relationshipController.dispose();
                          orNumberController.dispose();
                          tinController.dispose();
                          residentCertController.dispose();
                          placeIssuedController.dispose();
                          dateIssuedController.dispose();
                          amountController.dispose();
                          totalYearsController.dispose();
                          totalContractValueController.dispose();
                          locationController.dispose();
                          // Dispose deceased entries
                          for (final entry in deceasedEntries) {
                            entry.dispose();
                          }
                          nitcheIdController.dispose();
                        } catch (e) {
                          // Close loading dialog
                          Navigator.of(context).pop();

                          // Show error modal
                          await showDialog(
                            context: context,
                            builder: (BuildContext dialogContext) =>
                                AlertDialog(
                              title: const Text('Error'),
                              content: const Text(
                                  'Error processing nitche assignment. Please try again.'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(dialogContext).pop(),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                        }
                      } else {
                        // User cancelled the confirmation
                        print('Nitche assignment cancelled by user');
                      }
                    } else {
                      // Form validation failed (modal)
                      await showDialog(
                        context: context,
                        builder: (_) => const AlertDialog(
                          title: Text('Validation Error'),
                          content: Text(
                              'Please fill in all required fields correctly.'),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DashboardTheme.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Assign Nitche',
                    style: GoogleFonts.inter(
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

  // ==================== FINANCIAL CALCULATION METHODS ====================

  // Helper method to calculate financial values
  void _updateFinancialCalculations(
    DateTime? dateOfExpiration,
    TextEditingController amountController,
    TextEditingController totalYearsController,
    TextEditingController totalContractValueController,
  ) {
    if (dateOfExpiration != null) {
      final int currentYear = DateTime.now().year;
      final int expirationYear = dateOfExpiration.year;
      final int duration = expirationYear - currentYear;

      if (duration > 0) {
        totalYearsController.text = duration.toString();

        // Calculate total contract value: (duration × initial fee) - initial fee
        final double initialFee = double.tryParse(amountController.text) ?? 0.0;
        final double totalContractValue = (duration * initialFee) - initialFee;

        totalContractValueController.text = totalContractValue.toString();
      }
    }
  }

  // Helper method to build date fields with date picker
  Widget _buildDateField({
    required String label,
    required String hintText,
    required DateTime? selectedDate,
    required Function(DateTime) onDateSelected,
    DateTime? firstDate,
    DateTime? lastDate,
    IconData? prefixIcon,
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
        InkWell(
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: selectedDate ?? DateTime.now(),
              firstDate: firstDate ?? DateTime(1900),
              lastDate: lastDate ?? DateTime(2100),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: DashboardTheme.primary,
                      onPrimary: Colors.white,
                      surface: Colors.white,
                      onSurface: Color(0xFF1F2937),
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null) {
              onDateSelected(picked);
            }
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Color(0xFFE5E7EB),
                width: 1,
              ),
            ),
            child: TextFormField(
              readOnly: true,
              enabled: false,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 14,
                ),
                prefixIcon:
                    prefixIcon != null ? Icon(prefixIcon, size: 20) : null,
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(16),
                disabledBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Color(0xFF1F2937),
              ),
              controller: TextEditingController(
                text: selectedDate != null
                    ? dateTimeFormat("yMMMd", selectedDate)
                    : '',
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Validate required fields are not null/empty
  List<String> _validateRequiredFields(
    TextEditingController applicantNameController,
    TextEditingController applicantAddressController,
    TextEditingController applicantContactController,
    TextEditingController amountController,
    TextEditingController tinController,
    TextEditingController residentCertController,
    String? proofOfLeasePath,
  ) {
    final List<String> emptyFields = [];

    // Check applicant information
    if (applicantNameController.text.trim().isEmpty) {
      emptyFields.add('Applicant Name');
    }
    if (applicantAddressController.text.trim().isEmpty) {
      emptyFields.add('Applicant Address');
    }
    if (applicantContactController.text.trim().isEmpty) {
      emptyFields.add('Mobile Contact Number');
    }

    // Check contract terms
    if (amountController.text.trim().isEmpty) {
      emptyFields.add('Initial Contract Fee');
    }

    // Check document details
    if (tinController.text.trim().isEmpty) {
      emptyFields.add('TIN Number');
    }
    if (residentCertController.text.trim().isEmpty) {
      emptyFields.add('Resident Certificate');
    }
    if (proofOfLeasePath == null || proofOfLeasePath.trim().isEmpty) {
      emptyFields.add('Proof of Lease');
    }

    return emptyFields;
  }

  // Show validation error dialog for empty fields
  void _showValidationErrorDialog(List<String> emptyFields) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFF59E0B),
                size: 24,
              ),
              SizedBox(width: 12),
              Text(
                'Required Fields Missing',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
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
                Text(
                  'Please fill in the following required fields:',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 16),
                ...emptyFields
                    .map((field) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.circle,
                                size: 6,
                                color: Color(0xFFF59E0B),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  field,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: Color(0xFF374151),
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
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFF59E0B),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'OK',
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

  // Validate all field formats in nitche selection form
  Future<List<String>> _validateAllFieldFormats(
    TextEditingController applicantNameController,
    TextEditingController applicantAddressController,
    TextEditingController applicantContactController,
    TextEditingController amountController,
    TextEditingController tinController,
    TextEditingController residentCertController,
    List<DeceasedEntry> deceasedEntries,
  ) async {
    final List<String> formatErrors = [];

    // Check applicant name format
    final applicantName = applicantNameController.text.trim();
    if (applicantName.isNotEmpty) {
      if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(applicantName)) {
        formatErrors.add('Applicant Name can only contain letters and spaces');
      }
      if (applicantName.length < 2) {
        formatErrors.add('Applicant Name must be at least 2 characters');
      }
      if (applicantName.length > 50) {
        formatErrors.add('Applicant Name must not exceed 50 characters');
      }
    }

    // Check applicant address format
    final applicantAddress = applicantAddressController.text.trim();
    if (applicantAddress.isNotEmpty) {
      if (!RegExp(r'^[A-Za-z0-9\s.,#\-]+$').hasMatch(applicantAddress)) {
        formatErrors.add('Applicant Address contains invalid characters');
      }
      if (applicantAddress.length < 5) {
        formatErrors.add('Applicant Address must be at least 5 characters');
      }
    }

    // Check contact number format
    final contactNumber = applicantContactController.text.trim();
    if (contactNumber.isNotEmpty) {
      if (!RegExp(r'^09\d{9}$').hasMatch(contactNumber)) {
        formatErrors
            .add('Mobile Contact Number must be 11 digits starting with 09');
      }
    }

    // Check deceased names format
    for (int i = 0; i < deceasedEntries.length; i++) {
      final deceasedName = deceasedEntries[i].nameController.text.trim();
      if (deceasedName.isNotEmpty) {
        if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(deceasedName)) {
          formatErrors.add(
              'Deceased Name ${i + 1} can only contain letters and spaces');
        }
        if (deceasedName.length < 2) {
          formatErrors
              .add('Deceased Name ${i + 1} must be at least 2 characters');
        }
        if (deceasedName.length > 50) {
          formatErrors
              .add('Deceased Name ${i + 1} must not exceed 50 characters');
        }
      }
    }

    // Check amount format
    final amount = amountController.text.trim();
    if (amount.isNotEmpty) {
      if (double.tryParse(amount) == null) {
        formatErrors.add('Initial Contract Fee must be a valid number');
      } else if (double.parse(amount) <= 0) {
        formatErrors.add('Initial Contract Fee must be greater than 0');
      }
    }

    // Check TIN format
    final tin = tinController.text.trim();
    if (tin.isNotEmpty) {
      if (!RegExp(r'^\d{3}\s*-\s*\d{3}\s*-\s*\d{3}\s*-\s*\d{3}$')
          .hasMatch(tin)) {
        formatErrors.add('TIN Number must be in format: xxx - xxx - xxx - xxx');
      }
    }

    // Check resident certificate format
    final residentCert = residentCertController.text.trim();
    if (residentCert.isNotEmpty) {
      if (!RegExp(r'^\d{8,11}$').hasMatch(residentCert)) {
        formatErrors.add('Resident Certificate must be 8-11 digits');
      }
    }

    return formatErrors;
  }

  // Validate contact number uniqueness across different applicants in nitche selection
  Future<bool> _validateContactNumberUniquenessForNitche(
    TextEditingController applicantNameController,
    TextEditingController applicantContactController,
  ) async {
    final contactNumber = applicantContactController.text.trim();
    final applicantName = applicantNameController.text.trim();

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
                    title: Row(
                      children: [
                        Icon(
                          Icons.warning_rounded,
                          color: Color(0xFFEF4444),
                          size: 24,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Contact Number Already Used',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                      ],
                    ),
                    content: Text(
                      'This contact number ($contactNumber) is already registered to a different applicant: "${name}".\n\nPlease use a different contact number or verify the applicant name.',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
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
                            color: DashboardTheme.primary,
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

  // Show format error dialog
  void _showFormatErrorDialog(List<String> formatErrors) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.error_outline_rounded,
                color: Color(0xFFEF4444),
                size: 24,
              ),
              SizedBox(width: 12),
              Text(
                'Format Validation Errors',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
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
                Text(
                  'Please correct the following format errors:',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 16),
                ...formatErrors
                    .map((error) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.circle,
                                size: 6,
                                color: Color(0xFFEF4444),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  error,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: Color(0xFF374151),
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
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFEF4444),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'OK',
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

  // Helper method to build form fields with listener
  Widget _buildFormFieldWithListener(
    String label,
    TextEditingController controller,
    String hintText, {
    TextInputType? keyboardType,
    IconData? prefixIcon,
    int? maxLines,
    String? Function(String?)? validator,
    bool readOnly = false,
    bool enabled = true,
    StateSetter? setModalState,
  }) {
    final hasValue = controller.text.isNotEmpty;
    final isFormatCorrect =
        hasValue && (validator == null || validator(controller.text) == null);
    final validationError =
        hasValue && validator != null ? validator(controller.text) : null;

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
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF374151),
                ),
              ),
            ),
            if (isFormatCorrect)
              Icon(
                Icons.check_circle_rounded,
                color: Colors.green,
                size: 18,
              ),
          ],
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: validationError != null
                  ? const Color(0xFFEF4444)
                  : isFormatCorrect
                      ? Colors.transparent
                      : Color(0xFFE5E7EB),
              width: isFormatCorrect ? 0 : 1,
            ),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            readOnly: readOnly,
            enabled: enabled,
            onChanged: (value) {
              // Trigger validation on every keystroke
              if (setModalState != null) {
                setModalState(() {}); // Rebuild modal to show validation errors
              }
            },
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 14,
              ),
              prefixIcon:
                  prefixIcon != null ? Icon(prefixIcon, size: 20) : null,
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Color(0xFF1F2937),
            ),
          ),
        ),
        // Real-time validation error display
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
      ],
    );
  }

  // Helper method to build file upload field
  Widget _buildFileUploadField({
    required String labelText,
    required String hintText,
    required VoidCallback onUpload,
    String? uploadedFile,
    required VoidCallback onRemove,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF374151),
          ),
        ),
        SizedBox(height: 8),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Color(0xFFE5E7EB),
              width: 1,
            ),
          ),
          child: uploadedFile != null
              ? Row(
                  children: [
                    SizedBox(width: 12),
                    Icon(
                      Icons.attach_file_rounded,
                      color: Color(0xFF1E40AF),
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        uploadedFile.split('/').last,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Color(0xFF1F2937),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      onPressed: onRemove,
                      icon: Icon(
                        Icons.delete_rounded,
                        color: Colors.red.shade600,
                        size: 20,
                      ),
                    ),
                  ],
                )
              : InkWell(
                  onTap: onUpload,
                  borderRadius: BorderRadius.circular(8),
                  child: Row(
                    children: [
                      SizedBox(width: 12),
                      Icon(
                        Icons.upload_file_rounded,
                        color: Color(0xFF6B7280),
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        hintText,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  // ==================== DATABASE QUERY METHODS ====================

  // Method to get available nitches (dateofexpiration is null)
  Future<List<ContractRecord>> _getAvailableNitches() async {
    try {
      // Query: dateofexpiration is null
      final availableQuery = queryContractRecord(
        queryBuilder: (query) => query
            .where('type', isEqualTo: 'nitche')
            .where('dateofexpiration', isNull: true)
            .limit(50), // Limit results for better performance
      );

      // Execute query
      final availableResults = await availableQuery.first;

      return availableResults;
    } catch (e) {
      print('Error loading nitches: $e');
      return [];
    }
  }

  // Method to get active lot contracts only
  Future<List<ContractRecord>> _getAvailableLots() async {
    try {
      // Query all lot contracts
      final allLotsQuery = queryContractRecord(
        queryBuilder: (query) => query
            .where('type', isEqualTo: 'Lot')
            .limit(100), // Limit results for better performance
      );

      final allLots = await allLotsQuery.first;

      // Filter for active contracts only (future expiration dates)
      final activeLots = allLots.where((lot) {
        // Only show lots with active contracts (future expiration dates)
        if (lot.dateofexpiration != null &&
            lot.dateofexpiration!.isAfter(DateTime.now())) {
          return true;
        }

        return false;
      }).toList();

      return activeLots;
    } catch (e) {
      print('Error loading lots: $e');
      return [];
    }
  }

  // Validation methods for Lot Assignment Verification modal
  // Validate required fields are not null/empty
  List<String> _validateRequiredFieldsLotAssignment(
    TextEditingController applicantNameController,
    TextEditingController applicantAddressController,
    TextEditingController applicantContactController,
    TextEditingController orNumberController,
    TextEditingController tinController,
    TextEditingController residentCertController,
    String? proofOfLeasePath,
  ) {
    final List<String> emptyFields = [];

    // Check applicant information
    if (applicantNameController.text.trim().isEmpty) {
      emptyFields.add('Applicant Name');
    }
    if (applicantAddressController.text.trim().isEmpty) {
      emptyFields.add('Applicant Address');
    }
    if (applicantContactController.text.trim().isEmpty) {
      emptyFields.add('Mobile Contact Number');
    }

    // Check document details
    if (orNumberController.text.trim().isEmpty) {
      emptyFields.add('OR Number');
    }
    if (tinController.text.trim().isEmpty) {
      emptyFields.add('TIN Number');
    }
    if (residentCertController.text.trim().isEmpty) {
      emptyFields.add('Resident Certificate');
    }
    if (proofOfLeasePath == null || proofOfLeasePath.trim().isEmpty) {
      emptyFields.add('Proof of Lease');
    }

    return emptyFields;
  }

  // Validate all field formats in lot assignment form
  Future<List<String>> _validateAllFieldFormatsLotAssignment(
    TextEditingController applicantNameController,
    TextEditingController applicantAddressController,
    TextEditingController applicantContactController,
    TextEditingController tinController,
    TextEditingController residentCertController,
  ) async {
    final List<String> formatErrors = [];

    // Check applicant name format
    final applicantName = applicantNameController.text.trim();
    if (applicantName.isNotEmpty) {
      if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(applicantName)) {
        formatErrors.add('Applicant Name can only contain letters and spaces');
      }
      if (applicantName.length < 2) {
        formatErrors.add('Applicant Name must be at least 2 characters');
      }
      if (applicantName.length > 50) {
        formatErrors.add('Applicant Name must not exceed 50 characters');
      }
    }

    // Check applicant address format
    final applicantAddress = applicantAddressController.text.trim();
    if (applicantAddress.isNotEmpty) {
      if (!RegExp(r'^[A-Za-z0-9\s.,#\-]+$').hasMatch(applicantAddress)) {
        formatErrors.add('Applicant Address contains invalid characters');
      }
      if (applicantAddress.length < 5) {
        formatErrors.add('Applicant Address must be at least 5 characters');
      }
    }

    // Check contact number format
    final contactNumber = applicantContactController.text.trim();
    if (contactNumber.isNotEmpty) {
      if (!RegExp(r'^09\d{9}$').hasMatch(contactNumber)) {
        formatErrors
            .add('Mobile Contact Number must be 11 digits starting with 09');
      }
    }

    // Check TIN format
    final tin = tinController.text.trim();
    if (tin.isNotEmpty) {
      if (!RegExp(r'^\d{3}\s*-\s*\d{3}\s*-\s*\d{3}\s*-\s*\d{3}$')
          .hasMatch(tin)) {
        formatErrors.add('TIN Number must be in format: xxx - xxx - xxx - xxx');
      }
    }

    // Check resident certificate format
    final residentCert = residentCertController.text.trim();
    if (residentCert.isNotEmpty) {
      if (!RegExp(r'^\d{8,11}$').hasMatch(residentCert)) {
        formatErrors.add('Resident Certificate must be 8-11 digits');
      }
    }

    return formatErrors;
  }

  // Validate contact number uniqueness across different applicants for lot assignment
  Future<bool> _validateContactNumberUniquenessForLot(
    TextEditingController applicantNameController,
    TextEditingController applicantContactController,
  ) async {
    final contactNumber = applicantContactController.text.trim();
    final applicantName = applicantNameController.text.trim();

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
                    title: Row(
                      children: [
                        Icon(
                          Icons.warning_rounded,
                          color: Color(0xFFEF4444),
                          size: 24,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Contact Number Already Used',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                      ],
                    ),
                    content: Text(
                      'This contact number ($contactNumber) is already registered to a different applicant: "${name}".\n\nPlease use a different contact number or verify the applicant name.',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
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
                            color: DashboardTheme.primary,
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

  // Show empty fields dialog for lot assignment
  void _showEmptyFieldsDialogLotAssignment(List<String> emptyFields) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFF59E0B),
                size: 24,
              ),
              SizedBox(width: 12),
              Text(
                'Required Fields Missing',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
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
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
              ),
              SizedBox(height: 12),
              ...emptyFields
                  .map((field) => Padding(
                        padding: EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Icon(
                              Icons.circle,
                              size: 6,
                              color: Color(0xFFEF4444),
                            ),
                            SizedBox(width: 8),
                            Text(
                              field,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'OK',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Show format error dialog for lot assignment
  void _showFormatErrorDialogLotAssignment(List<String> formatErrors) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.error_outline_rounded,
                color: Color(0xFFEF4444),
                size: 24,
              ),
              SizedBox(width: 12),
              Text(
                'Format Validation Errors',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
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
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
              ),
              SizedBox(height: 12),
              ...formatErrors
                  .map((error) => Padding(
                        padding: EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.circle,
                              size: 6,
                              color: Color(0xFFEF4444),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                error,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: Color(0xFF1F2937),
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
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'OK',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Show verification dialog for invalid documents
  Future<void> _showVerificationDialog(
    DocumentVerificationResult result,
    dynamic selectedFile, {
    Function(String)? onUploadComplete,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.orange),
              SizedBox(width: 8),
              Text('Document Verification Failed'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'The uploaded document could not be verified as a legitimate lease document.',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 16),
                Text(
                  'Confidence Score: ${(result.confidence * 100).toStringAsFixed(0)}%',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 8),
                Text(
                  'Issues Detected:',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 8),
                ...result.detectedIssues.map((issue) => Padding(
                      padding: EdgeInsets.only(left: 16, bottom: 4),
                      child: Row(
                        children: [
                          Icon(Icons.close, size: 16, color: Colors.red),
                          SizedBox(width: 8),
                          Expanded(
                              child: Text(issue, style: GoogleFonts.inter())),
                        ],
                      ),
                    )),
                if (result.extractedText.isNotEmpty) ...[
                  SizedBox(height: 16),
                  Text(
                    'Extracted Text Preview:',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      result.extractedText.length > 200
                          ? '${result.extractedText.substring(0, 200)}...'
                          : result.extractedText,
                      style: GoogleFonts.inter(fontSize: 12),
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel Upload'),
            ),
          ],
        );
      },
    );
  }

  // Get MIME type from file name
  String _getMimeTypeFromFileName(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      default:
        return 'application/octet-stream';
    }
  }
}
