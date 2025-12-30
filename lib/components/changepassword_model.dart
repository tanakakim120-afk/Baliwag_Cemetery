import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:math';
import 'dart:ui';
import 'changepassword_widget.dart' show ChangepasswordWidget;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ChangepasswordModel extends FlutterFlowModel<ChangepasswordWidget> {
  ///  State fields for stateful widgets in this component.

  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode1;
  TextEditingController? textController1;
  String? Function(BuildContext, String?)? textController1Validator;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode2;
  TextEditingController? textController2;
  String? Function(BuildContext, String?)? textController2Validator;

  // State field(s) for Current Password TextField widget.
  FocusNode? currentPasswordFocusNode;
  TextEditingController? currentPasswordController;
  String? Function(BuildContext, String?)? currentPasswordControllerValidator;

  // State field(s) for New Password TextField widget.
  FocusNode? newPasswordFocusNode;
  TextEditingController? newPasswordController;
  String? Function(BuildContext, String?)? newPasswordControllerValidator;

  // State field(s) for Confirm Password TextField widget.
  FocusNode? confirmPasswordFocusNode;
  TextEditingController? confirmPasswordController;
  String? Function(BuildContext, String?)? confirmPasswordControllerValidator;

  // Password visibility states
  bool showCurrentPassword = false;
  bool showNewPassword = false;
  bool showConfirmPassword = false;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    textFieldFocusNode1?.dispose();
    textController1?.dispose();

    textFieldFocusNode2?.dispose();
    textController2?.dispose();

    currentPasswordFocusNode?.dispose();
    currentPasswordController?.dispose();

    newPasswordFocusNode?.dispose();
    newPasswordController?.dispose();

    confirmPasswordFocusNode?.dispose();
    confirmPasswordController?.dispose();
  }
}
