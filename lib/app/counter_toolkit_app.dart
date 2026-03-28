import 'package:counter_toolkit/app/app_metadata.dart';
import 'package:counter_toolkit/app/counter_toolkit_theme.dart';
import 'package:counter_toolkit/features/dashboard/presentation/dashboard_page.dart';
import 'package:counter_toolkit/features/stamps/data/default_stamp_catalog.dart';
import 'package:counter_toolkit/features/stamps/domain/best_fit_stamp_solver.dart';
import 'package:counter_toolkit/features/tracking/data/mock_tracking_service.dart';
import 'package:flutter/material.dart';

class CounterToolkitApp extends StatelessWidget {
  const CounterToolkitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appName,
      debugShowCheckedModeBanner: false,
      theme: buildCounterToolkitTheme(),
      home: const DashboardPage(
        trackingService: MockTrackingService(),
        stampSolver: BestFitStampSolver(defaultStampCatalog),
      ),
    );
  }
}
