import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'services/auth_service.dart';
import 'services/theme_service.dart';
import 'main/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    if (kIsWeb) {
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
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => ThemeService()),
      ],
      child: const StudentManagerApp(),
    ),
  );
}

class StudentManagerApp extends StatelessWidget {
  const StudentManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);
    
    return MaterialApp(
      title: 'Student Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1D61E7),
          brightness: themeService.isDarkMode ? Brightness.dark : Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
