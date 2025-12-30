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
import 'nitchecontract_form_copy_widget.dart' show NitchecontractFormCopyWidget;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class NitchecontractFormCopyModel
    extends FlutterFlowModel<NitchecontractFormCopyWidget> {
  ///  State fields for stateful widgets in this page.

  final formKey = GlobalKey<FormState>();
  // State field(s) for contract type widget.
  String? contractTypeValue;
  // State field(s) for unfocusNode widget.
  FocusNode? unfocusNode;
  // State field(s) for applicantname widget.
  FocusNode? applicantnameFocusNode;
  TextEditingController? applicantnameTextController;
  String? Function(BuildContext, String?)? applicantnameTextControllerValidator;
  // State field(s) for applicantcontact widget.
  FocusNode? applicantcontactFocusNode;
  TextEditingController? applicantcontactTextController;
  String? Function(BuildContext, String?)?
      applicantcontactTextControllerValidator;
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
  DateTime? datePicked3;
  DateTime? effectiveDatePicked;
  // Stores action output result for [Custom Action - yearsDuration] action in datepfexpiration widget.
  int? totalyears;
  // Stores action output result for [Custom Action - calculateTotalBalance] action in datepfexpiration widget.
  int? calculateTotalBalance;
  // State field(s) for dateofexpiration widget.
  FocusNode? dateofexpirationFocusNode;
  TextEditingController? dateofexpirationTextController;
  String? Function(BuildContext, String?)?
      dateofexpirationTextControllerValidator;
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
  DateTime? datePicked4;
  // State field(s) for dateissued widget.
  FocusNode? dateissuedFocusNode;
  TextEditingController? dateissuedTextController;
  String? Function(BuildContext, String?)? dateissuedTextControllerValidator;
  // State field(s) for placeissued widget.
  FocusNode? placeissuedFocusNode;
  TextEditingController? placeissuedTextController;
  String? Function(BuildContext, String?)? placeissuedTextControllerValidator;
  // State field(s) for amount widget.
  FocusNode? amountFocusNode;
  TextEditingController? amountTextController;
  String? Function(BuildContext, String?)? amountTextControllerValidator;
  // State field(s) for totalyears widget.
  FocusNode? totalyearsFocusNode;
  TextEditingController? totalyearsTextController;
  String? Function(BuildContext, String?)? totalyearsTextControllerValidator;
  // State field(s) for totalbalance widget.
  FocusNode? totalbalanceFocusNode;
  TextEditingController? totalbalanceTextController;
  String? Function(BuildContext, String?)? totalbalanceTextControllerValidator;
  // State field(s) for totalcontractvalue widget.
  FocusNode? totalcontractvalueFocusNode;
  TextEditingController? totalcontractvalueTextController;
  String? Function(BuildContext, String?)?
      totalcontractvalueTextControllerValidator;
  // State field(s) for orno widget.
  FocusNode? ornoFocusNode;
  TextEditingController? ornoTextController;
  String? Function(BuildContext, String?)? ornoTextControllerValidator;

  // State field(s) for proof of lease upload.
  String? proofOfLeasePath;
  // State field(s) for proof of lease text field.
  FocusNode? proofOfLeaseFocusNode;
  TextEditingController? proofOfLeaseTextController;
  String? Function(BuildContext, String?)? proofOfLeaseTextControllerValidator;

  // Multiple deceased entries support
  List<DeceasedEntry> deceasedEntries = [DeceasedEntry()];

  @override
  void initState(BuildContext context) {
    totalcontractvalueFocusNode = FocusNode();
    totalcontractvalueTextController = TextEditingController();
  }

  @override
  void dispose() {
    unfocusNode?.dispose();
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

    dateofexpirationFocusNode?.dispose();
    dateofexpirationTextController?.dispose();

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

    amountFocusNode?.dispose();
    amountTextController?.dispose();

    totalyearsFocusNode?.dispose();
    totalyearsTextController?.dispose();

    totalbalanceFocusNode?.dispose();
    totalbalanceTextController?.dispose();

    totalcontractvalueFocusNode?.dispose();
    totalcontractvalueTextController?.dispose();

    ornoFocusNode?.dispose();
    ornoTextController?.dispose();

    proofOfLeaseFocusNode?.dispose();
    proofOfLeaseTextController?.dispose();

    // Dispose all deceased entries
    for (final entry in deceasedEntries) {
      entry.dispose();
    }
    deceasedEntries.clear();
  }
}
