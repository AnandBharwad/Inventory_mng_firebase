import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:online_database_firebase/A_Firebase/auth/fb_login.dart';
import 'package:online_database_firebase/A_Firebase/auth/fb_registration.dart';
import 'package:online_database_firebase/firebase_options.dart';

void main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FbForm(),
    );
  }
}
