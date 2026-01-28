import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/custom_functions.dart' as functions;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'new_add_burial_location_model.dart';
export 'new_add_burial_location_model.dart';

class NewAddBurialLocationWidget extends StatefulWidget {
  const NewAddBurialLocationWidget({super.key});

  static String routeName = 'newAddBurialLocation';
  static String routePath = '/newAddBurialLocation';

  @override
  State<NewAddBurialLocationWidget> createState() =>
      _NewAddBurialLocationWidgetState();
}

class _NewAddBurialLocationWidgetState
    extends State<NewAddBurialLocationWidget> {
  late NewAddBurialLocationModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => NewAddBurialLocationModel());

    _model.blocklotTextController ??= TextEditingController();
    _model.blocklotFocusNode ??= FocusNode();

    _model.ownerTextController ??= TextEditingController();
    _model.ownerFocusNode ??= FocusNode();

    _model.streetTextController ??= TextEditingController();
    _model.streetFocusNode ??= FocusNode();

    _model.expirationTextController ??=
        TextEditingController(text: dateTimeFormat("yMd", _model.datePicked));
    _model.expirationFocusNode ??= FocusNode();

    _model.measurementTextController ??= TextEditingController();
    _model.measurementFocusNode ??= FocusNode();

    _model.amountTextController ??= TextEditingController(text: '1500');
    _model.amountFocusNode ??= FocusNode();

    _model.yearsTextController ??=
        TextEditingController(text: _model.yearsDuration?.toString());
    _model.yearsFocusNode ??= FocusNode();

    _model.balanceTextController ??= TextEditingController();
    _model.balanceFocusNode ??= FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  int _calculateContractDurationYears(DateTime expirationDate) {
    final bool isPastContract = (_model.contractTypeValue ?? 'new') == 'past';
    final int startYear =
        isPastContract && _model.effectiveDatePicked != null
            ? _model.effectiveDatePicked!.year
            : DateTime.now().year;
    final int expirationYear = expirationDate.year;
    final int duration = expirationYear - startYear;
    return duration > 0 ? duration : 0;
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  // Helper methods for validation

  String? _validateBlockLot(BuildContext context, String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Block-Lot is required';
    }
    
    // Check if the format is at least B1-L1
    final regExp = RegExp(r'^[bB](\d+)-[lL](\d+)$', caseSensitive: false);
    if (!regExp.hasMatch(value)) {
      return 'Format: B#-L# (e.g., B1-L1)';
    }
    
    // Extract numbers from the block and lot
    final matches = regExp.firstMatch(value);
    if (matches != null && matches.groupCount >= 2) {
      final block = int.tryParse(matches.group(1) ?? '0') ?? 0;
      final lot = int.tryParse(matches.group(2) ?? '0') ?? 0;
      
      // Check minimum dimensions (1x1)
      if (block < 1 || lot < 1) {
        return 'Minimum dimensions: B1-L1';
      }
    }
    
    return null;
  }

  // Check if Block-Lot already exists in contract collection
  Future<String?> _validateBlockLotExists(
      BuildContext context, String? value) async {
    if (value == null || value.trim().isEmpty) {
      return 'Block-Lot is required';
    }

    final trimmedValue = value.trim();

    // First validate format
    if (!RegExp(r'^[A-Z]\d+-L\d+$').hasMatch(trimmedValue)) {
      return 'Format should be: Letter-Number (e.g., B1-L1)';
    }

    try {
      // Query contract collection to check if location already exists
      final querySnapshot = await ContractRecord.collection
          .where('Location', isEqualTo: trimmedValue)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return 'Block-Lot "$trimmedValue" already exists in the system';
      }

      return null; // No duplicate found
    } catch (e) {
      // If there's an error checking, don't block the user
      // Just return the format validation result
      return null;
    }
  }

  // Check if Street already exists in contract collection
  Future<String?> _validateStreetExists(
      BuildContext context, String? value) async {
    if (value == null || value.trim().isEmpty) {
      return 'Street is required';
    }

    final trimmedValue = value.trim();

    // First validate format
    if (trimmedValue.length < 3) {
      return 'Street address must be at least 3 characters long';
    }
    final streetRegex = RegExp(
        r'^[A-Za-z0-9\s.,\-#]+(?:St\.?|Street|Ave\.?|Avenue|Rd\.?|Road|Ext\.?|Extension)?$');
    if (!streetRegex.hasMatch(trimmedValue)) {
      return 'Street address can only contain letters, numbers, spaces, commas, periods, #, hyphens, and common street suffixes (St, Street, Ave, Avenue, Rd, Road, Ext, Extension)';
    }

    try {
      // Query contract collection to check if street already exists
      final querySnapshot = await ContractRecord.collection
          .where('street', isEqualTo: trimmedValue)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return 'Street "$trimmedValue" already exists in the system';
      }

      return null; // No duplicate found
    } catch (e) {
      // If there's an error checking, don't block the user
      // Just return the format validation result
      return null;
    }
  }

  String? _validateNameLessee(BuildContext context, String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name/Lessee is required';
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

  String? _validateMeasurement(BuildContext context, String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Measurement is required';
    }
    // Validate format: should be like "3x5", "10x15", etc.
    final regExp = RegExp(r'^(\d+)x(\d+)$');
    if (!regExp.hasMatch(value.trim())) {
      return 'Format should be: NumberxNumber (e.g., 3x5)';
    }
    
    // Extract width and height
    final matches = regExp.firstMatch(value.trim());
    if (matches != null) {
      final width = int.tryParse(matches.group(1) ?? '0') ?? 0;
      final height = int.tryParse(matches.group(2) ?? '0') ?? 0;
      
      // Check minimum dimensions (1x1)
      if (width < 1 || height < 2) {
        return 'Minimum measurement is 1x2';
      }
    }
    
    return null;
  }

  String? _validateAmount(BuildContext context, String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Initial Contract Fee is required';
    }
    if (double.tryParse(value) == null) {
      return 'Amount must be a valid number';
    }
    if (double.parse(value) <= 0) {
      return 'Amount must be greater than 0';
    }
    return null;
  }

  // Custom validation for street address with Philippine address format
  String? _validateStreet(BuildContext context, String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Street is required';
    }

    final trimmedValue = value.trim();

    // Check minimum length
    if (trimmedValue.length < 3) {
      return 'Street address must be at least 3 characters long';
    }

    // Check if contains only allowed characters for Philippine street addresses
    // Allows letters, numbers, spaces, commas, periods, hyphens, hash, and common street suffixes
    final streetRegex = RegExp(
        r'^[A-Za-z0-9\s.,\-#]+(?:St\.?|Street|Ave\.?|Avenue|Rd\.?|Road|Ext\.?|Extension)?$');
    if (!streetRegex.hasMatch(trimmedValue)) {
      return 'Street address can only contain letters, numbers, spaces, commas, periods, #, hyphens, and common street suffixes (St, Street, Ave, Avenue, Rd, Road, Ext, Extension)';
    }

    return null;
  }

  // Comprehensive validation to check all fields for null/empty values
  bool _validateAllFields() {
    List<String> emptyFields = [];

    // Check basic information fields
    if (_model.blocklotTextController?.text.trim().isEmpty ?? true) {
      emptyFields.add('Block-Lot');
    }
    if (_model.ownerTextController?.text.trim().isEmpty ?? true) {
      emptyFields.add('Name/Lessee');
    }
    if (_model.streetTextController?.text.trim().isEmpty ?? true) {
      emptyFields.add('Street');
    }
    if (_model.measurementTextController?.text.trim().isEmpty ?? true) {
      emptyFields.add('Measurement');
    }
    if (_model.statusValue == null || _model.statusValue!.trim().isEmpty) {
      emptyFields.add('Status');
    }

    // Check contract details fields
    if (_model.amountTextController?.text.trim().isEmpty ?? true) {
      emptyFields.add('Initial Contract Fee');
    }
    if (_model.datePicked == null) {
      emptyFields.add('Date of Expiration');
    }
    
    // Check effective date for past contracts
    if (_model.contractTypeValue == 'past' && _model.effectiveDatePicked == null) {
      emptyFields.add('Effective Date');
    }
    
    // Check balance for past contracts
    if (_model.contractTypeValue == 'past' && 
        (_model.balanceTextController?.text.trim().isEmpty ?? true)) {
      emptyFields.add('Total Balance');
    }

    // If there are empty fields, show error dialog
    if (emptyFields.isNotEmpty) {
      _showValidationErrorDialog(emptyFields);
      return false;
    }

    return true;
  }

  // Comprehensive format validation to check all field formats before saving
  Future<bool> _validateAllFieldFormats() async {
    List<String> formatErrors = [];

    // Check Block-Lot format and existence
    final blockLotError = await _validateBlockLotExists(
        context, _model.blocklotTextController?.text);
    if (blockLotError != null) {
      formatErrors.add(blockLotError);
    }

    // Check Name/Lessee format
    final nameLesseeError =
        _validateNameLessee(context, _model.ownerTextController?.text);
    if (nameLesseeError != null) {
      formatErrors.add(nameLesseeError);
    }

    // Check Street format and existence
    final streetError =
        await _validateStreetExists(context, _model.streetTextController?.text);
    if (streetError != null) {
      formatErrors.add(streetError);
    }

    // Check Measurement format
    final measurement = _model.measurementTextController?.text.trim() ?? '';
    if (measurement.isNotEmpty) {
      if (!RegExp(r'^\d+x\d+$').hasMatch(measurement)) {
        formatErrors
            .add('Measurement format should be: NumberxNumber (e.g., 3x5)');
      }
    }

    // Check Amount format
    final amount = _model.amountTextController?.text.trim() ?? '';
    if (amount.isNotEmpty) {
      final amountValue = double.tryParse(amount);
      if (amountValue == null) {
        formatErrors.add('Initial Contract Fee must be a valid number');
      } else if (amountValue <= 0) {
        formatErrors.add('Initial Contract Fee must be greater than 0');
      }
    }

    // Check Date of Expiration (should be in the future for new contracts only)
    if (_model.datePicked != null && _model.contractTypeValue != 'past') {
      final now = DateTime.now();
      if (_model.datePicked!.isBefore(now)) {
        formatErrors.add('Date of Expiration must be in the future for new contracts');
      }
    }
    
    // For past contracts, validate that expiration date is after effective date
    if (_model.contractTypeValue == 'past' && 
        _model.effectiveDatePicked != null && 
        _model.datePicked != null) {
      if (_model.datePicked!.isBefore(_model.effectiveDatePicked!)) {
        formatErrors.add('Date of Expiration must be after Effective Date');
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

  // Show format error dialog for validation errors
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
                'Format Errors',
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
              // Green check icon when field format is correct
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
            height: 48,
            child: TextFormField(
              controller: controller,
              focusNode: focusNode,
              readOnly: isReadOnly,
              onChanged: (value) {
                if (onChanged != null) onChanged(value);
                setState(() {});
              },
              inputFormatters: inputFormatters,
              decoration: InputDecoration(
                hintText: hintText,
                prefixIcon: Icon(
                  prefixIcon,
                  color: Colors.grey.shade500,
                  size: 20,
                ),
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
              DateTime calculateInitialDate() {
                if (selectedDate != null) return selectedDate;
                final now = DateTime.now();
                if (firstDate != null && now.isBefore(firstDate)) {
                  return firstDate;
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
              height: 48,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: selectedDate != null
                      ? Colors.transparent
                      : Colors.grey.shade300,
                  width: selectedDate != null ? 0 : 1,
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
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

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: const Color(0xFFF8FAFC),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Subtitle Section
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                  child: Text(
                    'Complete the form below to add a new burial location',
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
                    key: _model.formKey2,
                    autovalidateMode: AutovalidateMode.disabled,
                    child: Column(
                      children: [
                        // Contract Type Selection Section
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
                                  FlutterFlowDropDown<String>(
                                    controller: _model.contractTypeValueController ??=
                                        FormFieldController<String>(
                                      _model.contractTypeValue ??= 'new',
                                    ),
                                    options: const ['new', 'past'],
                                    optionLabels: const ['New Contract', 'Add Existing Contract'],
                                    onChanged: (val) {
                                      safeSetState(() {
                                        _model.contractTypeValue = val;
                                        
                                        // Clear all text fields when contract type changes
                                        _model.blocklotTextController?.clear();
                                        _model.ownerTextController?.clear();
                                        _model.streetTextController?.clear();
                                        _model.measurementTextController?.clear();
                                        _model.amountTextController?.text = '1500';
                                        _model.expirationTextController?.clear();
                                        _model.yearsTextController?.clear();
                                        _model.balanceTextController?.clear();
                                        
                                        // Clear dates
                                        _model.datePicked = null;
                                        _model.effectiveDatePicked = null;
                                        
                                        // Reset status
                                        _model.statusValue = null;
                                      });
                                    },
                                    width: double.infinity,
                                    height: 56,
                                    textStyle: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF1F2937),
                                    ),
                                    hintText: 'Select contract type',
                                    icon: Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: const Color(0xFF6B7280),
                                      size: 24,
                                    ),
                                    fillColor: Colors.white,
                                    elevation: 2,
                                    borderColor: const Color(0xFFE5E7EB),
                                    borderWidth: 2,
                                    borderRadius: 12,
                                    margin: const EdgeInsetsDirectional.fromSTEB(
                                        16, 0, 16, 0),
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: _model.contractTypeValue == 'new'
                                          ? const Color(0xFFDCFCE7)
                                          : const Color(0xFFFEF3C7),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: _model.contractTypeValue == 'new'
                                            ? const Color(0xFF10B981)
                                            : const Color(0xFFF59E0B),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          _model.contractTypeValue == 'new'
                                              ? Icons.fiber_new_rounded
                                              : Icons.history_rounded,
                                          color: _model.contractTypeValue == 'new'
                                              ? const Color(0xFF10B981)
                                              : const Color(0xFFF59E0B),
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            _model.contractTypeValue == 'new'
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
                        
                        // Basic Information Section
                        _buildSectionCard(
                          title: 'Basic Information',
                          icon: Icons.location_on_rounded,
                          iconColor: const Color(0xFF1E40AF),
                          children: [
                            _buildFormRow([
                              _buildTextField(
                                controller: _model.blocklotTextController,
                                focusNode: _model.blocklotFocusNode,
                                labelText: 'Block-Lot*',
                                hintText: 'eg. B1-L1',
                                prefixIcon: Icons.grid_on_rounded,
                                validator: (context, value) =>
                                    _validateBlockLot(context, value),
                              ),
                              _buildTextField(
                                controller: _model.ownerTextController,
                                focusNode: _model.ownerFocusNode,
                                labelText: 'Name/Lessee*',
                                hintText: 'Enter name or lessee',
                                prefixIcon: Icons.person_rounded,
                                validator: _validateNameLessee,
                              ),
                              _buildTextField(
                                controller: _model.streetTextController,
                                focusNode: _model.streetFocusNode,
                                labelText: 'Street*',
                                hintText: 'Enter street address',
                                prefixIcon: Icons.home_rounded,
                                validator: _validateStreet,
                              ),
                            ]),
                            _buildFormRow([
                              _buildTextField(
                                controller: _model.measurementTextController,
                                focusNode: _model.measurementFocusNode,
                                labelText: 'Measurement*',
                                hintText: 'Enter lot measurement',
                                prefixIcon: Icons.straighten_rounded,
                                validator: (context, value) =>
                                    _validateMeasurement(context, value),
                              ),
                              Container(
                                margin: const EdgeInsets.only(bottom: 24),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            'Status*',
                                            style: GoogleFonts.inter(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: const Color(0xFF374151),
                                              letterSpacing: 0.2,
                                            ),
                                          ),
                                        ),
                                        // Green check icon when status is selected
                                        if (_model.statusValue != null &&
                                            _model.statusValue!.isNotEmpty)
                                          Icon(
                                            Icons.check_circle_rounded,
                                            color: const Color(0xFF10B981),
                                            size: 20,
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    SizedBox(
                                      height: 48,
                                      child: FlutterFlowDropDown<String>(
                                        controller: _model
                                                .statusValueController ??=
                                            FormFieldController<String>(null),
                                        options: [
                                          'with nitche',
                                          'with mausoleum'
                                        ],
                                        onChanged: (val) => safeSetState(
                                            () => _model.statusValue = val),
                                        width: double.infinity,
                                        height: 48,
                                        textStyle: GoogleFonts.inter(
                                          fontSize: 15,
                                          color: const Color(0xFF1F2937),
                                          fontWeight: FontWeight.w500,
                                        ),
                                        hintText: 'Select status...',
                                        icon: Icon(
                                          Icons.keyboard_arrow_down_rounded,
                                          color: Colors.grey.shade500,
                                          size: 20,
                                        ),
                                        fillColor: Colors.white,
                                        elevation: 2,
                                        borderColor: (_model.statusValue !=
                                                    null &&
                                                _model.statusValue!.isNotEmpty)
                                            ? Colors.transparent
                                            : Colors.grey.shade300,
                                        borderWidth: (_model.statusValue !=
                                                    null &&
                                                _model.statusValue!.isNotEmpty)
                                            ? 0
                                            : 1,
                                        borderRadius: 8,
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 0, vertical: 0),
                                        hidesUnderline: true,
                                        isOverButton: false,
                                        isSearchable: false,
                                        isMultiSelect: false,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(), // Empty container for 3rd column
                            ]),
                          ],
                        ),

                        // Contract Details Section
                        _buildSectionCard(
                          title: 'Contract Details',
                          icon: Icons.description_rounded,
                          iconColor: const Color(0xFFF59E0B),
                          children: [
                            _buildFormRow([
                              _buildTextField(
                                controller: _model.amountTextController,
                                focusNode: _model.amountFocusNode,
                                labelText: 'Initial Contract Fee (₱)*',
                                hintText: 'Enter amount',
                                prefixIcon:
                                    Icons.account_balance_wallet_rounded,
                                validator: (context, value) =>
                                    _validateAmount(context, value),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'^\d*\.?\d*')),
                                ],
                              ),
                              // Effective Date (only for past contracts)
                              if (_model.contractTypeValue == 'past')
                                _buildDateField(
                                  labelText: 'Effective Date*',
                                  hintText: 'Select effective date',
                                  controller: TextEditingController(
                                    text: _model.effectiveDatePicked != null
                                        ? dateTimeFormat(
                                            "yMd", _model.effectiveDatePicked)
                                        : '',
                                  ),
                                  selectedDate: _model.effectiveDatePicked,
                                  firstDate: DateTime(1900),
                                  lastDate: DateTime.now(),
                                  onDateSelected: (picked) async {
                                    safeSetState(() {
                                      _model.effectiveDatePicked = picked;
                                    });
                                  },
                                ),
                              
                              // Date of Expiration
                              _buildDateField(
                                labelText: _model.contractTypeValue == 'past'
                                    ? 'Date of Expiration*'
                                    : 'Date of Expiration*',
                                hintText: 'Select expiration date',
                                controller: _model.expirationTextController,
                                selectedDate: _model.datePicked,
                                firstDate: _model.contractTypeValue == 'past'
                                    ? DateTime(1900)
                                    : (functions.add5yrs() ?? DateTime(1900)),
                                lastDate: DateTime(2100),
                                onDateSelected: (picked) async {
                                  // Real-time validation for past contracts
                                  if (_model.contractTypeValue == 'past' && 
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
                                  
                                  safeSetState(() {
                                    _model.datePicked = picked;
                                  });
                                  
                                  // Always calculate years duration for both new and past contracts
                                  _model.expiredDATE = await actions
                                      .setExpired(_model.datePicked);
                                  FFAppState().expirationDateBalance =
                                      _model.datePicked;
                                  safeSetState(() {});
                                  _model.yearsDuration =
                                      _calculateContractDurationYears(
                                          _model.datePicked!);
                                  safeSetState(() {
                                    _model.yearsTextController?.text =
                                        _model.yearsDuration!.toString();
                                  });
                                  
                                  // Only auto-calculate balance for new contracts
                                  if (_model.contractTypeValue != 'past') {
                                    // Calculate total contract value: (duration × initial fee) - initial fee
                                    final double initialFee = double.tryParse(
                                            _model.amountTextController.text) ??
                                        0.0;
                                    final int duration =
                                        _model.yearsDuration ?? 0;

                                    _model.calculateTotalBalance =
                                        ((duration * initialFee) - initialFee)
                                            .toInt();
                                    safeSetState(() {
                                      _model.balanceTextController?.text = _model
                                          .calculateTotalBalance!
                                          .toString();
                                    });
                                    safeSetState(() {});
                                  }
                                },
                              ),
                              _buildTextField(
                                controller: _model.yearsTextController,
                                focusNode: _model.yearsFocusNode,
                                labelText: 'Contract Duration (Years)',
                                hintText: 'Auto-calculated',
                                prefixIcon: Icons.schedule_rounded,
                                isReadOnly: true,
                              ),
                            ]),
                            _buildFormRow([
                              _buildTextField(
                                controller: _model.balanceTextController,
                                focusNode: _model.balanceFocusNode,
                                labelText: _model.contractTypeValue == 'past'
                                    ? 'Total Balance (₱)*'
                                    : 'Total Balance (₱)',
                                hintText: _model.contractTypeValue == 'past'
                                    ? 'Enter total balance'
                                    : 'Auto-calculated',
                                prefixIcon: Icons.calculate_rounded,
                                isReadOnly: _model.contractTypeValue != 'past',
                                validator: _model.contractTypeValue == 'past'
                                    ? (context, value) {
                                        if (value == null || value.trim().isEmpty) {
                                          return 'Total Balance is required for past contracts';
                                        }
                                        if (double.tryParse(value) == null) {
                                          return 'Must be a valid number';
                                        }
                                        return null;
                                      }
                                    : null,
                              ),
                              Container(), // Empty container for 2nd column
                              Container(), // Empty container for 3rd column
                            ]),
                          ],
                        ),

                        // Enhanced Action Buttons - Card Style
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
                              // Header with checkmark icon
                              Row(
                                children: [
                                  Icon(
                                    Icons.check_circle_rounded,
                                    color: const Color(0xFF1E40AF),
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Ready to Add Burial Location?',
                                    style: GoogleFonts.inter(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF1F2937),
                                      letterSpacing: -0.3,
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
                                          context.safePop();
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
                                          if (!(await _validateAllFieldFormats())) {
                                            return; // Stop if format validation fails
                                          }

                                          if (_model.formKey2.currentState!
                                              .validate()) {
                                            // Ensure balance is calculated before contract creation
                                            if (_model.contractTypeValue !=
                                                    'past' &&
                                                _model.datePicked != null &&
                                                _model.amountTextController.text
                                                    .isNotEmpty) {
                                              try {
                                                _model.yearsDuration =
                                                    _calculateContractDurationYears(
                                                        _model.datePicked!);

                                                // Calculate total contract value: (duration × initial fee) - initial fee
                                                final double initialFee =
                                                    double.tryParse(_model
                                                            .amountTextController
                                                            .text) ??
                                                        0.0;
                                                final int duration =
                                                    _model.yearsDuration ?? 0;

                                                _model.calculateTotalBalance =
                                                    ((duration * initialFee) -
                                                            initialFee)
                                                        .toInt();

                                                safeSetState(() {
                                                  _model.yearsTextController
                                                      ?.text = _model
                                                          .yearsDuration
                                                          ?.toString() ??
                                                      '0';
                                                  _model.balanceTextController
                                                      ?.text = _model
                                                          .calculateTotalBalance
                                                          ?.toString() ??
                                                      '0';
                                                });
                                              } catch (e) {
                                                print(
                                                    'Error calculating balance: $e');
                                                // Set default values if calculation fails
                                                _model.yearsDuration = 0;
                                                _model.calculateTotalBalance =
                                                    0;
                                                _model.yearsTextController
                                                    ?.text = '0';
                                                _model.balanceTextController
                                                    ?.text = '0';
                                              }
                                            }

                                            // Show confirmation dialog
                                            final bool? confirmed =
                                                await showDialog<bool>(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: Text(
                                                    'Confirm Burial Location Creation',
                                                    style: GoogleFonts.inter(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: const Color(
                                                          0xFF1F2937),
                                                    ),
                                                  ),
                                                  content: Text(
                                                    'Are you sure you want to create this burial location? This action cannot be undone.',
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

                                            if (confirmed != true) return;

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
                                                      Text(
                                                          'Creating burial location...'),
                                                    ],
                                                  ),
                                                );
                                              },
                                            );

                                            try {
                                              // Determine if this is a new or past contract
                                              final bool isPastContract = _model.contractTypeValue == 'past';
                                              
                                              // Create new contract document directly
                                              await ContractRecord.collection
                                                  .doc()
                                                  .set({
                                                ...createContractRecordData(
                                                  leessee: _model
                                                      .ownerTextController.text,
                                                  street: _model
                                                      .streetTextController
                                                      .text,
                                                  measurement: _model
                                                      .measurementTextController
                                                      .text,
                                                  type: 'Lot',
                                                  lotLoccation: _model
                                                      .blocklotTextController
                                                      .text,
                                                  location: _model
                                                      .blocklotTextController
                                                      .text,
                                                  contractID: await FFAppState()
                                                      .getNextAvailableContractId(),
                                                  amount: _model
                                                      .amountTextController
                                                      .text,
                                                  lotstatus: _model.statusValue,
                                                  dateofexpiration:
                                                      _model.datePicked,
                                                  contractstatus: isPastContract ? 'past' : 'active',
                                                  status: 'available',
                                                  initialfee: double.tryParse(
                                                      _model
                                                          .amountTextController
                                                          .text),
                                                  balance: int.tryParse(_model
                                                      .balanceTextController
                                                      .text),
                                                  dateadded: isPastContract ? null : DateTime.now(),
                                                  dateEffective: isPastContract 
                                                      ? _model.effectiveDatePicked 
                                                      : null,
                                                ),
                                                // Deceased field
                                                'decFullName':
                                                    [], // Empty for now, will be populated when deceased is added
                                                // For new contracts, set dateEffective to server timestamp
                                                // For past contracts, it's already set above
                                                if (!isPastContract)
                                                  ...mapToFirestore(
                                                    {
                                                      'dateEffective': FieldValue
                                                          .serverTimestamp(),
                                                    },
                                                  ),
                                              });

                                              // Increment contract ID for next contract
                                              FFAppState().contractid =
                                                  FFAppState().contractid + 1;

                                              // Close loading dialog
                                              Navigator.of(context).pop();

                                              await showDialog(
                                                context: context,
                                                builder: (alertDialogContext) {
                                                  return AlertDialog(
                                                    content: Text(
                                                        'Data created successfully!'),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                                alertDialogContext),
                                                        child: Text('Ok'),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                              context.safePop();
                                            } catch (e) {
                                              // Close loading dialog
                                              Navigator.of(context).pop();

                                              // Show error dialog
                                              await showDialog(
                                                context: context,
                                                builder: (alertDialogContext) {
                                                  return AlertDialog(
                                                    title: Text('Error'),
                                                    content: Text(
                                                        'Failed to create burial location: ${e.toString()}'),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                                alertDialogContext),
                                                        child: Text('Ok'),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
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
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.add_location_alt_rounded,
                                              size: 20,
                                              color: Colors.white,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'ADD BURIAL LOCATION',
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
