import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'core/app.dart';
import 'core/config/app_config.dart';
import 'services/database/database_service.dart';
import 'services/notification/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize timezone data for notifications
  tz.initializeTimeZones();
  
  // Initialize services
  await AppConfig.initialize();
  await DatabaseService.initialize();
  await NotificationService.initialize();
  
  runApp(
    const ProviderScope(
      child: LacoApp(),
    ),
  );
}