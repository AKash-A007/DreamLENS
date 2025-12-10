import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/dashboard_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(const DreamLensApp());
}

class DreamLensApp extends StatelessWidget {
  const DreamLensApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DreamLENS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.black,
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Color(0xFF00FF00),
          elevation: 0,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFF00FF00), fontSize: 12),
          bodyMedium: TextStyle(color: Color(0xFF00FF00), fontSize: 11),
          bodySmall: TextStyle(color: Color(0xFF008800), fontSize: 10),
        ),
      ),
      home: const DashboardScreen(),
    );
  }
}