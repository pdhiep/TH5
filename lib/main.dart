import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'screens/main/splash_screen.dart';
import 'services/database_service.dart';
import 'services/auth_service.dart';
import 'services/theme_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    if (kIsWeb) {
      // Configuration for thuchanh5-89077
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyD0__87wT1FhwXPC208sb1QSxbtwATioPY",
          authDomain: "thuchanh5-89077.firebaseapp.com",
          projectId: "thuchanh5-89077",
          storageBucket: "thuchanh5-89077.firebasestorage.app",
          messagingSenderId: "273945897778",
          appId: "1:273945897778:web:48a1c977918e950761052b",
        ),
      );
    } else {
      await Firebase.initializeApp();
    }
    print("Firebase initialized successfully");
  } catch (e) {
    print("Firebase initialization failed: $e");
  }
  
  runApp(
    MultiProvider(
      providers: [
        Provider<DatabaseService>(create: (_) => DatabaseService()),
        Provider<AuthService>(create: (_) => AuthService()),
        ChangeNotifierProvider<ThemeService>(create: (_) => ThemeService()),
      ],
      child: const StudentManagerApp(),
    ),
  );
}

class StudentManagerApp extends StatelessWidget {
  const StudentManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        return MaterialApp(
          title: 'Student Manager',
          debugShowCheckedModeBanner: false,
          theme: ThemeService.lightTheme,
          darkTheme: ThemeService.darkTheme,
          themeMode: themeService.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: const SplashScreen(),
        );
      },
    );
  }
}
