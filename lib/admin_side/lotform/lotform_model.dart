import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import '/admin_side/shared/deceased_entry.dart';
import 'lotform_widget.dart';

class LotformModel extends FlutterFlowModel<LotformWidget> {
  ///  State fields for stateful widgets in this page.

  final unfocusNode = FocusNode();
  // State field(s) for TextField widget.
  FocusNode? applicantnameFocusNode;
  TextEditingController? applicantnameTextController;
  String? Function(BuildContext, String?)? applicantnameTextControllerValidator;
  // State field(s) for TextField widget.
  FocusNode? applicantcontactFocusNode;
  TextEditingController? applicantcontactTextController;
  String? Function(BuildContext, String?)?
      applicantcontactTextControllerValidator;
  // State field(s) for TextField widget.
  FocusNode? applicantaddressFocusNode;
  TextEditingController? applicantaddressTextController;
  String? Function(BuildContext, String?)?
      applicantaddressTextControllerValidator;
  // State field(s) for TextField widget.
  FocusNode? deceasednameFocusNode;
  TextEditingController? deceasednameTextController;
  String? Function(BuildContext, String?)? deceasednameTextControllerValidator;
  // State field(s) for TextField widget.
  FocusNode? residentcertFocusNode;
  TextEditingController? residentcertTextController;
  String? Function(BuildContext, String?)? residentcertTextControllerValidator;
  // State field(s) for TextField widget.
  FocusNode? placeissuedFocusNode;
  TextEditingController? placeissuedTextController;
  String? Function(BuildContext, String?)? placeissuedTextControllerValidator;
  // State field(s) for TextField widget.
  FocusNode? ornoFocusNode;
  TextEditingController? ornoTextController;
  String? Function(BuildContext, String?)? ornoTextControllerValidator;
  // State field(s) for TextField widget.
  FocusNode? amountFocusNode;
  TextEditingController? amountTextController;
  String? Function(BuildContext, String?)? amountTextControllerValidator;
  // State field(s) for TextField widget.
  FocusNode? tinFocusNode;
  TextEditingController? tinTextController;
  String? Function(BuildContext, String?)? tinTextControllerValidator;
  // State field(s) for TextField widget.
  FocusNode? tomblocationFocusNode;
  TextEditingController? tomblocationTextController;
  String? Function(BuildContext, String?)? tomblocationTextControllerValidator;
  // State field(s) for TextField widget.
  FocusNode? totalyearsFocusNode;
  TextEditingController? totalyearsTextController;
  String? Function(BuildContext, String?)? totalyearsTextControllerValidator;
  // State field(s) for TextField widget.
  FocusNode? totalbalanceFocusNode;
  TextEditingController? totalbalanceTextController;
  String? Function(BuildContext, String?)? totalbalanceTextControllerValidator;
  // State field(s) for TextField widget.
  FocusNode? totalcontractvalueFocusNode;
  TextEditingController? totalcontractvalueTextController;
  String? Function(BuildContext, String?)?
      totalcontractvalueTextControllerValidator;
  // State field(s) for TextField widget.
  FocusNode? dateofexpirationFocusNode;
  TextEditingController? dateofexpirationTextController;
  String? Function(BuildContext, String?)?
      dateofexpirationTextControllerValidator;
  // State field(s) for TextField widget.
  FocusNode? dateissuedFocusNode;
  TextEditingController? dateissuedTextController;
  String? Function(BuildContext, String?)? dateissuedTextControllerValidator;
  // State field(s) for FormField widget.
  final formKey1 = GlobalKey<FormState>();
  // State field(s) for DateTime widget.
  DateTime? datePicked;
  // State field(s) for DateTime widget.
  DateTime? datePicked2;
  // State field(s) for DateTime widget.
  DateTime? datePicked3;
  // State field(s) for DateTime widget.
  DateTime? datePicked4;

  // Multiple deceased entries support
  List<DeceasedEntry> deceasedEntries = [DeceasedEntry()];

  // State field(s) for proof of lease upload.
  String? proofOfLeasePath;

  /// Initialization and disposal methods.

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    unfocusNode.dispose();
    applicantnameFocusNode?.dispose();
    applicantnameTextController?.dispose();

    applicantcontactFocusNode?.dispose();
    applicantcontactTextController?.dispose();

    applicantaddressFocusNode?.dispose();
    applicantaddressTextController?.dispose();

    deceasednameFocusNode?.dispose();
    deceasednameTextController?.dispose();

    residentcertFocusNode?.dispose();
    residentcertTextController?.dispose();

    placeissuedFocusNode?.dispose();
    placeissuedTextController?.dispose();

    ornoFocusNode?.dispose();
    ornoTextController?.dispose();

    amountFocusNode?.dispose();
    amountTextController?.dispose();

    tinFocusNode?.dispose();
    tinTextController?.dispose();

    tomblocationFocusNode?.dispose();
    tomblocationTextController?.dispose();

    totalyearsFocusNode?.dispose();
    totalyearsTextController?.dispose();

    totalbalanceFocusNode?.dispose();
    totalbalanceTextController?.dispose();

    totalcontractvalueFocusNode?.dispose();
    totalcontractvalueTextController?.dispose();

    dateofexpirationFocusNode?.dispose();
    dateofexpirationTextController?.dispose();

    dateissuedFocusNode?.dispose();
    dateissuedTextController?.dispose();

    // Dispose deceased entries
    for (var entry in deceasedEntries) {
      entry.dispose();
    }
  }

  /// Action blocks are added here.

  /// Additional helper methods are added here.
}
