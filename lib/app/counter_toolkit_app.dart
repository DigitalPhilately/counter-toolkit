import 'package:counter_toolkit/app/counter_toolkit_theme.dart';
import 'package:counter_toolkit/features/dashboard/presentation/dashboard_page.dart';
import 'package:counter_toolkit/features/tracking/data/mock_tracking_service.dart';
import 'package:flutter/material.dart';

class CounterToolkitApp extends StatelessWidget {
  const CounterToolkitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Counter Toolkit',
      debugShowCheckedModeBanner: false,
      theme: buildCounterToolkitTheme(),
      home: const DashboardPage(trackingService: MockTrackingService()),
    );
  }
}
