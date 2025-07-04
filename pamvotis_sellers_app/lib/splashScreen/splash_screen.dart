import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pamvotis_sellers_app/authentication/auth_screen.dart';
import 'package:pamvotis_sellers_app/global/global.dart';
import 'package:pamvotis_sellers_app/mainScreens/home_screen.dart';



class MySplashScreen extends StatefulWidget {
  const MySplashScreen({super.key});

  @override
  State<MySplashScreen> createState() => _MySplashScreenState();
}



class _MySplashScreenState extends State<MySplashScreen> {
  
  startTimer(){

    Timer(const Duration(seconds: 4), () async {
      // if seller is logged in
      if(firebaseAuth.currentUser != null){
        Navigator.push(context, MaterialPageRoute(builder: (c) => const HomeScreen()));
      }
      // if seller is NOT logged in
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
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              //mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Image.asset(
                      "images/logo.png",
                      width: MediaQuery.of(context).size.width * .80, // Set your desired width
                      // or use height: 200, // Set your desired height
                    ),
                  ),
                ),
                //const SizedBox(height: 10,),
                const Padding(
                  padding: EdgeInsets.all(18.0),
                  child: Text(
                    "Sellers App",
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
      ),
    );
  }
}
