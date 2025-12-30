import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import '/flutter_flow/upload_data.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/custom_functions.dart' as functions;
import 'new_add_burial_location_widget.dart' show NewAddBurialLocationWidget;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class NewAddBurialLocationModel
    extends FlutterFlowModel<NewAddBurialLocationWidget> {
  ///  State fields for stateful widgets in this page.

  final formKey2 = GlobalKey<FormState>();
  final formKey1 = GlobalKey<FormState>();
  final formKey4 = GlobalKey<FormState>();
  final formKey3 = GlobalKey<FormState>();
  // State field(s) for blocklot widget.
  FocusNode? blocklotFocusNode;
  TextEditingController? blocklotTextController;
  String? Function(BuildContext, String?)? blocklotTextControllerValidator;
  String? _blocklotTextControllerValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'eg. B1-L1 is required';
    }

    if (!RegExp('^B\\d+-L\\d+\$').hasMatch(val)) {
      return 'Must be B(number)-L(number)';
    }
    return null;
  }

  // State field(s) for owner widget.
  FocusNode? ownerFocusNode;
  TextEditingController? ownerTextController;
  String? Function(BuildContext, String?)? ownerTextControllerValidator;
  String? _ownerTextControllerValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Field is required';
    }

    if (!RegExp('/^[A-Za-z\\s]+\$/').hasMatch(val)) {
      return 'Invalid text';
    }
    return null;
  }

  // State field(s) for street widget.
  FocusNode? streetFocusNode;
  TextEditingController? streetTextController;
  String? Function(BuildContext, String?)? streetTextControllerValidator;
  String? _streetTextControllerValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Street is required';
    }

    return null;
  }

  // State field(s) for contract type widget.
  String? contractTypeValue;
  FormFieldController<String>? contractTypeValueController;
  
  // State field(s) for status widget.
  String? statusValue;
  FormFieldController<String>? statusValueController;
  DateTime? datePicked;
  DateTime? effectiveDatePicked;
  // Stores action output result for [Custom Action - setExpired] action in Button widget.
  DateTime? expiredDATE;
  // Stores action output result for [Custom Action - yearsDuration] action in Button widget.
  int? yearsDuration;
  // Stores action output result for [Custom Action - calculateTotalBalance] action in Button widget.
  int? calculateTotalBalance;
  // State field(s) for expiration widget.
  FocusNode? expirationFocusNode;
  TextEditingController? expirationTextController;
  String? Function(BuildContext, String?)? expirationTextControllerValidator;
  // State field(s) for measurement widget.
  FocusNode? measurementFocusNode;
  TextEditingController? measurementTextController;
  String? Function(BuildContext, String?)? measurementTextControllerValidator;
  String? _measurementTextControllerValidator(
      BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Field is required';
    }

    if (!RegExp('^\\d+x\\d+\$').hasMatch(val)) {
      return 'Invalid text';
    }
    return null;
  }

  bool isDataUploading_uploadData7d = false;
  FFUploadedFile uploadedLocalFile_uploadData7d =
      FFUploadedFile(bytes: Uint8List.fromList([]));

  // State field(s) for amount widget.
  FocusNode? amountFocusNode;
  TextEditingController? amountTextController;
  String? Function(BuildContext, String?)? amountTextControllerValidator;
  // State field(s) for years widget.
  FocusNode? yearsFocusNode;
  TextEditingController? yearsTextController;
  String? Function(BuildContext, String?)? yearsTextControllerValidator;
  // State field(s) for balance widget.
  FocusNode? balanceFocusNode;
  TextEditingController? balanceTextController;
  String? Function(BuildContext, String?)? balanceTextControllerValidator;

  // State field(s) for resident certificate widget.
  FocusNode? residentCertFocusNode;
  TextEditingController? residentCertTextController;
  String? Function(BuildContext, String?)? residentCertTextControllerValidator;

  // State field(s) for TIN widget.
  FocusNode? tinFocusNode;
  TextEditingController? tinTextController;
  String? Function(BuildContext, String?)? tinTextControllerValidator;

  // State field(s) for OR number widget.
  FocusNode? orNumberFocusNode;
  TextEditingController? orNumberTextController;
  String? Function(BuildContext, String?)? orNumberTextControllerValidator;

  // State field(s) for place issued widget.
  FocusNode? placeIssuedFocusNode;
  TextEditingController? placeIssuedTextController;
  String? Function(BuildContext, String?)? placeIssuedTextControllerValidator;

  // State field(s) for date issued widget.
  FocusNode? dateIssuedFocusNode;
  TextEditingController? dateIssuedTextController;
  String? Function(BuildContext, String?)? dateIssuedTextControllerValidator;

  // State field(s) for proof of lease upload.
  String? proofOfLeasePath;

  @override
  void initState(BuildContext context) {
    blocklotTextControllerValidator = _blocklotTextControllerValidator;
    ownerTextControllerValidator = _ownerTextControllerValidator;
    streetTextControllerValidator = _streetTextControllerValidator;
    measurementTextControllerValidator = _measurementTextControllerValidator;
  }

  @override
  void dispose() {
    blocklotFocusNode?.dispose();
    blocklotTextController?.dispose();

    ownerFocusNode?.dispose();
    ownerTextController?.dispose();

    streetFocusNode?.dispose();
    streetTextController?.dispose();

    expirationFocusNode?.dispose();
    expirationTextController?.dispose();

    measurementFocusNode?.dispose();
    measurementTextController?.dispose();

    amountFocusNode?.dispose();
    amountTextController?.dispose();

    yearsFocusNode?.dispose();
    yearsTextController?.dispose();

    balanceFocusNode?.dispose();
    balanceTextController?.dispose();

    residentCertFocusNode?.dispose();
    residentCertTextController?.dispose();

    tinFocusNode?.dispose();
    tinTextController?.dispose();

    orNumberFocusNode?.dispose();
    orNumberTextController?.dispose();

    placeIssuedFocusNode?.dispose();
    placeIssuedTextController?.dispose();

    dateIssuedFocusNode?.dispose();
    dateIssuedTextController?.dispose();
  }
}
