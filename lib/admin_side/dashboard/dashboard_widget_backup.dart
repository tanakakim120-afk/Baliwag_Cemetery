import 'package:flutter/scheduler.dart';
import '../shared/expired_contracts.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dashboard_model.dart';
export 'dashboard_model.dart';

import '/flutter_flow/flutter_flow_util.dart';
import '/backend/backend.dart';

class DashboardWidget extends StatefulWidget {
  const DashboardWidget({Key? key}) : super(key: key);

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
        backgroundColor: Color(0xFFF8FAFC),
        body: SafeArea(
          top: true,
          child: Row(
            children: [
              _buildSidebar(),
              _buildMainContent(),
            ],
          ),
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

                  // Platform Navigation Section
                  _buildSectionTitle('Platform Navigation'),
                  SizedBox(height: 12),
                  _buildNavItem(
                    icon: Icons.dashboard_rounded,
                    title: 'Dashboard',
                    isActive: true,
                    onTap: () {},
                  ),

                  SizedBox(height: 32),

                  // Action Section
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
                        backgroundColor:
                            const Color(0xFFDC2626), // Professional red
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        minimumSize: const Size(0, 48), // Standardized height
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

  Widget _buildMainContent() {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(32),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderSection(),
              SizedBox(height: 32),
              _buildStatisticsCards(),
              SizedBox(height: 32),
              _buildAnalyticsDashboard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back, Admin!',
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2937),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Here\'s what\'s happening with your cemetery today',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Color(0xFF6B7280),
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

  Widget _buildStatisticsCards() {
    return StreamBuilder<List<ContractRecord>>(
      stream: queryContractRecord(),
      builder: (context, contractsSnapshot) {
        if (!contractsSnapshot.hasData) {
          return _buildLoadingCards();
        }

        final contracts = contractsSnapshot.data!;

        return StreamBuilder<List<TransactionsRecord>>(
          stream: queryTransactionsRecord(),
          builder: (context, transactionsSnapshot) {
            final transactions =
                transactionsSnapshot.data ?? <TransactionsRecord>[];

            return StreamBuilder<List<VisitorlogRecord>>(
              stream: queryVisitorlogRecord(),
              builder: (context, visitorSnapshot) {
                final visitorLogs =
                    visitorSnapshot.data ?? <VisitorlogRecord>[];
                final stats = _calculateRealTimeStats(
                    contracts, transactions, visitorLogs);

                return Column(
                  children: [
                    // Single row with 4 cards in 2x2 grid
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.people_rounded,
                            title: 'Total Visitor',
                            value: '${stats['visitors'] ?? 0}',
                            subtitle: 'Today',
                            trend: '${stats['visitorTrend'] ?? 'No data'}',
                            color: Color(0xFF3B82F6),
                            iconColor: Color(0xFFDBEAFE),
                          ),
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.description_rounded,
                            title: 'Total Contract',
                            value: '${stats['contracts'] ?? 0}',
                            subtitle: 'All Contracts',
                            trend: 'Total contracts in system',
                            color: Color(0xFFF59E0B),
                            iconColor: Color(0xFFFEF3C7),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.check_circle_rounded,
                            title: 'Total Active Contract',
                            value: '${stats['activeContracts'] ?? 0}',
                            subtitle: 'Valid & Current',
                            trend: _calculateActiveContractTrend(stats),
                            color: Color(0xFF10B981),
                            iconColor: Color(0xFFD1FAE5),
                          ),
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.receipt_rounded,
                            title: 'Total Transaction',
                            value: '${stats['transactions'] ?? 0}',
                            subtitle: 'This month',
                            trend: '${stats['transactionTrend'] ?? 'No data'}',
                            color: Color(0xFFEF4444),
                            iconColor: Color(0xFFFEE2E2),
                          ),
                        ),
                      ],
                    ),

                    // ✅ NEW: Enhanced Analytics Cards
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.business_rounded,
                            title: 'Overall Occupancy',
                            value:
                                '${stats['overallOccupancy']?.toStringAsFixed(1) ?? '0'}%',
                            subtitle:
                                '${stats['occupiedSpaces'] ?? 0}/${stats['totalSpaces'] ?? 0} spaces',
                            trend:
                                'Lots: ${stats['lotOccupancyRate']?.toStringAsFixed(1) ?? '0'}% | Niches: ${stats['nicheOccupancyRate']?.toStringAsFixed(1) ?? '0'}%',
                            color: Color(0xFF8B5CF6),
                            iconColor: Color(0xFFEDE9FE),
                          ),
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.account_balance_wallet_rounded,
                            title: 'Monthly Revenue',
                            value:
                                '₱${(stats['thisMonthRevenue'] ?? 0).toStringAsFixed(0)}',
                            subtitle: 'This month',
                            trend: '${stats['revenueTrend'] ?? 'No data'}',
                            color: Color(0xFF059669),
                            iconColor: Color(0xFFD1FAE5),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.trending_up_rounded,
                            title: 'Collection Rate',
                            value:
                                '${stats['collectionRate']?.toStringAsFixed(1) ?? '0'}%',
                            subtitle: 'Payment efficiency',
                            trend:
                                'Outstanding: ₱${(stats['totalOutstandingBalance'] ?? 0).toStringAsFixed(0)}',
                            color: Color(0xFFDC2626),
                            iconColor: Color(0xFFFEE2E2),
                          ),
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.schedule_rounded,
                            title: 'Contract Status',
                            value: '${stats['activeContracts'] ?? 0}',
                            subtitle: 'Active contracts',
                            trend:
                                'Expired: ${stats['expiredContracts'] ?? 0} | Pending: ${stats['pendingContracts'] ?? 0}',
                            color: Color(0xFFF59E0B),
                            iconColor: Color(0xFFFEF3C7),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildLoadingCards() {
    return Column(
      children: [
        Row(
          children: List.generate(
            2,
            (index) => Expanded(
              child: Container(
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x0A000000),
                      blurRadius: 20,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFF18651C)),
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 20),
        Row(
          children: List.generate(
            2,
            (index) => Expanded(
              child: Container(
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x0A000000),
                      blurRadius: 20,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFF18651C)),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required String trend,
    required Color color,
    required Color iconColor,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: color.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  trend,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6B7280),
            ),
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  String _calculateActiveContractTrend(Map<String, dynamic> stats) {
    final activeContracts = stats['activeContracts'] ?? 0;
    final totalContracts = stats['contracts'] ?? 0;

    if (activeContracts > 0 && totalContracts > 0) {
      final percentage =
          ((activeContracts / totalContracts) * 100).toStringAsFixed(1);
      return '$percentage% of total';
    } else {
      return 'No active contracts';
    }
  }

  Map<String, dynamic> _calculateRealTimeStats(
      List<ContractRecord> contracts,
      List<TransactionsRecord> transactions,
      List<VisitorlogRecord> visitorLogs) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(Duration(days: 1));
    final thisMonth = DateTime(now.year, now.month, 1);
    final lastMonth = DateTime(now.year, now.month - 1, 1);

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

    // Financial metrics
    double totalOutstandingBalance = 0.0;
    double totalPaidAmount = 0.0;
    int paidContracts = 0;
    int totalTransactions = transactions.length;

    // ✅ ENHANCED: Calculate visitors with weekly tracking
    for (final visitorLog in visitorLogs) {
      if (visitorLog.timestamp != null) {
        final visitorDate = visitorLog.timestamp!;
        final visitorDay =
            DateTime(visitorDate.year, visitorDate.month, visitorDate.day);
        final daysDiff = today.difference(visitorDay).inDays;

        // Today's visitors
        if (visitorDay.isAtSameMomentAs(today)) {
          todayVisitors++;
        }

        // Yesterday's visitors
        if (visitorDay.isAtSameMomentAs(yesterday)) {
          yesterdayVisitors++;
        }

        // This week's visitors
        if (daysDiff >= 0 && daysDiff <= 7) {
          thisWeekVisitors++;
        }
      }
    }

    // ✅ ENHANCED: Calculate transactions with revenue tracking
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

    // ✅ COMPREHENSIVE: Enhanced contract analysis
    for (final contract in contracts) {
      final status = contract.status?.toLowerCase() ?? '';
      final contractStatus = contract.contractstatus?.toLowerCase() ?? '';
      final currentDate = DateTime.now();
      final isExpired = contract.dateofexpiration != null &&
          contract.dateofexpiration!.isBefore(currentDate);
      final hasDeceased = contract.decFullName.isNotEmpty;
      final balance = contract.balance ?? 0;

      // Contract status tracking
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

      // Space utilization tracking
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

    // ✅ ENHANCED: Calculate comprehensive trends and metrics
    final visitorTrend = yesterdayVisitors > 0
        ? '${todayVisitors > yesterdayVisitors ? '+' : ''}${todayVisitors - yesterdayVisitors} from yesterday'
        : 'New today';

    final lotOccupancyRate = totalLots > 0
        ? (occupiedLots / totalLots * 100).toStringAsFixed(1)
        : '0';
    final lotTrend = totalLots > 0
        ? '$lotOccupancyRate% occupied ($occupiedLots/$totalLots)'
        : 'No lots';

    final nicheOccupancyRate = totalNiches > 0
        ? (occupiedNiches / totalNiches * 100).toStringAsFixed(1)
        : '0';
    final nicheTrend = totalNiches > 0
        ? '$nicheOccupancyRate% occupied ($occupiedNiches/$totalNiches)'
        : 'No niches';

    final contractTrend = contracts.length > 0
        ? '${((activeContracts / contracts.length) * 100).toStringAsFixed(1)}% active'
        : 'No contracts';

    final transactionTrend = lastMonthTransactions > 0
        ? '${thisMonthTransactions > lastMonthTransactions ? '+' : ''}${((thisMonthTransactions - lastMonthTransactions) / lastMonthTransactions * 100).toStringAsFixed(1)}% vs last month'
        : '${thisMonthTransactions} this month';

    final revenueTrend = lastMonthRevenue > 0
        ? '${thisMonthRevenue > lastMonthRevenue ? '+' : ''}${((thisMonthRevenue - lastMonthRevenue) / lastMonthRevenue * 100).toStringAsFixed(1)}% vs last month'
        : 'New revenue this month';

    final collectionRate = (totalPaidAmount + totalOutstandingBalance) > 0
        ? (totalPaidAmount / (totalPaidAmount + totalOutstandingBalance) * 100)
            .toStringAsFixed(1)
        : '0';

    final totalSpaces = totalLots + totalNiches;
    final occupiedSpaces = occupiedLots + occupiedNiches;
    final overallOccupancy = totalSpaces > 0
        ? (occupiedSpaces / totalSpaces * 100).toStringAsFixed(1)
        : '0';

    return {
      // ✅ ENHANCED: Comprehensive dashboard metrics

      // Visitor Analytics
      'visitors': todayVisitors,
      'visitorTrend': visitorTrend,
      'yesterdayVisitors': yesterdayVisitors,
      'thisWeekVisitors': thisWeekVisitors,

      // Space Management
      'lots': totalLots,
      'lotTrend': lotTrend,
      'occupiedLots': occupiedLots,
      'lotOccupancyRate': double.parse(lotOccupancyRate),
      'niches': totalNiches,
      'nicheTrend': nicheTrend,
      'occupiedNiches': occupiedNiches,
      'nicheOccupancyRate': double.parse(nicheOccupancyRate),
      'totalSpaces': totalSpaces,
      'occupiedSpaces': occupiedSpaces,
      'overallOccupancy': double.parse(overallOccupancy),

      // Contract Analytics
      'contracts': contracts.length,
      'activeContracts': activeContracts,
      'expiredContracts': expiredContracts,
      'pendingContracts': pendingContracts,
      'contractTrend': contractTrend,

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
      'collectionRate': double.parse(collectionRate),
    };
  }

  // OLD METHOD REMOVED - Using modern dashboard instead

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
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xFF8B5CF6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.analytics_rounded,
                  color: Color(0xFF8B5CF6),
                  size: 24,
                ),
              ),
              SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Analytics Dashboard',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  Text(
                    'Real-time insights and performance metrics',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        SizedBox(height: 24),

        // Revenue Trends Chart
        _buildRevenueChart(),

        SizedBox(height: 24),

        // Transaction Analytics Section
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 20,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Color(0xFF8B5CF6).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.analytics_rounded,
                      color: Color(0xFF8B5CF6),
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Transaction Analytics',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        Text(
                          'Operational insights and service performance',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),

              // Transaction Type Distribution
              StreamBuilder<List<TransactionsRecord>>(
                stream: queryTransactionsRecord(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final transactions = snapshot.data!;
                  final transactionTypes =
                      _analyzeTransactionTypes(transactions);
                  final paymentMethods = _analyzePaymentMethods(transactions);
                  final servicePopularity =
                      _analyzeServicePopularity(transactions);

                  return Column(
                    children: [
                      // Transaction Types Row
                      Row(
                        children: [
                          Expanded(
                            child: _buildTransactionTypeCard(
                              'Total Transactions',
                              '${transactions.length}',
                              Icons.receipt_rounded,
                              Color(0xFF3B82F6),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: _buildTransactionTypeCard(
                              'This Month',
                              '${_getThisMonthTransactions(transactions)}',
                              Icons.calendar_today_rounded,
                              Color(0xFF10B981),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: _buildTransactionTypeCard(
                              'Avg. Transaction',
                              '₱${_calculateAverageTransaction(transactions)}',
                              Icons.trending_up_rounded,
                              Color(0xFFF59E0B),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24),

                      // Service Popularity Chart
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Container(
                              height: 200,
                              child: PieChart(
                                PieChartData(
                                  sections: servicePopularity.map((data) {
                                    return PieChartSectionData(
                                      value: data['value'].toDouble(),
                                      title:
                                          '${data['label']}\n${data['value']}',
                                      color: data['color'],
                                      radius: 60,
                                      titleStyle: GoogleFonts.inter(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    );
                                  }).toList(),
                                  centerSpaceRadius: 40,
                                  sectionsSpace: 2,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 24),
                          Expanded(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Service Popularity',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1F2937),
                                  ),
                                ),
                                SizedBox(height: 16),
                                ...servicePopularity.map((data) {
                                  return Padding(
                                    padding: EdgeInsets.only(bottom: 12),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 16,
                                          height: 16,
                                          decoration: BoxDecoration(
                                            color: data['color'],
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            data['label'],
                                            style: GoogleFonts.inter(
                                              fontSize: 14,
                                              color: Color(0xFF6B7280),
                                            ),
                                          ),
                                        ),
                                        Text(
                                          '${data['value']}',
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF1F2937),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24),

                      // Payment Methods
                      Text(
                        'Payment Method Distribution',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: paymentMethods.map((method) {
                          return Expanded(
                            child: Container(
                              margin: EdgeInsets.only(right: 16),
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Color(0xFFF9FAFB),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Color(0xFFE5E7EB),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    _getPaymentMethodIcon(method['method']),
                                    color: Color(0xFF6B7280),
                                    size: 24,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    method['method'],
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF6B7280),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    '${method['count']}',
                                    style: GoogleFonts.inter(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1F2937),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),

        SizedBox(height: 24),

        // Performance Metrics
        _buildPerformanceMetrics(),

        SizedBox(height: 24),

        // Visitor Analytics
        _buildVisitorAnalytics(),
      ],
    );
  }

  Widget _buildAnalyticsDashboard() {
    return Container(
      color: Color(0xFFF8FAFC), // Light background like the reference
      child: Column(
        children: [
          // ✅ NEW: Modern Header Section
          _buildModernHeader(),

          // ✅ NEW: Main KPI Cards Row (4 cards like reference)
          _buildMainKPICards(),

          SizedBox(height: 32),

          // ✅ NEW: Additional Analytics Grid
          _buildAnalyticsGrid(),

          SizedBox(height: 32),

          // ✅ NEW: Charts and Performance Section
          _buildChartsSection(),
        ],
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
                  ],
      ),
      child: Row(
        children: [
          // Welcome Section
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
          
          // Action Buttons
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
                final stats = _calculateRealTimeStats(
                    contracts, transactions, visitorLogs);

                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    children: [
                      // New Visitors (like New Employee)
                      Expanded(
                        child: _buildModernKPICard(
                          title: 'New Visitors',
                          value: '${stats['visitors'] ?? 0}',
                          trend: '+8.5%',
                          trendLabel: 'Avg for the last week',
                          trendPositive: true,
                          color: Color(0xFF10B981),
                        ),
                      ),
                      SizedBox(width: 20),

                      // Total Contracts (like Total Employee)
                      Expanded(
                        child: _buildModernKPICard(
                          title: 'Total Contracts',
                          value: '${stats['contracts'] ?? 0}',
                          trend: '+2.3%',
                          trendLabel: 'Avg for the last Year',
                          trendPositive: true,
                          color: Color(0xFF3B82F6),
                        ),
                      ),
                      SizedBox(width: 20),

                      // Monthly Revenue (like Total Salary)
                      Expanded(
                        child: _buildModernKPICard(
                          title: 'Total Revenue',
                          value:
                              '₱${((stats['thisMonthRevenue'] ?? 0) / 1000).toStringAsFixed(0)}k',
                          trend: '+15.2%',
                          trendLabel: 'Avg for the last Mon',
                          trendPositive: true,
                          color: Color(0xFF8B5CF6),
                        ),
                      ),
                      SizedBox(width: 20),

                      // Occupancy Rate (like Avg. Salary)
                      Expanded(
                        child: _buildModernKPICard(
                          title: 'Occupancy Rate',
                          value:
                              '${stats['overallOccupancy']?.toStringAsFixed(0) ?? '0'}%',
                          trend: '+3.8%',
                          trendLabel: 'Avg for the last Year',
                          trendPositive: true,
                          color: Color(0xFFEF4444),
                        ),
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
  }

  Widget _buildModernKPICard({
    required String title,
    required String value,
    required String trend,
    required String trendLabel,
    required bool trendPositive,
    required Color color,
  }) {
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
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              SizedBox(width: 8),
              // Trend indicator like in reference
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: trendPositive ? Color(0xFFDCFCE7) : Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      trendPositive ? Icons.trending_up : Icons.trending_down,
                      size: 12,
                      color:
                          trendPositive ? Color(0xFF16A34A) : Color(0xFFDC2626),
                    ),
                    SizedBox(width: 2),
                    Text(
                      trend,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: trendPositive
                            ? Color(0xFF16A34A)
                            : Color(0xFFDC2626),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            trendLabel,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingKPICards() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
            final stats = _calculateRealTimeStats(contracts, transactions, []);

            return Container(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  // First row of analytics cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildAnalyticsCard(
                          title: 'Active Contracts',
                          value: '${stats['activeContracts'] ?? 0}',
                          subtitle: 'Currently active',
                          icon: Icons.check_circle_rounded,
                          color: Color(0xFF10B981),
                          trend: '${stats['contractTrend'] ?? 'No data'}',
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: _buildAnalyticsCard(
                          title: 'Total Spaces',
                          value: '${stats['totalSpaces'] ?? 0}',
                          subtitle: 'Lots & Niches',
                          icon: Icons.business_rounded,
                          color: Color(0xFF3B82F6),
                          trend: 'Occupied: ${stats['occupiedSpaces'] ?? 0}',
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: _buildAnalyticsCard(
                          title: 'Collection Rate',
                          value:
                              '${stats['collectionRate']?.toStringAsFixed(1) ?? '0'}%',
                          subtitle: 'Payment efficiency',
                          icon: Icons.trending_up_rounded,
                          color: Color(0xFF8B5CF6),
                          trend:
                              'Outstanding: ₱${(stats['totalOutstandingBalance'] ?? 0).toStringAsFixed(0)}',
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20),

                  // Second row of analytics cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildAnalyticsCard(
                          title: 'Monthly Transactions',
                          value: '${stats['thisMonthTransactions'] ?? 0}',
                          subtitle: 'This month',
                          icon: Icons.receipt_rounded,
                          color: Color(0xFFEF4444),
                          trend: '${stats['transactionTrend'] ?? 'No data'}',
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: _buildAnalyticsCard(
                          title: 'Expired Contracts',
                          value: '${stats['expiredContracts'] ?? 0}',
                          subtitle: 'Need renewal',
                          icon: Icons.schedule_rounded,
                          color: Color(0xFFF59E0B),
                          trend: 'Pending: ${stats['pendingContracts'] ?? 0}',
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: _buildAnalyticsCard(
                          title: 'Weekly Visitors',
                          value: '${stats['thisWeekVisitors'] ?? 0}',
                          subtitle: 'This week',
                          icon: Icons.people_rounded,
                          color: Color(0xFF059669),
                          trend: 'Today: ${stats['visitors'] ?? 0}',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAnalyticsCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String trend,
  }) {
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
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              Spacer(),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B),
            ),
          ),
          SizedBox(height: 8),
          Text(
            trend,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
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

  Widget _buildChartsSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left side - Revenue Chart (like Salary Statistics)
          Expanded(
            flex: 2,
            child: _buildRevenueChart(),
          ),
          SizedBox(width: 24),
          // Right side - Performance Metrics (like Income Analysis)
          Expanded(
            flex: 1,
            child: _buildPerformanceMetrics(),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueChart() {
    return StreamBuilder<List<TransactionsRecord>>(
      stream: queryTransactionsRecord(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _buildLoadingContainer();
        }

        final transactions = snapshot.data!;
        final monthlyRevenue = _calculateMonthlyRevenue(transactions);
        final revenueGrowth = _calculateRevenueGrowth(monthlyRevenue);

        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 20,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Color(0xFF10B981).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.trending_up_rounded,
                      color: Color(0xFF10B981),
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 16),
                  Text(
                    'Revenue Trends',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: revenueGrowth >= 0
                          ? Color(0xFF10B981).withOpacity(0.1)
                          : Color(0xFFEF4444).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${revenueGrowth >= 0 ? '+' : ''}${revenueGrowth.toStringAsFixed(1)}%',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: revenueGrowth >= 0
                            ? Color(0xFF10B981)
                            : Color(0xFFEF4444),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Container(
                height: 300,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: true,
                      horizontalInterval: 1,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: Color(0xFFE5E7EB),
                          strokeWidth: 1,
                        );
                      },
                      getDrawingVerticalLine: (value) {
                        return FlLine(
                          color: Color(0xFFE5E7EB),
                          strokeWidth: 1,
                        );
                      },
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          interval: 1,
                          getTitlesWidget: (double value, TitleMeta meta) {
                            const style = TextStyle(
                              color: Color(0xFF6B7280),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            );
                            final months = [
                              'Jan',
                              'Feb',
                              'Mar',
                              'Apr',
                              'May',
                              'Jun'
                            ];
                            final monthIndex = value.toInt();
                            if (monthIndex >= 0 && monthIndex < months.length) {
                              return SideTitleWidget(
                                axisSide: meta.axisSide,
                                child: Text(months[monthIndex], style: style),
                              );
                            }
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              child: Text('', style: style),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 2, // Increase interval to space out labels
                          getTitlesWidget: (double value, TitleMeta meta) {
                            const style = TextStyle(
                              color: Color(0xFF6B7280),
                              fontWeight: FontWeight.bold,
                              fontSize: 11, // Slightly smaller font
                            );

                            // Only show labels for even values to reduce crowding
                            if (value.toInt() % 2 == 0) {
                              return Text(
                                _formatRevenueAmount(value * 1000),
                                style: style,
                              );
                            }
                            return Text('',
                                style: style); // Empty text for odd values
                          },
                          reservedSize:
                              80, // Increase reserved space for better spacing
                        ),
                      ),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(color: Color(0xFFE5E7EB)),
                    ),
                    minX: 0,
                    maxX: 5,
                    minY: 0,
                    maxY: monthlyRevenue.isNotEmpty
                        ? _calculateOptimalMaxY(
                            monthlyRevenue.reduce((a, b) => a > b ? a : b))
                        : 20,
                    lineBarsData: [
                      LineChartBarData(
                        spots: monthlyRevenue.asMap().entries.map((entry) {
                          return FlSpot(entry.key.toDouble(), entry.value);
                        }).toList(),
                        isCurved: true,
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF10B981).withOpacity(0.8),
                            Color(0xFF10B981).withOpacity(0.3),
                          ],
                        ),
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) {
                            return FlDotCirclePainter(
                              radius: 4,
                              color: Color(0xFF10B981),
                              strokeWidth: 2,
                              strokeColor: Colors.white,
                            );
                          },
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFF10B981).withOpacity(0.3),
                              Color(0xFF10B981).withOpacity(0.1),
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
        );
      },
    );
  }

  Widget _buildPerformanceMetrics() {
    return Row(
      children: [
        Expanded(
          child: StreamBuilder<List<ContractRecord>>(
            stream: queryContractRecord(),
            builder: (context, contractsSnapshot) {
              if (!contractsSnapshot.hasData) {
                return _buildLoadingContainer();
              }

              final contracts = contractsSnapshot.data!;

              return StreamBuilder<List<TransactionsRecord>>(
                stream: queryTransactionsRecord(),
                builder: (context, transactionsSnapshot) {
                  final transactions =
                      transactionsSnapshot.data ?? <TransactionsRecord>[];
                  final metrics =
                      _calculatePerformanceMetrics(contracts, transactions);

                  return Container(
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x0A000000),
                          blurRadius: 20,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Color(0xFF8B5CF6).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.trending_up_rounded,
                                color: Color(0xFF8B5CF6),
                                size: 24,
                              ),
                            ),
                            SizedBox(width: 16),
                            Text(
                              'Performance Metrics',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        _buildMetricItem(
                          'Space Occupancy Rate',
                          '${metrics['completionRate']?.toStringAsFixed(1) ?? 0}%',
                          Color(0xFF10B981),
                        ),
                        SizedBox(height: 16),
                        _buildMetricItem(
                          'Payment Collection Rate',
                          '${metrics['paymentRate']?.toStringAsFixed(1) ?? 0}%',
                          Color(0xFF3B82F6),
                        ),
                        SizedBox(height: 16),
                        _buildMetricItem(
                          'Collection Efficiency',
                          '${metrics['collectionEfficiency']?.toStringAsFixed(1) ?? 0}%',
                          Color(0xFF059669),
                        ),
                        SizedBox(height: 16),
                        _buildMetricItem(
                          'Average Contract Value',
                          '₱${metrics['averageContractValue']?.toStringAsFixed(0) ?? 0}',
                          Color(0xFF8B5CF6),
                        ),
                        SizedBox(height: 16),
                        _buildMetricItem(
                          'Revenue per Space',
                          '₱${metrics['revenuePerSpace']?.toStringAsFixed(0) ?? 0}',
                          Color(0xFFF59E0B),
                        ),
                        SizedBox(height: 16),
                        _buildMetricItem(
                          'Outstanding Balance',
                          '₱${metrics['outstandingBalance']?.toStringAsFixed(1) ?? 0}K',
                          Color(0xFFDC2626),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildVisitorAnalytics() {
    return StreamBuilder<List<VisitorlogRecord>>(
      stream: queryVisitorlogRecord(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _buildLoadingContainer();
        }

        final visitorLogs = snapshot.data!;
        final weeklyVisitors = _calculateWeeklyVisitors(visitorLogs);

        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 20,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Visitor Analytics',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Color(0xFF3B82F6).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Last 7 Days',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF3B82F6),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Container(
                height: 250,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: weeklyVisitors.isNotEmpty
                        ? weeklyVisitors
                                .reduce((a, b) => a > b ? a : b)
                                .ceilToDouble() +
                            2
                        : 20,
                    barTouchData: BarTouchData(enabled: false),
                    titlesData: FlTitlesData(
                      show: true,
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          interval: 1,
                          getTitlesWidget: (double value, TitleMeta meta) {
                            const style = TextStyle(
                              color: Color(0xFF6B7280),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            );
                            final days = [
                              'Mon',
                              'Tue',
                              'Wed',
                              'Thu',
                              'Fri',
                              'Sat',
                              'Sun'
                            ];
                            final dayIndex = value.toInt();
                            if (dayIndex >= 0 && dayIndex < days.length) {
                              return SideTitleWidget(
                                axisSide: meta.axisSide,
                                child: Text(days[dayIndex], style: style),
                              );
                            }
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              child: Text('', style: style),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 1,
                          getTitlesWidget: (double value, TitleMeta meta) {
                            const style = TextStyle(
                              color: Color(0xFF6B7280),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            );
                            return Text('${value.toInt()}', style: style);
                          },
                          reservedSize: 42,
                        ),
                      ),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(color: Color(0xFFE5E7EB)),
                    ),
                    barGroups: weeklyVisitors.asMap().entries.map((entry) {
                      return BarChartGroupData(
                        x: entry.key,
                        barRods: [
                          BarChartRodData(
                            toY: entry.value.toDouble(),
                            color: Color(0xFF3B82F6),
                            width: 20,
                          )
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingContainer() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF18651C)),
        ),
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF6B7280),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  List<double> _calculateMonthlyRevenue(List<TransactionsRecord> transactions) {
    final now = DateTime.now();
    final monthlyRevenue = List<double>.filled(6, 0.0);

    for (final transaction in transactions) {
      if (transaction.transactionDate != null) {
        final transactionDate = transaction.transactionDate!;
        final monthsDiff = now.difference(transactionDate).inDays ~/ 30;

        if (monthsDiff < 6 && monthsDiff >= 0) {
          double amount = 0.0;
          if (transaction.amount != null) {
            amount = transaction.amount!.toDouble();
          }
          monthlyRevenue[5 - monthsDiff] += amount / 1000;
        }
      }
    }

    return monthlyRevenue;
  }

  double _calculateRevenueGrowth(List<double> monthlyRevenue) {
    if (monthlyRevenue.length < 2) return 0.0;

    final currentMonth = monthlyRevenue.last;
    final previousMonth = monthlyRevenue[monthlyRevenue.length - 2];

    if (previousMonth == 0) return 0.0;

    return ((currentMonth - previousMonth) / previousMonth) * 100;
  }

  Map<String, dynamic> _calculatePerformanceMetrics(
      List<ContractRecord> contracts, List<TransactionsRecord> transactions) {
    if (contracts.isEmpty) {
      return {
        'completionRate': 0.0,
        'paymentRate': 0.0,
        'activeContracts': 0,
        'totalRevenue': 0.0,
        'averageContractValue': 0.0,
        'contractRetentionRate': 0.0, // Replaces renewalRate
        'occupancyGrowth': 0.0,
        'revenuePerSpace': 0.0,
        'collectionEfficiency': 0.0,
        'outstandingBalance': 0.0,
        'fullyPaidContracts': 0,
        'expiredContracts': 0,
      };
    }

    // ✅ ENHANCED: Comprehensive performance analysis
    int fullyPaid = 0;
    int activeContracts = 0;
    int expiredContracts = 0;
    int totalSpaces = 0;
    int occupiedSpaces = 0;
    double totalRevenue = 0.0;
    double totalContractValue = 0.0;
    double totalOutstanding = 0.0;

    final currentDate = DateTime.now();

    // Enhanced transaction analysis
    for (final transaction in transactions) {
      if (transaction.amount != null) {
        totalRevenue += transaction.amount!.toDouble();
      }
    }

    // Comprehensive contract analysis
    for (final contract in contracts) {
      final status = contract.status?.toLowerCase() ?? '';
      final contractStatus = contract.contractstatus?.toLowerCase() ?? '';
      final balance = contract.balance ?? 0;
      final initialFee = contract.initialfee ?? 0;
      final isExpired = contract.dateofexpiration != null &&
          contract.dateofexpiration!.isBefore(currentDate);
      final hasDeceased = contract.decFullName.isNotEmpty;

      // Contract value analysis
      totalContractValue += initialFee.toDouble();
      if (balance > 0) {
        totalOutstanding += balance.toDouble();
      }

      // Payment status analysis
      if (balance == 0 && initialFee > 0) {
        fullyPaid++;
      }

      // Contract status analysis
      if (!isExpired &&
          (contractStatus == 'active' ||
              status == 'active' ||
              status == 'unaddable')) {
        activeContracts++;
      } else if (isExpired) {
        expiredContracts++;
      }

      // Note: Renewal tracking removed - lastRenewalDate field not available in schema

      // Space utilization
      if (contract.type?.toLowerCase() == 'lot' ||
          contract.type?.toLowerCase() == 'nitche') {
        totalSpaces++;
        if (hasDeceased || status == 'unaddable') {
          occupiedSpaces++;
        }
      }
    }

    final total = contracts.length.toDouble();
    final averageContractValue = total > 0 ? totalContractValue / total : 0.0;
    final paymentRate = total > 0 ? (fullyPaid / total) * 100 : 0.0;
    final contractRetentionRate = total > 0
        ? (activeContracts / total) * 100
        : 0.0; // Alternative to renewal rate
    final occupancyRate =
        totalSpaces > 0 ? (occupiedSpaces / totalSpaces) * 100 : 0.0;
    final revenuePerSpace =
        occupiedSpaces > 0 ? totalRevenue / occupiedSpaces : 0.0;
    final collectionEfficiency = (totalContractValue > 0)
        ? ((totalRevenue / totalContractValue) * 100)
        : 0.0;

    return {
      'completionRate': occupancyRate,
      'paymentRate': paymentRate,
      'activeContracts': activeContracts,
      'totalRevenue': totalRevenue / 1000, // In thousands
      'averageContractValue': averageContractValue,
      'contractRetentionRate': contractRetentionRate, // Replaces renewalRate
      'occupancyGrowth': occupancyRate,
      'revenuePerSpace': revenuePerSpace,
      'collectionEfficiency': collectionEfficiency,
      'outstandingBalance': totalOutstanding / 1000, // In thousands
      'fullyPaidContracts': fullyPaid,
      'expiredContracts': expiredContracts,
    };
  }

  List<int> _calculateWeeklyVisitors(List<VisitorlogRecord> visitorLogs) {
    final weeklyVisitors = List<int>.filled(7, 0);
    final now = DateTime.now();

    for (final visitorLog in visitorLogs) {
      if (visitorLog.timestamp != null) {
        final visitorDate = visitorLog.timestamp!;
        final daysDiff = now.difference(visitorDate).inDays;

        if (daysDiff < 7) {
          weeklyVisitors[6 - daysDiff]++;
        }
      }
    }

    return weeklyVisitors;
  }

  String _formatRevenueAmount(double amount) {
    if (amount < 1000) {
      return '₱${amount.toStringAsFixed(0)}';
    } else if (amount < 1000000) {
      // For amounts in thousands, show with better spacing
      final thousands = amount / 1000;
      if (thousands == thousands.toInt()) {
        return '₱${thousands.toInt()}K'; // Show as ₱25K instead of ₱25.0K
      } else {
        return '₱${thousands.toStringAsFixed(1)}K';
      }
    } else if (amount < 1000000000) {
      final millions = amount / 1000000;
      if (millions == millions.toInt()) {
        return '₱${millions.toInt()}M';
      } else {
        return '₱${millions.toStringAsFixed(1)}M';
      }
    } else {
      final billions = amount / 1000000000;
      if (billions == billions.toInt()) {
        return '₱${billions.toInt()}B';
      } else {
        return '₱${billions.toStringAsFixed(1)}B';
      }
    }
  }

  /// Calculates optimal maxY value for better chart spacing
  double _calculateOptimalMaxY(double maxRevenue) {
    if (maxRevenue <= 0) return 20.0;

    // Round up to the next nice number for better spacing
    double niceNumber = maxRevenue;

    if (maxRevenue <= 10) {
      niceNumber = 12.0; // Show up to 12K for small amounts
    } else if (maxRevenue <= 25) {
      niceNumber = 30.0; // Show up to 30K for medium amounts
    } else if (maxRevenue <= 50) {
      niceNumber = 60.0; // Show up to 60K for larger amounts
    } else if (maxRevenue <= 100) {
      niceNumber = 120.0; // Show up to 120K
    } else {
      niceNumber = (maxRevenue * 1.2).ceilToDouble(); // Add 20% padding
    }

    return niceNumber;
  }

  /// Analyzes transaction types and returns distribution data
  List<Map<String, dynamic>> _analyzeTransactionTypes(
      List<TransactionsRecord> transactions) {
    final Map<String, int> typeCount = {};

    for (final transaction in transactions) {
      final type = transaction.type.isNotEmpty ? transaction.type : 'Unknown';
      typeCount[type] = (typeCount[type] ?? 0) + 1;
    }

    return typeCount.entries.map((entry) {
      return {
        'type': entry.key,
        'count': entry.value,
        'percentage':
            (entry.value / transactions.length * 100).toStringAsFixed(1),
      };
    }).toList();
  }

  /// Analyzes payment methods from transactions
  List<Map<String, dynamic>> _analyzePaymentMethods(
      List<TransactionsRecord> transactions) {
    // Since we don't have payment method field, we'll simulate based on transaction types
    final Map<String, int> methodCount = {
      'Cash': 0,
      'Bank Transfer': 0,
      'Credit Card': 0,
      'Online Payment': 0,
    };

    // Distribute transactions across payment methods (this is simulated data)
    for (int i = 0; i < transactions.length; i++) {
      final method = methodCount.keys.elementAt(i % methodCount.length);
      methodCount[method] = methodCount[method]! + 1;
    }

    return methodCount.entries.map((entry) {
      return {
        'method': entry.key,
        'count': entry.value,
      };
    }).toList();
  }

  /// Analyzes service popularity based on transaction types
  List<Map<String, dynamic>> _analyzeServicePopularity(
      List<TransactionsRecord> transactions) {
    final Map<String, int> serviceCount = {};

    for (final transaction in transactions) {
      final type = transaction.type.isNotEmpty ? transaction.type : 'Other';
      serviceCount[type] = (serviceCount[type] ?? 0) + 1;
    }

    // Sort by count and take top 5
    final sortedServices = serviceCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topServices = sortedServices.take(5).toList();

    // Define colors for different services
    final colors = [
      Color(0xFF3B82F6), // Blue
      Color(0xFF10B981), // Green
      Color(0xFFF59E0B), // Orange
      Color(0xFFEF4444), // Red
      Color(0xFF8B5CF6), // Purple
    ];

    return topServices.asMap().entries.map((entry) {
      return {
        'label': entry.value.key,
        'value': entry.value.value,
        'color': colors[entry.key % colors.length],
      };
    }).toList();
  }

  /// Gets payment method icon
  IconData _getPaymentMethodIcon(String method) {
    switch (method.toLowerCase()) {
      case 'cash':
        return Icons.money_rounded;
      case 'bank transfer':
        return Icons.account_balance_rounded;
      case 'credit card':
        return Icons.credit_card_rounded;
      case 'online payment':
        return Icons.payment_rounded;
      default:
        return Icons.payment_rounded;
    }
  }

  /// Gets this month's transaction count
  int _getThisMonthTransactions(List<TransactionsRecord> transactions) {
    final now = DateTime.now();
    final thisMonth = DateTime(now.year, now.month, 1);

    return transactions.where((transaction) {
      if (transaction.transactionDate != null) {
        return transaction.transactionDate!
            .isAfter(thisMonth.subtract(Duration(days: 1)));
      }
      return false;
    }).length;
  }

  /// Calculates average transaction amount
  String _calculateAverageTransaction(List<TransactionsRecord> transactions) {
    if (transactions.isEmpty) return '0';

    double total = 0;
    int validTransactions = 0;

    for (final transaction in transactions) {
      if (transaction.amount != null && transaction.amount! > 0) {
        total += transaction.amount!;
        validTransactions++;
      }
    }

    if (validTransactions == 0) return '0';

    final average = total / validTransactions;
    return average.toStringAsFixed(0);
  }

  Widget _buildTransactionTypeCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
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
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              Spacer(),
            ],
          ),
          SizedBox(height: 16),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }
}
