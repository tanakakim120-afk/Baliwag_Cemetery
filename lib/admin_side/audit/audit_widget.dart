import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/flutter_flow_data_table.dart';
import '/custom_code/logo_utils.dart';
import '/admin_side/shared/expired_contracts.dart';
import 'dart:ui';
import 'dart:convert';
import 'dart:html' as html;
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'audit_model.dart';
export 'audit_model.dart';

class AuditWidget extends StatefulWidget {
  const AuditWidget({super.key});

  static String routeName = 'audit';
  static String routePath = '/audit';

  @override
  State<AuditWidget> createState() => _AuditWidgetState();
}

class _AuditWidgetState extends State<AuditWidget> {
  late AuditModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AuditModel());

    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();

    // Add listener to text controller for real-time search
    _model.textController!.addListener(() {
      if (mounted) {
        setState(() {});
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

    return StreamBuilder<List<AuditRecord>>(
      stream: queryAuditRecord(
        queryBuilder: (auditRecord) =>
            auditRecord.orderBy('timestamp', descending: true),
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
                        const Color(0xFF18651C),
                      ),
                      strokeWidth: 3.0,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Loading Audit Data...',
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
        List<AuditRecord> allAuditList = snapshot.data!;

        // Filter the data based on search text and date ranges
        List<AuditRecord> auditRecordList = allAuditList.where((audit) {
          // Apply text search filter
          if (_model.textController?.text.isNotEmpty == true) {
            final searchText = _model.textController!.text.toLowerCase();
            final id = audit.id?.toString().toLowerCase() ?? '';
            final name = audit.name.toLowerCase();
            final action = audit.action.toLowerCase();
            final timestamp = audit.stringtimestamp.toLowerCase();
            final ipAddress = audit.ipAddress.toLowerCase();
            final userId = audit.userId.toLowerCase();

            // Search in multiple fields
            bool matchesSearch = id.contains(searchText) ||
                name.contains(searchText) ||
                action.contains(searchText) ||
                timestamp.contains(searchText) ||
                ipAddress.contains(searchText) ||
                userId.contains(searchText);

            if (!matchesSearch) return false;
          }

          // Apply date filter to timestamps
          if (_model.startDate != null || _model.endDate != null) {
            bool hasValidDate = false;

            // Check timestamp
            if (audit.timestamp != null) {
              DateTime auditTimestamp = audit.timestamp!;

              // Normalize dates to start of day for accurate comparison
              final startDate = _model.startDate != null
                  ? DateTime(_model.startDate!.year, _model.startDate!.month,
                      _model.startDate!.day)
                  : null;
              final endDate = _model.endDate != null
                  ? DateTime(_model.endDate!.year, _model.endDate!.month,
                      _model.endDate!.day, 23, 59, 59)
                  : null;

              if (startDate != null && auditTimestamp.isBefore(startDate)) {
                return false;
              }
              if (endDate != null && auditTimestamp.isAfter(endDate)) {
                return false;
              }
              hasValidDate = true;
            }

            // If no valid dates found and filters are applied, exclude the audit
            if (!hasValidDate) {
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
                                  icon: Icons.circle,
                                  title: 'Audit Trail',
                                  isActive: true,
                                  onTap: () {},
                                ),
                                _buildNavItem(
                                  icon: Icons.people_outline_rounded,
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
                                    'Audit Trail',
                                    style: GoogleFonts.inter(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF1F2937),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'View and manage all audit activities',
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      color: const Color(0xFF6B7280),
                                      height: 1.4,
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
                                        focusNode: _model.textFieldFocusNode,
                                        obscureText: false,
                                        decoration: InputDecoration(
                                          hintText:
                                              'Search audit by ID, name, action, date, time, or IP address...',
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
                                        onChanged: (value) {
                                          setState(() {});
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),

                                  // Audit Date Filters
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
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF10B981)
                                              .withOpacity(0.3),
                                          blurRadius: 16,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: ElevatedButton.icon(
                                      onPressed: () async {
                                        await _downloadAuditListPDF(
                                            auditData: auditRecordList);
                                      },
                                      icon: const Icon(Icons.download_rounded,
                                          size: 18),
                                      label: Text(
                                        'Download PDF',
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFF3B82F6),
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 20,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16),
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
                                // Enhanced Table Header
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
                                      const Spacer(),
                                    ],
                                  ),
                                ),

                                // Enhanced Data Table
                                Expanded(
                                  child: FlutterFlowDataTable<AuditRecord>(
                                    controller:
                                        _model.paginatedDataTableController1,
                                    data: auditRecordList,
                                    columnsBuilder: (onSortChanged) => [
                                      DataColumn2(
                                        label: Container(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 20, horizontal: 16),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.numbers_rounded,
                                                color: Color(0xFF18651C),
                                                size: 18,
                                              ),
                                              SizedBox(width: 8),
                                              Text(
                                                'User ID',
                                                style: GoogleFonts.inter(
                                                  fontSize: 14,
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
                                              vertical: 20, horizontal: 16),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.person_rounded,
                                                color: Color(0xFF18651C),
                                                size: 18,
                                              ),
                                              SizedBox(width: 8),
                                              Text(
                                                'Name',
                                                style: GoogleFonts.inter(
                                                  fontSize: 14,
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
                                              vertical: 20, horizontal: 16),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.edit_rounded,
                                                color: Color(0xFF18651C),
                                                size: 18,
                                              ),
                                              SizedBox(width: 8),
                                              Text(
                                                'Action',
                                                style: GoogleFonts.inter(
                                                  fontSize: 14,
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
                                              vertical: 20, horizontal: 16),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.calendar_today_rounded,
                                                color: Color(0xFF18651C),
                                                size: 18,
                                              ),
                                              SizedBox(width: 8),
                                              Text(
                                                'Timestamp',
                                                style: GoogleFonts.inter(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xFF1F2937),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      // IP Address column removed per requirement
                                    ],
                                    dataRowBuilder: (audit, auditIndex,
                                            selected, onSelectChanged) =>
                                        DataRow(
                                      color: MaterialStateProperty.all(
                                        auditIndex % 2 == 0
                                            ? Color(0xFFF9FAFB)
                                            : Colors.white,
                                      ),
                                      cells: [
                                        DataCell(Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 12),
                                          child: Text(
                                            audit.userId.isNotEmpty
                                                ? audit.userId
                                                : 'N/A',
                                            style: GoogleFonts.inter(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF1F2937),
                                            ),
                                          ),
                                        )),
                                        DataCell(Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 12),
                                          child: Text(
                                            audit.name.isNotEmpty
                                                ? audit.name
                                                : 'N/A',
                                            style: GoogleFonts.inter(
                                              fontSize: 14,
                                              color: Color(0xFF1F2937),
                                            ),
                                          ),
                                        )),
                                        DataCell(Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 12),
                                          child: Text(
                                            audit.action.isNotEmpty
                                                ? audit.action
                                                : 'N/A',
                                            style: GoogleFonts.inter(
                                              fontSize: 14,
                                              color: Color(0xFF1F2937),
                                            ),
                                          ),
                                        )),
                                        DataCell(Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 12),
                                          child: Text(
                                            audit.stringtimestamp.isNotEmpty
                                                ? audit.stringtimestamp
                                                : audit.timestamp != null
                                                    ? dateTimeFormat(
                                                        'y MMMM d, h:mm a',
                                                        audit.timestamp!)
                                                    : 'N/A',
                                            style: GoogleFonts.inter(
                                              fontSize: 14,
                                              color: Color(0xFF1F2937),
                                            ),
                                          ),
                                        )),
                                        // IP Address cell removed per requirement
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

  // Method to download audit list as PDF
  Future<void> _downloadAuditListPDF({List<AuditRecord>? auditData}) async {
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
      final List<AuditRecord> currentData = auditData ?? [];

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
              'PDF report generated successfully! ${currentData.length} audit records included.'),
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
  Future<String> _generatePDFContent(List<AuditRecord> auditList) async {
    final StringBuffer content = StringBuffer();
    final logoBase64 = await _getLogoBase64();

    // Header
    content.writeln('''
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>Audit Trail Report</title>
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
        .footer { margin-top: 30px; text-align: center; color: #666; font-size: 12px; }
    </style>
</head>
<body>
    <div class="header">
        <div class="logo-container">
            <img src="data:image/png;base64,$logoBase64" alt="Logo" style="width: 80px; height: 80px; border-radius: 10px; margin-bottom: 15px;">
        </div>
        <div class="title">BALIWAG PUBLIC CEMETERY</div>
        <div class="subtitle">Audit Trail Report</div>
        <div class="subtitle">Management System</div>
    </div>
    
    <div class="info">
        <div class="info-row">
            <span class="info-label">Report Date:</span>
            <span class="info-value">${DateTime.now().toString().split('.')[0]}</span>
        </div>
        <div class="info-row">
            <span class="info-label">Total Audit Records:</span>
            <span class="info-value">${auditList.length}</span>
        </div>
        <div class="info-row">
            <span class="info-label">Search Term:</span>
            <span class="info-value">${_model.textController.text.isNotEmpty ? _model.textController.text : 'None'}</span>
        </div>
        <div class="info-row">
            <span class="info-label">Date Range:</span>
            <span class="info-value">${_model.startDate != null ? 'From: ${_model.startDate!.day}/${_model.startDate!.month}/${_model.startDate!.year}' : 'No start date'} ${_model.endDate != null ? 'To: ${_model.endDate!.day}/${_model.endDate!.month}/${_model.endDate!.year}' : 'No end date'}</span>
        </div>
    </div>
    
    <table>
        <thead>
            <tr>
                <th>User ID</th>
                <th>Name</th>
                <th>Action</th>
               <th>Timestamp</th>
            </tr>
        </thead>
        <tbody>
''');

    // Table rows
    for (final audit in auditList) {
      content.writeln('''
            <tr>
                <td>${audit.userId.isNotEmpty ? audit.userId : 'N/A'}</td>
                <td>${audit.name.isNotEmpty ? audit.name : 'N/A'}</td>
               <td>${audit.action.isNotEmpty ? audit.action : 'N/A'}</td>
               <td>${audit.stringtimestamp.isNotEmpty ? audit.stringtimestamp : audit.timestamp != null ? audit.timestamp.toString().split('.')[0] : 'N/A'}</td>
            </tr>
''');
    }

    // Footer
    content.writeln('''
        </tbody>
    </table>
    
    <div class="footer">
        <p>Generated on ${DateTime.now().toString().split('.')[0]}</p>
        <p>BALIWAG PUBLIC CEMETERY MANAGEMENT SYSTEM</p>
    </div>
</body>
</html>
''');

    return content.toString();
  }

  // Method to create and download PDF
  Future<void> _createAndDownloadPDF(String htmlContent, int auditCount) async {
    try {
      // For web platform, create a downloadable HTML file that can be converted to PDF
      // This approach works well for Flutter web applications

      // Create the HTML content as a downloadable file
      final bytes = utf8.encode(htmlContent);
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);

      // Create download link with timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      html.AnchorElement(href: url)
        ..setAttribute('download', 'audit_trail_report_$timestamp.html')
        ..click();

      // Clean up
      html.Url.revokeObjectUrl(url);
    } catch (e) {
      // Fallback: show error message
      throw Exception('Failed to create downloadable file: $e');
    }
  }

  // Method to get logo as base64 string for PDF
  Future<String> _getLogoBase64() async {
    return await LogoUtils.getLogoBase64();
  }
}
