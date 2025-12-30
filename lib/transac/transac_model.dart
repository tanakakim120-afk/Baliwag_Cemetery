import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/custom_functions.dart' as functions;
import 'transac_widget.dart' show TransacWidget;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class TransacModel extends FlutterFlowModel<TransacWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for DropDown widget.
  String? dropDownValue;
  FormFieldController<String>? dropDownValueController;
  // State field(s) for Yearsadd widget.
  FocusNode? yearsaddFocusNode;
  TextEditingController? yearsaddTextController;
  String? Function(BuildContext, String?)? yearsaddTextControllerValidator;
  // Stores action output result for [Custom Action - newCustomAction] action in Button widget.
  DateTime? newexpirationyear;
  // Stores action output result for [Custom Action - calculateTotalBalance] action in Button widget.
  int? nitcheRenewalBalance;
  // Stores action output result for [Custom Action - balance] action in Button widget.
  int? calculatenitcheBalance;
  // Stores action output result for [Custom Action - calculateTotalBalance] action in Button widget.
  int? lotRenewalBalance;
  // Stores action output result for [Custom Action - balance] action in Button widget.
  int? calculateLotBalance;
  // State field(s) for newexpiration widget.
  FocusNode? newexpirationFocusNode;
  TextEditingController? newexpirationTextController;
  String? Function(BuildContext, String?)? newexpirationTextControllerValidator;
  DateTime? datePicked;
  // State field(s) for AmountToPay widget.
  FocusNode? amountToPayFocusNode;
  TextEditingController? amountToPayTextController;
  String? Function(BuildContext, String?)? amountToPayTextControllerValidator;
  // State field(s) for lotInitial widget.
  FocusNode? lotInitialFocusNode;
  TextEditingController? lotInitialTextController;
  String? Function(BuildContext, String?)? lotInitialTextControllerValidator;
  // State field(s) for nitcheInitial widget.
  FocusNode? nitcheInitialFocusNode;
  TextEditingController? nitcheInitialTextController;
  String? Function(BuildContext, String?)? nitcheInitialTextControllerValidator;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode1;
  TextEditingController? textController6;
  String? Function(BuildContext, String?)? textController6Validator;
  // State field(s) for nitcheRenewalTotal widget.
  FocusNode? nitcheRenewalTotalFocusNode;
  TextEditingController? nitcheRenewalTotalTextController;
  String? Function(BuildContext, String?)?
      nitcheRenewalTotalTextControllerValidator;
  // State field(s) for lotRenewalTotal widget.
  FocusNode? lotRenewalTotalFocusNode;
  TextEditingController? lotRenewalTotalTextController;
  String? Function(BuildContext, String?)?
      lotRenewalTotalTextControllerValidator;
  // State field(s) for TotalBalanceLOT widget.
  FocusNode? totalBalanceLOTFocusNode;
  TextEditingController? totalBalanceLOTTextController;
  String? Function(BuildContext, String?)?
      totalBalanceLOTTextControllerValidator;
  // State field(s) for TotalBalanceNITCHE widget.
  FocusNode? totalBalanceNITCHEFocusNode;
  TextEditingController? totalBalanceNITCHETextController;
  String? Function(BuildContext, String?)?
      totalBalanceNITCHETextControllerValidator;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode2;
  TextEditingController? textController11;
  String? Function(BuildContext, String?)? textController11Validator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    yearsaddFocusNode?.dispose();
    yearsaddTextController?.dispose();

    newexpirationFocusNode?.dispose();
    newexpirationTextController?.dispose();

    amountToPayFocusNode?.dispose();
    amountToPayTextController?.dispose();

    lotInitialFocusNode?.dispose();
    lotInitialTextController?.dispose();

    nitcheInitialFocusNode?.dispose();
    nitcheInitialTextController?.dispose();

    textFieldFocusNode1?.dispose();
    textController6?.dispose();

    nitcheRenewalTotalFocusNode?.dispose();
    nitcheRenewalTotalTextController?.dispose();

    lotRenewalTotalFocusNode?.dispose();
    lotRenewalTotalTextController?.dispose();

    totalBalanceLOTFocusNode?.dispose();
    totalBalanceLOTTextController?.dispose();

    totalBalanceNITCHEFocusNode?.dispose();
    totalBalanceNITCHETextController?.dispose();

    textFieldFocusNode2?.dispose();
    textController11?.dispose();
  }
}
