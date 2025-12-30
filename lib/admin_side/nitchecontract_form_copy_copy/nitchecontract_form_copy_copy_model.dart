import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/flutter_flow/custom_functions.dart' as functions;
import 'nitchecontract_form_copy_copy_widget.dart'
    show NitchecontractFormCopyCopyWidget;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class NitchecontractFormCopyCopyModel
    extends FlutterFlowModel<NitchecontractFormCopyCopyWidget> {
  ///  State fields for stateful widgets in this page.

  final formKey = GlobalKey<FormState>();
  // State field(s) for applicantname widget.
  FocusNode? applicantnameFocusNode;
  TextEditingController? applicantnameTextController;
  String? Function(BuildContext, String?)? applicantnameTextControllerValidator;
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

    return null;
  }

  // State field(s) for applicantaddress widget.
  FocusNode? applicantaddressFocusNode;
  TextEditingController? applicantaddressTextController;
  String? Function(BuildContext, String?)?
      applicantaddressTextControllerValidator;
  // State field(s) for deceasedname widget.
  FocusNode? deceasednameFocusNode;
  TextEditingController? deceasednameTextController;
  String? Function(BuildContext, String?)? deceasednameTextControllerValidator;
  DateTime? datePicked1;
  // State field(s) for dateofdeath widget.
  FocusNode? dateofdeathFocusNode;
  TextEditingController? dateofdeathTextController;
  String? Function(BuildContext, String?)? dateofdeathTextControllerValidator;
  DateTime? datePicked2;
  // State field(s) for dateofburial widget.
  FocusNode? dateofburialFocusNode;
  TextEditingController? dateofburialTextController;
  String? Function(BuildContext, String?)? dateofburialTextControllerValidator;
  // State field(s) for tomblocation widget.
  FocusNode? tomblocationFocusNode;
  TextEditingController? tomblocationTextController;
  String? Function(BuildContext, String?)? tomblocationTextControllerValidator;
  // State field(s) for residentcert widget.
  FocusNode? residentcertFocusNode;
  TextEditingController? residentcertTextController;
  String? Function(BuildContext, String?)? residentcertTextControllerValidator;
  // State field(s) for tin widget.
  FocusNode? tinFocusNode;
  TextEditingController? tinTextController;
  String? Function(BuildContext, String?)? tinTextControllerValidator;
  DateTime? datePicked3;
  // State field(s) for dateissued widget.
  FocusNode? dateissuedFocusNode;
  TextEditingController? dateissuedTextController;
  String? Function(BuildContext, String?)? dateissuedTextControllerValidator;
  // State field(s) for placeissued widget.
  FocusNode? placeissuedFocusNode;
  TextEditingController? placeissuedTextController;
  String? Function(BuildContext, String?)? placeissuedTextControllerValidator;

  @override
  void initState(BuildContext context) {
    applicantcontactTextControllerValidator =
        _applicantcontactTextControllerValidator;
  }

  @override
  void dispose() {
    applicantnameFocusNode?.dispose();
    applicantnameTextController?.dispose();

    applicantcontactFocusNode?.dispose();
    applicantcontactTextController?.dispose();

    applicantaddressFocusNode?.dispose();
    applicantaddressTextController?.dispose();

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

    dateissuedFocusNode?.dispose();
    dateissuedTextController?.dispose();

    placeissuedFocusNode?.dispose();
    placeissuedTextController?.dispose();
  }
}
