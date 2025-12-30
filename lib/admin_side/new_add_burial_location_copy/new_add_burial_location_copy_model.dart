import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import '/flutter_flow/upload_data.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/custom_functions.dart' as functions;
import 'new_add_burial_location_copy_widget.dart'
    show NewAddBurialLocationCopyWidget;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class NewAddBurialLocationCopyModel
    extends FlutterFlowModel<NewAddBurialLocationCopyWidget> {
  ///  State fields for stateful widgets in this page.

  final formKey5 = GlobalKey<FormState>();
  final formKey1 = GlobalKey<FormState>();
  final formKey6 = GlobalKey<FormState>();
  final formKey4 = GlobalKey<FormState>();
  final formKey7 = GlobalKey<FormState>();
  final formKey8 = GlobalKey<FormState>();
  final formKey3 = GlobalKey<FormState>();
  final formKey2 = GlobalKey<FormState>();
  // State field(s) for owner widget.
  FocusNode? ownerFocusNode;
  TextEditingController? ownerTextController;
  String? Function(BuildContext, String?)? ownerTextControllerValidator;
  String? _ownerTextControllerValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Name/Leessee is required';
    }

    if (!RegExp('^[A-Za-z ]+\$').hasMatch(val)) {
      return 'Invalid text';
    }
    return null;
  }

  // State field(s) for blocklot widget.
  FocusNode? blocklotFocusNode;
  TextEditingController? blocklotTextController;
  String? Function(BuildContext, String?)? blocklotTextControllerValidator;
  String? _blocklotTextControllerValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'eg. B1-L1 is required';
    }

    if (!RegExp('^B\\d+-L\\d+\$').hasMatch(val)) {
      return 'Invalid text';
    }
    return null;
  }

  // State field(s) for measurement widget.
  FocusNode? measurementFocusNode;
  TextEditingController? measurementTextController;
  String? Function(BuildContext, String?)? measurementTextControllerValidator;
  String? _measurementTextControllerValidator(
      BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'eg. 2x3 is required';
    }

    if (!RegExp('^\\d+x\\d+\$').hasMatch(val)) {
      return 'Invalid text';
    }
    return null;
  }

  // State field(s) for status widget.
  String? statusValue;
  FormFieldController<String>? statusValueController;
  // State field(s) for street widget.
  FocusNode? streetFocusNode;
  TextEditingController? streetTextController;
  String? Function(BuildContext, String?)? streetTextControllerValidator;
  DateTime? datePicked;
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
  bool isDataUploading_uploadData7dj = false;
  FFUploadedFile uploadedLocalFile_uploadData7dj =
      FFUploadedFile(bytes: Uint8List.fromList([]));

  // State field(s) for amount widget.
  FocusNode? amountFocusNode1;
  TextEditingController? amountTextController1;
  String? Function(BuildContext, String?)? amountTextController1Validator;
  // State field(s) for years widget.
  FocusNode? yearsFocusNode;
  TextEditingController? yearsTextController;
  String? Function(BuildContext, String?)? yearsTextControllerValidator;
  // State field(s) for balance widget.
  FocusNode? balanceFocusNode;
  TextEditingController? balanceTextController;
  String? Function(BuildContext, String?)? balanceTextControllerValidator;
  // State field(s) for amount widget.
  FocusNode? amountFocusNode2;
  TextEditingController? amountTextController2;
  String? Function(BuildContext, String?)? amountTextController2Validator;

  @override
  void initState(BuildContext context) {
    ownerTextControllerValidator = _ownerTextControllerValidator;
    blocklotTextControllerValidator = _blocklotTextControllerValidator;
    measurementTextControllerValidator = _measurementTextControllerValidator;
  }

  @override
  void dispose() {
    ownerFocusNode?.dispose();
    ownerTextController?.dispose();

    blocklotFocusNode?.dispose();
    blocklotTextController?.dispose();

    measurementFocusNode?.dispose();
    measurementTextController?.dispose();

    streetFocusNode?.dispose();
    streetTextController?.dispose();

    expirationFocusNode?.dispose();
    expirationTextController?.dispose();

    amountFocusNode1?.dispose();
    amountTextController1?.dispose();

    yearsFocusNode?.dispose();
    yearsTextController?.dispose();

    balanceFocusNode?.dispose();
    balanceTextController?.dispose();

    amountFocusNode2?.dispose();
    amountTextController2?.dispose();
  }
}
