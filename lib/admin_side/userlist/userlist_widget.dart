import '/backend/backend.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_data_table.dart';
import '/custom_code/logo_utils.dart';
import '/custom_code/actions/index.dart';
import '/admin_side/shared/expired_contracts.dart';
import 'dart:ui';
import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'userlist_model.dart';
export 'userlist_model.dart';

class UserlistWidget extends StatefulWidget {
  const UserlistWidget({super.key});

  static String routeName = 'userlist';
  static String routePath = '/userlist';

  @override
  State<UserlistWidget> createState() => _UserlistWidgetState();
}

class _UserlistWidgetState extends State<UserlistWidget> {
  late UserlistModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => UserlistModel());

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

    return StreamBuilder<List<UsersRecord>>(
      stream: queryUsersRecord(
        queryBuilder: (users) => users.where(
          'type',
          isEqualTo: 'user',
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
                        const Color(0xFF18651C),
                      ),
                      strokeWidth: 3.0,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Loading User Data...',
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
        List<UsersRecord> allUsersList = snapshot.data!;

        // Filter the data based on search text
        List<UsersRecord> filteredUsersList = allUsersList.where((user) {
          // Apply text search filter
          if (_model.textController?.text.isNotEmpty == true) {
            final searchText = _model.textController!.text.toLowerCase();
            final userId = user.uid.toLowerCase();
            final fullName = user.fullname?.toLowerCase() ?? '';
            final email = user.email?.toLowerCase() ?? '';
            final phoneNumber = user.phoneNumber?.toLowerCase() ?? '';

            // Search in multiple fields
            bool matchesSearch = userId.contains(searchText) ||
                fullName.contains(searchText) ||
                email.contains(searchText) ||
                phoneNumber.contains(searchText);

            if (!matchesSearch) return false;
          }

          // Apply date filter
          if (_model.startDate != null || _model.endDate != null) {
            // Use the created_time field
            DateTime? userCreatedDate = user.createdTime;

            if (userCreatedDate != null) {
              // Apply start date filter
              if (_model.startDate != null &&
                  userCreatedDate.isBefore(_model.startDate!)) {
                return false;
              }

              // Apply end date filter
              if (_model.endDate != null &&
                  userCreatedDate.isAfter(_model.endDate!)) {
                return false;
              }
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
                                  isActive: false,
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
                                  icon: Icons.circle,
                                  title: 'User Management',
                                  isActive: true,
                                  onTap: () {},
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
                                    'User Management',
                                    style: GoogleFonts.inter(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF1F2937),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'View and manage all users in the system',
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      color: const Color(0xFF6B7280),
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 40),

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
                                          hintText:
                                              'Search users by name, email, or User ID',
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
                                  const SizedBox(width: 16),

                                  // Start Date Picker
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

                                  // End Date Picker
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
                                  const SizedBox(width: 12),

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
                                  const SizedBox(width: 24),

                                  _buildActionButton(
                                    onPressed: () async {
                                      // Download PDF functionality
                                      await _downloadNitcheListPDF(
                                          userData: allUsersList);
                                    },
                                    icon: Icons.download_rounded,
                                    label: 'Download PDF',
                                    color: const Color(0xFF3B82F6),
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
                                                if (_model.textController?.text
                                                        .isNotEmpty ==
                                                    true)
                                                  Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 12,
                                                            vertical: 6),
                                                    decoration: BoxDecoration(
                                                      color: Color(0xFF18651C)
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
                                                            Color(0xFF18651C),
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
                                          '${filteredUsersList.length} of ${allUsersList.length} records',
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
                                  child: FlutterFlowDataTable<UsersRecord>(
                                    controller:
                                        _model.paginatedDataTableController1,
                                    data: filteredUsersList,
                                    columnsBuilder: (onSortChanged) => [
                                      _buildDataColumn(
                                          'User ID', Icons.numbers_rounded),
                                      _buildDataColumn(
                                          'Name', Icons.person_rounded),
                                      _buildDataColumn(
                                          'Email', Icons.email_rounded),
                                      _buildDataColumn(
                                          'Phone Number', Icons.phone_rounded),
                                      _buildDataColumn(
                                          'Created At', Icons.schedule_rounded),
                                      _buildDataColumn(
                                          'Actions', Icons.settings_rounded),
                                    ],
                                    dataRowBuilder: (user, userIndex, selected,
                                            onSelectChanged) =>
                                        DataRow(
                                      color: MaterialStateProperty.all(
                                        userIndex % 2 == 0
                                            ? const Color(0xFFF9FAFB)
                                            : Colors.white,
                                      ),
                                      cells: [
                                        _buildDataCell(
                                          child: Text(
                                            user.uid,
                                            style: GoogleFonts.inter(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: const Color(0xFF1F2937),
                                            ),
                                          ),
                                        ),
                                        _buildDataCell(
                                          child: Text(
                                            user.fullname.isNotEmpty
                                                ? user.fullname
                                                : 'N/A',
                                            style: GoogleFonts.inter(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: const Color(0xFF1F2937),
                                            ),
                                          ),
                                        ),
                                        _buildDataCell(
                                          child: Text(
                                            user.email.isNotEmpty
                                                ? user.email
                                                : 'N/A',
                                            style: GoogleFonts.inter(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: const Color(0xFF1F2937),
                                            ),
                                          ),
                                        ),
                                        _buildDataCell(
                                          child: Text(
                                            user.phoneNumber.isNotEmpty
                                                ? user.phoneNumber
                                                : 'N/A',
                                            style: GoogleFonts.inter(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: const Color(0xFF1F2937),
                                            ),
                                          ),
                                        ),
                                        _buildDataCell(
                                          child: Text(
                                            user.createdTime != null
                                                ? user.createdTime.toString()
                                                : 'N/A',
                                            style: GoogleFonts.inter(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: const Color(0xFF1F2937),
                                            ),
                                          ),
                                        ),
                                        _buildDataCell(
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                onPressed: () async {
                                                  // Edit Password functionality
                                                  await showDialog(
                                                    context: context,
                                                    builder:
                                                        (alertDialogContext) {
                                                      return Dialog(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(24),
                                                        ),
                                                        child: Container(
                                                          width: 500,
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(32),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        24),
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: const Color(
                                                                    0x1A000000),
                                                                blurRadius: 20,
                                                                offset:
                                                                    const Offset(
                                                                        0, 10),
                                                              ),
                                                            ],
                                                          ),
                                                          child: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              // Header Section
                                                              Row(
                                                                children: [
                                                                  Container(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            12),
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: const Color(
                                                                              0xFF18651C)
                                                                          .withOpacity(
                                                                              0.1),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              16),
                                                                    ),
                                                                    child: Icon(
                                                                      Icons
                                                                          .lock_rounded,
                                                                      color: const Color(
                                                                          0xFF18651C),
                                                                      size: 28,
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                      width:
                                                                          16),
                                                                  Expanded(
                                                                    child:
                                                                        Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Text(
                                                                          'Edit User Password',
                                                                          style:
                                                                              GoogleFonts.inter(
                                                                            fontSize:
                                                                                24,
                                                                            fontWeight:
                                                                                FontWeight.w700,
                                                                            color:
                                                                                const Color(0xFF1F2937),
                                                                          ),
                                                                        ),
                                                                        const SizedBox(
                                                                            height:
                                                                                4),
                                                                        Text(
                                                                          'Update the password for this user account',
                                                                          style:
                                                                              GoogleFonts.inter(
                                                                            fontSize:
                                                                                14,
                                                                            color:
                                                                                const Color(0xFF6B7280),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              const SizedBox(
                                                                  height: 32),

                                                              // User Info Section
                                                              Container(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        20),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: const Color(
                                                                      0xFFF9FAFB),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              16),
                                                                  border: Border
                                                                      .all(
                                                                    color: const Color(
                                                                        0xFFE5E7EB),
                                                                    width: 1,
                                                                  ),
                                                                ),
                                                                child: Row(
                                                                  children: [
                                                                    Container(
                                                                      padding: const EdgeInsets
                                                                          .all(
                                                                          10),
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: const Color(
                                                                            0xFF18651C),
                                                                        borderRadius:
                                                                            BorderRadius.circular(12),
                                                                      ),
                                                                      child:
                                                                          Icon(
                                                                        Icons
                                                                            .person_rounded,
                                                                        color: Colors
                                                                            .white,
                                                                        size:
                                                                            20,
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                        width:
                                                                            16),
                                                                    Expanded(
                                                                      child:
                                                                          Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                          Text(
                                                                            'User Details',
                                                                            style:
                                                                                GoogleFonts.inter(
                                                                              fontSize: 12,
                                                                              fontWeight: FontWeight.w600,
                                                                              color: const Color(0xFF6B7280),
                                                                              letterSpacing: 0.5,
                                                                            ),
                                                                          ),
                                                                          const SizedBox(
                                                                              height: 4),
                                                                          Text(
                                                                            user.fullname.isNotEmpty
                                                                                ? user.fullname
                                                                                : user.email,
                                                                            style:
                                                                                GoogleFonts.inter(
                                                                              fontSize: 16,
                                                                              fontWeight: FontWeight.w600,
                                                                              color: const Color(0xFF1F2937),
                                                                            ),
                                                                          ),
                                                                          if (user.fullname.isNotEmpty &&
                                                                              user.email.isNotEmpty)
                                                                            Text(
                                                                              user.email,
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
                                                              ),
                                                              const SizedBox(
                                                                  height: 24),

                                                              // Password Fields Section
                                                              Text(
                                                                'New Password',
                                                                style:
                                                                    GoogleFonts
                                                                        .inter(
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  color: const Color(
                                                                      0xFF374151),
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  height: 8),
                                                              Container(
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              12),
                                                                  border: Border
                                                                      .all(
                                                                    color: const Color(
                                                                        0xFFE5E7EB),
                                                                    width: 1.5,
                                                                  ),
                                                                ),
                                                                child:
                                                                    TextFormField(
                                                                  obscureText:
                                                                      true,
                                                                  decoration:
                                                                      InputDecoration(
                                                                    hintText:
                                                                        'Enter new password',
                                                                    border:
                                                                        InputBorder
                                                                            .none,
                                                                    contentPadding:
                                                                        const EdgeInsets
                                                                            .symmetric(
                                                                      horizontal:
                                                                          20,
                                                                      vertical:
                                                                          16,
                                                                    ),
                                                                    prefixIcon:
                                                                        Icon(
                                                                      Icons
                                                                          .lock_outline_rounded,
                                                                      color: const Color(
                                                                          0xFF9CA3AF),
                                                                      size: 20,
                                                                    ),
                                                                  ),
                                                                  style:
                                                                      GoogleFonts
                                                                          .inter(
                                                                    fontSize:
                                                                        14,
                                                                    color: const Color(
                                                                        0xFF1F2937),
                                                                  ),
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  height: 32),

                                                              Text(
                                                                'Confirm Password',
                                                                style:
                                                                    GoogleFonts
                                                                        .inter(
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  color: const Color(
                                                                      0xFF374151),
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  height: 8),
                                                              Container(
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              12),
                                                                  border: Border
                                                                      .all(
                                                                    color: const Color(
                                                                        0xFFE5E7EB),
                                                                    width: 1.5,
                                                                  ),
                                                                ),
                                                                child:
                                                                    TextFormField(
                                                                  obscureText:
                                                                      true,
                                                                  decoration:
                                                                      InputDecoration(
                                                                    hintText:
                                                                        'Confirm new password',
                                                                    border:
                                                                        InputBorder
                                                                            .none,
                                                                    contentPadding:
                                                                        const EdgeInsets
                                                                            .symmetric(
                                                                      horizontal:
                                                                          20,
                                                                      vertical:
                                                                          16,
                                                                    ),
                                                                    prefixIcon:
                                                                        Icon(
                                                                      Icons
                                                                          .lock_outline_rounded,
                                                                      color: const Color(
                                                                          0xFF9CA3AF),
                                                                      size: 20,
                                                                    ),
                                                                  ),
                                                                  style:
                                                                      GoogleFonts
                                                                          .inter(
                                                                    fontSize:
                                                                        14,
                                                                    color: const Color(
                                                                        0xFF1F2937),
                                                                  ),
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  height: 32),

                                                              // Action Buttons
                                                              Row(
                                                                children: [
                                                                  Expanded(
                                                                    child:
                                                                        TextButton(
                                                                      onPressed:
                                                                          () =>
                                                                              Navigator.pop(alertDialogContext),
                                                                      style: TextButton
                                                                          .styleFrom(
                                                                        padding: const EdgeInsets
                                                                            .symmetric(
                                                                            vertical:
                                                                                16),
                                                                        shape:
                                                                            RoundedRectangleBorder(
                                                                          borderRadius:
                                                                              BorderRadius.circular(12),
                                                                          side:
                                                                              BorderSide(
                                                                            color:
                                                                                const Color(0xFFE5E7EB),
                                                                            width:
                                                                                1,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      child:
                                                                          Text(
                                                                        'Cancel',
                                                                        style: GoogleFonts
                                                                            .inter(
                                                                          fontSize:
                                                                              14,
                                                                          fontWeight:
                                                                              FontWeight.w600,
                                                                          color:
                                                                              const Color(0xFF6B7280),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                      width:
                                                                          16),
                                                                  Expanded(
                                                                    child:
                                                                        ElevatedButton(
                                                                      onPressed:
                                                                          () async {
                                                                        // TODO: Implement password change logic
                                                                        Navigator.pop(
                                                                            alertDialogContext);
                                                                        ScaffoldMessenger.of(context)
                                                                            .showSnackBar(
                                                                          SnackBar(
                                                                            content:
                                                                                Row(
                                                                              children: [
                                                                                Icon(
                                                                                  Icons.check_circle_rounded,
                                                                                  color: Colors.white,
                                                                                  size: 20,
                                                                                ),
                                                                                const SizedBox(width: 12),
                                                                                Text(
                                                                                  'Password updated successfully!',
                                                                                  style: GoogleFonts.inter(
                                                                                    fontWeight: FontWeight.w600,
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                            backgroundColor:
                                                                                const Color(0xFF10B981),
                                                                            behavior:
                                                                                SnackBarBehavior.floating,
                                                                            shape:
                                                                                RoundedRectangleBorder(
                                                                              borderRadius: BorderRadius.circular(12),
                                                                            ),
                                                                          ),
                                                                        );
                                                                      },
                                                                      style: ElevatedButton
                                                                          .styleFrom(
                                                                        backgroundColor:
                                                                            const Color(0xFF18651C),
                                                                        foregroundColor:
                                                                            Colors.white,
                                                                        padding: const EdgeInsets
                                                                            .symmetric(
                                                                            vertical:
                                                                                16),
                                                                        shape:
                                                                            RoundedRectangleBorder(
                                                                          borderRadius:
                                                                              BorderRadius.circular(12),
                                                                        ),
                                                                        elevation:
                                                                            0,
                                                                      ),
                                                                      child:
                                                                          Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: [
                                                                          Icon(
                                                                            Icons.lock_reset_rounded,
                                                                            size:
                                                                                18,
                                                                          ),
                                                                          const SizedBox(
                                                                              width: 8),
                                                                          Text(
                                                                            'Update Password',
                                                                            style:
                                                                                GoogleFonts.inter(
                                                                              fontSize: 14,
                                                                              fontWeight: FontWeight.w600,
                                                                            ),
                                                                          ),
                                                                        ],
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
                                                icon: Icon(Icons.lock_rounded),
                                                color: const Color(0xFF18651C),
                                                tooltip: 'Edit Password',
                                              ),
                                              const SizedBox(width: 8),
                                              IconButton(
                                                onPressed: () async {
                                                  // Dynamic user suspension functionality
                                                  await showDialog(
                                                    context: context,
                                                    builder:
                                                        (alertDialogContext) {
                                                      return StatefulBuilder(
                                                        builder: (context,
                                                            setState) {
                                                          DateTime
                                                              selectedEndDate =
                                                              DateTime.now()
                                                                  .add(Duration(
                                                                      days: 3));
                                                          String
                                                              suspensionReason =
                                                              '';

                                                          return AlertDialog(
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          20),
                                                            ),
                                                            contentPadding:
                                                                EdgeInsets.all(
                                                                    24),
                                                            insetPadding: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        40,
                                                                    vertical:
                                                                        24),
                                                            content:
                                                                ConstrainedBox(
                                                              constraints:
                                                                  BoxConstraints(
                                                                minWidth: 500,
                                                                maxWidth: 600,
                                                              ),
                                                              child:
                                                                  IntrinsicWidth(
                                                                child: Column(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    // Title Section
                                                                    Row(
                                                                      children: [
                                                                        Icon(
                                                                          Icons
                                                                              .block_rounded,
                                                                          color:
                                                                              const Color(0xFFF59E0B),
                                                                          size:
                                                                              24,
                                                                        ),
                                                                        const SizedBox(
                                                                            width:
                                                                                12),
                                                                        Text(
                                                                          'Suspend User Login',
                                                                          style:
                                                                              GoogleFonts.inter(
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                            fontSize:
                                                                                20,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    const SizedBox(
                                                                        height:
                                                                            24),
                                                                    // Content Section
                                                                    Text(
                                                                      'Configure user suspension:',
                                                                      style: GoogleFonts
                                                                          .inter(
                                                                        fontWeight:
                                                                            FontWeight.w600,
                                                                        fontSize:
                                                                            16,
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                        height:
                                                                            20),
                                                                    Text(
                                                                      'Suspension End Date:',
                                                                      style: GoogleFonts
                                                                          .inter(
                                                                        fontSize:
                                                                            15,
                                                                        fontWeight:
                                                                            FontWeight.w500,
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                        height:
                                                                            12),
                                                                    InkWell(
                                                                      onTap:
                                                                          () async {
                                                                        final DateTime?
                                                                            picked =
                                                                            await showDatePicker(
                                                                          context:
                                                                              context,
                                                                          initialDate:
                                                                              selectedEndDate,
                                                                          firstDate:
                                                                              DateTime.now().add(Duration(days: 1)),
                                                                          lastDate:
                                                                              DateTime.now().add(Duration(days: 365)),
                                                                          builder:
                                                                              (context, child) {
                                                                            return Theme(
                                                                              data: Theme.of(context).copyWith(
                                                                                colorScheme: ColorScheme.light(
                                                                                  primary: const Color(0xFFF59E0B),
                                                                                  onPrimary: Colors.white,
                                                                                  surface: Colors.white,
                                                                                  onSurface: Colors.black,
                                                                                ),
                                                                              ),
                                                                              child: child!,
                                                                            );
                                                                          },
                                                                        );
                                                                        if (picked !=
                                                                                null &&
                                                                            picked !=
                                                                                selectedEndDate) {
                                                                          setState(
                                                                              () {
                                                                            selectedEndDate =
                                                                                picked;
                                                                          });
                                                                        }
                                                                      },
                                                                      child:
                                                                          Container(
                                                                        width: double
                                                                            .infinity,
                                                                        padding: EdgeInsets.symmetric(
                                                                            horizontal:
                                                                                20,
                                                                            vertical:
                                                                                16),
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          border: Border.all(
                                                                              color: const Color(0xFFE5E7EB),
                                                                              width: 1.5),
                                                                          borderRadius:
                                                                              BorderRadius.circular(12),
                                                                          color:
                                                                              Colors.white,
                                                                          boxShadow: [
                                                                            BoxShadow(
                                                                              color: Colors.black.withOpacity(0.05),
                                                                              blurRadius: 4,
                                                                              offset: Offset(0, 2),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        child:
                                                                            Row(
                                                                          children: [
                                                                            Icon(
                                                                              Icons.calendar_today,
                                                                              color: const Color(0xFFF59E0B),
                                                                              size: 22,
                                                                            ),
                                                                            const SizedBox(width: 16),
                                                                            Text(
                                                                              '${selectedEndDate.day}/${selectedEndDate.month}/${selectedEndDate.year}',
                                                                              style: GoogleFonts.inter(
                                                                                fontSize: 17,
                                                                                fontWeight: FontWeight.w500,
                                                                                color: const Color(0xFF1F2937),
                                                                              ),
                                                                            ),
                                                                            const Spacer(),
                                                                            Icon(
                                                                              Icons.arrow_drop_down,
                                                                              color: const Color(0xFF6B7280),
                                                                              size: 24,
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                        height:
                                                                            12),
                                                                    Text(
                                                                      'Duration: ${selectedEndDate.difference(DateTime.now()).inDays} days',
                                                                      style: GoogleFonts
                                                                          .inter(
                                                                        fontSize:
                                                                            14,
                                                                        color: const Color(
                                                                            0xFF6B7280),
                                                                        fontWeight:
                                                                            FontWeight.w500,
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                        height:
                                                                            24),
                                                                    Text(
                                                                      'Reason (optional):',
                                                                      style: GoogleFonts
                                                                          .inter(
                                                                        fontSize:
                                                                            15,
                                                                        fontWeight:
                                                                            FontWeight.w500,
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                        height:
                                                                            12),
                                                                    TextField(
                                                                      onChanged:
                                                                          (value) {
                                                                        suspensionReason =
                                                                            value;
                                                                      },
                                                                      decoration:
                                                                          InputDecoration(
                                                                        hintText:
                                                                            'Enter suspension reason...',
                                                                        hintStyle:
                                                                            GoogleFonts.inter(
                                                                          color:
                                                                              const Color(0xFF9CA3AF),
                                                                          fontSize:
                                                                              14,
                                                                        ),
                                                                        border:
                                                                            OutlineInputBorder(
                                                                          borderRadius:
                                                                              BorderRadius.circular(12),
                                                                          borderSide:
                                                                              BorderSide(
                                                                            color:
                                                                                const Color(0xFFE5E7EB),
                                                                            width:
                                                                                1.5,
                                                                          ),
                                                                        ),
                                                                        enabledBorder:
                                                                            OutlineInputBorder(
                                                                          borderRadius:
                                                                              BorderRadius.circular(12),
                                                                          borderSide:
                                                                              BorderSide(
                                                                            color:
                                                                                const Color(0xFFE5E7EB),
                                                                            width:
                                                                                1.5,
                                                                          ),
                                                                        ),
                                                                        focusedBorder:
                                                                            OutlineInputBorder(
                                                                          borderRadius:
                                                                              BorderRadius.circular(12),
                                                                          borderSide:
                                                                              BorderSide(
                                                                            color:
                                                                                const Color(0xFFF59E0B),
                                                                            width:
                                                                                2,
                                                                          ),
                                                                        ),
                                                                        contentPadding:
                                                                            EdgeInsets.symmetric(
                                                                          horizontal:
                                                                              16,
                                                                          vertical:
                                                                              16,
                                                                        ),
                                                                      ),
                                                                      maxLines:
                                                                          3,
                                                                      style: GoogleFonts
                                                                          .inter(
                                                                        fontSize:
                                                                            14,
                                                                        color: const Color(
                                                                            0xFF1F2937),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                            actions: [
                                                              TextButton(
                                                                onPressed: () =>
                                                                    Navigator.pop(
                                                                        alertDialogContext),
                                                                child: Text(
                                                                  'Cancel',
                                                                  style:
                                                                      GoogleFonts
                                                                          .inter(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    color: const Color(
                                                                        0xFF6B7280),
                                                                  ),
                                                                ),
                                                              ),
                                                              ElevatedButton(
                                                                onPressed:
                                                                    () async {
                                                                  // Implement dynamic user suspension logic
                                                                  Navigator.pop(
                                                                      alertDialogContext);

                                                                  final success =
                                                                      await suspendUser(
                                                                    user,
                                                                    selectedEndDate,
                                                                    suspensionReason
                                                                            .isEmpty
                                                                        ? null
                                                                        : suspensionReason,
                                                                  );

                                                                  if (success) {
                                                                    ScaffoldMessenger.of(
                                                                            context)
                                                                        .showSnackBar(
                                                                      SnackBar(
                                                                        content:
                                                                            Text('User suspended until ${selectedEndDate.day}/${selectedEndDate.month}/${selectedEndDate.year}'),
                                                                        backgroundColor:
                                                                            const Color(0xFFF59E0B),
                                                                      ),
                                                                    );
                                                                  } else {
                                                                    ScaffoldMessenger.of(
                                                                            context)
                                                                        .showSnackBar(
                                                                      SnackBar(
                                                                        content:
                                                                            Text('Failed to suspend user'),
                                                                        backgroundColor:
                                                                            const Color(0xFFEF4444),
                                                                      ),
                                                                    );
                                                                  }
                                                                },
                                                                style: ElevatedButton
                                                                    .styleFrom(
                                                                  backgroundColor:
                                                                      const Color(
                                                                          0xFFF59E0B),
                                                                  foregroundColor:
                                                                      Colors
                                                                          .white,
                                                                ),
                                                                child: Text(
                                                                  'Suspend User',
                                                                  style:
                                                                      GoogleFonts
                                                                          .inter(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          );
                                                        },
                                                      );
                                                    },
                                                  );
                                                },
                                                icon: Icon(Icons.block_rounded),
                                                color: const Color(0xFFF59E0B),
                                                tooltip:
                                                    'Suspend User (Dynamic)',
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
    required Color color,
    bool isSmall = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isSmall ? 12 : 16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: isSmall ? 16 : 18),
        label: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: isSmall ? 12 : 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: EdgeInsets.symmetric(
            horizontal: isSmall ? 16 : 24,
            vertical: isSmall ? 10 : 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isSmall ? 12 : 16),
          ),
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
    final isUnaddable = status.toLowerCase() == 'unaddable';
    final color =
        isUnaddable ? const Color(0xFFEF4444) : const Color(0xFF10B981);
    final icon = isUnaddable ? Icons.block_rounded : Icons.check_circle_rounded;

    // Format the status text with expiration date if available
    String statusText = status.isNotEmpty ? status : 'Unknown';

    if (dateOfExpiration != null) {
      // Format: "Addable after MM/DD/YYYY" or "Unaddable until MM/DD/YYYY"
      final month = dateOfExpiration.month.toString().padLeft(2, '0');
      final day = dateOfExpiration.day.toString().padLeft(2, '0');
      final year = dateOfExpiration.year.toString();

      if (isUnaddable) {
        statusText = 'Unaddable until $month/$day/$year';
      } else {
        statusText = 'Addable after $month/$day/$year';
      }
    } else {
      // If no expiration date, just show the status without date
      if (isUnaddable) {
        statusText = 'Unaddable';
      } else {
        statusText = 'Addable';
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            statusText,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // Method to add new nitche directly to contract collection
  Future<void> _addNewNitche() async {
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
        dateofexpiration:
            null, // dateofexpiration is intentionally null for nitche
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
                      color: const Color(0xFF10B981).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '₱',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF10B981),
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

  // Method to download user list as PDF
  Future<void> _downloadNitcheListPDF({List<UsersRecord>? userData}) async {
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
      final List<UsersRecord> currentData = userData ?? [];

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
              'PDF report generated successfully! ${currentData.length} users included.'),
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
  Future<String> _generatePDFContent(List<UsersRecord> userList) async {
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
            <img src="data:image/png;base64,${_getLogoBase64()}" alt="Logo" style="width: 80px; height: 80px; border-radius: 10px; margin-bottom: 15px;">
        </div>
        <div class="title">BALIWAG PUBLIC CEMETERY</div>
        <div class="subtitle">User Management Report</div>
        <div class="subtitle">Management System</div>
    </div>
    
    <div class="info">
        <div class="info-row">
            <span class="info-label">Report Date:</span>
            <span class="info-value">${DateTime.now().toString().split('.')[0]}</span>
        </div>
        <div class="info-row">
            <span class="info-label">Total Users:</span>
            <span class="info-value">${userList.length}</span>
        </div>
        <div class="info-row">
            <span class="info-label">Search Term:</span>
            <span class="info-value">${_model.textController.text.isNotEmpty ? _model.textController.text : 'None'}</span>
        </div>
    </div>
    
    <table>
        <thead>
            <tr>
                <th>User ID</th>
                <th>Name</th>
                <th>Email</th>
                <th>Phone Number</th>
                <th>Created At</th>
            </tr>
        </thead>
        <tbody>
''');

    // Table rows
    for (final user in userList) {
      content.writeln('''
            <tr>
                <td>${user.uid}</td>
                <td>${user.fullname.isNotEmpty ? user.fullname : 'N/A'}</td>
                <td>${user.email.isNotEmpty ? user.email : 'N/A'}</td>
                <td>${user.phoneNumber.isNotEmpty ? user.phoneNumber : 'N/A'}</td>
                <td>${user.createdTime != null ? user.createdTime.toString() : 'N/A'}</td>
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
  Future<void> _createAndDownloadPDF(String htmlContent, int userCount) async {
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
        ..setAttribute('download', 'user_list_report_$timestamp.html')
        ..click();

      // Clean up
      html.Url.revokeObjectUrl(url);
    } catch (e) {
      // Fallback: show error message
      throw Exception('Failed to create downloadable file: $e');
    }
  }
}
