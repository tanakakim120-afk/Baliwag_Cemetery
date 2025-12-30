import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'lat_lng.dart';
import 'place.dart';
import 'uploaded_file.dart';
import '/backend/backend.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/auth/firebase_auth/auth_util.dart';

DateTime? add5yrs() {
  // add 5years in the current year
  return DateTime.now().add(Duration(days: 5 * 365)); // Adding 5 years
}

DateTime? add1day() {
  // add 1 day
  return DateTime.now().add(Duration(days: 1)); // Adding 1 day
}

String? newCustomFunction() {
  // generate an OR.No which is have unique number. include the year like. 2025-0001
  DateTime now = DateTime.now();
  String year = now.year.toString();
  int uniqueNumber = math.Random().nextInt(9999) +
      1; // Generate a unique number between 1 and 9999
  String formattedNumber =
      uniqueNumber.toString().padLeft(4, '0'); // Format to 4 digits
  return '$year-$formattedNumber'; // Return the formatted OR.No
}

DateTime? startofof2025() {
  // get the start of january 2025
  return DateTime(2025, 1, 1); // Return the start of January 2025
}

String? newCustomFunction2(String? balance) {
  // create a function that will calculate the total balance from the totalContractBalance field from the contract document
  // Assuming we have a Firestore collection named 'contracts' with a field 'totalContractBalance'
  double totalBalance = 0.0;

  Future<double> calculateTotalBalance() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('contract').get();
    for (var doc in snapshot.docs) {
      totalBalance +=
          doc['totalContraBalance'] ?? 0.0; // Add the balance if it exists
    }
    return totalBalance; // Return the total balance
  }

  return totalBalance.toString(); // Return the total balance as a string
}

int? calculateBalance(
  int balance,
  int payment,
) {
  int result = balance - payment;
  return result;
}

DateTime? years(String? input) {
  if (input == null || input.isEmpty) return null;

  try {
    final yearsToAdd = int.parse(input); // Convert string to int
    final now = DateTime.now();
    return DateTime(now.year + yearsToAdd, now.month, now.day);
  } catch (e) {
    // Return null if input is not a valid integer
    return null;
  }
}
