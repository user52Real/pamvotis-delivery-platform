import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as f_storage;
import '../models/user_model.dart';
import '/global/global.dart';
import '/mainScreens/home_screen.dart';
import '/widgets/custom_text_field.dart';
import '/widgets/error_dialog.dart';
import '/widgets/loading_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  XFile? imageXFile;
  Uint8List? webImage;
  final ImagePicker _picker = ImagePicker();
  String sellerImageUrl = "";

  Future<void> _getImage() async {
    if (kIsWeb) {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
      );
      if (image != null) {
        var f = await image.readAsBytes();
        setState(() {
          webImage = f;
          imageXFile = image;
        });
      }
    } else {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
      );
      if (image != null) {
        setState(() {
          imageXFile = image;
        });
      }
    }
  }

  Future<void> formValidation() async {
    if (imageXFile == null) {
      showDialog(
          context: context,
          builder: (c) {
            return ErrorDialog(
              message: "Please select an image",
            );
          }
      );
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      showDialog(
          context: context,
          builder: (c) {
            return ErrorDialog(
              message: "Passwords do not match.",
            );
          }
      );
      return;
    }

    if (confirmPasswordController.text.isNotEmpty &&
        emailController.text.isNotEmpty &&
        nameController.text.isNotEmpty) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (c) {
            return LoadingDialog(
              message: "Registering Account",
            );
          }
      );

      await uploadImageAndRegister();
    } else {
      showDialog(
          context: context,
          builder: (c) {
            return ErrorDialog(
              message: "Please fill all the required fields.",
            );
          }
      );
    }
  }

  Future<void> uploadImageAndRegister() async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      f_storage.Reference reference = f_storage.FirebaseStorage.instance
          .ref()
          .child("users")
          .child(fileName);

      f_storage.UploadTask uploadTask;
      if (kIsWeb) {
        uploadTask = reference.putData(webImage!);
      } else {
        uploadTask = reference.putFile(File(imageXFile!.path));
      }

      f_storage.TaskSnapshot taskSnapshot = await uploadTask;
      sellerImageUrl = await taskSnapshot.ref.getDownloadURL();

      // Register user
      await authenticateAndRegister();
    } catch (e) {
      Navigator.pop(context);
      showDialog(
          context: context,
          builder: (c) {
            return ErrorDialog(
              message: e.toString(),
            );
          }
      );
    }
  }

  Future<void> authenticateAndRegister() async {
    try {
      UserCredential userCredential = await firebaseAuth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (userCredential.user != null) {
        // Send email verification
        await userCredential.user!.sendEmailVerification();

        await saveDataToFirestore(userCredential.user!);

        // Show verification dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (c) => AlertDialog(
            title: const Text('Verify Your Email'),
            content: const Text(
                'A verification email has been sent to your email address. Please verify your email before continuing.'
            ),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.pop(context);
                  firebaseAuth.signOut();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (c) => const AuthScreen()),
                  );
                },
              ),
            ],
          ),
        );
      }
    } catch (error) {
      Navigator.pop(context);
      showDialog(
          context: context,
          builder: (c) {
            return ErrorDialog(
              message: error.toString(),
            );
          }
      );
    }
  }

  Future<void> saveDataToFirestore(User currentUser) async {
    final userModel = UserModel(
      uid: currentUser.uid,
      email: currentUser.email ?? '',
      name: nameController.text.trim(),
      photoUrl: sellerImageUrl,
      status: "approved",
      userCart: ['garbageValue'],
    );

    // Save to Firestore
    await FirebaseFirestore.instance
        .collection("users")
        .doc(currentUser.uid)
        .set(userModel.toFirestore());

    // Save locally
    sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences!.setString("uid", currentUser.uid);
    await sharedPreferences!.setString("email", currentUser.email ?? '');
    await sharedPreferences!.setString("name", nameController.text.trim());
    await sharedPreferences!.setString("photoUrl", sellerImageUrl);
    await sharedPreferences!.setStringList("userCart", ['garbageValue']);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          constraints: const BoxConstraints(maxHeight: 120),
          child: Image.asset(
            "images/logo.png",
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 20),
        // Profile Image Picker
        InkWell(
          onTap: _getImage,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(2),
            child: CircleAvatar(
              radius: 45,
              backgroundColor: Colors.white,
              backgroundImage: _getImageProvider(),
              child: _buildImagePlaceholder(),
            ),
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
                data: Icons.person,
                controller: nameController,
                hintText: "Name",
                isObsecre: false,
              ),
              const SizedBox(height: 10),
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
              const SizedBox(height: 10),
              CustomTextField(
                data: Icons.lock,
                controller: confirmPasswordController,
                hintText: "Confirm Password",
                isObsecre: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Register Button
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
              "Register",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  ImageProvider? _getImageProvider() {
    if (kIsWeb) {
      if (webImage != null) {
        return MemoryImage(webImage!);
      }
    } else {
      if (imageXFile != null) {
        return FileImage(File(imageXFile!.path));
      }
    }
    return null;
  }

  Widget? _buildImagePlaceholder() {
    if ((kIsWeb && webImage == null) || (!kIsWeb && imageXFile == null)) {
      return const Icon(
        Icons.add_photo_alternate,
        size: 40,
        color: Colors.grey,
      );
    }
    return null;
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}