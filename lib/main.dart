import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:oxford_focus/core/theme/app_theme.dart';
import 'package:oxford_focus/data/services/notification_service.dart';
import 'package:oxford_focus/ui/screens/onboarding_screen.dart';
import 'package:oxford_focus/ui/shell/main_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  // Init Notifications
  await NotificationService().init();
  NotificationService().scheduleDailyReminder();

  // Check if onboarding has been completed
  final prefs = await SharedPreferences.getInstance();
  final onboardingDone = prefs.getBool('onboarding_done') ?? false;

  runApp(
    ProviderScope(
      child: OxfordFocusApp(showOnboarding: !onboardingDone),
    ),
  );
}

class OxfordFocusApp extends StatelessWidget {
  final bool showOnboarding;
  const OxfordFocusApp({super.key, required this.showOnboarding});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Oxford Focus',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: showOnboarding ? const OnboardingScreen() : const MainShell(),
    );
  }
}
