// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

/// Custom action to calculate the total balance based on the amount and years
Future<int> calculateTotalBalance(String amountText, int durationYears) async {
  // Return 0 if the amount is null or empty
  if (amountText == null || amountText.isEmpty) {
    return 0;
  }

  // Parse the amount from the string to a double
  double amount = double.tryParse(amountText) ?? 0.0;

  // Calculate the total balance by multiplying amount by durationYears
  double totalBalance = amount * durationYears;

  // Debugging: print the calculated total balance
  print("Calculated Total Balance: $totalBalance");

  // Return the total balance rounded to the nearest integer
  return totalBalance.round();
}
