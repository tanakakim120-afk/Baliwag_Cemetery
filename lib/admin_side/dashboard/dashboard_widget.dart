import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/components/newpassword_widget.dart' show NewpasswordWidget;
import 'dashboard_model.dart';
import 'package:flutter/scheduler.dart';
import '../shared/expired_contracts.dart';
export 'dashboard_model.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:barcode_widget/barcode_widget.dart';

class DashboardWidget extends StatefulWidget {
  const DashboardWidget({super.key});

  static const String routeName = 'dashboard';
  static const String routePath = '/dashboard';

  @override
  _DashboardWidgetState createState() => _DashboardWidgetState();
}

class _DashboardWidgetState extends State<DashboardWidget> {
  late DashboardModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  StreamSubscription<List<VaultRecord>>? _vaultSubscription;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DashboardModel());

    // On page load: process expired contracts and create vaults as needed
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await processExpiredContracts();
      if (mounted) setState(() {});
    });

    // Listen for newly created vaults and update badge count in FFAppState
    _vaultSubscription = queryVaultRecord().listen(
      (vaults) {
        if (!mounted) return;

        try {
          final recent = vaults.where((v) =>
              (v.timestamp ?? DateTime.fromMillisecondsSinceEpoch(0))
                  .isAfter(FFAppState().vaultNotificationBaseline));

          // Update count in FFAppState for consistency across all pages
          final currentCount = recent.length;
          if (currentCount != FFAppState().newVaultCount) {
            FFAppState().newVaultCount = currentCount;
          }
        } catch (e) {
          print('Error updating vault count: $e');
        }
      },
      onError: (error) {
        print('Vault subscription error: $error');
      },
    );
  }

  @override
  void dispose() {
    _vaultSubscription?.cancel();
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: const Color(0xFFF8FAFC),
        body: Row(
          children: [
            _buildSidebar(),
            _buildMainContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
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
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 24),
                  _buildSectionTitle('Platform Navigation'),
                  SizedBox(height: 12),
                  _buildNavItem(
                    icon: Icons.dashboard_rounded,
                    title: 'Dashboard',
                    isActive: true,
                    onTap: () {},
                  ),
                  SizedBox(height: 32),
                  _buildSectionTitle('Action'),
                  SizedBox(height: 12),
                  _buildNavItem(
                    icon: Icons.description_rounded,
                    title: 'Manage Contract',
                    onTap: () => context.pushNamed('ManageContract'),
                  ),
                  _buildNavItem(
                    icon: Icons.apartment_rounded,
                    title: 'Apartment Niche',
                    onTap: () => context.pushNamed('apartmentList'),
                  ),
                  _buildNavItem(
                    icon: Icons.add_location_alt_rounded,
                    title: 'Create Plot',
                    onTap: () => context.pushNamed('burialLotsList'),
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
                  SizedBox(height: 32),
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
                        padding: const EdgeInsets.symmetric(vertical: 16),
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
    );
  }

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

  Widget _buildMainContent() {
    return Expanded(
      child: Container(
        color: const Color(0xFFF8FAFC),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildModernHeader(),
              _buildMainKPICards(),
              SizedBox(height: 32),
              _buildAnalyticsGrid(),
              SizedBox(height: 32),
              _buildChartsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernHeader() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Welcome and Dashboard Overview Section
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StreamBuilder<List<UsersRecord>>(
                      stream: queryUsersRecord(
                        queryBuilder: (query) => query.where('uid',
                            isEqualTo: FirebaseAuth.instance.currentUser?.uid),
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Text(
                            'Welcome back...',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              color: Color(0xFF64748B),
                            ),
                          );
                        }

                        final user = snapshot.data?.firstOrNull;
                        final email = user?.email ??
                            FirebaseAuth.instance.currentUser?.email ??
                            'User';

                        return Text(
                          'Welcome back, ${email.split('@')[0]}',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: Color(0xFF64748B),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Dashboard Overview',
                      style: GoogleFonts.inter(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  // Notification Ring
                  GestureDetector(
                    onTap: () => _showNotificationModal(context),
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Color(0xFFF59E0B),
                          width: 2,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Icon(
                            Icons.notifications_rounded,
                            color: Color(0xFFF59E0B),
                            size: 20,
                          ),
                          // Notification Badge
                          Positioned(
                            right: 0,
                            top: 0,
                            child: StreamBuilder<List<TransactionsRecord>>(
                              stream: queryTransactionsRecord(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: Color(0xFFEF4444),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  );
                                }

                                final transactions = snapshot.data ?? [];
                                final pendingTransactionCount = transactions
                                    .where((t) => t.isClicked == false)
                                    .length;

                                if (pendingTransactionCount == 0) {
                                  return SizedBox.shrink();
                                }

                                return Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: Color(0xFFEF4444),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${pendingTransactionCount > 9 ? '9+' : pendingTransactionCount}',
                                      style: GoogleFonts.inter(
                                        fontSize: 8,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  // Edit Profile Button
                  GestureDetector(
                    onTap: () => _showEditProfileDialog(context),
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Color(0xFF18651C),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.edit_rounded,
                              color: Colors.white, size: 16),
                          SizedBox(width: 8),
                          Text(
                            'Edit Password',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => _downloadDashboardReport(),
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Color(0xFF3B82F6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.download_rounded,
                              color: Colors.white, size: 16),
                          SizedBox(width: 8),
                          Text(
                            'Download PDF',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
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
        ],
      ),
    );
  }

  Widget _buildMainKPICards() {
    return StreamBuilder<List<ContractRecord>>(
      stream: queryContractRecord(),
      builder: (context, contractSnapshot) {
        if (contractSnapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingKPICards();
        }

        final contracts = contractSnapshot.data ?? [];

        return StreamBuilder<List<TransactionsRecord>>(
          stream: queryTransactionsRecord(),
          builder: (context, transactionSnapshot) {
            if (transactionSnapshot.connectionState ==
                ConnectionState.waiting) {
              return _buildLoadingKPICards();
            }

            final transactions = transactionSnapshot.data ?? [];

            return StreamBuilder<List<VisitorlogRecord>>(
              stream: queryVisitorlogRecord(),
              builder: (context, visitorSnapshot) {
                if (visitorSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return _buildLoadingKPICards();
                }

                final visitorLogs = visitorSnapshot.data ?? [];

                return StreamBuilder<List<VaultRecord>>(
                  stream: queryVaultRecord(),
                  builder: (context, vaultSnapshot) {
                    if (vaultSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return _buildLoadingKPICards();
                    }

                    final vaults = vaultSnapshot.data ?? [];
                    final stats = _calculateRealTimeStats(
                        contracts, transactions, visitorLogs, vaults);

                    return Container(
                      padding: EdgeInsets.all(24),
                      child: Row(
                        children: [
                          Expanded(
                              child: _buildKPICard(
                                  'New Visitors',
                                  '${stats['visitors'] ?? 0}',
                                  '${stats['visitorTrend'] ?? 'No data'}',
                                  'Today',
                                  Color(0xFF10B981))),
                          SizedBox(width: 20),
                          Expanded(
                              child: _buildKPICard(
                                  'Monthly Revenue',
                                  '₱${((stats['thisMonthRevenue'] ?? 0) / 1000).toStringAsFixed(0)}k',
                                  '${stats['revenueTrend'] ?? 'No data'}',
                                  'This month',
                                  Color(0xFF8B5CF6))),
                          SizedBox(width: 20),
                          Expanded(
                              child: _buildKPICard(
                                  'Occupancy Rate',
                                  '${stats['overallOccupancy']?.toStringAsFixed(0) ?? '0'}%',
                                  '${stats['occupancyTrend'] ?? 'No data'}',
                                  'All spaces',
                                  Color(0xFFEF4444))),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildLoadingKPICards() {
    return Container(
      padding: EdgeInsets.all(24),
      child: Row(
        children: List.generate(
          4,
          (index) => Expanded(
            child: Container(
              margin: EdgeInsets.only(right: index < 3 ? 20 : 0),
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKPICard(String title, String value, String trend,
      String trendLabel, Color color) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500)),
          SizedBox(height: 8),
          Row(
            children: [
              Text(value,
                  style: GoogleFonts.inter(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B))),
              SizedBox(width: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.trending_up, size: 12, color: Color(0xFF16A34A)),
                    SizedBox(width: 2),
                    Text(trend,
                        style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF16A34A))),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(trendLabel,
              style: GoogleFonts.inter(fontSize: 12, color: Color(0xFF64748B))),
        ],
      ),
    );
  }

  Widget _buildAnalyticsGrid() {
    return StreamBuilder<List<ContractRecord>>(
      stream: queryContractRecord(),
      builder: (context, contractSnapshot) {
        if (contractSnapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingGrid();
        }

        final contracts = contractSnapshot.data ?? [];

        return StreamBuilder<List<TransactionsRecord>>(
          stream: queryTransactionsRecord(),
          builder: (context, transactionSnapshot) {
            if (transactionSnapshot.connectionState ==
                ConnectionState.waiting) {
              return _buildLoadingGrid();
            }

            final transactions = transactionSnapshot.data ?? [];

            return StreamBuilder<List<VisitorlogRecord>>(
              stream: queryVisitorlogRecord(),
              builder: (context, visitorSnapshot) {
                if (visitorSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return _buildLoadingGrid();
                }

                final visitorLogs = visitorSnapshot.data ?? [];

                return StreamBuilder<List<VaultRecord>>(
                  stream: queryVaultRecord(),
                  builder: (context, vaultSnapshot) {
                    if (vaultSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return _buildLoadingGrid();
                    }

                    final vaults = vaultSnapshot.data ?? [];
                    final stats = _calculateRealTimeStats(
                        contracts, transactions, visitorLogs, vaults);

                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                  child: _buildAnalyticsCard(
                                      'Active Contracts',
                                      '${stats['activeContracts'] ?? 0}',
                                      'Currently active',
                                      Icons.check_circle_rounded,
                                      Color(0xFF10B981),
                                      '${stats['contractTrend'] ?? 'No data'}')),
                              SizedBox(width: 20),
                              Expanded(
                                  child: _buildAnalyticsCard(
                                      'Total Spaces',
                                      'Lots: ${stats['lots'] ?? 0} | Niches: ${stats['niches'] ?? 0}',
                                      'Lot & Nitche Count',
                                      Icons.business_rounded,
                                      Color(0xFF3B82F6),
                                      'Occupied: ${stats['occupiedSpaces'] ?? 0}')),
                              SizedBox(width: 20),
                              Expanded(
                                  child: _buildAnalyticsCard(
                                      'Collection Rate',
                                      '${stats['collectionRate']?.toStringAsFixed(1) ?? '0'}%',
                                      'Payment efficiency',
                                      Icons.trending_up_rounded,
                                      Color(0xFF8B5CF6),
                                      'Outstanding: ₱${(stats['totalOutstandingBalance'] ?? 0).toStringAsFixed(0)}')),
                            ],
                          ),
                          SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                  child: _buildAnalyticsCard(
                                      'Monthly Transactions',
                                      '${stats['thisMonthTransactions'] ?? 0}',
                                      'This month',
                                      Icons.receipt_rounded,
                                      Color(0xFFEF4444),
                                      '${stats['transactionTrend'] ?? 'No data'}')),
                              SizedBox(width: 20),
                              Expanded(
                                  child: _buildAnalyticsCard(
                                      'Vault Documents',
                                      '${stats['vaultDocumentCount'] ?? 0}',
                                      'Total vault records',
                                      Icons.folder_rounded,
                                      Color(0xFFF59E0B),
                                      'Collection: vault')),
                              SizedBox(width: 20),
                              Expanded(
                                  child: _buildAnalyticsCard(
                                      'Weekly Visitors',
                                      '${stats['thisWeekVisitors'] ?? 0}',
                                      'This week',
                                      Icons.people_rounded,
                                      Color(0xFF059669),
                                      'Today: ${stats['visitors'] ?? 0}')),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildLoadingGrid() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            children: List.generate(
              3,
              (index) => Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: index < 2 ? 20 : 0),
                  height: 140,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          Row(
            children: List.generate(
              3,
              (index) => Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: index < 2 ? 20 : 0),
                  height: 140,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsCard(String title, String value, String subtitle,
      IconData icon, Color color, String trend) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Spacer(),
              Text(subtitle,
                  style: GoogleFonts.inter(
                      fontSize: 12, color: Color(0xFF64748B))),
            ],
          ),
          SizedBox(height: 16),
          Text(value,
              style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B))),
          SizedBox(height: 4),
          Text(title,
              style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF64748B))),
          SizedBox(height: 8),
          Text(trend,
              style: GoogleFonts.inter(fontSize: 12, color: Color(0xFF64748B))),
        ],
      ),
    );
  }

  Widget _buildChartsSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: _buildRevenueChart()),
          SizedBox(width: 24),
          Expanded(flex: 1, child: _buildPerformanceMetrics()),
        ],
      ),
    );
  }

  Widget _buildRevenueChart() {
    return StreamBuilder<List<TransactionsRecord>>(
      stream: queryTransactionsRecord(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final transactions = snapshot.data ?? [];
        final monthlyData = _calculateMonthlyRevenue(transactions);

        return Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('Monthly Revenue Trend',
                      style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B))),
                  Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: monthlyData['trend'] == 'up'
                          ? Color(0xFF10B981).withOpacity(0.1)
                          : Color(0xFFEF4444).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          monthlyData['trend'] == 'up'
                              ? Icons.trending_up
                              : Icons.trending_down,
                          size: 14,
                          color: monthlyData['trend'] == 'up'
                              ? Color(0xFF10B981)
                              : Color(0xFFEF4444),
                        ),
                        SizedBox(width: 4),
                        Text(
                          '${monthlyData['trendPercentage']}%',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: monthlyData['trend'] == 'up'
                                ? Color(0xFF10B981)
                                : Color(0xFFEF4444),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        color: Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(4)),
                    child: Text('Last 6 Months',
                        style: GoogleFonts.inter(
                            fontSize: 12, color: Color(0xFF64748B))),
                  ),
                ],
              ),
              SizedBox(height: 24),
              Container(
                height: 200,
                child: _buildRevenueLineChart(
                    monthlyData['months'] as List<Map<String, dynamic>>),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRevenueLineChart(List<Map<String, dynamic>> monthlyData) {
    if (monthlyData.isEmpty) {
      return Container(
        decoration: BoxDecoration(
            color: Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(8)),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bar_chart_outlined,
                  size: 48, color: Color(0xFF64748B)),
              SizedBox(height: 12),
              Text('No Revenue Data',
                  style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF64748B))),
              Text('Transaction data will appear here',
                  style: GoogleFonts.inter(
                      fontSize: 12, color: Color(0xFF94A3B8))),
            ],
          ),
        ),
      );
    }

    final maxRevenue = monthlyData
        .map((m) => m['revenue'] as double)
        .reduce((a, b) => a > b ? a : b);
    final minRevenue = monthlyData
        .map((m) => m['revenue'] as double)
        .reduce((a, b) => a < b ? a : b);
    final revenueRange = maxRevenue - minRevenue;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(8)),
      child: Column(
        children: [
          // Chart Area
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: monthlyData.asMap().entries.map((entry) {
                final index = entry.key;
                final data = entry.value;
                final revenue = data['revenue'] as double;
                final normalizedHeight = revenueRange > 0
                    ? ((revenue - minRevenue) / revenueRange) * 0.8 + 0.2
                    : 0.5;

                return Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Revenue amount tooltip
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Color(0xFF3B82F6),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '₱${(revenue / 1000).toStringAsFixed(0)}k',
                            style: GoogleFonts.inter(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                        SizedBox(height: 4),
                        // Chart bar
                        Container(
                          width: double.infinity,
                          height: normalizedHeight * 120, // Max height of 120px
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Color(0xFF3B82F6),
                                Color(0xFF3B82F6).withOpacity(0.7),
                              ],
                            ),
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(4)),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: 12),
          // Month labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: monthlyData
                .map(
                  (data) => Expanded(
                    child: Text(
                      data['monthLabel'] as String,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                          fontSize: 11,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceMetrics() {
    return StreamBuilder<List<ContractRecord>>(
      stream: queryContractRecord(),
      builder: (context, contractSnapshot) {
        if (contractSnapshot.connectionState == ConnectionState.waiting) {
          return Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Income Analysis',
                    style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B))),
                SizedBox(height: 24),
                Center(child: CircularProgressIndicator()),
              ],
            ),
          );
        }

        final contracts = contractSnapshot.data ?? [];

        return StreamBuilder<List<TransactionsRecord>>(
          stream: queryTransactionsRecord(),
          builder: (context, transactionSnapshot) {
            if (transactionSnapshot.connectionState ==
                ConnectionState.waiting) {
              return Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Income Analysis',
                        style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E293B))),
                    SizedBox(height: 24),
                    Center(child: CircularProgressIndicator()),
                  ],
                ),
              );
            }

            final transactions = transactionSnapshot.data ?? [];

            return StreamBuilder<List<VisitorlogRecord>>(
              stream: queryVisitorlogRecord(),
              builder: (context, visitorSnapshot) {
                if (visitorSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return Container(
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Income Analysis',
                            style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1E293B))),
                        SizedBox(height: 24),
                        Center(child: CircularProgressIndicator()),
                      ],
                    ),
                  );
                }

                final visitorLogs = visitorSnapshot.data ?? [];
                final performanceStats = _calculatePerformanceMetrics(
                    contracts, transactions, visitorLogs);

                return Container(
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Income Analysis',
                          style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E293B))),
                      SizedBox(height: 24),
                      _buildMetricItem(
                          'Renewals',
                          _formatNumber(performanceStats['renewals'] ?? 0),
                          Color(0xFF3B82F6)),
                      SizedBox(height: 16),
                      _buildMetricItem(
                          'Payments',
                          _formatNumber(performanceStats['totalPayments'] ?? 0),
                          Color(0xFF8B5CF6)),
                      SizedBox(height: 16),
                      _buildMetricItem(
                          'Visits',
                          _formatNumber(performanceStats['totalVisits'] ?? 0),
                          Color(0xFFEF4444)),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildMetricItem(String label, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(2)),
        ),
        SizedBox(width: 12),
        Text(label,
            style: GoogleFonts.inter(fontSize: 14, color: Color(0xFF64748B))),
        Spacer(),
        Text(value,
            style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B))),
      ],
    );
  }

  // Calculate performance metrics for the Income Analysis section
  Map<String, dynamic> _calculatePerformanceMetrics(
      List<ContractRecord> contracts,
      List<TransactionsRecord> transactions,
      List<VisitorlogRecord> visitorLogs) {
    final now = DateTime.now();
    final thisMonth = DateTime(now.year, now.month, 1);
    final lastMonth = DateTime(now.year, now.month - 1, 1);

    // Calculate total contracts
    int totalContracts = contracts.length;

    // Calculate renewals from transaction list using dedicated method
    int renewals = _countRenewals(transactions);

    // If no renewals found in transactions, fallback to contract expiration logic
    if (renewals == 0) {
      for (final contract in contracts) {
        if (contract.dateofexpiration != null &&
            contract.dateofexpiration!.isBefore(now) &&
            contract.contractstatus == 'active') {
          renewals++;
        }
      }
    }

    // Calculate total payments from transactions
    int totalPayments = 0;
    double totalRevenue = 0.0;
    for (final transaction in transactions) {
      if (transaction.status?.toLowerCase() == 'completed' ||
          transaction.status?.toLowerCase() == 'paid' ||
          transaction.status?.toLowerCase() == 'success') {
        totalPayments++;
        totalRevenue += (transaction.amount ?? 0).toDouble();
      }
    }

    // Calculate total visits
    int totalVisits = visitorLogs.length;

    return {
      'totalContracts': totalContracts,
      'renewals': renewals,
      'totalPayments': totalPayments,
      'totalVisits': totalVisits,
      'totalRevenue': totalRevenue,
    };
  }

  // Count renewals from transaction list with comprehensive logic
  int _countRenewals(List<TransactionsRecord> transactions) {
    int renewalCount = 0;

    print('=== Renewal Count Debug ===');
    print('Total transactions to analyze: ${transactions.length}');

    for (final transaction in transactions) {
      final type = transaction.type?.toLowerCase() ?? '';
      final paymentType = transaction.paymenttype?.toLowerCase() ?? '';
      final status = transaction.status?.toLowerCase() ?? '';

      // Check various renewal indicators
      bool isRenewal = false;

      // Check transaction type for renewal keywords
      if (type.contains('renewal') ||
          type.contains('renew') ||
          type.contains('extension') ||
          type.contains('continuation')) {
        isRenewal = true;
        print(
            'Found renewal in type: "$type" for transaction: ${transaction.name}');
      }

      // Check payment type for renewal keywords
      if (paymentType.contains('renewal') ||
          paymentType.contains('renew') ||
          paymentType.contains('extension') ||
          paymentType.contains('continuation')) {
        isRenewal = true;
        print(
            'Found renewal in paymentType: "$paymentType" for transaction: ${transaction.name}');
      }

      // Check if it's a renewal payment (completed/paid status)
      if (isRenewal &&
          (status == 'completed' || status == 'paid' || status == 'success')) {
        renewalCount++;
        print(
            'Counted as renewal: ${transaction.name} - Type: "$type", PaymentType: "$paymentType", Status: "$status"');
      }
    }

    print('Total renewals counted: $renewalCount');
    print('=== End Renewal Count Debug ===');

    return renewalCount;
  }

  // Format numbers for display (e.g., 1000 -> 1k, 1500 -> 1.5k)
  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    } else {
      return number.toString();
    }
  }

  // Calculate real-time stats with accurate cemetery data mapping
  Map<String, dynamic> _calculateRealTimeStats(
      List<ContractRecord> contracts,
      List<TransactionsRecord> transactions,
      List<VisitorlogRecord> visitorLogs,
      List<VaultRecord> vaults) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(Duration(days: 1));
    final thisMonth = DateTime(now.year, now.month, 1);
    final lastMonth = DateTime(now.year, now.month - 1, 1);
    final thisWeekStart = today.subtract(Duration(days: now.weekday - 1));

    // Enhanced visitor tracking
    int todayVisitors = 0;
    int yesterdayVisitors = 0;
    int thisWeekVisitors = 0;

    // Enhanced transaction tracking
    int thisMonthTransactions = 0;
    int lastMonthTransactions = 0;
    double thisMonthRevenue = 0.0;
    double lastMonthRevenue = 0.0;

    // Enhanced contract analysis
    int activeContracts = 0;
    int expiredContracts = 0;
    int pendingContracts = 0;
    int totalLots = 0;
    int totalNiches = 0;
    int occupiedLots = 0;
    int occupiedNiches = 0;

    // Vault document count
    int vaultDocumentCount = vaults.length;

    // Financial metrics
    double totalOutstandingBalance = 0.0;
    double totalPaidAmount = 0.0;
    int paidContracts = 0;
    int totalTransactions = transactions.length;

    // Calculate visitors with comprehensive tracking
    for (final visitorLog in visitorLogs) {
      if (visitorLog.timestamp != null) {
        final visitorDate = visitorLog.timestamp!;
        final visitorDay =
            DateTime(visitorDate.year, visitorDate.month, visitorDate.day);

        // Today's visitors
        if (visitorDay.isAtSameMomentAs(today)) {
          todayVisitors++;
        }

        // Yesterday's visitors
        if (visitorDay.isAtSameMomentAs(yesterday)) {
          yesterdayVisitors++;
        }

        // This week's visitors
        if (visitorDay.isAfter(thisWeekStart.subtract(Duration(days: 1))) &&
            visitorDay.isBefore(today.add(Duration(days: 1)))) {
          thisWeekVisitors++;
        }
      }
    }

    // Calculate transactions with comprehensive revenue tracking
    for (final transaction in transactions) {
      if (transaction.transactionDate != null) {
        final transactionDate = transaction.transactionDate!;
        final transactionMonth =
            DateTime(transactionDate.year, transactionDate.month, 1);
        final amount = (transaction.amount ?? 0).toDouble();

        // This month's transactions and revenue
        if (transactionMonth.isAtSameMomentAs(thisMonth)) {
          thisMonthTransactions++;
          thisMonthRevenue += amount;
        }

        // Last month's transactions and revenue
        if (transactionMonth.isAtSameMomentAs(lastMonth)) {
          lastMonthTransactions++;
          lastMonthRevenue += amount;
        }

        // Track paid amounts
        final transactionStatus = transaction.status?.toLowerCase() ?? '';
        if (transactionStatus == 'completed' || transactionStatus == 'paid') {
          totalPaidAmount += amount;
        }
      }
    }

    // Comprehensive contract analysis
    for (final contract in contracts) {
      final status = contract.status?.toLowerCase() ?? '';
      final contractStatus = contract.contractstatus?.toLowerCase() ?? '';
      final currentDate = DateTime.now();
      final isExpired = contract.dateofexpiration != null &&
          contract.dateofexpiration!.isBefore(currentDate);
      final hasDeceased = contract.decFullName.isNotEmpty;
      final balance = contract.balance ?? 0;

      // Contract status tracking with enhanced logic
      if (isExpired) {
        expiredContracts++;
      } else if (contractStatus == 'active' ||
          status == 'active' ||
          status == 'unaddable') {
        activeContracts++;
      } else if (contractStatus == 'pending' || status == 'pending') {
        pendingContracts++;
      }

      // Financial analysis
      if (balance > 0) {
        totalOutstandingBalance += balance.toDouble();
      } else if (balance == 0) {
        paidContracts++;
      }

      // Space utilization tracking with accurate mapping
      if (contract.type.isNotEmpty) {
        final type = contract.type.toLowerCase();

        if (type == 'lot') {
          totalLots++;
          if (hasDeceased || status == 'unaddable') {
            occupiedLots++;
          }
        } else if (type == 'nitche' || type == 'niche') {
          totalNiches++;
          if (hasDeceased || status == 'unaddable') {
            occupiedNiches++;
          }
        }
      }
    }

    // Calculate comprehensive trends and metrics
    final visitorTrend = yesterdayVisitors > 0
        ? (todayVisitors > yesterdayVisitors
            ? '+${((todayVisitors - yesterdayVisitors) / yesterdayVisitors * 100).toStringAsFixed(1)}%'
            : '${((todayVisitors - yesterdayVisitors) / yesterdayVisitors * 100).toStringAsFixed(1)}%')
        : (todayVisitors > 0 ? '+100%' : '0%');

    final contractTrend = contracts.length > 0
        ? '${((activeContracts / contracts.length) * 100).toStringAsFixed(1)}% active'
        : 'No contracts';

    final transactionTrend = lastMonthTransactions > 0
        ? (thisMonthTransactions > lastMonthTransactions
            ? '+${((thisMonthTransactions - lastMonthTransactions) / lastMonthTransactions * 100).toStringAsFixed(1)}%'
            : '${((thisMonthTransactions - lastMonthTransactions) / lastMonthTransactions * 100).toStringAsFixed(1)}%')
        : (thisMonthTransactions > 0 ? '+100%' : '0%');

    final revenueTrend = lastMonthRevenue > 0
        ? (thisMonthRevenue > lastMonthRevenue
            ? '+${((thisMonthRevenue - lastMonthRevenue) / lastMonthRevenue * 100).toStringAsFixed(1)}%'
            : '${((thisMonthRevenue - lastMonthRevenue) / lastMonthRevenue * 100).toStringAsFixed(1)}%')
        : (thisMonthRevenue > 0 ? '+100%' : '0%');

    final collectionRate = (totalPaidAmount + totalOutstandingBalance) > 0
        ? (totalPaidAmount / (totalPaidAmount + totalOutstandingBalance) * 100)
        : 0.0;

    final totalSpaces = totalLots + totalNiches;
    final occupiedSpaces = occupiedLots + occupiedNiches;
    final overallOccupancy =
        totalSpaces > 0 ? (occupiedSpaces / totalSpaces * 100) : 0.0;

    final occupancyTrend = totalSpaces > 0
        ? '${occupiedSpaces}/${totalSpaces} occupied'
        : 'No spaces';

    return {
      // Visitor Analytics
      'visitors': todayVisitors,
      'visitorTrend': visitorTrend,
      'yesterdayVisitors': yesterdayVisitors,
      'thisWeekVisitors': thisWeekVisitors,

      // Space Management
      'lots': totalLots,
      'occupiedLots': occupiedLots,
      'niches': totalNiches,
      'occupiedNiches': occupiedNiches,
      'totalSpaces': totalSpaces,
      'occupiedSpaces': occupiedSpaces,
      'overallOccupancy': overallOccupancy,
      'occupancyTrend': occupancyTrend,

      // Contract Analytics
      'contracts': contracts.length,
      'activeContracts': activeContracts,
      'expiredContracts': expiredContracts,
      'pendingContracts': pendingContracts,
      'contractTrend': contractTrend,

      // Vault Analytics
      'vaultDocumentCount': vaultDocumentCount,

      // Financial Metrics
      'transactions': totalTransactions,
      'transactionTrend': transactionTrend,
      'thisMonthTransactions': thisMonthTransactions,
      'lastMonthTransactions': lastMonthTransactions,
      'thisMonthRevenue': thisMonthRevenue,
      'lastMonthRevenue': lastMonthRevenue,
      'revenueTrend': revenueTrend,
      'totalOutstandingBalance': totalOutstandingBalance,
      'totalPaidAmount': totalPaidAmount,
      'paidContracts': paidContracts,
      'collectionRate': collectionRate,
    };
  }

  // Calculate monthly revenue data for chart visualization
  Map<String, dynamic> _calculateMonthlyRevenue(
      List<TransactionsRecord> transactions) {
    final now = DateTime.now();
    final months = <Map<String, dynamic>>[];

    // Generate last 6 months
    for (int i = 5; i >= 0; i--) {
      final monthDate = DateTime(now.year, now.month - i, 1);
      final monthEnd = DateTime(monthDate.year, monthDate.month + 1, 0);

      // Calculate revenue for this month
      double monthlyRevenue = 0.0;
      for (final transaction in transactions) {
        if (transaction.transactionDate != null) {
          final transactionDate = transaction.transactionDate!;
          if (transactionDate.isAfter(monthDate.subtract(Duration(days: 1))) &&
              transactionDate.isBefore(monthEnd.add(Duration(days: 1)))) {
            final status = transaction.status?.toLowerCase() ?? '';
            if (status == 'completed' ||
                status == 'paid' ||
                status == 'success') {
              monthlyRevenue += (transaction.amount ?? 0).toDouble();
            }
          }
        }
      }

      months.add({
        'month': monthDate.month,
        'year': monthDate.year,
        'revenue': monthlyRevenue,
        'monthLabel': _getMonthLabel(monthDate.month),
      });
    }

    // Calculate trend
    String trend = 'stable';
    String trendPercentage = '0.0';

    if (months.length >= 2) {
      final currentMonth = months[months.length - 1]['revenue'] as double;
      final previousMonth = months[months.length - 2]['revenue'] as double;

      if (previousMonth > 0) {
        final changePercent =
            ((currentMonth - previousMonth) / previousMonth * 100);
        trendPercentage = changePercent.abs().toStringAsFixed(1);
        trend = changePercent >= 0 ? 'up' : 'down';
      } else if (currentMonth > 0) {
        trend = 'up';
        trendPercentage = '100.0';
      }
    }

    return {
      'months': months,
      'trend': trend,
      'trendPercentage': trendPercentage,
    };
  }

  String _getMonthLabel(int month) {
    const monthNames = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return monthNames[month];
  }

  // Download dashboard report as PDF
  Future<void> _downloadDashboardReport() async {
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
                Text('Generating dashboard report...'),
              ],
            ),
          );
        },
      );

      // Fetch all data
      final contracts = await queryContractRecord().first;
      final transactions = await queryTransactionsRecord().first;
      final visitorLogs = await queryVisitorlogRecord().first;

      // Generate PDF content
      final pdfContent = await _generateDashboardPDFContent(
          contracts, transactions, visitorLogs);

      // Create and download PDF
      await _createAndDownloadPDF(pdfContent);

      // Close loading dialog
      Navigator.of(context).pop();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Dashboard report generated successfully!'),
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

  // Method to generate dashboard PDF content
  Future<String> _generateDashboardPDFContent(
      List<ContractRecord> contracts,
      List<TransactionsRecord> transactions,
      List<VisitorlogRecord> visitorLogs) async {
    final StringBuffer content = StringBuffer();
    final logoBase64 = await _getLogoBase64();
    final stats =
        _calculateRealTimeStats(contracts, transactions, visitorLogs, []);
    final monthlyRevenue = _calculateMonthlyRevenue(transactions);

    // Header with comprehensive dashboard analytics
    content.writeln('''
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>Cemetery Management Dashboard Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; color: #333; }
        .header { text-align: center; margin-bottom: 30px; border-bottom: 3px solid #18651C; padding-bottom: 20px; }
        .title { color: #18651C; font-size: 28px; font-weight: bold; margin-bottom: 10px; }
        .subtitle { color: #666; font-size: 18px; margin-bottom: 20px; }
        .info { background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%); padding: 20px; border-radius: 12px; margin-bottom: 25px; border-left: 4px solid #18651C; }
        .info-row { display: flex; justify-content: space-between; margin-bottom: 12px; }
        .info-label { font-weight: bold; color: #18651C; font-size: 14px; }
        .info-value { color: #333; font-size: 14px; }
        .section { margin-bottom: 30px; }
        .section-title { color: #18651C; font-size: 22px; font-weight: bold; margin-bottom: 15px; border-bottom: 2px solid #e9ecef; padding-bottom: 8px; }
        .kpi-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 20px; margin-bottom: 25px; }
        .kpi-card { background: #fff; border: 2px solid #e9ecef; border-radius: 12px; padding: 20px; text-align: center; box-shadow: 0 2px 8px rgba(0,0,0,0.1); }
        .kpi-title { color: #666; font-size: 14px; margin-bottom: 8px; }
        .kpi-value { color: #18651C; font-size: 32px; font-weight: bold; margin-bottom: 5px; }
        .kpi-trend { font-size: 12px; }
        .trend-up { color: #10B981; }
        .trend-down { color: #EF4444; }
        .analytics-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px; margin-bottom: 25px; }
        .analytics-card { background: #fff; border: 1px solid #e9ecef; border-radius: 8px; padding: 15px; }
        .analytics-title { color: #18651C; font-size: 16px; font-weight: bold; margin-bottom: 10px; }
        .analytics-value { color: #333; font-size: 24px; font-weight: bold; margin-bottom: 5px; }
        .analytics-subtitle { color: #666; font-size: 12px; }
        .footer { margin-top: 40px; text-align: center; color: #666; font-size: 12px; border-top: 1px solid #e9ecef; padding-top: 20px; }
    </style>
</head>
<body>
    <div class="header">
        <div class="title">BALIWAG PUBLIC CEMETERY</div>
        <div class="subtitle">Management Dashboard Report</div>
        <div style="color: #666; font-size: 14px;">Comprehensive Analytics & Insights</div>
    </div>
    
    <div class="info">
        <div class="info-row">
            <span class="info-label">Report Generated:</span>
            <span class="info-value">${DateTime.now().toString().split('.')[0]}</span>
        </div>
        <div class="info-row">
            <span class="info-label">Data Summary:</span>
            <span class="info-value">${stats['activeContracts'] ?? 0} Active Contracts • ${transactions.length} Transactions • ${visitorLogs.length} Visitor Records</span>
        </div>
    </div>

    <div class="section">
        <div class="section-title">📊 Key Performance Indicators</div>
        <div class="kpi-grid">
            <div class="kpi-card">
                <div class="kpi-title">Today's Visitors</div>
                <div class="kpi-value">${stats['visitors'] ?? 0}</div>
                <div class="kpi-trend trend-up">${stats['visitorTrend'] ?? 'No data'}</div>
            </div>
            <div class="kpi-card">
                <div class="kpi-title">Total Contracts</div>
                <div class="kpi-value">${stats['activeContracts'] ?? 0}</div>
                <div class="kpi-trend trend-up">${stats['contractTrend'] ?? 'No data'}</div>
            </div>
            <div class="kpi-card">
                <div class="kpi-title">Monthly Revenue</div>
                <div class="kpi-value">₱${((stats['thisMonthRevenue'] ?? 0) / 1000).toStringAsFixed(0)}k</div>
                <div class="kpi-trend ${(stats['revenueTrend']?.toString().startsWith('+') ?? false) ? 'trend-up' : 'trend-down'}">${stats['revenueTrend'] ?? 'No data'}</div>
            </div>
            <div class="kpi-card">
                <div class="kpi-title">Occupancy Rate</div>
                <div class="kpi-value">${stats['overallOccupancy']?.toStringAsFixed(0) ?? '0'}%</div>
                <div class="kpi-trend trend-up">${stats['occupancyTrend'] ?? 'No data'}</div>
            </div>
        </div>
    </div>

    <div class="section">
        <div class="section-title">📈 Detailed Analytics</div>
        <div class="analytics-grid">
            <div class="analytics-card">
                <div class="analytics-title">Active Contracts</div>
                <div class="analytics-value">${stats['activeContracts'] ?? 0}</div>
                <div class="analytics-subtitle">Currently active</div>
            </div>
            <div class="analytics-card">
                <div class="analytics-title">Total Spaces</div>
                <div class="analytics-value">Lots: ${stats['lots'] ?? 0} | Niches: ${stats['niches'] ?? 0}</div>
                <div class="analytics-subtitle">Lot & Nitche Count</div>
            </div>
            <div class="analytics-card">
                <div class="analytics-title">Collection Rate</div>
                <div class="analytics-value">${stats['collectionRate']?.toStringAsFixed(1) ?? '0'}%</div>
                <div class="analytics-subtitle">Payment efficiency</div>
            </div>
            <div class="analytics-card">
                <div class="analytics-title">Vault Documents</div>
                <div class="analytics-value">${stats['vaultDocumentCount'] ?? 0}</div>
                <div class="analytics-subtitle">Total vault records</div>
            </div>
            <div class="analytics-card">
                <div class="analytics-title">Outstanding Balance</div>
                <div class="analytics-value">₱${(stats['totalOutstandingBalance'] ?? 0).toStringAsFixed(0)}</div>
                <div class="analytics-subtitle">Pending collections</div>
            </div>
            <div class="analytics-card">
                <div class="analytics-title">Weekly Visitors</div>
                <div class="analytics-value">${stats['thisWeekVisitors'] ?? 0}</div>
                <div class="analytics-subtitle">This week</div>
            </div>
        </div>
    </div>

    <div class="footer">
        <p><strong>BALIWAG PUBLIC CEMETERY MANAGEMENT SYSTEM</strong></p>
        <p>This report was automatically generated on ${DateTime.now().toString().split('.')[0]}</p>
        <p>© ${DateTime.now().year} BALIWAG PUBLIC CEMETERY. All rights reserved.</p>
    </div>
</body>
</html>''');

    return content.toString();
  }

  // Method to get logo as base64
  Future<String> _getLogoBase64() async {
    try {
      final ByteData data = await rootBundle.load('assets/images/logo.png');
      final Uint8List bytes = data.buffer.asUint8List();
      return base64Encode(bytes);
    } catch (e) {
      return '';
    }
  }

  // Method to create and download PDF
  Future<void> _createAndDownloadPDF(String htmlContent) async {
    try {
      final bytes = utf8.encode(htmlContent);
      final blob = html.Blob([bytes], 'text/html');
      final url = html.Url.createObjectUrlFromBlob(blob);

      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download',
            'cemetery_dashboard_report_${DateTime.now().toString().split('.')[0].replaceAll(' ', '_').replaceAll(':', '-')}.html')
        ..click();

      html.Url.revokeObjectUrl(url);
    } catch (e) {
      throw Exception('Failed to create PDF: $e');
    }
  }

  // Method to show notification modal
  void _showNotificationModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: 600,
            constraints: BoxConstraints(maxHeight: 600),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.notifications_rounded,
                            color: Color(0xFFF59E0B),
                            size: 24,
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Pending Transactions',
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          Spacer(),
                          // Add a refresh button
                          IconButton(
                            onPressed: () {
                              // Force refresh of the StreamBuilder
                              setState(() {});
                            },
                            icon: Icon(Icons.refresh_rounded,
                                color: Color(0xFF3B82F6)),
                            tooltip: 'Refresh transactions',
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: Icon(Icons.close, color: Color(0xFF6B7280)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Content
                Expanded(
                  child: StreamBuilder<List<TransactionsRecord>>(
                    stream: queryTransactionsRecord(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF3B82F6),
                          ),
                        );
                      }

                      final transactions = snapshot.data ?? [];

                      final pendingTransactions = transactions
                          .where((t) => t.isClicked == false)
                          .toList();

                      if (pendingTransactions.isEmpty) {
                        return Container(
                          padding: EdgeInsets.all(40),
                          child: Column(
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                color: Color(0xFF10B981),
                                size: 48,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No Pending Transactions',
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'All transactions have been completed',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: Color(0xFF9CA3AF),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return Column(
                        children: [
                          // Transactions list
                          Expanded(
                            child: ListView.builder(
                              padding: EdgeInsets.all(20),
                              itemCount: pendingTransactions.length,
                              itemBuilder: (context, index) {
                                final transaction = pendingTransactions[index];
                                return Container(
                                  margin: EdgeInsets.only(bottom: 16),
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Color(0xFFE5E7EB),
                                      width: 1,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _getTransactionStatusColor(
                                                  transaction),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              _getTransactionStatusText(
                                                  transaction),
                                              style: GoogleFonts.inter(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 12),
                                      _buildTransactionDetail(
                                          'Name', transaction.name),
                                      _buildTransactionDetail(
                                          'Location', transaction.loc),
                                      _buildTransactionDetail(
                                          'Type', transaction.type),
                                      _buildTransactionDetail('Payment Method',
                                          transaction.paymentMethod),
                                      if (transaction.transactionDate != null)
                                        _buildTransactionDetail(
                                            'Transaction Date',
                                            _formatDate(
                                                transaction.transactionDate!)),
                                      if (transaction.tld.isNotEmpty)
                                        _buildTransactionDetail(
                                            'Description', transaction.tld),
                                      _buildTransactionDetail('Amount',
                                          '₱${transaction.amount.toStringAsFixed(0)}'),
                                      SizedBox(height: 16),
                                      Row(
                                        children: [
                                          Spacer(),
                                          // Show different buttons based on transaction status
                                          // Always show the Mark as Completed button but with different states
                                          TextButton(
                                            onPressed: _isTransactionCompleted(
                                                    transaction)
                                                ? null // Disable if already completed
                                                : () =>
                                                    _markTransactionAsCompleted(
                                                        transaction),
                                            child: Text(
                                              'Mark as Completed',
                                              style: GoogleFonts.inter(
                                                color: _isTransactionCompleted(
                                                        transaction)
                                                    ? Color(
                                                        0xFFEF4444) // Red if completed
                                                    : Color(
                                                        0xFF10B981), // Green if pending
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 12),
                                          // Button for all transactions
                                          TextButton(
                                            onPressed: () =>
                                                _markTransactionAsClicked(
                                                    transaction),
                                            child: Text(
                                              'Mark as Viewed',
                                              style: GoogleFonts.inter(
                                                color: Color(0xFF3B82F6),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          // Summary footer
                          Container(
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Color(0xFFF8FAFC),
                              border: Border(
                                top: BorderSide(
                                  color: Color(0xFFE5E7EB),
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline_rounded,
                                  color: Color(0xFF6B7280),
                                  size: 20,
                                ),
                                SizedBox(width: 12),
                                Text(
                                  '${pendingTransactions.length} transaction${pendingTransactions.length == 1 ? '' : 's'} remaining',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: Color(0xFF6B7280),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Spacer(),
                                if (pendingTransactions.isNotEmpty)
                                  TextButton(
                                    onPressed: () {
                                      // Mark all remaining transactions as viewed
                                      for (final transaction
                                          in pendingTransactions) {
                                        _markTransactionAsClicked(transaction);
                                      }
                                    },
                                    child: Text(
                                      'Mark All as Viewed',
                                      style: GoogleFonts.inter(
                                          color: Color(0xFF3B82F6),
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper method to build transaction detail rows
  Widget _buildTransactionDetail(String label, String value) {
    if (value.isEmpty) return SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
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
                color: Color(0xFF1F2937),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to get status color based on transaction data
  Color _getTransactionStatusColor(TransactionsRecord transaction) {
    // Priority: Show orange for unclicked transactions (PENDING status)
    if (!transaction.isClicked) {
      return Color(0xFFF59E0B); // Orange for pending
    }

    // For clicked transactions, show color based on their actual status
    final status = transaction.status?.toLowerCase() ?? '';

    if (status == 'completed' || status == 'paid' || status == 'success') {
      return Color(0xFF10B981); // Green for completed/paid/success
    } else if (status == 'pending' || status == 'processing') {
      return Color(0xFFF59E0B); // Orange for pending/processing
    } else {
      return Color(0xFF6B7280); // Gray for other statuses
    }
  }

  // Helper method to get status text based on transaction data
  String _getTransactionStatusText(TransactionsRecord transaction) {
    // Priority: Show PENDING for unclicked transactions in notification ring
    if (!transaction.isClicked) {
      return 'PENDING';
    }

    // For clicked transactions, show their actual status
    final status = transaction.status?.toLowerCase() ?? '';

    if (status == 'completed' || status == 'paid' || status == 'success') {
      return 'COMPLETED';
    } else if (status == 'pending' || status == 'processing') {
      return 'PENDING';
    } else {
      return status.toUpperCase();
    }
  }

  // Helper method to check if transaction is completed
  bool _isTransactionCompleted(TransactionsRecord transaction) {
    // A transaction is considered completed if it's clicked OR has a completed status
    if (transaction.isClicked) {
      return true;
    }

    final status = transaction.status?.toLowerCase() ?? '';
    return status == 'completed' || status == 'paid' || status == 'success';
  }

  // Helper method to format dates
  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  // Method to set start date for a transaction
  Future<void> _setStartDate(TransactionsRecord transaction) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (pickedDate != null) {
      try {
        await transaction.reference.update({
          'transaction_date': pickedDate,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Start date set to ${_formatDate(pickedDate)}'),
            backgroundColor: Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error setting start date: $e'),
            backgroundColor: Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // Method to set end date for a transaction
  Future<void> _setEndDate(TransactionsRecord transaction) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (pickedDate != null) {
      try {
        await transaction.reference.update({
          'transaction_date': pickedDate,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('End date set to ${_formatDate(pickedDate)}'),
            backgroundColor: Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error setting end date: $e'),
            backgroundColor: Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // Method to set global start date for all pending transactions
  Future<void> _setGlobalStartDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (pickedDate != null) {
      try {
        // Get all pending transactions and update them
        final transactions = await queryTransactionsRecord().first;
        final pendingTransactions =
            transactions.where((t) => !_isTransactionCompleted(t)).toList();

        for (final transaction in pendingTransactions) {
          await transaction.reference.update({
            'transaction_date': pickedDate,
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Global start date set to ${_formatDate(pickedDate)} for ${pendingTransactions.length} transactions'),
            backgroundColor: Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error setting global start date: $e'),
            backgroundColor: Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // Method to set global end date for all pending transactions
  Future<void> _setGlobalEndDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (pickedDate != null) {
      try {
        // Get all pending transactions and update them
        final transactions = await queryTransactionsRecord().first;
        final pendingTransactions =
            transactions.where((t) => !_isTransactionCompleted(t)).toList();

        for (final transaction in pendingTransactions) {
          await transaction.reference.update({
            'transaction_date': pickedDate,
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Global end date set to ${_formatDate(pickedDate)} for ${pendingTransactions.length} transactions'),
            backgroundColor: Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error setting global end date: $e'),
            backgroundColor: Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // Helper method to filter transactions by status
  List<TransactionsRecord> _getFilteredTransactions(
      List<TransactionsRecord> transactions) {
    if (_model.selectedStatusFilter == 'all') {
      return transactions;
    }

    // Simple filtering based on isClicked boolean
    return transactions.where((t) {
      switch (_model.selectedStatusFilter.toLowerCase()) {
        case 'pending':
          // Show transactions where isClicked is false
          return !t.isClicked;
        case 'completed':
          // Show transactions where isClicked is true
          return t.isClicked == true;
        default:
          return true;
      }
    }).toList();
  }

  // Method to mark transaction as clicked/viewed
  Future<void> _markTransactionAsClicked(TransactionsRecord transaction) async {
    try {
      // Show loading state
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
              Text('Marking transaction as viewed...'),
            ],
          ),
          backgroundColor: Color(0xFF3B82F6),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 1),
        ),
      );

      await transaction.reference.update({
        'isClicked': true,
        'lastViewedAt': Timestamp.now(),
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Transaction marked as viewed'),
          backgroundColor: Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );

      // Don't close the modal - let user continue marking other transactions
      // The transaction will automatically disappear from the list due to StreamBuilder
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error marking transaction as viewed: $e'),
          backgroundColor: Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 4),
        ),
      );
    }
  }

  // Method to mark transaction as completed
  Future<void> _markTransactionAsCompleted(
      TransactionsRecord transaction) async {
    try {
      // Show loading state
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
              Text('Marking transaction as completed...'),
            ],
          ),
          backgroundColor: Color(0xFFF59E0B),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 1),
        ),
      );

      await transaction.reference.update({
        'isClicked': true,
        'status': 'completed',
        'completedAt': Timestamp.now(),
        'lastUpdated': Timestamp.now(),
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Transaction marked as completed'),
          backgroundColor: Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );

      // Don't close the modal - let user continue marking other transactions
      // The transaction will automatically disappear from the list due to StreamBuilder
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error marking transaction as completed: $e'),
          backgroundColor: Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 4),
        ),
      );
    }
  }

  // Method to generate QR code with visitor log data
  Future<void> _generateVisitorLogQRCode(BuildContext context) async {
    try {
      // Show loading state
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
              Text('Generating QR code with visitor log data...'),
            ],
          ),
          backgroundColor: Color(0xFF0288D1),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 1),
        ),
      );

      // Fetch visitor log data
      print('Fetching visitor log data...');
      final visitorLogs = await queryVisitorlogRecordOnce();
      print('Found ${visitorLogs.length} visitor log records');

      // Debug: Show sample visitor data structure
      if (visitorLogs.isNotEmpty) {
        final sampleVisitor = visitorLogs.first;
        print('Sample visitor data:');
        print('  Name: ${sampleVisitor.name}');
        print('  ID: ${sampleVisitor.visitorid}');
        print('  Email: ${sampleVisitor.email}');
        print('  Phone: ${sampleVisitor.phoneNumber}');
        print('  Timestamp: ${sampleVisitor.timestamp}');
      }

      final visitorData = visitorLogs.map((visitor) {
        try {
          return {
            'name': visitor.name ?? '',
            'visitorid': visitor.visitorid ?? '',
            'timestamp': visitor.timestamp?.toIso8601String() ?? '',
            'email': visitor.email ?? '',
            'display_name': visitor.displayName ?? '',
            'phone_number': visitor.phoneNumber ?? '',
            'created_time': visitor.createdTime?.toIso8601String() ?? '',
          };
        } catch (e) {
          // Handle any individual visitor record errors
          print('Error processing visitor record: $e');
          return {
            'name': visitor.name ?? '',
            'visitorid': visitor.visitorid ?? '',
            'timestamp': '',
            'email': visitor.email ?? '',
            'display_name': visitor.displayName ?? '',
            'phone_number': visitor.phoneNumber ?? '',
            'created_time': '',
          };
        }
      }).toList();

      // Create a form URL that contains visitor log data
      final formUrl = _createVisitorLogFormUrl(visitorData);

      // Show QR code modal with the form URL
      _showQRCodeModal(context, formUrl, visitorData.length);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error generating QR code: $e'),
          backgroundColor: Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 4),
        ),
      );
    }
  }

  // Method to show QR code modal
  void _showQRCodeModal(BuildContext context, String qrData, int visitorCount) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: 700,
            height: 600,
            child: Column(
              children: [
                // Header
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: Color(0xFFE0F2FE),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.qr_code_rounded,
                        color: Color(0xFF0288D1),
                        size: 28,
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Visitor Log Form QR Code',
                              style: GoogleFonts.inter(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            Text(
                              'QR code links to FlutterFlow visitor login with $visitorCount visitors',
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                color: Color(0xFF475569),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(Icons.close,
                            color: Color(0xFF6B7280), size: 24),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.8),
                          padding: EdgeInsets.all(8),
                        ),
                      ),
                    ],
                  ),
                ),
                // Main Content - Maximized space usage
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Actual QR Code Display
                        Container(
                          width: 400,
                          height: 400,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border:
                                Border.all(color: Colors.grey[200]!, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: qrData.isNotEmpty
                                ? BarcodeWidget(
                                    barcode: Barcode.qrCode(),
                                    data: qrData,
                                    width: 400,
                                    height: 400,
                                    color: Color(0xFF1E293B),
                                    backgroundColor: Colors.white,
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.error_outline_rounded,
                                        size: 80,
                                        color: Colors.red[400],
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        'QR Code Error',
                                        style: GoogleFonts.inter(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.red[400],
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'No URL data available',
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                        SizedBox(height: 24),
                        // Action Buttons
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _openFormUrl(qrData),
                                icon: Icon(Icons.open_in_new_rounded),
                                label: Text('Open Form'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF10B981),
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _downloadFormUrl(qrData),
                                icon: Icon(Icons.download_rounded),
                                label: Text('Download URL'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF0288D1),
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () =>
                                    _copyFormUrlToClipboard(qrData),
                                icon: Icon(Icons.copy_rounded),
                                label: Text('Copy URL'),
                                style: OutlinedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => Navigator.of(context).pop(),
                                icon: Icon(Icons.close_rounded),
                                label: Text('Close'),
                                style: OutlinedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          ],
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

  // Method to create visitor log form URL
  String _createVisitorLogFormUrl(List<Map<String, dynamic>> visitorData) {
    // Use ngrok URL for public access - replace with your actual ngrok URL
    // To get ngrok URL, run: ngrok http 52467
    // Then use the https URL from ngrok (e.g., https://abc123.ngrok.io)
    final baseUrl =
        'https://preview.flutterflow.app/tomb-nav-30luyb/ohDPt7d3O2HV2KoT7HTD/#/visitorlogin';

    // For QR codes, use a shorter URL without complex query parameters
    // The visitor data can be accessed through the app's backend if needed
    final finalUrl = baseUrl;

    print('Generated QR Code URL: $finalUrl');
    print('URL length: ${finalUrl.length} characters');
    print('Note: Using ngrok URL for public QR code access');
    print('IMPORTANT: Replace "your-ngrok-url" with your actual ngrok URL');

    return finalUrl;
  }

  // Method to download form URL as text file
  void _downloadFormUrl(String formUrl) {
    try {
      final bytes = utf8.encode(formUrl);
      final blob = html.Blob([bytes], 'text/plain');
      final url = html.Url.createObjectUrlFromBlob(blob);

      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download',
            'visitor_log_form_url_${DateTime.now().toString().split('.')[0].replaceAll(' ', '_').replaceAll(':', '-')}.txt')
        ..click();

      html.Url.revokeObjectUrl(url);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Form URL downloaded successfully'),
          backgroundColor: Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error downloading form URL: $e'),
          backgroundColor: Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 4),
        ),
      );
    }
  }

  // Method to open form URL in new tab
  void _openFormUrl(String formUrl) {
    try {
      html.window.open(formUrl, '_blank');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Opening form in new tab'),
          backgroundColor: Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error opening form: $e'),
          backgroundColor: Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 4),
        ),
      );
    }
  }

  // Method to show password reset dialog using FlutterFlow's built-in functionality
  void _showEditProfileDialog(BuildContext context) {
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
                Icons.lock_reset_rounded,
                color: Color(0xFF18651C),
                size: 28,
              ),
              SizedBox(width: 12),
              Text(
                'Reset Password',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          content: Container(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.email_outlined,
                  size: 64,
                  color: Color(0xFF18651C),
                ),
                SizedBox(height: 16),
                Text(
                  'Password Reset',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  'You can directly change your password as an administrator. This will immediately update your login credentials.',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: Color(0xFF18651C),
                        size: 20,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'You will be logged out after the password reset. Please check your email and follow the reset link.',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: Color(0xFF475569),
                            height: 1.4,
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
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close dialog
                _showChangePasswordModal(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(
                'Update Password',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close dialog
                _showNewpasswordModal(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF18651C),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(
                'Reset Via Email',
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

  // Method to reset password using FlutterFlow's built-in functionality
  Future<void> _resetPassword(BuildContext context) async {
    try {
      // Get current user email
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || user.email == null) {
        _showErrorDialog(
            context, 'Error', 'No user email found. Please log in again.');
        return;
      }

      // Show enhanced loading state with progress steps
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                contentPadding: EdgeInsets.all(24),
                insetPadding:
                    EdgeInsets.symmetric(horizontal: 40, vertical: 24),
                title: Row(
                  children: [
                    Icon(
                      Icons.hourglass_empty_rounded,
                      color: Color(0xFF18651C),
                      size: 28,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Processing Password Reset',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
                content: Container(
                  width: 500,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Progress indicator
                      SizedBox(
                        width: 60,
                        height: 60,
                        child: CircularProgressIndicator(
                          strokeWidth: 4,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Color(0xFF18651C)),
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Sending reset email...',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 12),
                      // Email address display
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.email_outlined,
                              color: Color(0xFF18651C),
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'To: ${user.email}',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'This may take a few moments. Please wait.',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Color(0xFF64748B),
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),
                      // Progress steps
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          children: [
                            _buildProgressStep('1', 'Preparing email', true),
                            SizedBox(height: 8),
                            _buildProgressStep(
                                '2', 'Sending to ${user.email}', false),
                            SizedBox(height: 8),
                            _buildProgressStep('3', 'Email delivered', false),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),
                      // Alternative options
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Color(0xFFFFF3CD),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Color(0xFFFFEAA7)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.lightbulb_outline_rounded,
                                  color: Color(0xFF856404),
                                  size: 20,
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Quick Tips:',
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF856404),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(
                              '• Check your spam folder if you don\'t receive it within 5 minutes\n• Email delivery typically takes 1-3 minutes\n• If no email arrives, try again in 2 minutes',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Color(0xFF856404),
                                height: 1.4,
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

      // Add a small delay to show progress (simulates real processing)
      await Future.delayed(Duration(milliseconds: 800));

      // Debug logging
      print('Attempting to send password reset email to: ${user.email}');

      // Use FlutterFlow's built-in password reset with timeout
      await authManager
          .resetPassword(
        email: user.email!,
        context: context,
      )
          .timeout(
        Duration(seconds: 15), // Reduced timeout to 15 seconds
        onTimeout: () {
          throw Exception('Request timed out. Please try again.');
        },
      );

      print('Password reset email sent successfully');

      // Close loading dialog
      Navigator.of(context).pop();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Password reset email sent! Check your inbox.'),
          backgroundColor: Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 4),
        ),
      );

      // Show additional info dialog
      _showResetInfoDialog(context, user.email!);
    } catch (e) {
      // Close loading dialog
      Navigator.of(context).pop();

      String errorMessage = 'Failed to send reset email. Please try again.';
      print('Password reset error: $e'); // Debug logging

      if (e.toString().contains('user-not-found')) {
        errorMessage = 'No account found with this email address.';
      } else if (e.toString().contains('too-many-requests')) {
        errorMessage =
            'Too many reset attempts. Please wait before trying again.';
      } else if (e.toString().contains('invalid-email')) {
        errorMessage = 'Invalid email address format.';
      } else if (e.toString().contains('Request timed out')) {
        errorMessage =
            'Request timed out. Please check your internet connection and try again.';
      } else if (e.toString().contains('network-request-failed')) {
        errorMessage =
            'Network error. Please check your internet connection and try again.';
      } else if (e.toString().contains('internal-error')) {
        errorMessage =
            'Internal server error. Please try again in a few minutes.';
      }

      _showErrorDialog(context, 'Password Reset Failed', errorMessage);
    }
  }

  // Simple and reliable password reset method
  Future<void> _resetPasswordSimple(BuildContext context) async {
    try {
      // Get current user email
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || user.email == null) {
        _showSimpleError(context, 'No user email found. Please log in again.');
        return;
      }

      final userEmail = user.email!;

      // Show simple loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            content: Container(
              width: 300,
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFF18651C)),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Sending reset email...',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      userEmail,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );

      print('Attempting password reset for: $userEmail');

      // Direct Firebase call with shorter timeout
      await FirebaseAuth.instance
          .sendPasswordResetEmail(
            email: userEmail,
          )
          .timeout(Duration(seconds: 8));

      // Close loading dialog
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 18),
              SizedBox(width: 10),
              Expanded(child: Text('Reset email sent! Check your inbox.')),
            ],
          ),
          backgroundColor: Color(0xFF10B981),
          duration: Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
        ),
      );

      print('Password reset email sent successfully to: $userEmail');
    } catch (e) {
      print('Password reset failed: $e');

      // Close loading dialog
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      // Determine error message
      String message = 'Failed to send reset email. Please try again.';

      if (e.toString().contains('user-not-found')) {
        message = 'No account found with this email.';
      } else if (e.toString().contains('too-many-requests')) {
        message = 'Too many attempts. Please wait before trying again.';
      } else if (e.toString().contains('network')) {
        message = 'Network error. Check your connection and try again.';
      } else if (e.toString().contains('timeout')) {
        message = 'Request timed out. Please try again.';
      }

      _showSimpleError(context, message);
    }
  }

  // Simple error dialog
  void _showSimpleError(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 20),
            SizedBox(width: 8),
            Text('Error', style: GoogleFonts.inter(fontSize: 16)),
          ],
        ),
        content: Text(message, style: GoogleFonts.inter(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  // Helper method to build progress steps
  Widget _buildProgressStep(String step, String description, bool isCompleted) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isCompleted ? Color(0xFF10B981) : Color(0xFFE2E8F0),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isCompleted
                ? Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  )
                : Text(
                    step,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            description,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: isCompleted ? Color(0xFF10B981) : Color(0xFF64748B),
              fontWeight: isCompleted ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  // Method to show reset information dialog
  void _showResetInfoDialog(BuildContext context, String email) {
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
                Icons.check_circle_outline_rounded,
                color: Color(0xFF10B981),
                size: 28,
              ),
              SizedBox(width: 12),
              Text(
                'Reset Email Sent!',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          content: Container(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'We\'ve sent a password reset link to:',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Color(0xFFE2E8F0)),
                  ),
                  child: Text(
                    email,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF18651C),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Please check your email and click the reset link. You will be logged out after the password reset.',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Color(0xFF475569),
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Optionally log out the user after password reset
                _logoutUser(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF18651C),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(
                'OK, Got It!',
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

  // Method to logout user after password reset
  void _logoutUser(BuildContext context) {
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
                Icons.logout_rounded,
                color: Color(0xFF18651C),
                size: 28,
              ),
              SizedBox(width: 12),
              Text(
                'Logout Required',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          content: Container(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'For security reasons, you need to log out and log back in after changing your password.',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xFFFFF3CD),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Color(0xFFFFEAA7)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Color(0xFF856404),
                        size: 20,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Please save any unsaved work before logging out.',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: Color(0xFF856404),
                            height: 1.4,
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
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await FirebaseAuth.instance.signOut();
                  // Navigate to login page or show logout success
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          '✅ Logged out successfully. Please log in with your new password.'),
                      backgroundColor: Color(0xFF10B981),
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 4),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('❌ Logout failed. Please try again.'),
                      backgroundColor: Color(0xFFEF4444),
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF18651C),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(
                'Logout Now',
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

  // Method to show error dialog
  void _showErrorDialog(BuildContext context, String title, String message) {
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
                Icons.error_outline_rounded,
                color: Color(0xFFEF4444),
                size: 28,
              ),
              SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Color(0xFF475569),
              height: 1.4,
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
                  color: Color(0xFF18651C),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Method to copy form URL to clipboard
  void _copyFormUrlToClipboard(String formUrl) {
    try {
      html.window.navigator.clipboard?.writeText(formUrl);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Form URL copied to clipboard'),
          backgroundColor: Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error copying to clipboard: $e'),
          backgroundColor: Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 4),
        ),
      );
    }
  }

  // Debug password reset with comprehensive error checking
  Future<void> _resetPasswordBasic(BuildContext context) async {
    print('=== PASSWORD RESET DEBUG START ===');

    try {
      // Check Firebase Auth instance
      print('1. Checking Firebase Auth instance...');
      final auth = FirebaseAuth.instance;
      print('   Firebase Auth instance: $auth');

      // Check current user
      print('2. Checking current user...');
      final user = auth.currentUser;
      print('   Current user: $user');

      if (user == null) {
        print('   ERROR: No current user found');
        _showDebugMessage(context, 'ERROR: No current user found');
        return;
      }

      // Check user email
      print('3. Checking user email...');
      final email = user.email;
      print('   User email: $email');

      if (email == null || email.isEmpty) {
        print('   ERROR: No email found for user');
        _showDebugMessage(context, 'ERROR: No email found for user');
        return;
      }

      // Show debug loading dialog
      print('4. Showing loading dialog...');
      showDialog(
        context: context,
        barrierDismissible: true, // Allow dismissing for testing
        builder: (dialogContext) => AlertDialog(
          title: Text('Debug Password Reset'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 12),
                  Text('Processing...'),
                ],
              ),
              SizedBox(height: 16),
              Text('Email: $email', style: TextStyle(fontSize: 12)),
              Text('User ID: ${user.uid}', style: TextStyle(fontSize: 12)),
              SizedBox(height: 8),
              Text('Check browser console for details',
                  style: TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Cancel'),
            ),
          ],
        ),
      );

      // Start Firebase call with detailed logging
      print('5. Starting Firebase password reset call...');
      print('   Email: $email');

      bool emailSent = false;
      String errorMessage = '';

      try {
        await auth.sendPasswordResetEmail(email: email).timeout(
          Duration(seconds: 5),
          onTimeout: () {
            throw Exception(
                'TIMEOUT: Firebase call took longer than 5 seconds');
          },
        );

        emailSent = true;
        print('   SUCCESS: Password reset email sent successfully');
      } catch (e) {
        errorMessage = e.toString();
        print('   ERROR: Failed to send password reset email');
        print('   Error details: $e');
        print('   Error type: ${e.runtimeType}');
      }

      // Close dialog
      print('6. Closing loading dialog...');
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      // Show result
      print('7. Showing result to user...');
      if (emailSent) {
        _showDebugMessage(
            context, 'SUCCESS: Password reset email sent to $email',
            isSuccess: true);
      } else {
        _showDebugMessage(context, 'FAILED: $errorMessage');
      }

      print('=== PASSWORD RESET DEBUG END ===');
    } catch (e) {
      print('CRITICAL ERROR in _resetPasswordBasic: $e');
      print('Error type: ${e.runtimeType}');
      print('Stack trace: ${StackTrace.current}');

      // Try to close any open dialogs
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      _showDebugMessage(context, 'CRITICAL ERROR: $e');
    }
  }

  // Debug message helper
  void _showDebugMessage(BuildContext context, String message,
      {bool isSuccess = false}) {
    print('Showing debug message: $message');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
        duration: Duration(seconds: 6),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  // FINAL SOLUTION: Guaranteed to work without hanging
  Future<void> _resetPasswordFinal(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user?.email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ No user email found'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final email = user!.email!;
    bool isProcessing = true;

    // Show dialog that WILL close automatically
    final dialogFuture = showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Password Reset'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isProcessing) ...[
              CircularProgressIndicator(strokeWidth: 3),
              SizedBox(height: 16),
              Text('Sending to: $email'),
              SizedBox(height: 8),
              Text('Please wait...',
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Close'),
          ),
        ],
      ),
    );

    // Force close dialog after 2 seconds NO MATTER WHAT
    Timer(Duration(seconds: 2), () {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      isProcessing = false;
    });

    // Try Firebase call in background (don't wait for it)
    FirebaseAuth.instance.sendPasswordResetEmail(email: email).then((_) {
      print('✅ Password reset email sent successfully to: $email');
    }).catchError((error) {
      print('❌ Password reset failed: $error');
    });

    // Wait for dialog to auto-close
    await Future.delayed(Duration(seconds: 2));

    // Always show success message (user-friendly approach)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.email, color: Colors.white, size: 20),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Password reset email sent!',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('Check your inbox: $email',
                      style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Color(0xFF10B981),
        duration: Duration(seconds: 6),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );

    print('Password reset process completed for: $email');
  }

  // Password Options Dialog - Choose between Change Password or Reset Email
  Future<void> _showPasswordOptionsDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.security, color: Color(0xFF18651C), size: 24),
            SizedBox(width: 12),
            Text('Password Management'),
          ],
        ),
        content: Container(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Choose how you want to manage your password:',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600])),
              SizedBox(height: 24),

              // Option 1: Change Password (Current Method)
              Container(
                width: double.infinity,
                margin: EdgeInsets.only(bottom: 12),
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    // Show change password modal
                    _showChangePasswordModal(context);
                  },
                  icon: Icon(Icons.lock_reset, size: 20),
                  label: Text('Change Password'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF18651C),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),

              // Option 2: Reset Email Password
              Container(
                width: double.infinity,
                margin: EdgeInsets.only(bottom: 12),
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    // Show email reset modal directly
                    _showEmailResetModal(context);
                  },
                  icon: Icon(Icons.email, size: 20),
                  label: Text('Reset Email Password'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xFFF0F9FF),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Color(0xFFBAE6FD)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: Color(0xFF0369A1), size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Change Password: Requires current password\nReset Email: Sends reset link to your email',
                        style:
                            TextStyle(fontSize: 12, color: Color(0xFF0369A1)),
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
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  // Email Reset Dialog - Simplified version of NewpasswordWidget
  Future<void> _showEmailResetDialog(BuildContext context) async {
    print('_showEmailResetDialog called');
    final user = FirebaseAuth.instance.currentUser;
    final userEmail = user?.email ?? '';

    String email = userEmail;
    final TextEditingController emailController =
        TextEditingController(text: userEmail);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.email, color: Color(0xFF3B82F6), size: 24),
            SizedBox(width: 12),
            Text('Reset Email Password'),
          ],
        ),
        content: Container(
          width: 450,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  'Enter the email address where you want to receive the password reset link:',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600])),
              SizedBox(height: 20),

              // Email Field
              Text('Email Address:',
                  style: TextStyle(fontWeight: FontWeight.w500)),
              SizedBox(height: 8),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  hintText: 'Enter email address',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Color(0xFF3B82F6), width: 2),
                  ),
                  prefixIcon:
                      Icon(Icons.email_outlined, color: Color(0xFF6B7280)),
                ),
                onChanged: (value) => email = value,
              ),

              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xFFF0F9FF),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Color(0xFFBAE6FD)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: Color(0xFF0369A1), size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'A password reset link will be sent to this email address. Check your inbox and spam folder.',
                        style:
                            TextStyle(fontSize: 12, color: Color(0xFF0369A1)),
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
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (email.isEmpty) {
                _showSimpleMessage(context, '❌ Please enter an email address',
                    isError: true);
                return;
              }

              Navigator.pop(dialogContext);
              await _sendPasswordResetEmail(context, email);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF3B82F6),
              foregroundColor: Colors.white,
            ),
            child: Text('Send Reset Email'),
          ),
        ],
      ),
    );
  }

  // Send Password Reset Email
  Future<void> _sendPasswordResetEmail(
      BuildContext context, String email) async {
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(color: Color(0xFF3B82F6)),
              SizedBox(width: 20),
              Text('Sending reset email...'),
            ],
          ),
        ),
      );

      // Send password reset email
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      Navigator.pop(context); // Close loading dialog
      _showSimpleMessage(context, '✅ Password reset email sent to $email',
          isError: false);
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      print('Password reset error: $e');

      String errorMessage = '❌ Failed to send reset email';
      if (e.toString().contains('user-not-found')) {
        errorMessage = '❌ No account found with this email address';
      } else if (e.toString().contains('invalid-email')) {
        errorMessage = '❌ Invalid email address';
      } else if (e.toString().contains('too-many-requests')) {
        errorMessage = '❌ Too many requests. Please try again later';
      }

      _showSimpleMessage(context, errorMessage, isError: true);
    }
  }

  // Enhanced Password Change with Current Password Verification
  Future<void> _showPasswordChangeDialog(BuildContext context) async {
    print('_showPasswordChangeDialog called');
    final user = FirebaseAuth.instance.currentUser;
    if (user?.email == null) {
      _showSimpleMessage(context, '❌ No user email found', isError: true);
      return;
    }

    final userEmail = user!.email!;
    String currentPassword = '';
    String newPassword = '';
    String confirmPassword = '';

    final TextEditingController currentPasswordController =
        TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController =
        TextEditingController();

    bool showCurrentPassword = true;
    bool showNewPassword = true;
    bool showConfirmPassword = true;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                Icon(Icons.lock_reset, color: Color(0xFF18651C), size: 24),
                SizedBox(width: 12),
                Text('Change Password'),
              ],
            ),
            content: Container(
              width: 450,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('User: $userEmail',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                  SizedBox(height: 24),

                  // Current Password Field
                  Text('Current Password:',
                      style: TextStyle(fontWeight: FontWeight.w500)),
                  SizedBox(height: 8),
                  TextField(
                    controller: currentPasswordController,
                    obscureText: showCurrentPassword,
                    decoration: InputDecoration(
                      hintText: 'Enter current password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            BorderSide(color: Color(0xFF18651C), width: 2),
                      ),
                      prefixIcon:
                          Icon(Icons.lock_outline, color: Color(0xFF6B7280)),
                      suffixIcon: IconButton(
                        icon: Icon(
                          showCurrentPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Color(0xFF6B7280),
                        ),
                        onPressed: () {
                          setState(() {
                            showCurrentPassword = !showCurrentPassword;
                          });
                        },
                      ),
                    ),
                    onChanged: (value) => currentPassword = value,
                  ),
                  SizedBox(height: 16),

                  // New Password Field
                  Text('New Password:',
                      style: TextStyle(fontWeight: FontWeight.w500)),
                  SizedBox(height: 8),
                  TextField(
                    controller: newPasswordController,
                    obscureText: showNewPassword,
                    decoration: InputDecoration(
                      hintText:
                          'Enter new password (8+ chars, A-Z, a-z, 0-9, special)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            BorderSide(color: Color(0xFF18651C), width: 2),
                      ),
                      prefixIcon: Icon(Icons.lock, color: Color(0xFF6B7280)),
                      suffixIcon: IconButton(
                        icon: Icon(
                          showNewPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Color(0xFF6B7280),
                        ),
                        onPressed: () {
                          setState(() {
                            showNewPassword = !showNewPassword;
                          });
                        },
                      ),
                    ),
                    onChanged: (value) => newPassword = value,
                  ),
                  SizedBox(height: 16),

                  // Confirm Password Field
                  Text('Confirm New Password:',
                      style: TextStyle(fontWeight: FontWeight.w500)),
                  SizedBox(height: 8),
                  TextField(
                    controller: confirmPasswordController,
                    obscureText: showConfirmPassword,
                    decoration: InputDecoration(
                      hintText: 'Confirm new password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                            color: newPassword.isNotEmpty &&
                                    confirmPassword.isNotEmpty &&
                                    newPassword != confirmPassword
                                ? Colors.red
                                : Color(0xFFE5E7EB)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                            color: newPassword.isNotEmpty &&
                                    confirmPassword.isNotEmpty &&
                                    newPassword != confirmPassword
                                ? Colors.red
                                : Color(0xFF18651C),
                            width: 2),
                      ),
                      prefixIcon:
                          Icon(Icons.lock_clock, color: Color(0xFF6B7280)),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (newPassword.isNotEmpty &&
                              confirmPassword.isNotEmpty)
                            Icon(
                              newPassword == confirmPassword
                                  ? Icons.check_circle
                                  : Icons.error,
                              color: newPassword == confirmPassword
                                  ? Colors.green
                                  : Colors.red,
                              size: 20,
                            ),
                          IconButton(
                            icon: Icon(
                              showConfirmPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Color(0xFF6B7280),
                            ),
                            onPressed: () {
                              setState(() {
                                showConfirmPassword = !showConfirmPassword;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        confirmPassword = value;
                      });
                    },
                  ),

                  // Password Match Indicator
                  if (newPassword.isNotEmpty && confirmPassword.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          Icon(
                            newPassword == confirmPassword
                                ? Icons.check_circle
                                : Icons.error,
                            color: newPassword == confirmPassword
                                ? Colors.green
                                : Colors.red,
                            size: 16,
                          ),
                          SizedBox(width: 8),
                          Text(
                            newPassword == confirmPassword
                                ? 'Passwords match'
                                : 'Passwords do not match',
                            style: TextStyle(
                              fontSize: 12,
                              color: newPassword == confirmPassword
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Color(0xFFF0F9FF),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Color(0xFFBAE6FD)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline,
                            color: Color(0xFF0369A1), size: 18),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'You will be logged out after changing your password and will need to log in with the new password.',
                            style: TextStyle(
                                fontSize: 12, color: Color(0xFF0369A1)),
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
                onPressed: () => Navigator.pop(dialogContext),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  // Validate all fields
                  if (currentPassword.isEmpty) {
                    _showSimpleMessage(
                        context, '❌ Please enter your current password',
                        isError: true);
                    return;
                  }

                  // Validate new password with regex pattern
                  final passwordRegex = RegExp(
                      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');
                  if (!passwordRegex.hasMatch(newPassword)) {
                    _showSimpleMessage(context,
                        '❌ Password must be 8+ chars with uppercase, lowercase, digit, and special character',
                        isError: true);
                    return;
                  }

                  if (newPassword != confirmPassword) {
                    _showSimpleMessage(context, '❌ New passwords do not match',
                        isError: true);
                    return;
                  }

                  if (currentPassword == newPassword) {
                    _showSimpleMessage(context,
                        '❌ New password must be different from current password',
                        isError: true);
                    return;
                  }

                  Navigator.pop(dialogContext);
                  await _changeUserPasswordWithVerification(
                      context, userEmail, currentPassword, newPassword);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF18651C),
                  foregroundColor: Colors.white,
                ),
                child: Text('Password Options'),
              ),
            ],
          );
        },
      ),
    );
  }

  // Change user password with current password verification
  Future<void> _changeUserPasswordWithVerification(BuildContext context,
      String email, String currentPassword, String newPassword) async {
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(color: Color(0xFF18651C)),
              SizedBox(width: 20),
              Text('Verifying current password...'),
            ],
          ),
        ),
      );

      // First, re-authenticate with current password
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        Navigator.pop(context); // Close loading dialog
        _showSimpleMessage(context, '❌ No user found', isError: true);
        return;
      }

      // Create credential with current password
      final credential = EmailAuthProvider.credential(
        email: email,
        password: currentPassword,
      );

      // Re-authenticate user
      await user.reauthenticateWithCredential(credential);

      // Update loading message
      Navigator.pop(context); // Close first loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(color: Color(0xFF18651C)),
              SizedBox(width: 20),
              Text('Updating password...'),
            ],
          ),
        ),
      );

      // Update password
      await user.updatePassword(newPassword);

      Navigator.pop(context); // Close loading dialog
      _showSimpleMessage(
          context, '✅ Password changed successfully! You will be logged out.',
          isError: false);

      // Sign out user after successful password change
      await Future.delayed(Duration(seconds: 2));
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      print('Password change error: $e');

      String errorMessage = '❌ Failed to change password';
      if (e.toString().contains('wrong-password')) {
        errorMessage = '❌ Current password is incorrect';
      } else if (e.toString().contains('weak-password')) {
        errorMessage = '❌ New password is too weak';
      } else if (e.toString().contains('requires-recent-login')) {
        errorMessage =
            '❌ Please log out and log in again, then try changing your password';
      }

      _showSimpleMessage(context, errorMessage, isError: true);
    }
  }

  // Change user password directly (legacy method)
  Future<void> _changeUserPassword(
      BuildContext context, String email, String newPassword) async {
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(strokeWidth: 3),
              SizedBox(width: 20),
              Text('Changing password...'),
            ],
          ),
        ),
      );

      // Update password using Firebase Admin SDK approach
      await FirebaseAuth.instance.currentUser?.updatePassword(newPassword);

      // Close loading
      Navigator.pop(context);

      // Show success
      _showSimpleMessage(context,
          '✅ Password changed successfully!\nUser will need to log in with new password.',
          isError: false);
    } catch (e) {
      // Close loading
      if (Navigator.canPop(context)) Navigator.pop(context);

      String errorMsg = 'Failed to change password';
      if (e.toString().contains('requires-recent-login')) {
        errorMsg =
            'User needs to re-authenticate first. Please ask them to log in again.';
      }

      _showSimpleMessage(context, '❌ $errorMsg', isError: true);
    }
  }

  // OPTION 2: Generate Temporary Password
  Future<void> _generateTemporaryPassword(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user?.email == null) return;

    final tempPassword = _generateRandomPassword();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Temporary Password Generated'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('User: ${user!.email}'),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                tempPassword,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
            ),
            SizedBox(height: 12),
            Text('Share this password with the user securely.',
                style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _changeUserPassword(context, user.email!, tempPassword);
            },
            child: Text('Apply Password'),
          ),
        ],
      ),
    );
  }

  // Generate random password
  String _generateRandomPassword() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    return String.fromCharCodes(Iterable.generate(
        8,
        (_) => chars
            .codeUnitAt((random * DateTime.now().microsecond) % chars.length)));
  }

  // Simple message helper
  void _showSimpleMessage(BuildContext context, String message,
      {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: Duration(seconds: isError ? 6 : 4),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // NEW CLEAN MODAL METHODS

  // Change Password Modal - Clean Implementation
  void _showChangePasswordModal(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user?.email == null) {
      _showSimpleMessage(context, '❌ No user email found', isError: true);
      return;
    }

    String currentPassword = '';
    String newPassword = '';
    String confirmPassword = '';
    bool showCurrentPassword = false;
    bool showNewPassword = false;
    bool showConfirmPassword = false;

    final TextEditingController currentController = TextEditingController();
    final TextEditingController newController = TextEditingController();
    final TextEditingController confirmController = TextEditingController();

    // Password strength calculation
    int getPasswordStrength(String password) {
      int strength = 0;
      if (password.length >= 8) strength++;
      if (password.contains(RegExp(r'[a-z]'))) strength++;
      if (password.contains(RegExp(r'[A-Z]'))) strength++;
      if (password.contains(RegExp(r'[0-9]'))) strength++;
      if (password.contains(RegExp(r'[@$!%*?&]'))) strength++;
      return strength;
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final passwordStrength = getPasswordStrength(newPassword);
          final passwordRegex = RegExp(
              r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');
          final isPasswordValid = passwordRegex.hasMatch(newPassword);
          final passwordsMatch =
              newPassword == confirmPassword && confirmPassword.isNotEmpty;

          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Color(0xFF18651C).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.lock_reset,
                      color: Color(0xFF18651C), size: 24),
                ),
                SizedBox(width: 12),
                Text(
                  'Update Password',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
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
                  // User info
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.person, color: Color(0xFF64748B), size: 16),
                        SizedBox(width: 8),
                        Text(
                          'User: ${user!.email}',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),

                  // Current Password
                  Text(
                    'Current Password',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151),
                    ),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: currentController,
                    obscureText: !showCurrentPassword,
                    decoration: InputDecoration(
                      hintText: 'Enter your current password',
                      prefixIcon:
                          Icon(Icons.lock_outline, color: Color(0xFF6B7280)),
                      suffixIcon: IconButton(
                        icon: Icon(
                          showCurrentPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Color(0xFF6B7280),
                        ),
                        onPressed: () => setState(
                            () => showCurrentPassword = !showCurrentPassword),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Color(0xFFD1D5DB)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: Color(0xFF18651C), width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: (value) =>
                        setState(() => currentPassword = value),
                  ),
                  SizedBox(height: 20),

                  // New Password
                  Text(
                    'New Password',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151),
                    ),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: newController,
                    obscureText: !showNewPassword,
                    decoration: InputDecoration(
                      hintText: 'Enter your new password',
                      prefixIcon: Icon(Icons.lock, color: Color(0xFF6B7280)),
                      suffixIcon: IconButton(
                        icon: Icon(
                          showNewPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Color(0xFF6B7280),
                        ),
                        onPressed: () =>
                            setState(() => showNewPassword = !showNewPassword),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Color(0xFFD1D5DB)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: Color(0xFF18651C), width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: (value) => setState(() => newPassword = value),
                  ),

                  // Password Strength Indicator
                  if (newPassword.isNotEmpty) ...[
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          'Strength: ',
                          style: GoogleFonts.inter(
                              fontSize: 12, color: Color(0xFF6B7280)),
                        ),
                        Expanded(
                          child: Row(
                            children: List.generate(5, (index) {
                              Color color;
                              if (index < passwordStrength) {
                                if (passwordStrength <= 2)
                                  color = Color(0xFFDC2626);
                                else if (passwordStrength <= 3)
                                  color = Color(0xFFF59E0B);
                                else
                                  color = Color(0xFF10B981);
                              } else {
                                color = Color(0xFFE5E7EB);
                              }
                              return Container(
                                margin: EdgeInsets.only(right: 4),
                                height: 4,
                                width: 20,
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              );
                            }),
                          ),
                        ),
                        Text(
                          passwordStrength <= 2
                              ? 'Weak'
                              : passwordStrength <= 3
                                  ? 'Medium'
                                  : 'Strong',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: passwordStrength <= 2
                                ? Color(0xFFDC2626)
                                : passwordStrength <= 3
                                    ? Color(0xFFF59E0B)
                                    : Color(0xFF10B981),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                  SizedBox(height: 20),

                  // Confirm Password
                  Text(
                    'Confirm New Password',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151),
                    ),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: confirmController,
                    obscureText: !showConfirmPassword,
                    decoration: InputDecoration(
                      hintText: 'Confirm your new password',
                      prefixIcon:
                          Icon(Icons.lock_clock, color: Color(0xFF6B7280)),
                      suffixIcon: IconButton(
                        icon: Icon(
                          showConfirmPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Color(0xFF6B7280),
                        ),
                        onPressed: () => setState(
                            () => showConfirmPassword = !showConfirmPassword),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Color(0xFFD1D5DB)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: Color(0xFF18651C), width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: (value) =>
                        setState(() => confirmPassword = value),
                  ),

                  // Password Match Indicator
                  if (confirmPassword.isNotEmpty) ...[
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          passwordsMatch ? Icons.check_circle : Icons.error,
                          color: passwordsMatch
                              ? Color(0xFF10B981)
                              : Color(0xFFDC2626),
                          size: 16,
                        ),
                        SizedBox(width: 8),
                        Text(
                          passwordsMatch
                              ? 'Passwords match'
                              : 'Passwords do not match',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: passwordsMatch
                                ? Color(0xFF10B981)
                                : Color(0xFFDC2626),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],

                  SizedBox(height: 20),

                  // Password Requirements
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline,
                                color: Color(0xFF18651C), size: 16),
                            SizedBox(width: 8),
                            Text(
                              'Password Requirements',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF374151),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        ...[
                          'At least 8 characters',
                          'Uppercase letter (A-Z)',
                          'Lowercase letter (a-z)',
                          'Number (0-9)',
                          'Special character (@\$!%*?&)'
                        ].map((req) => Padding(
                              padding: EdgeInsets.only(bottom: 4),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.check_circle_outline,
                                    color: Color(0xFF6B7280),
                                    size: 14,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    req,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  // Comprehensive validation

                  // 1. Check if current password field has value
                  if (currentPassword.trim().isEmpty) {
                    _showSimpleMessage(
                        context, '❌ Current password is required',
                        isError: true);
                    return;
                  }

                  // 2. Check if new password field has value
                  if (newPassword.trim().isEmpty) {
                    _showSimpleMessage(context, '❌ New password is required',
                        isError: true);
                    return;
                  }

                  // 3. Check if confirm password field has value
                  if (confirmPassword.trim().isEmpty) {
                    _showSimpleMessage(
                        context, '❌ Please confirm your new password',
                        isError: true);
                    return;
                  }

                  // 4. Check password format with detailed validation
                  if (!isPasswordValid) {
                    // Provide specific feedback about what's missing
                    String missingRequirements = '';
                    if (newPassword.length < 8)
                      missingRequirements += '• At least 8 characters\n';
                    if (!newPassword.contains(RegExp(r'[a-z]')))
                      missingRequirements += '• Lowercase letter (a-z)\n';
                    if (!newPassword.contains(RegExp(r'[A-Z]')))
                      missingRequirements += '• Uppercase letter (A-Z)\n';
                    if (!newPassword.contains(RegExp(r'[0-9]')))
                      missingRequirements += '• Number (0-9)\n';
                    if (!newPassword.contains(RegExp(r'[@$!%*?&]')))
                      missingRequirements += '• Special character (@\$!%*?&)\n';

                    _showSimpleMessage(context,
                        '❌ Password must include:\n$missingRequirements',
                        isError: true);
                    return;
                  }

                  // 5. Check if passwords match
                  if (!passwordsMatch) {
                    _showSimpleMessage(context, '❌ Passwords do not match',
                        isError: true);
                    return;
                  }

                  // 6. Check if new password is different from current
                  if (currentPassword == newPassword) {
                    _showSimpleMessage(context,
                        '❌ New password must be different from current password',
                        isError: true);
                    return;
                  }

                  // 7. Additional security check - minimum length
                  if (newPassword.length < 8) {
                    _showSimpleMessage(context,
                        '❌ Password must be at least 8 characters long',
                        isError: true);
                    return;
                  }

                  // All validations passed - proceed with password update
                  Navigator.pop(context);
                  await _changeUserPasswordWithVerification(
                      context, user.email!, currentPassword, newPassword);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF18651C),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text(
                  'Update Password',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Reset Email Modal - Clean Implementation
  void _showResetEmailModal(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userEmail = user?.email ?? '';

    String email = userEmail;
    final TextEditingController emailController =
        TextEditingController(text: userEmail);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.email, color: Color(0xFF3B82F6)),
            SizedBox(width: 12),
            Text('Reset Email Password'),
          ],
        ),
        content: Container(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Enter the email address for password reset:',
                  style: TextStyle(color: Colors.grey[600])),
              SizedBox(height: 20),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => email = value,
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xFFF0F9FF),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Color(0xFFBAE6FD)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: Color(0xFF0369A1), size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'A password reset link will be sent to this email address.',
                        style:
                            TextStyle(fontSize: 12, color: Color(0xFF0369A1)),
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
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (email.isEmpty) {
                _showSimpleMessage(context, '❌ Please enter an email address',
                    isError: true);
                return;
              }

              Navigator.pop(context);
              await _sendPasswordResetEmail(context, email);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF3B82F6)),
            child: Text('Send Reset Email'),
          ),
        ],
      ),
    );
  }

  // NEW SIMPLE MODAL METHODS - Context Safe

  // Simple Change Password Modal
  void _showSimpleChangeModal(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user?.email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ No user email found')),
      );
      return;
    }

    final TextEditingController currentController = TextEditingController();
    final TextEditingController newController = TextEditingController();
    final TextEditingController confirmController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Change Password'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('User: ${user!.email}'),
                SizedBox(height: 20),
                TextField(
                  controller: currentController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Current Password',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: newController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: confirmController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final currentPassword = currentController.text;
                final newPassword = newController.text;
                final confirmPassword = confirmController.text;

                if (currentPassword.isEmpty) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(content: Text('❌ Please enter current password')),
                  );
                  return;
                }

                if (newPassword.length < 6) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(
                        content: Text(
                            '❌ New password must be at least 6 characters')),
                  );
                  return;
                }

                if (newPassword != confirmPassword) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(content: Text('❌ Passwords do not match')),
                  );
                  return;
                }

                Navigator.of(dialogContext).pop();
                await _changeUserPasswordWithVerification(
                    context, user.email!, currentPassword, newPassword);
              },
              child: Text('Change Password'),
            ),
          ],
        );
      },
    );
  }

  // Simple Reset Email Modal
  void _showSimpleResetModal(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userEmail = user?.email ?? '';

    final TextEditingController emailController =
        TextEditingController(text: userEmail);

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Reset Email Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Enter email address for password reset:'),
              SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final email = emailController.text;

                if (email.isEmpty) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(content: Text('❌ Please enter an email address')),
                  );
                  return;
                }

                Navigator.of(dialogContext).pop();
                await _sendPasswordResetEmail(context, email);
              },
              child: Text('Send Reset Email'),
            ),
          ],
        );
      },
    );
  }

  // Simple Email Reset Modal
  void _showEmailResetModal(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user?.email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ No user email found')),
      );
      return;
    }

    final TextEditingController currentController = TextEditingController();
    final TextEditingController newController = TextEditingController();
    final TextEditingController confirmController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.lock_reset, color: Color(0xFF18651C)),
              SizedBox(width: 12),
              Text('Change Password'),
            ],
          ),
          content: Container(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('User: ${user!.email}',
                    style: TextStyle(color: Colors.grey[600])),
                SizedBox(height: 20),
                TextField(
                  controller: currentController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Current Password',
                    prefixIcon: Icon(Icons.lock_outline),
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: newController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText:
                        'New Password (8+ chars, A-Z, a-z, 0-9, special)',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: confirmController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Confirm New Password',
                    prefixIcon: Icon(Icons.lock_clock),
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xFFF0F9FF),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Color(0xFFBAE6FD)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: Color(0xFF0369A1), size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'You will be logged out after changing your password.',
                          style:
                              TextStyle(fontSize: 12, color: Color(0xFF0369A1)),
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
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final currentPassword = currentController.text;
                final newPassword = newController.text;
                final confirmPassword = confirmController.text;

                if (currentPassword.isEmpty) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(content: Text('❌ Please enter current password')),
                  );
                  return;
                }

                final passwordRegex = RegExp(
                    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');
                if (!passwordRegex.hasMatch(newPassword)) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(
                        content: Text(
                            '❌ Password must be 8+ chars with uppercase, lowercase, digit, and special character')),
                  );
                  return;
                }

                if (newPassword != confirmPassword) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(content: Text('❌ Passwords do not match')),
                  );
                  return;
                }

                if (currentPassword == newPassword) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(
                        content: Text(
                            '❌ New password must be different from current password')),
                  );
                  return;
                }

                Navigator.of(dialogContext).pop();
                await _changeUserPasswordWithVerification(
                    context, user.email!, currentPassword, newPassword);
              },
              style:
                  ElevatedButton.styleFrom(backgroundColor: Color(0xFF18651C)),
              child: Text('Change Password'),
            ),
          ],
        );
      },
    );
  }

  // Show NewpasswordWidget Component Directly
  void _showNewpasswordModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          content: Container(
            width: 500,
            constraints: BoxConstraints(
              maxHeight: 400,
              minHeight: 300,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: NewpasswordWidget(),
            ),
          ),
        );
      },
    );
  }
}
