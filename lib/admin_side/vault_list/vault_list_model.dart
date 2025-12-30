import 'dart:async';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_data_table.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'vault_list_widget.dart';

class VaultListModel extends FlutterFlowModel<VaultListWidget> {
  ///  State fields for stateful widgets in this page.

  final unfocusNode = FocusNode();
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(String?)? textControllerValidator;
  // State field(s) for PaginatedDataTable widget.
  final paginatedDataTableController1 =
      FlutterFlowDataTableController<VaultRecord>();

  // Date filter fields
  DateTime? startDate;
  DateTime? endDate;

  // Search debouncing
  Timer? searchTimer;

  /// Initialization and disposal methods.

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    unfocusNode.dispose();
    textFieldFocusNode?.dispose();
    textController?.dispose();
    searchTimer?.cancel();
  }

  /// Action blocks are added here.

  /// Additional helper methods are added here.
}
