import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:pamvotis_admin_web_portal/authentication/login_screen.dart';
import 'package:pamvotis_admin_web_portal/main_screen/home_screen.dart';

Future<void> main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  //
  //
  // if(kIsWeb){
  //   await Firebase.initializeApp(
  //       name: 'Admin Web Panel',
  //       options: const FirebaseOptions(
  //           apiKey: "",
  //           authDomain: "",
  //           projectId: "",
  //           storageBucket: "",
  //           messagingSenderId: "",
  //           appId: "",
  //           measurementId: ""
  //       )
  //   );
  // }
  // else {
  //   await Firebase.initializeApp();
  // }
  // sharedPreferences = await SharedPreferences.getInstance();
  // runApp(const MyApp());

  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "",
          authDomain: "",
          projectId: "",
          storageBucket: "",
          messagingSenderId: "",
          appId: "",
          measurementId: ""));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pamvotis Admin Web Portal',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: FirebaseAuth.instance.currentUser == null
          ? const LoginScreen()
          : const HomeScreen(),
    );
  }
}
