import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/flutter_flow/custom_functions.dart' as functions;
import 'lott_contract_form_widget.dart' show LottContractFormWidget;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class LottContractFormModel extends FlutterFlowModel<LottContractFormWidget> {
  ///  State fields for stateful widgets in this page.

  final formKey = GlobalKey<FormState>();
  // State field(s) for applicantname widget.
  FocusNode? applicantnameFocusNode;
  TextEditingController? applicantnameTextController;
  String? Function(BuildContext, String?)? applicantnameTextControllerValidator;
  String? _applicantnameTextControllerValidator(
      BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Name Of Applicant is required';
    }

    if (!RegExp('^[A-Za-z. ]+\$').hasMatch(val)) {
      return 'Invalid text';
    }
    return null;
  }

  // State field(s) for applicantaddress widget.
  FocusNode? applicantaddressFocusNode;
  TextEditingController? applicantaddressTextController;
  String? Function(BuildContext, String?)?
      applicantaddressTextControllerValidator;
  String? _applicantaddressTextControllerValidator(
      BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Address Of Applicant is required';
    }

    if (!RegExp('^[A-Za-z0-9\\s,.\'-]*\$').hasMatch(val)) {
      return 'Invalid text';
    }
    return null;
  }

  // State field(s) for applicantcontact widget.
  FocusNode? applicantcontactFocusNode;
  TextEditingController? applicantcontactTextController;
  String? Function(BuildContext, String?)?
      applicantcontactTextControllerValidator;
  String? _applicantcontactTextControllerValidator(
      BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Contact Number Of Applicant is required';
    }

    if (!RegExp('^09\\d{9}\$').hasMatch(val)) {
      return 'eg.09xxxxxxxxx';
    }
    return null;
  }

  // State field(s) for deceasedname widget.
  FocusNode? deceasednameFocusNode;
  TextEditingController? deceasednameTextController;
  String? Function(BuildContext, String?)? deceasednameTextControllerValidator;
  String? _deceasednameTextControllerValidator(
      BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Name Of Decased is required';
    }

    if (!RegExp('^[A-Za-z. ]+\$').hasMatch(val)) {
      return 'Invalid text';
    }
    return null;
  }

  // State field(s) for dateofdeath widget.
  FocusNode? dateofdeathFocusNode;
  TextEditingController? dateofdeathTextController;
  String? Function(BuildContext, String?)? dateofdeathTextControllerValidator;
  DateTime? datePicked1;
  DateTime? datePicked2;
  // State field(s) for dateofburial widget.
  FocusNode? dateofburialFocusNode;
  TextEditingController? dateofburialTextController;
  String? Function(BuildContext, String?)? dateofburialTextControllerValidator;
  // State field(s) for tomblocation widget.
  FocusNode? tomblocationFocusNode;
  TextEditingController? tomblocationTextController;
  String? Function(BuildContext, String?)? tomblocationTextControllerValidator;
  String? _tomblocationTextControllerValidator(
      BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'lotlocation is required';
    }

    if (!RegExp('').hasMatch(val)) {
      return 'Invalid text';
    }
    return null;
  }

  DateTime? datePicked3;

  // State field(s) for totalyears widget.
  FocusNode? totalyearsFocusNode;
  TextEditingController? totalyearsTextController;
  String? Function(BuildContext, String?)? totalyearsTextControllerValidator;

  // State field(s) for totalcontractvalue widget.
  FocusNode? totalcontractvalueFocusNode;
  TextEditingController? totalcontractvalueTextController;
  String? Function(BuildContext, String?)?
      totalcontractvalueTextControllerValidator;

  // State field(s) for residentcert widget.
  FocusNode? residentcertFocusNode;
  TextEditingController? residentcertTextController;
  String? Function(BuildContext, String?)? residentcertTextControllerValidator;
  // State field(s) for tin widget.
  FocusNode? tinFocusNode;
  TextEditingController? tinTextController;
  String? Function(BuildContext, String?)? tinTextControllerValidator;
  String? _tinTextControllerValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Tax Identification Number is required';
    }

    if (!RegExp('^[0-9]+\$').hasMatch(val)) {
      return 'Invalid text';
    }
    return null;
  }

  // State field(s) for orno widget.
  FocusNode? ornoFocusNode;
  TextEditingController? ornoTextController;
  String? Function(BuildContext, String?)? ornoTextControllerValidator;
  String? _ornoTextControllerValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Official Receipt # is required';
    }

    return null;
  }

  // State field(s) for placeissued widget.
  FocusNode? placeissuedFocusNode;
  TextEditingController? placeissuedTextController;
  String? Function(BuildContext, String?)? placeissuedTextControllerValidator;
  // State field(s) for di widget.
  FocusNode? diFocusNode;
  TextEditingController? diTextController;
  String? Function(BuildContext, String?)? diTextControllerValidator;
  // State field(s) for amount widget.
  FocusNode? amountFocusNode;
  TextEditingController? amountTextController;
  String? Function(BuildContext, String?)? amountTextControllerValidator;
  String? _amountTextControllerValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return '1500 is required';
    }

    if (!RegExp('^[0-9]+\$').hasMatch(val)) {
      return 'Invalid text';
    }
    return null;
  }

  @override
  void initState(BuildContext context) {
    applicantnameTextControllerValidator =
        _applicantnameTextControllerValidator;
    applicantaddressTextControllerValidator =
        _applicantaddressTextControllerValidator;
    applicantcontactTextControllerValidator =
        _applicantcontactTextControllerValidator;
    deceasednameTextControllerValidator = _deceasednameTextControllerValidator;
    tomblocationTextControllerValidator = _tomblocationTextControllerValidator;
    tinTextControllerValidator = _tinTextControllerValidator;
    ornoTextControllerValidator = _ornoTextControllerValidator;
    amountTextControllerValidator = _amountTextControllerValidator;
  }

  @override
  void dispose() {
    applicantnameFocusNode?.dispose();
    applicantnameTextController?.dispose();

    applicantaddressFocusNode?.dispose();
    applicantaddressTextController?.dispose();

    applicantcontactFocusNode?.dispose();
    applicantcontactTextController?.dispose();

    deceasednameFocusNode?.dispose();
    deceasednameTextController?.dispose();

    dateofdeathFocusNode?.dispose();
    dateofdeathTextController?.dispose();

    dateofburialFocusNode?.dispose();
    dateofburialTextController?.dispose();

    tomblocationFocusNode?.dispose();
    tomblocationTextController?.dispose();

    residentcertFocusNode?.dispose();
    residentcertTextController?.dispose();

    tinFocusNode?.dispose();
    tinTextController?.dispose();

    ornoFocusNode?.dispose();
    ornoTextController?.dispose();

    placeissuedFocusNode?.dispose();
    placeissuedTextController?.dispose();

    diFocusNode?.dispose();
    diTextController?.dispose();

    amountFocusNode?.dispose();
    amountTextController?.dispose();

    totalyearsFocusNode?.dispose();
    totalyearsTextController?.dispose();

    totalcontractvalueFocusNode?.dispose();
    totalcontractvalueTextController?.dispose();
  }
}
