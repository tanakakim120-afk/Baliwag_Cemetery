import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:math';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'visitorlogin_model.dart';
export 'visitorlogin_model.dart';

class VisitorloginWidget extends StatefulWidget {
  const VisitorloginWidget({super.key});

  static String routeName = 'visitorlogin';
  static String routePath = '/visitorlogin';

  @override
  State<VisitorloginWidget> createState() => _VisitorloginWidgetState();
}

class _VisitorloginWidgetState extends State<VisitorloginWidget>
    with TickerProviderStateMixin {
  late VisitorloginModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final animationsMap = <String, AnimationInfo>{};

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => VisitorloginModel());

    _model.textController1 ??= TextEditingController();
    _model.textFieldFocusNode1 ??= FocusNode();

    _model.textController2 ??= TextEditingController();
    _model.textFieldFocusNode2 ??= FocusNode();

    // Initialize validators
    _model.textController1Validator =
        (context, value) => _validateRequired(context, value, 'Full Name');
    _model.textController2Validator =
        (context, value) => _validateContactOrEmail(context, value);

    animationsMap.addAll({
      'containerOnPageLoadAnimation': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
          MoveEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(0.0, 110.0),
            end: Offset(0.0, 0.0),
          ),
        ],
      ),
    });
    setupAnimations(
      animationsMap.values.where((anim) =>
          anim.trigger == AnimationTrigger.onActionTrigger ||
          !anim.applyInitialState),
      this,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  // Helper methods for validation
  String? _validateRequired(
      BuildContext context, String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  String? _validateContactOrEmail(BuildContext context, String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number or email is required';
    }

    // Check if it's an email
    if (value.contains('@') && value.contains('.')) {
      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value)) {
        return 'Please enter a valid email address';
      }
    } else {
      // Check if it's a valid phone number
      if (value.length != 11) {
        return 'Phone number must be 11 digits';
      }
      if (!value.startsWith('09')) {
        return 'Phone number must start with 09';
      }
      if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
        return 'Phone number must contain only numbers';
      }
    }
    return null;
  }

  // Helper methods for border styling
  Color _getBorderColor(
      String? text, String? Function(BuildContext, String?)? validator) {
    if (text == null || text.isEmpty) return Colors.grey.shade300;
    if (validator != null && validator(context, text) != null)
      return Colors.red.shade400;
    return const Color(0xFF18651C);
  }

  double _getBorderWidth(
      String? text, String? Function(BuildContext, String?)? validator) {
    if (text == null || text.isEmpty) return 1;
    if (validator != null && validator(context, text) != null) return 2;
    return 2;
  }

  // Comprehensive form validation method
  bool _validateForm() {
    final List<String> validationErrors = [];

    // Validate Full Name
    final nameError =
        _validateRequired(context, _model.textController1.text, 'Full Name');
    if (nameError != null) {
      validationErrors.add(nameError);
    } else {
      // Additional name validation
      final name = _model.textController1.text.trim();
      if (name.length < 2) {
        validationErrors.add('Full Name must be at least 2 characters long');
      }
      if (name.length > 50) {
        validationErrors.add('Full Name must not exceed 50 characters');
      }
      if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(name)) {
        validationErrors.add('Full Name can only contain letters and spaces');
      }
    }

    // Validate Contact/Email
    final contactError =
        _validateContactOrEmail(context, _model.textController2.text);
    if (contactError != null) {
      validationErrors.add(contactError);
    }

    // Check if there are validation errors
    if (validationErrors.isNotEmpty) {
      _showValidationErrorDialog(validationErrors);
      return false;
    }

    return true;
  }

  // Show validation error dialog
  void _showValidationErrorDialog(List<String> errors) {
    showDialog(
      context: context,
      builder: (alertDialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(
                Icons.error_outline_rounded,
                color: Colors.red.shade600,
                size: 24,
              ),
              SizedBox(width: 12),
              Text(
                'Validation Error',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Please correct the following errors:',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFF6B7280),
                ),
              ),
              SizedBox(height: 12),
              ...errors
                  .map((error) => Padding(
                        padding: EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.circle,
                              size: 6,
                              color: Colors.red.shade600,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                error,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: const Color(0xFF1F2937),
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
              onPressed: () => Navigator.pop(alertDialogContext),
              child: Text(
                'OK',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF18651C),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Helper method to build form fields
  Widget _buildTextField({
    required TextEditingController? controller,
    required FocusNode? focusNode,
    required String labelText,
    required String hintText,
    required IconData prefixIcon,
    String? Function(BuildContext, String?)? validator,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            labelText,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF374151),
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 48,
            child: TextFormField(
              controller: controller,
              focusNode: focusNode,
              onChanged: (value) {
                setState(() {}); // Rebuild to show validation errors
              },
              inputFormatters: inputFormatters,
              decoration: InputDecoration(
                hintText: hintText,
                prefixIcon: Icon(
                  prefixIcon,
                  color: const Color(0xFF18651C),
                  size: 20,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: _getBorderColor(controller?.text, validator),
                    width: _getBorderWidth(controller?.text, validator),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: _getBorderColor(controller?.text, validator),
                    width: _getBorderWidth(controller?.text, validator),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: const Color(0xFF18651C),
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: Colors.red.shade400,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                hintStyle: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                  letterSpacing: 0.2,
                ),
              ),
              style: GoogleFonts.inter(
                fontSize: 15,
                color: const Color(0xFF1F2937),
                fontWeight: FontWeight.w500,
                letterSpacing: 0.2,
              ),
            ),
          ),
          // Real-time validation error display
          if (validator != null && controller?.text.isNotEmpty == true)
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: validator(context, controller?.text) != null ? 20 : 0,
              child: validator(context, controller?.text) != null
                  ? Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        validator(context, controller?.text)!,
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
      ),
    );
  }

  // Helper method to build section cards
  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Widget> children,
    Color? backgroundColor,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 32),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1F2937),
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...children,
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
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: responsiveVisibility(
          context: context,
          phone: false,
          tablet: false,
          tabletLandscape: false,
        )
            ? AppBar(
                backgroundColor: Colors.transparent,
                automaticallyImplyLeading: false,
                elevation: 0.0,
              )
            : null,
        body: SafeArea(
          top: true,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Header Section with Logo
                Container(
                  width: double.infinity,
                  padding: const EdgeInsetsDirectional.fromSTEB(
                      24.0, 40.0, 24.0, 32.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFF18651C),
                        const Color(0xFF18651C).withOpacity(0.8),
                        const Color(0xFF18651C).withOpacity(0.6),
                      ],
                    ),
                  ),
                  child: Column(
                    children: [
                      // Logo Container
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            'assets/images/logo.png',
                            width: 120.0,
                            height: 120.0,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Welcome Text
                      Text(
                        'Welcome to Our Facility',
                        style: GoogleFonts.inter(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Please complete the visitor registration form below',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withOpacity(0.9),
                          letterSpacing: 0.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                // Form Sections
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Visitor Information Section
                      _buildSectionCard(
                        title: 'Visitor Information',
                        icon: Icons.person_outline_rounded,
                        iconColor: const Color(0xFF8B5CF6),
                        children: [
                          _buildTextField(
                            controller: _model.textController1,
                            focusNode: _model.textFieldFocusNode1,
                            labelText: 'Full Name*',
                            hintText: 'Enter your complete name',
                            prefixIcon: Icons.person_outline_rounded,
                            validator: _model.textController1Validator,
                          ),
                          _buildTextField(
                            controller: _model.textController2,
                            focusNode: _model.textFieldFocusNode2,
                            labelText: 'Phone Number or Email*',
                            hintText:
                                'Enter your phone number or email address',
                            prefixIcon: Icons.contact_phone_outlined,
                            validator: _model.textController2Validator,
                          ),
                        ],
                      ),

                      // Privacy Consent Section
                      _buildSectionCard(
                        title: 'Privacy Consent',
                        icon: Icons.privacy_tip_outlined,
                        iconColor: const Color(0xFFF59E0B),
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Theme(
                                  data: ThemeData(
                                    checkboxTheme: CheckboxThemeData(
                                      visualDensity: VisualDensity.compact,
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                    unselectedWidgetColor:
                                        const Color(0xFFCBD5E1),
                                  ),
                                  child: Checkbox(
                                    value: _model.checkboxValue ??= false,
                                    onChanged: (newValue) async {
                                      safeSetState(() =>
                                          _model.checkboxValue = newValue!);
                                    },
                                    side: const BorderSide(
                                      width: 2,
                                      color: Color(0xFFCBD5E1),
                                    ),
                                    activeColor: const Color(0xFF18651C),
                                    checkColor: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    'I agree to the collection and processing of my personal data as per the Data Privacy Act of 2012.',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF475569),
                                      height: 1.4,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // Submit Button Section
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(top: 16),
                        child: SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (_model.checkboxValue == true) {
                                // Validate form before submission
                                if (_validateForm()) {
                                  await _submitVisitorRecord();
                                }
                              } else {
                                _showPrivacyConsentDialog();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF18651C),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.check_circle_outline_rounded,
                                  size: 20,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Submit Visit Record',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animateOnPageLoad(
                    animationsMap['containerOnPageLoadAnimation']!),

                // Bottom Spacing
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Submit visitor record
  Future<void> _submitVisitorRecord() async {
    try {
      await VisitorlogRecord.collection.doc().set({
        ...createVisitorlogRecordData(
          name: _model.textController1.text,
          visitorid: '',
        ),
        ...mapToFirestore(
          {
            'timestamp': FieldValue.serverTimestamp(),
          },
        ),
      });

      _showSuccessDialog();
    } catch (e) {
      _showErrorDialog('Failed to submit visitor record. Please try again.');
    }
  }

  // Show success dialog
  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (alertDialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF10B981),
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Success!',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          content: Text(
            'Visitor details have been recorded successfully. Thank you for visiting our facility.',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF475569),
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(alertDialogContext),
              child: Text(
                'Continue',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF18651C),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Show privacy consent dialog
  void _showPrivacyConsentDialog() {
    showDialog(
      context: context,
      builder: (alertDialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              const Icon(
                Icons.privacy_tip_outlined,
                color: Color(0xFFF59E0B),
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Privacy Consent Required',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          content: Text(
            'You must check the box to agree to the collection and processing of your personal data as per the Data Privacy Act of 2012 before you can proceed.',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF475569),
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(alertDialogContext),
              child: Text(
                'I Understand',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF18651C),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Show error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (alertDialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: Color(0xFFEF4444),
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Error',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF475569),
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(alertDialogContext),
              child: Text(
                'Try Again',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF18651C),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
