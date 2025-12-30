// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

/// create a function that will add the given number in the current year
Future<DateTime> newCustomAction(int? yearsToAdd) async {
  // Get the current date
  DateTime currentDate = DateTime.now();

  // Handle null case - if no years provided, return current date
  if (yearsToAdd == null) {
    return currentDate;
  }

  // Add the specified number of years to the current date
  DateTime futureDate = DateTime(
    currentDate.year + yearsToAdd,
    currentDate.month,
    currentDate.day,
    currentDate.hour,
    currentDate.minute,
    currentDate.second,
    currentDate.millisecond,
    currentDate.microsecond,
  );

  return futureDate;
}
