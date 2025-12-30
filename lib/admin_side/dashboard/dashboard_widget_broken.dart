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
                      icon: Icon(Icons.logout_rounded, color: Colors.white, size: 20),
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
