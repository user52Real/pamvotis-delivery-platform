import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pamvotis_users_web/global/global.dart';
import '../authentication/auth_screen.dart';
import '../mainScreens/home_screen.dart';

class MySplashScreen extends StatefulWidget {
  const MySplashScreen({super.key});

  @override
  State<MySplashScreen> createState() => _MySplashScreenState();
}

class _MySplashScreenState extends State<MySplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
    _checkUserStatus();
  }

  void _initializeAnimation() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeIn)
    );

    _controller.forward();
  }

  Future<void> _checkUserStatus() async {
    _timer = Timer(const Duration(seconds: 3), () async {
      if (!mounted) return;

      try {
        final currentUser = firebaseAuth.currentUser;

        if (currentUser == null) {
          _navigateToScreen(const AuthScreen());
          return;
        }

        // Check user status in Firestore
        final userDoc = await FirebaseFirestore.instance
            .collection("users")
            .doc(currentUser.uid)
            .get();

        if (!mounted) return;

        if (!userDoc.exists || userDoc.data() == null) {
          await firebaseAuth.signOut();
          _navigateToScreen(const AuthScreen());
          return;
        }

        final userData = userDoc.data()!;
        if (userData["status"] != "approved") {
          await firebaseAuth.signOut();
          _navigateToScreen(const AuthScreen());
          return;
        }

        // User is approved, navigate to home
        _navigateToScreen(const HomeScreen());
      } catch (e) {
        debugPrint("Error during navigation: $e");
        if (!mounted) return;
        _navigateToScreen(const AuthScreen());
      }
    });
  }

  void _navigateToScreen(Widget screen) {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => screen,
        transitionDuration: const Duration(milliseconds: 500),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        color: Colors.white,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: LayoutBuilder(
              builder: (context, constraints) {
                double maxWidth = constraints.maxWidth > 600 ? 600 : constraints.maxWidth * 0.8;

                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        "images/logo.png",
                        width: maxWidth,
                        fit: BoxFit.contain,
                      ).animate()
                          .fadeIn(duration: 600.ms)
                          .scale(delay: 200.ms),
                      const SizedBox(height: 30),
                      const Text(
                        "Order food with ease",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 40,
                          fontFamily: "Lexend",
                          letterSpacing: 3,
                        ),
                      ).animate()
                          .fadeIn(delay: 300.ms)
                          .slideY(begin: 0.3, end: 0),
                    ],
                  ),
                );
              }
          ),
        ),
      ),
    );
  }
}