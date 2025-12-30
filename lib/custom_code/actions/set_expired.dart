// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

Future<DateTime> setExpired(DateTime? expiredContract) async {
  // Take the value of burial interment as a parameter then add 5 years
  if (expiredContract != null) {
    return expiredContract
        .add(Duration(days: 1825)); // Adding 5 years (1825 days)
  } else {
    throw Exception('Expired contract date is null');
  }
}
