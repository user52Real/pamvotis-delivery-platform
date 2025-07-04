import 'dart:async';

import 'package:flutter/material.dart';
import '../authentication/auth_screen.dart';
import '../mainScreens/home_screen.dart';

import '../global/global.dart';



class MySplashScreen extends StatefulWidget {
  const MySplashScreen({super.key});

  @override
  State<MySplashScreen> createState() => _MySplashScreenState();
}



class _MySplashScreenState extends State<MySplashScreen> {
  
  startTimer(){

    Timer(const Duration(seconds: 4), () async {
      // if rider is logged in
      if(firebaseAuth.currentUser != null){
        Navigator.push(context, MaterialPageRoute(builder: (c) => const HomeScreen()));
      }
      // if rider is NOT logged in
      else {
        Navigator.push(context, MaterialPageRoute(builder: (c) => const AuthScreen()));
      }
    });
  }

  @override
  void initState() {
    super.initState();

    startTimer();
  }
  
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Image.asset("images/logo1.png"),
              ),
              const SizedBox(height: 10,),
              const Padding(
                padding: EdgeInsets.all(18.0),
                child: Text(
                  "Riders App",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 40,
                    fontFamily: "Lexend",
                    letterSpacing: 3,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
