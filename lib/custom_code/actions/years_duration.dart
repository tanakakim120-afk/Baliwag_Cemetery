// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

/// Custom action to calculate years difference between current date and
/// expiration date
Future<int> yearsDuration(DateTime expirationDateBalance) async {
  // Get the current date
  DateTime currentDate = DateTime.now();

  // Ensure expirationDateBalance is a valid DateTime
  if (expirationDateBalance.isBefore(currentDate)) {
    return 0; // If expiration date is in the past, return 0 years
  }

  // Calculate the duration between the current date and expiration date
  Duration duration = expirationDateBalance.difference(currentDate);

  // Calculate the duration in years (accounting for leap years by dividing by 365.25)
  int contractDurationYears = (duration.inDays / 365.25).round();

  // Return the calculated years difference
  return contractDurationYears;
}
