import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  bool isConnected = false;
  String error = '';
  
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
    isConnected = true;
    print("Firebase initialized successfully");
  } catch (e) {
    error = e.toString();
    print("Firebase initialization failed: $e");
  }

  runApp(FirebaseTestApp(isConnected: isConnected, error: error));
}

class FirebaseTestApp extends StatelessWidget {
  final bool isConnected;
  final String error;
  
  const FirebaseTestApp({super.key, required this.isConnected, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Connection Test',
      home: Scaffold(
        appBar: AppBar(title: const Text('Firebase Status')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isConnected ? Icons.check_circle : Icons.error,
                color: isConnected ? Colors.green : Colors.red,
                size: 80,
              ),
              const SizedBox(height: 16),
              Text(
                isConnected ? 'Firebase Connected!' : 'Firebase connection failed.',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              if (error.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    error,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
