import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_data_table.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'manage_contract_widget.dart' show ManageContractWidget;
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:text_search/text_search.dart';

class ManageContractModel extends FlutterFlowModel<ManageContractWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;
  List<ContractRecord> simpleSearchResults = [];
  DateTime? datePicked;

  // Date filter fields for contract dates
  DateTime? startDate;
  DateTime? endDate;

  // Filter field for status filtering
  String? selectedFilter;

  // Contract type dropdown
  String? selectedContractType;

  // Pay balance modal controllers
  TextEditingController? payerNameController;
  TextEditingController? amountController;
  FocusNode? payerNameFocusNode;
  FocusNode? amountFocusNode;

  // Renew contract modal controllers
  DateTime? renewalExpirationDate;
  TextEditingController? renewalFeeController;
  FocusNode? renewalFeeFocusNode;
  TextEditingController? contractDurationController;
  TextEditingController? totalContractValueController;
  FocusNode? contractDurationFocusNode;
  FocusNode? totalContractValueFocusNode;

  // Transaction summary modal state
  bool? agreeToTerms;

  // Validation error messages for pay balance modal
  String? payerNameError;
  String? amountError;

  // State field(s) for PaginatedDataTable widget.
  final paginatedDataTableController1 =
      FlutterFlowDataTableController<ContractRecord>();
  // State field(s) for PaginatedDataTable widget.
  final paginatedDataTableController2 =
      FlutterFlowDataTableController<ContractRecord>();

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    textFieldFocusNode?.dispose();
    textController?.dispose();
    payerNameController?.dispose();
    amountController?.dispose();
    payerNameFocusNode?.dispose();
    amountFocusNode?.dispose();
    renewalFeeController?.dispose();
    renewalFeeFocusNode?.dispose();
    contractDurationController?.dispose();
    totalContractValueController?.dispose();
    contractDurationFocusNode?.dispose();
    totalContractValueFocusNode?.dispose();

    paginatedDataTableController1.dispose();
    paginatedDataTableController2.dispose();
  }
}
