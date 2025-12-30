import 'package:flutter/scheduler.dart';
import '../shared/expired_contracts.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dashboard_model.dart';
export 'dashboard_model.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DashboardModel());
    // On page load: process expired contracts and create vaults as needed
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await processExpiredContracts();
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
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
            color: Color(0x1A000000),
            blurRadius: 20,
            offset: Offset(0, 4),
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
                        backgroundColor: const Color(0xFFDC2626),
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
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back, Admin',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: Color(0xFF64748B),
                  ),
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
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'This Month',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF475569),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Color(0xFF3B82F6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.download_rounded, color: Colors.white, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Download',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainKPICards() {
    return Container(
      padding: EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
              child: _buildKPICard('New Visitors', '64', '+8.5%',
                  'Avg for the last week', Color(0xFF10B981))),
          SizedBox(width: 20),
          Expanded(
              child: _buildKPICard('Total Contracts', '536', '+2.3%',
                  'Avg for the last Year', Color(0xFF3B82F6))),
          SizedBox(width: 20),
          Expanded(
              child: _buildKPICard('Total Revenue', '₱35k', '+15.2%',
                  'Avg for the last Mon', Color(0xFF8B5CF6))),
          SizedBox(width: 20),
          Expanded(
              child: _buildKPICard('Occupancy Rate', '81%', '+3.8%',
                  'Avg for the last Year', Color(0xFFEF4444))),
        ],
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
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                  child: _buildAnalyticsCard(
                      'Active Contracts',
                      '245',
                      'Currently active',
                      Icons.check_circle_rounded,
                      Color(0xFF10B981),
                      '85.2% active')),
              SizedBox(width: 20),
              Expanded(
                  child: _buildAnalyticsCard(
                      'Total Spaces',
                      '320',
                      'Lots & Niches',
                      Icons.business_rounded,
                      Color(0xFF3B82F6),
                      'Occupied: 260')),
              SizedBox(width: 20),
              Expanded(
                  child: _buildAnalyticsCard(
                      'Collection Rate',
                      '92.5%',
                      'Payment efficiency',
                      Icons.trending_up_rounded,
                      Color(0xFF8B5CF6),
                      'Outstanding: ₱125k')),
            ],
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                  child: _buildAnalyticsCard(
                      'Monthly Transactions',
                      '89',
                      'This month',
                      Icons.receipt_rounded,
                      Color(0xFFEF4444),
                      '+12.5% vs last month')),
              SizedBox(width: 20),
              Expanded(
                  child: _buildAnalyticsCard(
                      'Expired Contracts',
                      '12',
                      'Need renewal',
                      Icons.schedule_rounded,
                      Color(0xFFF59E0B),
                      'Pending: 8')),
              SizedBox(width: 20),
              Expanded(
                  child: _buildAnalyticsCard(
                      'Weekly Visitors',
                      '156',
                      'This week',
                      Icons.people_rounded,
                      Color(0xFF059669),
                      'Today: 24')),
            ],
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
              Text('Revenue Statistics',
                  style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B))),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                    color: Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(4)),
                child: Text('All Data',
                    style: GoogleFonts.inter(
                        fontSize: 12, color: Color(0xFF64748B))),
              ),
              SizedBox(width: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                    color: Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(4)),
                child: Text('Sep 2023 to Sep 2024',
                    style: GoogleFonts.inter(
                        fontSize: 12, color: Color(0xFF64748B))),
              ),
            ],
          ),
          SizedBox(height: 24),
          Container(
            height: 200,
            decoration: BoxDecoration(
                color: Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8)),
            child: Center(
              child: Text('Revenue Chart\n(Chart implementation)',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                      fontSize: 14, color: Color(0xFF64748B))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceMetrics() {
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
          _buildMetricItem('Contracts', '28k', Color(0xFF10B981)),
          SizedBox(height: 16),
          _buildMetricItem('Renewals', '2k', Color(0xFF3B82F6)),
          SizedBox(height: 16),
          _buildMetricItem('Payments', '1.8k', Color(0xFF8B5CF6)),
          SizedBox(height: 16),
          _buildMetricItem('Visits', '1.2k', Color(0xFFEF4444)),
        ],
      ),
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
}
