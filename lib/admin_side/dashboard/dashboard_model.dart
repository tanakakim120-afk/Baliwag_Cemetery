import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/components/notif_widget.dart';
import '/components/profile_widget.dart';
import '/components/qrcode_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'dashboard_widget.dart' show DashboardWidget;
import 'package:badges/badges.dart' as badges;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class DashboardModel extends FlutterFlowModel<DashboardWidget> {
  // Status filter for transactions
  String selectedStatusFilter = 'all';

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
