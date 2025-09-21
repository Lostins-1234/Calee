import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iitropar/frequently_used.dart';
import 'package:iitropar/views/landing_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:iitropar/database/local_db.dart';
import 'firebase_options.dart';
import 'package:alarm/alarm.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:iitropar/views/PBTabView.dart';
import 'package:iitropar/views/signin.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:adaptive_theme/adaptive_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await requestNotificationPermission();
  await Alarm.init();
  await Firebase.initializeApp(
    name: 'calee-app',
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.playIntegrity,
  );
  await EventDB.startInstance();

  User? user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    user = await FirebaseAuth.instance.authStateChanges().first;
  }

  bool signin = (EventDB.firstRun() || user == null);
  if (!signin) {
    await Ids.resolveUser();
  }

  RootPage.signin(signin);
  final savedThemeMode = await AdaptiveTheme.getThemeMode();
  runApp(App(savedThemeMode: savedThemeMode));
}

Future<void> requestNotificationPermission() async {
  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }

  if (await Permission.notification.isGranted) {
    print("Notification permission granted");
  } else {
    print("Notification permission denied");
  }
}

// Function to handle alarm triggers
void _onAlarmTrigger(AlarmSettings alarmSettings) {
  print("Alarm Triggered at: ${alarmSettings.dateTime}");
  showAlarmNotification(alarmSettings);
}

// Function to show a notification when alarm rings
void showAlarmNotification(AlarmSettings alarmSettings) {
  print("Reminder: ${alarmSettings.notificationTitle}");
  print("Alarm Triggered at: ${alarmSettings.dateTime}");
}

class App extends StatelessWidget {
  final AdaptiveThemeMode? savedThemeMode;
  const App({super.key, this.savedThemeMode});

  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      light: _lightTheme,  // Updated Light Theme
      dark: _darkTheme,    // Updated Dark Theme
      initial: savedThemeMode ?? AdaptiveThemeMode.light,
      builder: (theme, darkTheme) => MaterialApp(
        key: ValueKey(savedThemeMode),  //  Forces rebuild on theme change
        title: 'IIT Ropar App',
        debugShowCheckedModeBanner: false,
        theme: theme,
        darkTheme: darkTheme,
        initialRoute: '/',
        home: const RootPage(),
      ),
    );
  }
}

final ThemeData _lightTheme = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: const Color(0xFFF2F2F2),
  fontFamily: 'Montserrat',
  colorScheme: const ColorScheme.light(
    primary: Color(0xFF666666),
    secondary: Color(0xFFD1D1D1),
    background: Color(0xFFF2F2F2),
    surface: Colors.white,
    onPrimary: Colors.white,
    onSecondary: Colors.black87,
    onBackground: Colors.black87,
    onSurface: Colors.black,
    error: Color(0xFFD64550),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    iconTheme: IconThemeData(color: Colors.black87),
  ),
  cardColor: Colors.white,
  shadowColor: Colors.grey.withOpacity(0.2),

  // ✅ Add this
  cardTheme: CardTheme(
    elevation: 0,
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
  expansionTileTheme: const ExpansionTileThemeData(
    collapsedBackgroundColor: Colors.transparent,
    backgroundColor: Colors.transparent,
    tilePadding: EdgeInsets.symmetric(horizontal: 16),
    childrenPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    iconColor: Colors.black87,
    collapsedIconColor: Colors.black54,
  ),
);



// Dark Theme
final ThemeData _darkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xFF121212),
  fontFamily: 'Montserrat',
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFFBBBBBB),
    secondary: Color(0xFF242424),
    background: Color(0xFF121212),
    surface: Color(0xFF1E1E1E),
    onPrimary: Color.fromARGB(255, 67, 67, 67),
    onSecondary: Colors.white,
    onBackground: Colors.white,
    onSurface: Colors.white70,
    error: Color(0xFFFF5252),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    iconTheme: IconThemeData(color: Colors.white),
  ),
  cardColor: const Color(0xFF1E1E1E),
  shadowColor: Colors.black.withOpacity(0.3),

  // Add this
  cardTheme: CardTheme(
    elevation: 0,
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
  expansionTileTheme: const ExpansionTileThemeData(
    collapsedBackgroundColor: Colors.transparent,
    backgroundColor: Colors.transparent,
    tilePadding: EdgeInsets.symmetric(horizontal: 16),
    childrenPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    iconColor: Colors.white,
    collapsedIconColor: Colors.white60,
  ),
);





