import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/upload_data.dart';
import '/backend/firebase_storage/storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '/admin_side/shared/deceased_entry.dart';
import 'lotform_model.dart';
export 'lotform_model.dart';

class LotformWidget extends StatefulWidget {
  const LotformWidget({
    Key? key,
    this.id,
    this.lotLocation,
    this.lotAmount,
  }) : super(key: key);

  final DocumentReference? id;
  final String? lotLocation;
  final double? lotAmount;

  @override
  _LotformWidgetState createState() => _LotformWidgetState();
}

class _LotformWidgetState extends State<LotformWidget> {
  late LotformModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LotformModel());
    _initializeControllers();
  }

  void _initializeControllers() {
    // Initialize controllers and validators
    _model.applicantnameTextControllerValidator = _validateApplicantName;
    _model.applicantcontactTextControllerValidator =
        (context, value) => _validateContactNumber(value);
    _model.applicantaddressTextControllerValidator =
        _validateResidentialAddress;
    _model.deceasednameTextControllerValidator = _validateApplicantName;

    _model.amountTextControllerValidator =
        (context, value) => _validateAmount(value);

    // Initialize required document validators
    _model.residentcertTextControllerValidator = _validateResidentCertificate;
    _model.tinTextControllerValidator = (context, value) => _validateTIN(value);
    _model.placeissuedTextControllerValidator =
        (context, value) => _validateRequired(value, 'Place Issued');

    // Initialize controllers
    _model.applicantnameTextController = TextEditingController();
    _model.applicantcontactTextController = TextEditingController();
    _model.applicantaddressTextController = TextEditingController();
    _model.deceasednameTextController = TextEditingController();
    _model.amountTextController = TextEditingController();
    _model.tomblocationTextController = TextEditingController();
    _model.totalyearsTextController = TextEditingController();
    _model.totalbalanceTextController = TextEditingController();
    _model.totalcontractvalueTextController = TextEditingController();
    _model.dateofexpirationTextController = TextEditingController();
    _model.dateissuedTextController =
        TextEditingController(text: dateTimeFormat("yMd", DateTime.now()));
    _model.datePicked4 =
        DateTime.now(); // Set initial date for document issue date picker

    // Initialize required document controllers
    _model.residentcertTextController = TextEditingController();
    _model.tinTextController = TextEditingController();
    _model.ornoTextController = TextEditingController(
        text: 'OR-${DateTime.now().millisecondsSinceEpoch}');
    _model.placeissuedTextController = TextEditingController(text: 'Baliwag');

    // Initialize focus nodes
    _model.applicantnameFocusNode = FocusNode();
    _model.applicantcontactFocusNode = FocusNode();
    _model.applicantaddressFocusNode = FocusNode();
    _model.deceasednameFocusNode = FocusNode();
    _model.amountFocusNode = FocusNode();
    _model.tomblocationFocusNode = FocusNode();
    _model.totalyearsFocusNode = FocusNode();
    _model.totalbalanceFocusNode = FocusNode();
    _model.dateofexpirationFocusNode = FocusNode();

    // Initialize required document focus nodes
    _model.residentcertFocusNode = FocusNode();
    _model.tinFocusNode = FocusNode();
    _model.ornoFocusNode = FocusNode();
    _model.placeissuedFocusNode = FocusNode();
    _model.dateissuedFocusNode = FocusNode();

    // Set initial values from route parameters
    if (widget.lotLocation != null &&
        _model.tomblocationTextController != null) {
      _model.tomblocationTextController!.text = widget.lotLocation!;
    }
    if (widget.lotAmount != null && _model.amountTextController != null) {
      _model.amountTextController!.text = widget.lotAmount!.toString();
    }
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
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

  // Validation methods
  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  String? _validateContactNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Mobile Contact Number is required';
    }
    if (!RegExp(r'^09\d{9}$').hasMatch(value.trim())) {
      return 'Mobile Contact Number must be 11 digits starting with 09';
    }
    return null;
  }

  String? _validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Amount is required';
    }
    final amount = double.tryParse(value);
    if (amount == null || amount <= 0) {
      return 'Amount must be a positive number';
    }
    return null;
  }

  String? _validateTIN(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'TIN Number is required';
    }
    if (!RegExp(r'^\d{3}\s*-\s*\d{3}\s*-\s*\d{3}\s*-\s*\d{3}$')
        .hasMatch(value.trim())) {
      return 'TIN Number must be in format: xxx - xxx - xxx - xxx';
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
    // Proof of Lease is optional - removed from required validation

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
    final contactError =
        _validateContactNumber(_model.applicantcontactTextController?.text);
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
    final tinError = _validateTIN(_model.tinTextController?.text);
    if (tinError != null) {
      formatErrors.add(tinError);
    }

    // Check deceased entries format
    for (int i = 0; i < _model.deceasedEntries.length; i++) {
      final entry = _model.deceasedEntries[i];
      final deceasedNameError =
          _validateApplicantName(context, entry.nameController.text);
      if (deceasedNameError != null) {
        formatErrors.add(deceasedNameError);
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
                  fontWeight: FontWeight.w600,
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
                  fontSize: 16,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 16),
              ...emptyFields
                  .map((field) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
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
                                  color: Colors.grey.shade700,
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
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
              ),
              child: Text(
                'OK',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
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
                'Format Errors Found',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
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
                  fontSize: 16,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 16),
              ...formatErrors
                  .map((error) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                                  color: Colors.grey.shade700,
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
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF59E0B),
                foregroundColor: Colors.white,
              ),
              child: Text(
                'OK',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
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
    context.watch<FFAppState>();

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
                    'Complete the form below to add deceased person to burial plot location',
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
                    key: _model.formKey1,
                    child: Column(
                      children: [
                        // Primary Applicant Information
                        _buildSectionCard(
                          title: 'Primary Applicant Information',
                          icon: Icons.person_outline_rounded,
                          iconColor: const Color(0xFF8B5CF6),
                          children: [
                            _buildFormRow([
                              _buildTextField(
                                controller: _model.tomblocationTextController ??
                                    TextEditingController(),
                                focusNode:
                                    _model.tomblocationFocusNode ?? FocusNode(),
                                labelText: 'Location*',
                                hintText: 'Enter location',
                                prefixIcon: Icons.location_on_rounded,
                                isReadOnly: true,
                              ),
                              _buildTextField(
                                controller:
                                    _model.applicantnameTextController ??
                                        TextEditingController(),
                                focusNode: _model.applicantnameFocusNode ??
                                    FocusNode(),
                                labelText: 'Applicant Full Name*',
                                hintText: 'Enter complete name',
                                prefixIcon: Icons.person_outline_rounded,
                                validator:
                                    _model.applicantnameTextControllerValidator,
                              ),
                              _buildTextField(
                                controller:
                                    _model.applicantcontactTextController ??
                                        TextEditingController(),
                                focusNode: _model.applicantcontactFocusNode ??
                                    FocusNode(),
                                labelText: 'Mobile Contact Number*',
                                hintText: 'Enter 11-digit mobile number',
                                prefixIcon: Icons.phone_rounded,
                                validator: _model
                                    .applicantcontactTextControllerValidator,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                              ),
                              _buildTextField(
                                controller:
                                    _model.applicantaddressTextController ??
                                        TextEditingController(),
                                focusNode: _model.applicantaddressFocusNode ??
                                    FocusNode(),
                                labelText: 'Residential Address*',
                                hintText: 'Enter complete address',
                                prefixIcon: Icons.location_on_rounded,
                                validator: _model
                                    .applicantaddressTextControllerValidator,
                              ),
                            ]),
                          ],
                        ),

                        const SizedBox(height: 24),

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
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime(2100),
                                      onDateSelected: (picked) {
                                        setState(() {
                                          deceasedEntry.burialDate = picked;
                                          deceasedEntry
                                                  .burialDateController.text =
                                              dateTimeFormat("yMd", picked);
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

                        const SizedBox(height: 24),

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
                                labelText:
                                    'Resident Certificate ( Community Tax Certificate / Sedula )*',
                                hintText: 'Enter certificate number',
                                prefixIcon: Icons.card_membership_rounded,
                                validator: _validateResidentCertificate,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                              ),
                              _buildTextField(
                                controller: _model.tinTextController,
                                focusNode: _model.tinFocusNode,
                                labelText: 'Tax Identification Number (TIN)*',
                                hintText:
                                    'Enter TIN in format: xxx - xxx - xxx - xxx',
                                prefixIcon: Icons.badge_rounded,
                                validator: (context, value) =>
                                    _validateTIN(value),
                              ),
                              _buildTextField(
                                controller: _model.ornoTextController,
                                focusNode: _model.ornoFocusNode,
                                labelText: 'Official Receipt Number (OR)*',
                                hintText: 'Auto-generated OR number',
                                prefixIcon: Icons.receipt_rounded,
                                isReadOnly: true,
                              ),
                            ]),
                            _buildFormRow([
                              _buildTextField(
                                controller: _model.placeissuedTextController,
                                focusNode: _model.placeissuedFocusNode,
                                labelText: 'Document Issue Location*',
                                hintText: 'Enter place of issue',
                                prefixIcon: Icons.location_on_rounded,
                                validator: (context, value) =>
                                    _validateRequired(value, 'Place Issued'),
                              ),
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
                              _buildFileUploadField(
                                labelText: 'Proof of Lease (Optional)',
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
                                          'Ready to Update Contract?',
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
                                        onPressed: () => context.safePop(),
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

                                          if (_model.formKey1.currentState
                                                  ?.validate() ??
                                              false) {
                                            // Show confirmation dialog
                                            final bool? confirmed =
                                                await showDialog<bool>(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: Text(
                                                    'Confirm Lot Contract Update',
                                                    style: GoogleFonts.inter(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: const Color(
                                                          0xFF1F2937),
                                                    ),
                                                  ),
                                                  content: Text(
                                                    'Are you sure you want to update this lot contract? This action cannot be undone.',
                                                    style: GoogleFonts.inter(
                                                      fontSize: 16,
                                                      color:
                                                          Colors.grey.shade700,
                                                    ),
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.of(context)
                                                              .pop(false),
                                                      child: Text(
                                                        'Cancel',
                                                        style:
                                                            GoogleFonts.inter(
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
                                                        style:
                                                            GoogleFonts.inter(
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
                                              await _updateExistingContractDocument();
                                            }
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
                                        child: Text(
                                          'CONTINUE',
                                          style: GoogleFonts.inter(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                            letterSpacing: 0.5,
                                          ),
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

  // Helper methods will be added here
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

  Widget _buildDateField({
    required String labelText,
    required String hintText,
    required TextEditingController? controller,
    required DateTime? selectedDate,
    required DateTime? firstDate,
    required DateTime? lastDate,
    required Function(DateTime) onDateSelected,
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
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: selectedDate ?? firstDate ?? DateTime.now(),
                firstDate: firstDate ?? DateTime(1900),
                lastDate: lastDate ?? DateTime.now(),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: const Color(0xFF1E40AF),
                        onPrimary: Colors.white,
                        surface: Colors.white,
                        onSurface: const Color(0xFF1F2937),
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null) {
                onDateSelected(picked);
                if (controller != null) {
                  controller.text = dateTimeFormat('yMd', picked);
                }
              }
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: 48, // Fixed height to match text fields
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: selectedDate != null
                      ? Colors.transparent
                      : Colors.grey.shade300,
                  width: selectedDate != null ? 0 : 1,
                ),
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
        InkWell(
          onTap: uploadedFile == null ? onUpload : null,
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
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
                          size: 18,
                        ),
                      ),
                    ],
                  )
                : Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(12),
                    ),
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
        ),
      ],
    );
  }

  // Helper method to upload proof of lease
  Future<void> _uploadProofOfLease() async {
    try {
      // Show loading message
      showUploadMessage(context, 'Selecting file...', showLoading: true);

      // Select file using file picker
      final selectedFile = await selectFile(
        storageFolderPath: 'proof_of_lease',
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
      );

      if (selectedFile != null) {
        // Update loading message
        showUploadMessage(context, 'Uploading file to storage...',
            showLoading: true);

        // Actually upload the file to Firebase Storage
        final downloadUrl =
            await uploadData(selectedFile.storagePath, selectedFile.bytes);

        if (downloadUrl != null) {
          // Store the download URL instead of just the storage path
          setState(() {
            _model.proofOfLeasePath = downloadUrl;
          });

          // Hide loading message
          ScaffoldMessenger.of(context).hideCurrentSnackBar();

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Proof of lease uploaded successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          // Upload failed
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to upload file to storage'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        // Hide loading message
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }
    } catch (e) {
      // Hide loading message
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading file: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  // Helper method to remove proof of lease
  void _removeProofOfLease() {
    setState(() {
      _model.proofOfLeasePath = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Proof of lease removed!'),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _updateExistingContractDocument() async {
    print('Updating existing lot contract document...');

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
      // Read existing contract data to preserve all original values
      final currentDoc = await widget.id!.get();
      final currentData = currentDoc.data() as Map<String, dynamic>?;

      // Merge original data with new deceased information
      final Map<String, dynamic> contractData = {
        // Preserve ALL original contract data
        ...?currentData,

        // Override only the fields that need to change
        'status': 'unaddable', // Change status when deceased is added

        // Add multiple deceased-related fields - Use FieldValue.arrayUnion for consistency
        'applcantAddress': FieldValue.arrayUnion(
            [_model.applicantaddressTextController?.text ?? '']),
        'decFullName': [
          ...(currentData?['decFullName'] as List<dynamic>?)?.cast<String>() ??
              [],
          ..._model.deceasedEntries
              .map((entry) => entry.nameController.text)
              .where((name) => name.isNotEmpty)
              .toList()
        ].where((name) => name.isNotEmpty).toList(),
        'burialinternment': [
          ...(currentData?['burialinternment'] as List<dynamic>?)
                  ?.map((e) => e as Timestamp)
                  .toList() ??
              [],
          ..._model.deceasedEntries
              .where((entry) => entry.burialDate != null)
              .map((entry) => Timestamp.fromDate(entry.burialDate!))
              .toList()
        ],
        'dateofdeath': [
          ...(currentData?['dateofdeath'] as List<dynamic>?)
                  ?.map((e) => e as Timestamp)
                  .toList() ??
              [],
          ..._model.deceasedEntries
              .where((entry) => entry.deathDate != null)
              .map((entry) => Timestamp.fromDate(entry.deathDate!))
              .toList()
        ],
        'applicantName': FieldValue.arrayUnion(
            [_model.applicantnameTextController?.text ?? '']),
        'applicantContactNumber': FieldValue.arrayUnion(
            [int.tryParse(_model.applicantcontactTextController?.text ?? '')]),

        // Add required document fields - Use correct column names to match ContractRecord model
        'ResidentCert': _model.residentcertTextController?.text ?? '',
        'TIN': _model.tinTextController?.text ?? '',
        'OR': _model.ornoTextController?.text ?? '',
        'placeIssued': _model.placeissuedTextController?.text ?? '',
        'dateIssued': _model.datePicked4 ?? DateTime.now(),
        'proofoflease': _model.proofOfLeasePath ??
            '', // Image Path - proof of lease file path
      };

      // Debug: Print what's being saved for deceased entries
      print('Debug: Lotform - Saving multiple deceased entries:');
      print('Debug: Total deceased entries: ${_model.deceasedEntries.length}');
      for (int i = 0; i < _model.deceasedEntries.length; i++) {
        final entry = _model.deceasedEntries[i];
        print(
            'Debug: Entry $i - Name: "${entry.nameController.text}", Death Date: ${entry.deathDate}, Burial Date: ${entry.burialDate}');
      }
      print(
          'Debug: Existing decFullName: ${(currentData?['decFullName'] as List<dynamic>?)?.cast<String>() ?? []}');
      print(
          'Debug: New names to add: ${_model.deceasedEntries.map((entry) => entry.nameController.text).where((name) => name.isNotEmpty).toList()}');
      print(
          'Debug: Existing dateofdeath: ${(currentData?['dateofdeath'] as List<dynamic>?)?.length ?? 0} entries');
      print(
          'Debug: New death dates to add: ${_model.deceasedEntries.where((entry) => entry.deathDate != null).map((entry) => entry.deathDate).toList()}');
      print(
          'Debug: NOTE: Using regular arrays instead of FieldValue.arrayUnion to allow duplicate entries');

      // Use set to replace entire document while preserving original values
      await widget.id!.set(contractData);

      Navigator.of(context).pop();
      _showSuccessDialog(isNewDocument: false, isLot: true);
    } catch (e) {
      Navigator.of(context).pop();
      _showErrorDialog('Error', 'Failed to update contract: ${e.toString()}');
    }
  }

  void _showSuccessDialog({required bool isNewDocument, required bool isLot}) {
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
                Icons.check_circle_rounded,
                color: const Color(0xFF10B981),
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Success!',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Text(
            isNewDocument
                ? 'New ${isLot ? 'lot' : 'nitche'} created successfully!'
                : 'Contract updated successfully!',
            style: GoogleFonts.inter(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.safePop();
              },
              child: Text(
                'OK',
                style: GoogleFonts.inter(
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

  void _showErrorDialog(String title, String message) {
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
                Icons.error_rounded,
                color: const Color(0xFFEF4444),
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: GoogleFonts.inter(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'OK',
                style: GoogleFonts.inter(
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
