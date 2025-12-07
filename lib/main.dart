import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:oxford_focus/core/theme/app_theme.dart';
import 'package:oxford_focus/data/services/notification_service.dart';
import 'package:oxford_focus/ui/screens/dashboard_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Removed Firebase.initializeApp();
  
  // Initialize Hive - Still used implicitly by HiveFlutter if we use it elsewhere?
  // We removed explicit Hive usage in providers, but keeping it if other parts use it.
  // Assuming no other parts use it for now given the context, but safe to keep init or remove.
  // User asked for SQLite. I'll keep Hive init just in case `notification_service` or others use it, 
  // but looking at directory structure, likely not.
  // Actually, I'll keep it to avoid breaking unseen code, but it's likely redundant.
  await Hive.initFlutter();
  
  // Init Notifications
  await NotificationService().init();
  NotificationService().scheduleDailyReminder();
  
  runApp(
    const ProviderScope(
      child: OxfordFocusApp(),
    ),
  );
}

class OxfordFocusApp extends StatelessWidget {
  const OxfordFocusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Oxford Focus',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const DashboardScreen(),
    );
  }
}
