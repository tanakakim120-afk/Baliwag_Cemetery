import 'package:flutter/material.dart';

class DeceasedEntry {
  TextEditingController nameController = TextEditingController();
  FocusNode nameFocusNode = FocusNode();
  TextEditingController deathDateController = TextEditingController();
  FocusNode deathDateFocusNode = FocusNode();
  DateTime? deathDate;
  TextEditingController burialDateController = TextEditingController();
  FocusNode burialDateFocusNode = FocusNode();
  DateTime? burialDate;

  void dispose() {
    nameController.dispose();
    nameFocusNode.dispose();
    deathDateController.dispose();
    deathDateFocusNode.dispose();
    burialDateController.dispose();
    burialDateFocusNode.dispose();
  }
}





