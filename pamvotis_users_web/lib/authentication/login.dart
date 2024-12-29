import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../utils/rate_limiter.dart';
import '/global/global.dart';
import '/mainScreens/home_screen.dart';
import '/widgets/custom_text_field.dart';
import '/widgets/error_dialog.dart';
import '/widgets/loading_dialog.dart';
import 'forgot_password.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Future<void> formValidation() async {
    if (emailController.text.isNotEmpty && passwordController.text.isNotEmpty) {
      await loginNow();
    } else {
      showDialog(
        context: context,
        builder: (c) => ErrorDialog(
          message: "Please write email/password",
        ),
      );
    }
  }

  Future<void> loginNow() async {
    if (!RateLimiter.shouldAllowLogin(emailController.text)) {
      final remainingTime = RateLimiter.getRemainingLockoutTime(emailController.text);
      showDialog(
        context: context,
        builder: (c) => ErrorDialog(
          message: "Too many login attempts. Please try again in ${remainingTime!.inMinutes} minutes.",
        ),
      );
      return;
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => LoadingDialog(
        message: "Checking Credentials",
      ),
    );

    try {
      // Attempt login
      final userCredential = await firebaseAuth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Check if login was successful
      if (userCredential.user == null) {
        throw Exception('Login failed - no user returned');
      }

      await readDataAndSetDataLocally(userCredential.user!);
      UserSession.updateLastActivity();
    } catch (error) {
      if (!mounted) return;
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (c) => ErrorDialog(message: error.toString()),
      );
    }
  }

  // lib/authentication/login.dart
  Future<void> readDataAndSetDataLocally(User currentUser) async {
    try {
      // First, verify SharedPreferences is initialized
      if (sharedPreferences == null) {
        await initializeSharedPreferences();
      }

      final snapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUser.uid)
          .get();

      if (!snapshot.exists || snapshot.data() == null) {
        throw Exception('User data not found');
      }

      // Safely create user model with null checks
      final userData = snapshot.data()!;
      final userModel = UserModel(
        uid: userData['uid'] ?? currentUser.uid,
        email: userData['email'] ?? currentUser.email ?? '',
        name: userData['name'] ?? '',
        photoUrl: userData['photoUrl'] ?? '',
        status: userData['status'] ?? 'pending',
        userCart: List<String>.from(userData['userCart'] ?? ['garbageValue']),
      );

      // Validate user status
      if (userModel.status != "approved") {
        await firebaseAuth.signOut();
        throw Exception('Account not approved. Please contact support.');
      }

      // Save to SharedPreferences with null checks
      await Future.wait([
        sharedPreferences!.setString("uid", userModel.uid),
        sharedPreferences!.setString("email", userModel.email),
        sharedPreferences!.setString("name", userModel.name),
        sharedPreferences!.setString("photoUrl", userModel.photoUrl),
        sharedPreferences!.setStringList("userCart", userModel.userCart),
      ]);

      if (!mounted) return;

      Navigator.pop(context); // Remove loading dialog
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (c) => const HomeScreen()),
      );
    } catch (error) {
      if (!mounted) return;
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (c) => ErrorDialog(
          message: "Login failed: ${error.toString()}",
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo
        Container(
          constraints: const BoxConstraints(maxHeight: 120),
          child: Image.asset(
            "images/logo.png",
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 20),

        // Form
        Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                data: Icons.email,
                controller: emailController,
                hintText: "Email",
                isObsecre: false,
              ),
              const SizedBox(height: 10),
              CustomTextField(
                data: Icons.lock,
                controller: passwordController,
                hintText: "Password",
                isObsecre: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Login Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: formValidation,
            child: const Text(
              "Login",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Forgot Password Button
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (c) => const ForgotPasswordScreen()),
            );
          },
          child: const Text(
            "Forgot Password?",
            style: TextStyle(
              color: Colors.blue,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}