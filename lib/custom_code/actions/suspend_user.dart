// Automatic FlutterFlow imports
import '/backend/backend.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

/// Custom action to suspend a user until a specified end date
/// [userRecord] - The user record to suspend
/// [suspensionEndDate] - The date when suspension should end
/// [reason] - Reason for suspension (optional)
Future<bool> suspendUser(
  UsersRecord userRecord,
  DateTime suspensionEndDate,
  String? reason,
) async {
  try {
    // Validate that end date is in the future
    DateTime now = DateTime.now();
    if (suspensionEndDate.isBefore(now) ||
        suspensionEndDate.isAtSameMomentAs(now)) {
      print('Error: Suspension end date must be in the future');
      return false;
    }

    // Calculate suspension start date (now)
    DateTime startDate = now;

    // Create updated user data with suspension information
    final updatedData = createUsersRecordData(
      email: userRecord.email,
      displayName: userRecord.displayName,
      photoUrl: userRecord.photoUrl,
      uid: userRecord.uid,
      createdTime: userRecord.createdTime,
      phoneNumber: userRecord.phoneNumber,
      password: userRecord.password,
      fullname: userRecord.fullname,
      address: userRecord.address,
      type: userRecord.type,
      stringusercreated: userRecord.stringusercreated,
      isSuspended: true,
      suspensionStartDate: startDate,
      suspensionEndDate: suspensionEndDate,
      suspensionReason: reason ?? 'Suspended by administrator',
    );

    // Update the user record in Firestore
    await userRecord.reference.update(updatedData);

    // Calculate duration for logging
    Duration duration = suspensionEndDate.difference(startDate);
    int days = duration.inDays;

    print(
        'User ${userRecord.email} suspended until ${suspensionEndDate.toString().split(' ')[0]} ($days days)');
    return true;
  } catch (e) {
    print('Error suspending user: $e');
    return false;
  }
}

/// Custom action to suspend a user for a specified number of days (backward compatibility)
/// [userRecord] - The user record to suspend
/// [suspensionDays] - Number of days to suspend the user
/// [reason] - Reason for suspension (optional)
Future<bool> suspendUserForDays(
  UsersRecord userRecord,
  int suspensionDays,
  String? reason,
) async {
  DateTime endDate = DateTime.now().add(Duration(days: suspensionDays));
  return await suspendUser(userRecord, endDate, reason);
}

/// Custom action to unsuspend a user
/// [userRecord] - The user record to unsuspend
Future<bool> unsuspendUser(UsersRecord userRecord) async {
  try {
    // Create updated user data without suspension information
    final updatedData = createUsersRecordData(
      email: userRecord.email,
      displayName: userRecord.displayName,
      photoUrl: userRecord.photoUrl,
      uid: userRecord.uid,
      createdTime: userRecord.createdTime,
      phoneNumber: userRecord.phoneNumber,
      password: userRecord.password,
      fullname: userRecord.fullname,
      address: userRecord.address,
      type: userRecord.type,
      stringusercreated: userRecord.stringusercreated,
      isSuspended: false,
      suspensionStartDate: null,
      suspensionEndDate: null,
      suspensionReason: null,
    );

    // Update the user record in Firestore
    await userRecord.reference.update(updatedData);

    print('User ${userRecord.email} unsuspended');
    return true;
  } catch (e) {
    print('Error unsuspending user: $e');
    return false;
  }
}

/// Custom action to check if a user is currently suspended
/// [userRecord] - The user record to check
Future<bool> isUserSuspended(UsersRecord userRecord) async {
  if (!userRecord.isSuspended) {
    return false;
  }

  // Check if suspension has expired
  if (userRecord.suspensionEndDate != null) {
    DateTime now = DateTime.now();
    if (now.isAfter(userRecord.suspensionEndDate!)) {
      // Suspension has expired, automatically unsuspend
      await unsuspendUser(userRecord);
      return false;
    }
  }

  return true;
}
