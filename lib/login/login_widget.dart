import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'login_model.dart';
export 'login_model.dart';

class LoginWidget extends StatefulWidget {
  const LoginWidget({super.key});

  static String routeName = 'login';
  static String routePath = '/login';

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  late LoginModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LoginModel());

    _model.emailAddressTextController ??= TextEditingController();
    _model.emailAddressFocusNode ??= FocusNode();

    _model.passwordTextController ??= TextEditingController();
    _model.passwordFocusNode ??= FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(0xFF18651C).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Color(0xFF18651C),
              size: 20,
            ),
          ),
          SizedBox(width: 16),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Color(0xFF4B5563),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Color(0xFFF8FAFC),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF18651C).withOpacity(0.05),
                Color(0xFFF8FAFC),
                Color(0xFF18651C).withOpacity(0.05),
              ],
            ),
          ),
          child: SafeArea(
          top: true,
          child: Row(
            children: [
                // Left Side - Logo and Welcome Section
              Expanded(
                  flex: 1,
                child: Container(
                    padding: EdgeInsets.all(48),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Logo Section
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF18651C).withOpacity(0.2),
                                blurRadius: 30,
                                offset: Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Image.asset(
                              'assets/images/logo.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(height: 32),

                        // Welcome Text
                        Text(
                          'BALIWAG CITY CEMETERY',
                          style: GoogleFonts.rubik(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF18651C),
                            letterSpacing: 1.0,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'PROVINCE OF BULACAN',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF6B7280),
                            letterSpacing: 2.0,
                          ),
                        ),
                        SizedBox(height: 24),

                        // Description
                        Text(
                          'Welcome to the official cemetery management system. Access your account to manage operations, view records, and maintain our sacred grounds.',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            color: Color(0xFF4B5563),
                            height: 1.6,
                          ),
                        ),
                        SizedBox(height: 32),

                        // Features List
                        _buildFeatureItem(
                            Icons.security_rounded, 'Secure Access Control'),
                        _buildFeatureItem(
                            Icons.analytics_rounded, 'Real-time Analytics'),
                        _buildFeatureItem(
                            Icons.people_rounded, 'User Management'),
                        _buildFeatureItem(
                            Icons.description_rounded, 'Record Management'),
                      ],
                    ),
                  ),
                ),

                // Right Side - Login Form
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: EdgeInsets.all(48),
                    child: Center(
                      child: Container(
                        width: 400,
                        padding: EdgeInsets.all(40),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x1A000000),
                              blurRadius: 30,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                            child: Column(
                          mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            // Login Header
                                Text(
                                  'Welcome Back',
                              style: GoogleFonts.inter(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Sign in to your account',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                            SizedBox(height: 32),

                            // Email Field
                            Text(
                              'Email Address',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF374151),
                              ),
                            ),
                            SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Color(0xFFE5E7EB),
                                  width: 1,
                                ),
                              ),
                                    child: TextFormField(
                                controller: _model.emailAddressTextController,
                                      focusNode: _model.emailAddressFocusNode,
                                      autofocus: true,
                                      autofillHints: [AutofillHints.email],
                                      obscureText: false,
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  color: Color(0xFF1F2937),
                                ),
                                      decoration: InputDecoration(
                                  hintText: 'Enter your email',
                                  hintStyle: GoogleFonts.inter(
                                    color: Color(0xFF9CA3AF),
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.email_outlined,
                                    color: Color(0xFF6B7280),
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 24),

                            // Password Field
                            Text(
                              'Password',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF374151),
                              ),
                            ),
                            SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Color(0xFFE5E7EB),
                                  width: 1,
                                ),
                              ),
                                    child: TextFormField(
                                      controller: _model.passwordTextController,
                                      focusNode: _model.passwordFocusNode,
                                autofocus: false,
                                      autofillHints: [AutofillHints.password],
                                      obscureText: !_model.passwordVisibility,
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  color: Color(0xFF1F2937),
                                ),
                                      decoration: InputDecoration(
                                  hintText: 'Enter your password',
                                  hintStyle: GoogleFonts.inter(
                                    color: Color(0xFF9CA3AF),
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.lock_outline_rounded,
                                    color: Color(0xFF6B7280),
                                    size: 20,
                                  ),
                                        suffixIcon: InkWell(
                                    onTap: () => setState(
                                            () => _model.passwordVisibility =
                                                !_model.passwordVisibility,
                                          ),
                                          child: Icon(
                                            _model.passwordVisibility
                                          ? Icons.visibility_off_rounded
                                          : Icons.visibility_rounded,
                                      color: Color(0xFF6B7280),
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 24),

                            // Login Button
                            Container(
                              width: double.infinity,
                              child: ElevatedButton(
                                    onPressed: () async {
                                  final email =
                                      _model.emailAddressTextController?.text ??
                                          '';
                                  final password =
                                      _model.passwordTextController?.text ?? '';

                                  if (email.isEmpty || password.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Please enter both email and password'),
                                        backgroundColor: Color(0xFFEF4444),
                                      ),
                                    );
                                    return;
                                  }

                                  try {
                                      final user =
                                          await authManager.signInWithEmail(
                                        context,
                                      email,
                                      password,
                                    );

                                    if (user != null) {
                                      context.goNamed('dashboard');
                                    }
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Login failed: ${e.toString()}'),
                                        backgroundColor: Color(0xFFEF4444),
                                      ),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF18651C),
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                child: Text(
                                  'Sign In',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 24),

                            // Footer Text
                            Center(
                              child: Text(
                                '© 2024 Baliwag City Cemetery. All rights reserved.',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: Color(0xFF9CA3AF),
                                ),
                                textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                        ),
                    ),
                  ),
                ),
              ),
            ],
            ),
          ),
        ),
      ),
    );
  }
}
