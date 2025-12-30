import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import '/admin_side/shared/deceased_entry.dart';
import '/admin_side/shared/document_verification_service.dart';
import '/flutter_flow/upload_data.dart';
import '/backend/firebase_storage/storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import 'nitchecontract_form_copy_model.dart';
export 'nitchecontract_form_copy_model.dart';

class NitchecontractFormCopyWidget extends StatefulWidget {
  const NitchecontractFormCopyWidget({
    Key? key,
    this.id,
    this.nitcheLocation,
    this.nitcheAmount,
    this.contractType,
  }) : super(key: key);

  final DocumentReference? id;
  final String? nitcheLocation;
  final double? nitcheAmount;
  final String? contractType; // 'nitche' or 'lot'

  @override
  _NitchecontractFormCopyWidgetState createState() =>
      _NitchecontractFormCopyWidgetState();
}

class _NitchecontractFormCopyWidgetState
    extends State<NitchecontractFormCopyWidget> {
  late NitchecontractFormCopyModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => NitchecontractFormCopyModel());

    // Initialize contract type to 'new' by default
    _model.contractTypeValue = 'new';

    // Initialize controllers and validators
    _model.applicantnameTextControllerValidator = _validateApplicantName;
    _model.applicantcontactTextControllerValidator = _validateContactNumber;
    _model.applicantaddressTextControllerValidator =
        _validateResidentialAddress;

    _model.residentcertTextControllerValidator = _validateResidentCertificate;
    _model.placeissuedTextControllerValidator =
        (context, value) => _validateRequired(context, value, 'Place Issued');
    _model.ornoTextControllerValidator =
        (context, value) => _validateRequired(context, value, 'OR Number');
    _model.amountTextControllerValidator = _validateAmount;
    _model.tinTextControllerValidator = _validateTIN;
    _model.proofOfLeaseTextControllerValidator = null; // Optional field

    // Initialize controllers
    _model.applicantnameTextController ??= TextEditingController();
    _model.applicantcontactTextController ??= TextEditingController();
    _model.applicantaddressTextController ??= TextEditingController();

    _model.residentcertTextController ??= TextEditingController();
    _model.placeissuedTextController ??= TextEditingController();
    _model.ornoTextController ??= TextEditingController();
    _model.amountTextController ??= TextEditingController();
    _model.tinTextController ??= TextEditingController();
    _model.tomblocationTextController ??= TextEditingController();
    _model.totalyearsTextController ??= TextEditingController();
    _model.totalbalanceTextController ??= TextEditingController();
    _model.totalcontractvalueTextController ??= TextEditingController();
    _model.dateofexpirationTextController ??= TextEditingController();
    _model.dateissuedTextController ??= TextEditingController();
    _model.proofOfLeaseTextController ??= TextEditingController();

    // Initialize focus nodes
    _model.unfocusNode ??= FocusNode();
    _model.applicantnameFocusNode ??= FocusNode();
    _model.applicantcontactFocusNode ??= FocusNode();
    _model.applicantaddressFocusNode ??= FocusNode();

    _model.residentcertFocusNode ??= FocusNode();
    _model.placeissuedFocusNode ??= FocusNode();
    _model.ornoFocusNode ??= FocusNode();
    _model.amountFocusNode ??= FocusNode();
    _model.tinFocusNode ??= FocusNode();
    _model.tomblocationFocusNode ??= FocusNode();
    _model.totalyearsFocusNode ??= FocusNode();
    _model.totalbalanceFocusNode ??= FocusNode();
    _model.dateofexpirationFocusNode ??= FocusNode();
    _model.dateissuedFocusNode ??= FocusNode();
    _model.proofOfLeaseFocusNode ??= FocusNode();

    // Set initial values from route parameters
    if (widget.nitcheLocation != null) {
      _model.tomblocationTextController?.text = widget.nitcheLocation!;
    }
    if (widget.nitcheAmount != null) {
      _model.amountTextController?.text = widget.nitcheAmount!.toString();
    }

    // Set default value for place issued
    _model.placeissuedTextController?.text = 'Baliwag';

    // Set default value for ORN using app state qrcode
    _model.ornoTextController?.text = FFAppState().qrcode.isNotEmpty
        ? FFAppState().qrcode
        : 'QR-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';

    // Set default value for date issued to current timestamp
    _model.dateissuedTextController?.text =
        dateTimeFormat("yMd", DateTime.now());
    _model.datePicked4 = DateTime.now(); // Set initial date for date picker

    // Update contract calculations
    _updateContractCalculations();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  // Helper method to update contract calculations
  void _updateContractCalculations() {
    if (_model.datePicked3 != null) {
      final int startYear =
          _model.effectiveDatePicked?.year ?? DateTime.now().year;
      final int expirationYear = _model.datePicked3!.year;
      final int duration = expirationYear - startYear;

      if (duration > 0) {
        _model.totalyears = duration;
        _model.totalyearsTextController?.text = duration.toString();

        // Only calculate total contract value for new contracts
        if ((_model.contractTypeValue ?? 'new') != 'past' && widget.nitcheAmount != null) {
          final double totalContractValue =
              (duration * widget.nitcheAmount!) - widget.nitcheAmount!;

          print('Debug: Calculating total contract value');
          print('Debug: nitcheAmount = ${widget.nitcheAmount}');
          print('Debug: duration = $duration');
          print('Debug: startYear = $startYear');
          print('Debug: totalContractValue = $totalContractValue');
          print(
              'Debug: totalcontractvalueTextController exists = ${_model.totalcontractvalueTextController != null}');

          _model.totalcontractvalueTextController?.text =
              totalContractValue.toString();
          print(
              'Debug: Set totalcontractvalueTextController.text = ${_model.totalcontractvalueTextController?.text}');
        }
      }
    }
  }

  // Helper methods for validation
  String? _validateRequired(
      BuildContext context, String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  String? _validateContactNumber(BuildContext context, String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Mobile Contact Number is required';
    }
    if (!RegExp(r'^09\d{9}$').hasMatch(value.trim())) {
      return 'Mobile Contact Number must be 11 digits starting with 09';
    }
    return null;
  }

  // Validate contact number uniqueness across different applicants
  Future<bool> _validateContactNumberUniqueness() async {
    final contactNumber = _model.applicantcontactTextController?.text.trim();
    final applicantName = _model.applicantnameTextController?.text.trim();

    if (contactNumber == null || contactNumber.isEmpty) {
      return true; // Skip if empty (handled by other validation)
    }

    if (applicantName == null || applicantName.isEmpty) {
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
              _showErrorDialog(
                'Contact Number Already Used',
                'This contact number ($contactNumber) is already registered to a different applicant: "${name}".\n\nPlease use a different contact number or verify the applicant name.',
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

  String? _validateTIN(BuildContext context, String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'TIN Number is required';
    }
    if (!RegExp(r'^\d{3}\s*-\s*\d{3}\s*-\s*\d{3}\s*-\s*\d{3}$')
        .hasMatch(value.trim())) {
      return 'TIN Number must be in format: xxx - xxx - xxx - xxx';
    }
    return null;
  }

  String? _validateAmount(BuildContext context, String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Amount is required';
    }
    final amount = double.tryParse(value);
    if (amount == null || amount <= 0) {
      return 'Amount must be a positive number';
    }
    return null;
  }

  String? _validateApplicantName(BuildContext context, String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Applicant Full Name is required';
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
      return 'Name can only contain letters and spaces';
    }
    return null;
  }

  String? _validateResidentialAddress(BuildContext context, String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Residential Address is required';
    }
    final trimmedValue = value.trim();
    if (trimmedValue.length < 5) {
      return 'Address must be at least 5 characters long';
    }
    final addressRegex = RegExp(r'^[A-Za-z0-9\s.,#\-]+$');
    if (!addressRegex.hasMatch(trimmedValue)) {
      return 'Address can only contain letters, numbers, spaces, commas, periods, #, and hyphens';
    }
    return null;
  }

  String? _validateResidentCertificate(BuildContext context, String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Resident Certificate is required';
    }
    final trimmedValue = value.trim();
    if (!RegExp(r'^\d{8,11}$').hasMatch(trimmedValue)) {
      return 'Certificate number must be 8-11 digits';
    }
    return null;
  }

  // Comprehensive validation to check all fields for null/empty values
  bool _validateAllFields() {
    List<String> emptyFields = [];

    // Check primary applicant information
    if (_model.applicantnameTextController?.text.trim().isEmpty ?? true) {
      emptyFields.add('Applicant Full Name');
    }
    if (_model.applicantcontactTextController?.text.trim().isEmpty ?? true) {
      emptyFields.add('Mobile Contact Number');
    }
    if (_model.applicantaddressTextController?.text.trim().isEmpty ?? true) {
      emptyFields.add('Residential Address');
    }

    // Check required documentation
    if (_model.residentcertTextController?.text.trim().isEmpty ?? true) {
      emptyFields.add('Resident Certificate');
    }
    if (_model.tinTextController?.text.trim().isEmpty ?? true) {
      emptyFields.add('Tax Identification Number (TIN)');
    }
    if (_model.placeissuedTextController?.text.trim().isEmpty ?? true) {
      emptyFields.add('Document Issue Location');
    }
    if (_model.ornoTextController?.text.trim().isEmpty ?? true) {
      emptyFields.add('OR Number');
    }
    if (_model.amountTextController?.text.trim().isEmpty ?? true) {
      emptyFields.add('Amount');
    }
    if (_model.proofOfLeasePath == null || _model.proofOfLeasePath!.isEmpty) {
      emptyFields.add('Proof of Lease');
    }

    // Check deceased entries
    for (int i = 0; i < _model.deceasedEntries.length; i++) {
      final entry = _model.deceasedEntries[i];
      if (entry.nameController.text.trim().isEmpty) {
        emptyFields.add('Deceased Person Name');
      }
      if (entry.deathDate == null) {
        emptyFields.add('Date of Death');
      }
      if (entry.burialDate == null) {
        emptyFields.add('Date of Burial');
      }
    }
    
    // Check contract dates
    if (_model.datePicked3 == null) {
      emptyFields.add('Date of Expiration');
    }
    
    // Check effective date for past contracts
    if ((_model.contractTypeValue ?? 'new') == 'past' && _model.effectiveDatePicked == null) {
      emptyFields.add('Effective Date');
    }

    // If there are empty fields, show error dialog
    if (emptyFields.isNotEmpty) {
      _showValidationErrorDialog(emptyFields);
      return false;
    }

    return true;
  }

  // Comprehensive format validation to check all field formats before saving
  bool _validateAllFieldFormats() {
    List<String> formatErrors = [];

    // Check Applicant Full Name format
    final applicantNameError = _validateApplicantName(
        context, _model.applicantnameTextController?.text);
    if (applicantNameError != null) {
      formatErrors.add(applicantNameError);
    }

    // Check Mobile Contact Number format
    final contactError = _validateContactNumber(
        context, _model.applicantcontactTextController?.text);
    if (contactError != null) {
      formatErrors.add(contactError);
    }

    // Check Residential Address format
    final addressError = _validateResidentialAddress(
        context, _model.applicantaddressTextController?.text);
    if (addressError != null) {
      formatErrors.add(addressError);
    }

    // Check Resident Certificate format
    final residentCertError = _validateResidentCertificate(
        context, _model.residentcertTextController?.text);
    if (residentCertError != null) {
      formatErrors.add(residentCertError);
    }

    // Check TIN Number format
    final tinError = _validateTIN(context, _model.tinTextController?.text);
    if (tinError != null) {
      formatErrors.add(tinError);
    }

    // Check Amount format
    final amountError =
        _validateAmount(context, _model.amountTextController?.text);
    if (amountError != null) {
      formatErrors.add(amountError);
    }

    // Check deceased entries format
    for (int i = 0; i < _model.deceasedEntries.length; i++) {
      final entry = _model.deceasedEntries[i];
      final deceasedNameError =
          _validateApplicantName(context, entry.nameController.text);
      if (deceasedNameError != null) {
        formatErrors.add(deceasedNameError);
      }
      
      // Validate that burial date is >= death date
      if (entry.deathDate != null && entry.burialDate != null) {
        if (entry.burialDate!.isBefore(entry.deathDate!)) {
          formatErrors.add(
              'Date of Burial must be equal to or after Date of Death for deceased person ${i + 1}');
        }
      }
    }
    
    // Validate expiration date is greater than effective date for past contracts
    if ((_model.contractTypeValue ?? 'new') == 'past' && 
        _model.effectiveDatePicked != null && 
        _model.datePicked3 != null) {
      if (_model.datePicked3!.isBefore(_model.effectiveDatePicked!) || 
          _model.datePicked3!.isAtSameMomentAs(_model.effectiveDatePicked!)) {
        formatErrors.add('Date of Expiration must be greater than Effective Date');
      }
    }

    // If there are format errors, show error dialog
    if (formatErrors.isNotEmpty) {
      _showFormatErrorDialog(formatErrors);
      return false;
    }

    return true;
  }

  // Show validation error dialog with list of empty fields
  void _showValidationErrorDialog(List<String> emptyFields) {
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
                'Please fill in the following required fields:',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 12),
              ...emptyFields.map((field) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
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
                              color: const Color(0xFF1F2937),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'OK',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E40AF),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Show format error dialog with list of format errors
  void _showFormatErrorDialog(List<String> formatErrors) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.warning_rounded,
                color: const Color(0xFFF59E0B),
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Format Validation Errors',
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
                'Please correct the following format errors:',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 12),
              ...formatErrors.map((error) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.circle,
                          size: 6,
                          color: const Color(0xFFF59E0B),
                        ),
                        const SizedBox(width: 8),
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
                  )),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'OK',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E40AF),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Helper methods for border styling
  Color _getBorderColor(
      String? text, String? Function(BuildContext, String?)? validator) {
    if (text == null || text.isEmpty) return Colors.grey.shade300;
    if (validator != null && validator(context, text) != null)
      return Colors.red.shade400;
    return const Color(0xFF1E40AF);
  }

  double _getBorderWidth(
      String? text, String? Function(BuildContext, String?)? validator) {
    if (text == null || text.isEmpty) return 1;
    if (validator != null && validator(context, text) != null) return 2;
    return 2;
  }

  // Helper method to build text fields
  Widget _buildTextField({
    required TextEditingController? controller,
    required FocusNode? focusNode,
    required String labelText,
    required String hintText,
    required IconData prefixIcon,
    bool isReadOnly = false,
    String? Function(BuildContext, String?)? validator,
    List<TextInputFormatter>? inputFormatters,
    void Function(String?)? onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  labelText,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF374151),
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              // Green check icon when format is correct
              if (controller?.text.isNotEmpty == true &&
                  (validator == null ||
                      validator(context, controller?.text) == null))
                Icon(
                  Icons.check_circle_rounded,
                  color: const Color(0xFF10B981),
                  size: 20,
                ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 48, // Fixed height to match date field
            child: TextFormField(
              controller: controller,
              focusNode: focusNode,
              readOnly: isReadOnly,
              onChanged: (value) {
                // Trigger validation on every keystroke
                if (onChanged != null) onChanged(value);
                setState(() {}); // Rebuild to show validation errors
              },
              inputFormatters: inputFormatters,
              decoration: InputDecoration(
                hintText: hintText,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: (controller?.text.isNotEmpty == true &&
                            (validator == null ||
                                validator(context, controller?.text) == null))
                        ? Colors.transparent
                        : _getBorderColor(controller?.text, validator),
                    width: (controller?.text.isNotEmpty == true &&
                            (validator == null ||
                                validator(context, controller?.text) == null))
                        ? 0
                        : _getBorderWidth(controller?.text, validator),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: (controller?.text.isNotEmpty == true &&
                            (validator == null ||
                                validator(context, controller?.text) == null))
                        ? Colors.transparent
                        : _getBorderColor(controller?.text, validator),
                    width: (controller?.text.isNotEmpty == true &&
                            (validator == null ||
                                validator(context, controller?.text) == null))
                        ? 0
                        : _getBorderWidth(controller?.text, validator),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: (controller?.text.isNotEmpty == true &&
                            (validator == null ||
                                validator(context, controller?.text) == null))
                        ? Colors.transparent
                        : const Color(0xFF1E40AF),
                    width: (controller?.text.isNotEmpty == true &&
                            (validator == null ||
                                validator(context, controller?.text) == null))
                        ? 0
                        : 2,
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
                fillColor: isReadOnly ? Colors.grey.shade50 : Colors.white,
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
                color:
                    isReadOnly ? Colors.grey.shade700 : const Color(0xFF1F2937),
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

  // Helper method to build date fields
  Widget _buildDateField({
    required String labelText,
    required String hintText,
    required TextEditingController? controller,
    required DateTime? selectedDate,
    required DateTime? firstDate,
    required DateTime? lastDate,
    required Function(DateTime) onDateSelected,
    bool isRequired = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  labelText,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF374151),
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              // Green check icon when date is selected
              if (selectedDate != null)
                Icon(
                  Icons.check_circle_rounded,
                  color: const Color(0xFF10B981),
                  size: 20,
                ),
            ],
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () async {
              // Calculate proper initialDate that respects firstDate constraint
              DateTime calculateInitialDate() {
                if (selectedDate != null) return selectedDate!;
                final now = DateTime.now();
                if (firstDate != null && now.isBefore(firstDate!)) {
                  return firstDate!;
                }
                return now;
              }

              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: calculateInitialDate(),
                firstDate: firstDate ?? DateTime(1900),
                lastDate: lastDate ?? DateTime(2100),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: Color(0xFF1E40AF),
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
            child: Container(
              height: 48, // Fixed height to match text field
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    color: Colors.grey.shade500,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      selectedDate != null
                          ? dateTimeFormat("yMd", selectedDate)
                          : hintText,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: selectedDate != null
                            ? const Color(0xFF1F2937)
                            : Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Colors.grey.shade400,
                    size: 20,
                  ),
                ],
              ),
            ),
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

  // Helper method to build form rows with 3 columns
  Widget _buildFormRow(List<Widget> children) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children.map((child) {
        final index = children.indexOf(child);
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 0 : 12,
              right: index == children.length - 1 ? 0 : 12,
            ),
            child: child,
          ),
        );
      }).toList(),
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
            fontWeight: FontWeight.w600,
            color: const Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFE5E7EB),
              width: 1,
            ),
          ),
          child: uploadedFile != null
              ? Row(
                  children: [
                    const SizedBox(width: 12),
                    Icon(
                      Icons.attach_file_rounded,
                      color: const Color(0xFF1E40AF),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        uploadedFile
                            .split('/')
                            .last
                            .replaceAll(RegExp(r'_\d+\.'), '.'),
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: const Color(0xFF1F2937),
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
                  borderRadius: BorderRadius.circular(12),
                  child: Row(
                    children: [
                      const SizedBox(width: 12),
                      Icon(
                        Icons.upload_file_rounded,
                        color: const Color(0xFF6B7280),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        hintText,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

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
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Helper: ensure all loading dialogs are dismissed
  void _clearAllLoadingDialogs() {
    while (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  // Helper method to upload proof of lease
  Future<void> _uploadProofOfLease() async {
    try {
      // Show loading modal
      _showLoadingDialog('Selecting file...');

      // Select file using file picker
      final selectedFile = await selectFile(
        storageFolderPath: 'proof_of_lease',
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
      );

      if (selectedFile != null) {
        // Switch to verification loading modal
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
        _showLoadingDialog('Verifying document authenticity...');

        // Get file name from storage path and determine MIME type
        final fileName = selectedFile.storagePath.split('/').last;
        final mimeType = _getMimeTypeFromFileName(fileName);

        // Verify document authenticity
        final verificationResult =
            await DocumentVerificationService.verifyDocument(
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
          await _showVerificationDialog(verificationResult, selectedFile);
          return;
        }

        // Switch to upload loading modal
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
        _showLoadingDialog('Uploading verified file to storage...');

        // Actually upload the file to Firebase Storage
        final downloadUrl =
            await uploadData(selectedFile.storagePath, selectedFile.bytes);

        if (downloadUrl != null) {
          // Store the download URL instead of just the storage path
          setState(() {
            _model.proofOfLeasePath = downloadUrl;
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
      await _showMessageDialog('Error', 'Error uploading file: $e');
    }
  }

  // Show verification dialog for invalid documents
  Future<void> _showVerificationDialog(
    DocumentVerificationResult result,
    dynamic selectedFile,
  ) async {
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

  // Helper method to determine MIME type from file name
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

  // Helper method to remove proof of lease
  void _removeProofOfLease() {
    setState(() {
      _model.proofOfLeasePath = null;
    });
    _showMessageDialog('Removed', 'Proof of lease removed!');
  }

  // Helper method to get location value with proper retention
  String _getLocationValue() {
    // Priority 1: Use widget nitcheLocation (passed from parent)
    if (widget.nitcheLocation != null && widget.nitcheLocation!.isNotEmpty) {
      return widget.nitcheLocation!;
    }

    // Priority 2: Use tomb location text controller
    if (_model.tomblocationTextController?.text.isNotEmpty == true) {
      return _model.tomblocationTextController!.text;
    }

    // Priority 3: Return empty string as fallback
    return '';
  }

  // Method to update contract document
  Future<void> _updateContractDocument() async {
    print('_updateContractDocument called');

    // Check if this is a new nitche creation (no contract ID passed)
    if (widget.id == null) {
      await _createNewNitcheDocument();
    } else {
      await _updateExistingContractDocument();
    }
  }

  // Method to create a new nitche document in contract collection
  Future<void> _createNewNitcheDocument() async {
    print('Creating new nitche document...');

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Creating nitche...'),
            ],
          ),
        );
      },
    );

    try {
      // Get current timestamp
      final DateTime now = DateTime.now();
      final Timestamp timestamp = Timestamp.fromDate(now);

      // Get the next auto-incrementing nitche ID
      final int currentNitcheId = FFAppState().nitcheid;
      final int nitcheidValue = FFAppState().getNextNitcheId();

      print('Current nitche ID: $currentNitcheId');
      print('Creating nitche with ID: $nitcheidValue');
      print('Nitche Location: ${widget.nitcheLocation}');
      print('Nitche Amount: ${widget.nitcheAmount}');

      // Prepare the new nitche data
      final Map<String, dynamic> nitcheData = {
        'nitcheid': nitcheidValue, // unique generated nitche ID (integer)
        'amount': '1000', // fixed amount = 1000 (as string)
        'nitcheidString': nitcheidValue.toString(), // string representation
        'type':
            widget.contractType ?? 'nitche', // dynamic type based on contract
        'status': 'available', // status = available
        'Location': nitcheidValue.toString(), // location as string
        'dateadded': timestamp, // dateadded = timestamp
        'dateofexpiration': null, // dateofexpiration = null for nitche
      };

      // Create the new nitche document in contract collection
      await FirebaseFirestore.instance.collection('contract').add(nitcheData);

      // Close loading dialog
      Navigator.of(context).pop();

      // Show success message
      _showSuccessDialog(isNewDocument: true, isNitche: true);
    } catch (e) {
      // Close loading dialog
      Navigator.of(context).pop();

      // Show error message
      _showErrorDialog('Error', 'Failed to create nitche: ${e.toString()}');
    }
  }

  // Method to update existing contract document
  Future<void> _updateExistingContractDocument() async {
    print('Updating existing contract document...');

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Processing contract...'),
            ],
          ),
        );
      },
    );

    try {
      // Get current timestamp
      final DateTime now = DateTime.now();
      final Timestamp timestamp = Timestamp.fromDate(now);

      // Get and increment contract ID from app state
      final int contractIdValue = FFAppState().contractid;
      FFAppState().contractid = contractIdValue + 1;

      // Debug: Print the contractID value being used
      print('Setting contractID to: $contractIdValue');
      print('Nitche Location: ${widget.nitcheLocation}');
      print('Nitche Amount: ${widget.nitcheAmount}');
      print('DEBUG: Location value to be saved: ${_getLocationValue()}');
      print('DEBUG: Widget nitcheLocation: ${widget.nitcheLocation}');
      print(
          'DEBUG: Controller text: ${_model.tomblocationTextController?.text}');

      // Prepare the update data
      final Map<String, dynamic> updateData = {
        // Keep nitche identification fields
        'nitcheid': widget.nitcheLocation != null
            ? int.tryParse(widget.nitcheLocation!) ?? 0
            : 0,
        'nitcheidString': widget.nitcheLocation ?? '',
        'type': widget.contractType ?? 'nitche',
        'status':
            'unaddable', // Status becomes unaddable when deceased is added

        // Contract details
        'amount': _model.amountTextController?.text ?? '', // String
        'OR': _model.ornoTextController?.text ?? '', // String
        'TIN': _model.tinTextController?.text ?? '', // String
        'ResidentCert': _model.residentcertTextController?.text ?? '', // String
        'placeIssued': _model.placeissuedTextController?.text ?? '', // String
        'dateIssued': _model.datePicked4 != null
            ? Timestamp.fromDate(_model.datePicked4!)
            : null, // DateTime
        'proofoflease': _model.proofOfLeasePath ??
            '', // Image Path - proof of lease file path
        'Location': _getLocationValue(), // Retain original location

        // Contract ID fields
        'contractID': contractIdValue ?? 0, // Integer from app state
        'contractidString': contractIdValue?.toString() ?? '', // String

        // Deceased information - Multiple entries support
        'decFullName': _model.deceasedEntries
            .map((entry) => entry.nameController.text)
            .where((name) => name.isNotEmpty)
            .toList(), // List<String>
        'dateEffective': (_model.contractTypeValue ?? 'new') == 'past' && _model.effectiveDatePicked != null
            ? Timestamp.fromDate(_model.effectiveDatePicked!)
            : timestamp, // DateTime - use selected date for past contracts
        'applicantName': FieldValue.arrayUnion(
            [_model.applicantnameTextController?.text ?? '']), // List<String>
        'applicantContactNumber': FieldValue.arrayUnion([
          int.tryParse(_model.applicantcontactTextController?.text ?? '0') ?? 0
        ]), // List<Integer>
        'applcantAddress': FieldValue.arrayUnion([
          _model.applicantaddressTextController?.text ?? ''
        ]), // List<String>
        'dateofexpiration': _model.datePicked3 != null
            ? Timestamp.fromDate(_model.datePicked3!)
            : null, // DateTime
        'contractstatus': (_model.contractTypeValue ?? 'new') == 'past' ? 'past' : 'active', // String - based on contract type
        'burialinternment': _model.deceasedEntries
            .where((entry) => entry.burialDate != null)
            .map((entry) => Timestamp.fromDate(entry.burialDate!))
            .toList(), // List<DateTime>
        'dateofdeath': _model.deceasedEntries
            .where((entry) => entry.deathDate != null)
            .map((entry) => Timestamp.fromDate(entry.deathDate!))
            .toList(), // List<DateTime>

        // Financial fields
        'initialfee':
            double.tryParse(_model.amountTextController?.text ?? '0') ??
                0.0, // Double
        'balance': int.tryParse(
                _model.totalcontractvalueTextController?.text ?? '0') ??
            0, // Integer
        'totalContraBalance': double.tryParse(
                _model.totalcontractvalueTextController?.text ?? '0') ??
            0.0, // Double

        // Additional fields
        'stringEffectivedate': timestamp.toString(), // String
        'stringExpirationdate':
            _model.dateofexpirationTextController?.text ?? '', // String
        'lastUpdated': timestamp, // DateTime
        'timestamp': timestamp, // Timestamp field
      };

      // Debug: Print what's being saved for deceased entries
      print(
          'Debug: NitchecontractFormCopy - Saving multiple deceased entries:');
      print('Debug: Total deceased entries: ${_model.deceasedEntries.length}');
      for (int i = 0; i < _model.deceasedEntries.length; i++) {
        final entry = _model.deceasedEntries[i];
        print(
            'Debug: Entry $i - Name: "${entry.nameController.text}", Death Date: ${entry.deathDate}, Burial Date: ${entry.burialDate}');
      }
      print(
          'Debug: New names to save: ${_model.deceasedEntries.map((entry) => entry.nameController.text).where((name) => name.isNotEmpty).toList()}');
      print(
          'Debug: New death dates to save: ${_model.deceasedEntries.where((entry) => entry.deathDate != null).map((entry) => entry.deathDate).toList()}');
      print(
          'Debug: New burial dates to save: ${_model.deceasedEntries.where((entry) => entry.burialDate != null).map((entry) => entry.burialDate).toList()}');

      // Get the document ID from the route parameters
      final String documentId = widget.id!.id;

      // Update the existing document (merge changes instead of replacing)
      await FirebaseFirestore.instance
          .collection('contract')
          .doc(documentId)
          .update(updateData);

      // Close loading dialog
      Navigator.of(context).pop();

      // Show success message
      _showSuccessDialog(isNewDocument: false, isNitche: false);
    } catch (e) {
      // Close loading dialog
      Navigator.of(context).pop();

      // Show error message
      _showErrorDialog('Error', 'Failed to update contract: ${e.toString()}');
    }
  }

  // Helper method to show success dialog
  void _showSuccessDialog({bool isNewDocument = false, bool isNitche = false}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: const Color(0xFF10B981),
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Success!',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          content: Text(
            isNitche
                ? 'Nitche has been successfully created!'
                : isNewDocument
                    ? 'Contract has been successfully created!'
                    : 'Contract has been successfully updated!',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Colors.grey.shade700,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.pop();
              },
              child: Text(
                'Continue',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E40AF),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Helper method to show error dialog
  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.error_rounded,
                color: Colors.red.shade500,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Colors.grey.shade700,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'OK',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E40AF),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: const Color(0xFFF8FAFC),
        body: SafeArea(
          top: true,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Subtitle Section
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                  child: Text(
                    'Complete the form below to create a new contract or update existing one',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),

                // Form Sections
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _model.formKey,
                    child: Column(
                      children: [
                        // Contract Type Selection
                        _buildSectionCard(
                          title: 'Contract Type',
                          icon: Icons.description_rounded,
                          iconColor: const Color(0xFF7C3AED),
                          children: [
                            Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Select Contract Type*',
                                          style: GoogleFonts.inter(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF374151),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  DropdownButtonFormField<String>(
                                    value: _model.contractTypeValue ?? 'new',
                                    items: const [
                                      DropdownMenuItem(value: 'new', child: Text('New Contract')),
                                      DropdownMenuItem(value: 'past', child: Text('Add Existing Contract')),
                                    ],
                                    onChanged: (val) {
                                      setState(() {
                                        _model.contractTypeValue = val;
                                        
                                        // Clear form data when contract type changes
                                        // (Keep: initial fee, document issue location, document issue date)
                                        
                                        // Applicant information
                                        _model.applicantnameTextController?.clear();
                                        _model.applicantcontactTextController?.clear();
                                        _model.applicantaddressTextController?.clear();
                                        
                                        // Deceased entries - reset to one empty entry
                                        _model.deceasedEntries.clear();
                                        _model.deceasedEntries.add(DeceasedEntry());
                                        
                                        // Contract details (keep amountTextController - initial fee)
                                        _model.dateofexpirationTextController?.clear();
                                        _model.totalyearsTextController?.clear();
                                        _model.totalcontractvalueTextController?.clear();
                                        
                                        // Documentation (keep placeissuedTextController, dateissuedTextController, datePicked4)
                                        _model.residentcertTextController?.clear();
                                        _model.tinTextController?.clear();
                                        
                                        // Handle OR field based on contract type
                                        if (val == 'past') {
                                          _model.ornoTextController?.clear();
                                        } else {
                                          final qrCode = FFAppState().qrcode;
                                          final generatedFallback = 'QR-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
                                          _model.ornoTextController?.text =
                                              qrCode.isNotEmpty ? qrCode : generatedFallback;
                                        }
                                        
                                        // Clear dates (keep datePicked4 - document issue date)
                                        _model.datePicked3 = null;
                                        _model.effectiveDatePicked = null;
                                        
                                        // Clear proof of lease
                                        _model.proofOfLeasePath = null;
                                      });
                                    },
                                    decoration: InputDecoration(
                                      hintText: 'Select contract type',
                                      hintStyle: GoogleFonts.inter(
                                        fontSize: 16,
                                        color: const Color(0xFF9CA3AF),
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color: Color(0xFFE5E7EB),
                                          width: 2,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color: Color(0xFFE5E7EB),
                                          width: 2,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color: Color(0xFF1E40AF),
                                          width: 2,
                                        ),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 16,
                                      ),
                                    ),
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF1F2937),
                                    ),
                                    icon: const Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: Color(0xFF6B7280),
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: (_model.contractTypeValue ?? 'new') == 'new'
                                          ? const Color(0xFFDCFCE7)
                                          : const Color(0xFFFEF3C7),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: (_model.contractTypeValue ?? 'new') == 'new'
                                            ? const Color(0xFF10B981)
                                            : const Color(0xFFF59E0B),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          (_model.contractTypeValue ?? 'new') == 'new'
                                              ? Icons.fiber_new_rounded
                                              : Icons.history_rounded,
                                          color: (_model.contractTypeValue ?? 'new') == 'new'
                                              ? const Color(0xFF10B981)
                                              : const Color(0xFFF59E0B),
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            (_model.contractTypeValue ?? 'new') == 'new'
                                                ? 'This is a new contract being created now'
                                                : 'This is an existing client contract that will be migrated into the system',
                                            style: GoogleFonts.inter(
                                              fontSize: 14,
                                              color: const Color(0xFF374151),
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
                        const SizedBox(height: 24),
                        
                        // Primary Applicant Information
                        _buildSectionCard(
                          title: 'Primary Applicant Information',
                          icon: Icons.person_outline_rounded,
                          iconColor: const Color(0xFF8B5CF6),
                          children: [
                            _buildFormRow([
                              _buildTextField(
                                controller: _model.applicantnameTextController,
                                focusNode: _model.applicantnameFocusNode,
                                labelText: 'Applicant Full Name*',
                                hintText: 'Enter complete name',
                                prefixIcon: Icons.person_outline_rounded,
                                validator: _validateApplicantName,
                              ),
                              _buildTextField(
                                controller:
                                    _model.applicantcontactTextController,
                                focusNode: _model.applicantcontactFocusNode,
                                labelText: 'Mobile Contact Number*',
                                hintText: 'Enter 11-digit mobile number',
                                prefixIcon: Icons.phone_rounded,
                                validator: _validateContactNumber,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                              ),
                              _buildTextField(
                                controller:
                                    _model.applicantaddressTextController,
                                focusNode: _model.applicantaddressFocusNode,
                                labelText: 'Residential Address*',
                                hintText: 'Enter complete address',
                                prefixIcon: Icons.location_on_rounded,
                                validator: _validateResidentialAddress,
                              ),
                            ]),
                          ],
                        ),

                        // Deceased Details Section - Multiple Entries Support
                        _buildSectionCard(
                          title: 'Deceased Person Information',
                          icon: Icons.people_alt_rounded,
                          iconColor: const Color(0xFF3B82F6),
                          children: [
                            // Section header with Add Another Deceased button
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                  onPressed: () {
                                    // Debug: Log location value before adding deceased
                                    print(
                                        'DEBUG: Adding deceased entry. Current location: ${_getLocationValue()}');
                                    print(
                                        'DEBUG: Widget nitcheLocation: ${widget.nitcheLocation}');
                                    print(
                                        'DEBUG: Controller text: ${_model.tomblocationTextController?.text}');

                                    setState(() {
                                      _model.deceasedEntries
                                          .add(DeceasedEntry());
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
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF3B82F6),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // Dynamic deceased entries
                            ..._model.deceasedEntries
                                .asMap()
                                .entries
                                .map((entry) {
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
                                            color: const Color(0xFF6B7280),
                                          ),
                                        ),
                                        const Spacer(),
                                        IconButton(
                                          onPressed: () {
                                            setState(() {
                                              final entryToRemove =
                                                  _model.deceasedEntries[index];
                                              _model.deceasedEntries
                                                  .removeAt(index);
                                              entryToRemove.dispose();
                                            });
                                          },
                                          icon: Icon(
                                            Icons.remove_circle_outline_rounded,
                                            color: const Color(0xFFEF4444),
                                            size: 20,
                                          ),
                                          tooltip:
                                              'Remove this deceased person',
                                        ),
                                      ],
                                    ),
                                  // Form row with deceased fields
                                  _buildFormRow([
                                    _buildTextField(
                                      controller: deceasedEntry.nameController,
                                      focusNode: deceasedEntry.nameFocusNode,
                                      labelText: 'Deceased Person Name*',
                                      hintText: 'Enter the complete name',
                                      prefixIcon: Icons.person_rounded,
                                      validator: _validateApplicantName,
                                    ),
                                    _buildDateField(
                                      labelText: 'Date of Death*',
                                      hintText: 'Select Date of Death',
                                      controller:
                                          deceasedEntry.deathDateController,
                                      selectedDate: deceasedEntry.deathDate,
                                      firstDate: DateTime(1900),
                                      lastDate: DateTime.now(),
                                      onDateSelected: (picked) {
                                        setState(() {
                                          deceasedEntry.deathDate = picked;
                                          deceasedEntry
                                                  .deathDateController.text =
                                              dateTimeFormat("yMd", picked);
                                        });
                                      },
                                    ),
                                    _buildDateField(
                                      labelText: 'Date of Burial*',
                                      hintText: 'Select Date of Burial',
                                      controller:
                                          deceasedEntry.burialDateController,
                                      selectedDate: deceasedEntry.burialDate,
                                      firstDate: DateTime(1900),
                                      lastDate: DateTime(2100),
                                      onDateSelected: (picked) {
                                        setState(() {
                                          deceasedEntry.burialDate = picked;
                                          deceasedEntry
                                                  .burialDateController.text =
                                              dateTimeFormat("yMd", picked);
                                          
                                          // Real-time validation: Check if burial date is before death date
                                          if (deceasedEntry.deathDate != null && 
                                              picked.isBefore(deceasedEntry.deathDate!)) {
                                            // Show immediate error dialog
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: Row(
                                                    children: [
                                                      Icon(
                                                        Icons.error_outline_rounded,
                                                        color: const Color(0xFFEF4444),
                                                        size: 28,
                                                      ),
                                                      const SizedBox(width: 12),
                                                      Text(
                                                        'Invalid Date',
                                                        style: GoogleFonts.inter(
                                                          fontSize: 20,
                                                          fontWeight: FontWeight.w600,
                                                          color: const Color(0xFF1F2937),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  content: Text(
                                                    'Date of Burial cannot be before Date of Death.\n\nDeath Date: ${dateTimeFormat("yMd", deceasedEntry.deathDate!)}\nBurial Date: ${dateTimeFormat("yMd", picked)}',
                                                    style: GoogleFonts.inter(
                                                      fontSize: 16,
                                                      color: const Color(0xFF6B7280),
                                                    ),
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () => Navigator.of(context).pop(),
                                                      child: Text(
                                                        'OK',
                                                        style: GoogleFonts.inter(
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.w600,
                                                          color: const Color(0xFF1E40AF),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                            // Clear the invalid burial date
                                            deceasedEntry.burialDate = null;
                                            deceasedEntry.burialDateController.clear();
                                          }
                                        });
                                      },
                                    ),
                                  ]),
                                  // Spacing between entries
                                  if (index < _model.deceasedEntries.length - 1)
                                    const SizedBox(height: 24),
                                ],
                              );
                            }).toList(),
                          ],
                        ),

                        // Contract Terms & Pricing Section
                        _buildSectionCard(
                          title: 'Contract Terms & Financial Details',
                          icon: Icons.description_rounded,
                          iconColor: const Color(0xFF059669),
                          children: [
                            _buildFormRow([
                              _buildTextField(
                                controller: _model.tomblocationTextController,
                                focusNode: _model.tomblocationFocusNode,
                                labelText: 'Assigned Nitche Location*',
                                hintText: 'Pre-selected location',
                                prefixIcon: Icons.location_on_rounded,
                                isReadOnly: true,
                              ),
                              _buildTextField(
                                controller: _model.amountTextController,
                                focusNode: _model.amountFocusNode,
                                labelText: 'Initial Contract Fee (₱)*',
                                hintText: 'Set the initial fee amount',
                                prefixIcon:
                                    Icons.account_balance_wallet_rounded,
                                validator: _validateAmount,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[0-9.]')),
                                ],
                              ),
                              // Effective Date (only for past contracts)
                              if ((_model.contractTypeValue ?? 'new') == 'past')
                                _buildDateField(
                                  labelText: 'Effective Date*',
                                  hintText: 'Select effective date',
                                  controller: TextEditingController(
                                    text: _model.effectiveDatePicked != null
                                        ? dateTimeFormat("yMd", _model.effectiveDatePicked)
                                        : '',
                                  ),
                                  selectedDate: _model.effectiveDatePicked,
                                  firstDate: DateTime(1900),
                                  lastDate: DateTime.now(),
                                  onDateSelected: (picked) {
                                    setState(() {
                                      _model.effectiveDatePicked = picked;
                                    });
                                  },
                                ),
                              _buildDateField(
                                labelText: 'Date of Expiration*',
                                hintText: 'Select expiration date',
                                controller:
                                    _model.dateofexpirationTextController,
                                selectedDate: _model.datePicked3,
                                firstDate: (_model.contractTypeValue ?? 'new') == 'past'
                                    ? DateTime(1900)
                                    : DateTime.now().add(const Duration(days: 1825)),
                                lastDate: DateTime(2100),
                                onDateSelected: (picked) {
                                  // Real-time validation for past contracts
                                  if ((_model.contractTypeValue ?? 'new') == 'past' && 
                                      _model.effectiveDatePicked != null) {
                                    if (picked.isBefore(_model.effectiveDatePicked!) || 
                                        picked.isAtSameMomentAs(_model.effectiveDatePicked!)) {
                                      // Show error dialog
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Row(
                                              children: [
                                                Icon(
                                                  Icons.error_outline_rounded,
                                                  color: const Color(0xFFEF4444),
                                                  size: 28,
                                                ),
                                                const SizedBox(width: 12),
                                                Text(
                                                  'Invalid Date',
                                                  style: GoogleFonts.inter(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.w600,
                                                    color: const Color(0xFF1F2937),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            content: Text(
                                              'Date of Expiration must be greater than Effective Date.\n\nEffective Date: ${dateTimeFormat("yMd", _model.effectiveDatePicked!)}\nExpiration Date: ${dateTimeFormat("yMd", picked)}',
                                              style: GoogleFonts.inter(
                                                fontSize: 16,
                                                color: const Color(0xFF6B7280),
                                              ),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.of(context).pop(),
                                                child: Text(
                                                  'OK',
                                                  style: GoogleFonts.inter(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                    color: const Color(0xFF1E40AF),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                      // Don't set the invalid date
                                      return;
                                    }
                                  }
                                  
                                  setState(() {
                                    _model.datePicked3 = picked;
                                    _model.dateofexpirationTextController.text =
                                        dateTimeFormat("yMd", picked);
                                    // Always auto-calculate contract duration for both contract types
                                    _updateContractCalculations();
                                  });
                                },
                              ),
                            ]),
                            _buildFormRow([
                              _buildTextField(
                                controller: _model.totalyearsTextController,
                                focusNode: _model.totalyearsFocusNode,
                                labelText: 'Contract Duration (Years)',
                                hintText: 'Auto-calculated',
                                prefixIcon: Icons.schedule_rounded,
                                isReadOnly: true,
                              ),
                              _buildTextField(
                                controller:
                                    _model.totalcontractvalueTextController,
                                focusNode: _model.totalcontractvalueFocusNode,
                                labelText: (_model.contractTypeValue ?? 'new') == 'past'
                                    ? 'Total Contract Value (₱)*'
                                    : 'Total Contract Value (₱)*',
                                hintText: (_model.contractTypeValue ?? 'new') == 'past'
                                    ? 'Enter total contract value'
                                    : 'Auto-calculated: (Duration × Initial Fee) - Initial Fee',
                                prefixIcon:
                                    Icons.account_balance_wallet_rounded,
                                isReadOnly: (_model.contractTypeValue ?? 'new') != 'past',
                                inputFormatters: (_model.contractTypeValue ?? 'new') == 'past'
                                    ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))]
                                    : null,
                              ),
                            ]),
                          ],
                        ),

                        // Required Documentation Section
                        _buildSectionCard(
                          title: 'Required Documentation',
                          icon: Icons.assignment_rounded,
                          iconColor: const Color(0xFFEF4444),
                          children: [
                            _buildFormRow([
                              _buildTextField(
                                controller: _model.residentcertTextController,
                                focusNode: _model.residentcertFocusNode,
                                labelText: 'Resident Certificate Number*',
                                hintText: 'Enter certificate number',
                                prefixIcon: Icons.description_rounded,
                                validator: _validateResidentCertificate,
                              ),
                              _buildTextField(
                                controller: _model.tinTextController,
                                focusNode: _model.tinFocusNode,
                                labelText: 'Tax Identification Number (TIN)*',
                                hintText:
                                    'Enter TIN in format: xxx - xxx - xxx - xxx',
                                prefixIcon: Icons.badge_rounded,
                                validator: _validateTIN,
                              ),
                            ]),
                            _buildFormRow([
                              _buildDateField(
                                labelText: 'Document Issue Date*',
                                hintText: 'Select document issue date',
                                controller: _model.dateissuedTextController,
                                selectedDate: _model.datePicked4,
                                firstDate: DateTime(1900),
                                lastDate: DateTime.now(),
                                onDateSelected: (picked) {
                                  setState(() {
                                    _model.datePicked4 = picked;
                                    _model.dateissuedTextController?.text =
                                        dateTimeFormat("yMd", picked);
                                  });
                                },
                              ),
                              _buildTextField(
                                controller: _model.placeissuedTextController,
                                focusNode: _model.placeissuedFocusNode,
                                labelText: 'Document Issue Location*',
                                hintText: 'Baliwag',
                                prefixIcon: Icons.location_on_rounded,
                                validator: (context, value) =>
                                    _validateRequired(
                                        context, value, 'Place Issued'),
                              ),
                              _buildTextField(
                                controller: _model.ornoTextController,
                                focusNode: _model.ornoFocusNode,
                                labelText: 'Official Receipt Number (OR)*',
                                hintText: 'Enter OR Receipt Number',
                                prefixIcon: Icons.receipt_rounded,
                                validator: (context, value) =>
                                    _validateRequired(
                                        context, value, 'OR Number'),
                              ),
                              _buildFileUploadField(
                                labelText: 'Proof of Lease*',
                                hintText: 'Upload lease document',
                                onUpload: () => _uploadProofOfLease(),
                                uploadedFile: _model.proofOfLeasePath,
                                onRemove: () => _removeProofOfLease(),
                              ),
                            ]),
                          ],
                        ),

                        // Enhanced Action Buttons
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.all(24),
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFF1E40AF),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF1E40AF).withOpacity(0.1),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Header with icon and title
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1E40AF)
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.check_circle_rounded,
                                      color: const Color(0xFF1E40AF),
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Ready to Create Contract?',
                                          style: GoogleFonts.inter(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFF1F2937),
                                            letterSpacing: -0.3,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Subtitle text
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Review all information before proceeding',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade600,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              // Action Buttons
                              Row(
                                children: [
                                  Expanded(
                                    child: SizedBox(
                                      height: 56,
                                      child: OutlinedButton(
                                        onPressed: () {
                                          context.goNamed('apartmentList');
                                        },
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 20),
                                          side: BorderSide(
                                            color: Colors.grey.shade300,
                                            width: 1.5,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: Text(
                                          'CANCEL',
                                          style: GoogleFonts.inter(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey.shade700,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: SizedBox(
                                      height: 56,
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          // First check for null/empty fields before form validation
                                          if (!_validateAllFields()) {
                                            return; // Stop if validation fails
                                          }

                                          // Then check for format validation errors
                                          if (!_validateAllFieldFormats()) {
                                            return; // Stop if format validation fails
                                          }

                                          // Show confirmation dialog
                                          final bool? confirmed =
                                              await showDialog<bool>(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: Text(
                                                  widget.id == null
                                                      ? 'Confirm Nitche Creation'
                                                      : 'Confirm Contract Creation',
                                                  style: GoogleFonts.inter(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.w600,
                                                    color:
                                                        const Color(0xFF1F2937),
                                                  ),
                                                ),
                                                content: Text(
                                                  widget.id == null
                                                      ? 'Are you sure you want to create this nitche? This action cannot be undone.'
                                                      : 'Are you sure you want to create this contract? This action cannot be undone.',
                                                  style: GoogleFonts.inter(
                                                    fontSize: 16,
                                                    color: Colors.grey.shade700,
                                                  ),
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.of(context)
                                                            .pop(false),
                                                    child: Text(
                                                      'Cancel',
                                                      style: GoogleFonts.inter(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors
                                                            .grey.shade600,
                                                      ),
                                                    ),
                                                  ),
                                                  ElevatedButton(
                                                    onPressed: () =>
                                                        Navigator.of(context)
                                                            .pop(true),
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          const Color(
                                                              0xFF1E40AF),
                                                      foregroundColor:
                                                          Colors.white,
                                                    ),
                                                    child: Text(
                                                      'Confirm',
                                                      style: GoogleFonts.inter(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          );

                                          if (confirmed == true) {
                                            print(
                                                'Form confirmed, starting validation...');

                                            // Validate contact number uniqueness first
                                            final isContactUnique =
                                                await _validateContactNumberUniqueness();
                                            if (!isContactUnique) {
                                              print(
                                                  'Contact number uniqueness validation failed!');
                                              return; // Stop submission if contact number is not unique
                                            }

                                            // If no contract ID, this is a new nitche creation - skip form validation
                                            if (widget.id == null) {
                                              print(
                                                  'Creating new nitche - skipping form validation');
                                              await _updateContractDocument();
                                            } else {
                                              // Validate form for existing contract updates
                                              if (_model.formKey.currentState!
                                                  .validate()) {
                                                print(
                                                    'Form validation passed, updating document...');
                                                await _updateContractDocument();
                                              } else {
                                                print(
                                                    'Form validation failed!');
                                              }
                                            }
                                          } else {
                                            print(
                                                'Form confirmation cancelled');
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFF1E40AF),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 20),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          elevation: 2,
                                          shadowColor: const Color(0xFF1E40AF)
                                              .withOpacity(0.35),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            if (widget.contractType ==
                                                'nitche') ...[
                                              Icon(
                                                Icons.add_location_alt_rounded,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                              const SizedBox(width: 8),
                                            ],
                                            Text(
                                              widget.id == null
                                                  ? 'CREATE NITCHE'
                                                  : 'CONTINUE',
                                              style: GoogleFonts.inter(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                                letterSpacing: 0.5,
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
                      ],
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
