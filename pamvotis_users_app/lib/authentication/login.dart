import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pamvotis_users_app/global/global.dart';
import 'package:pamvotis_users_app/mainScreens/home_screen.dart';
import 'package:pamvotis_users_app/widgets/custom_text_field.dart';
import 'package:pamvotis_users_app/widgets/error_dialog.dart';
import 'package:pamvotis_users_app/widgets/loading_dialog.dart';

import 'auth_screen.dart';
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

  formValidation(){
    if(emailController.text.isNotEmpty && passwordController.text.isNotEmpty){
      //login
      loginNow();
    }
    else {
      showDialog(
        context: context,
        builder: (c){
          return ErrorDialog(
            message: "Please write email/password",
          );
        }
      );
    }
  }

  loginNow() async {
    showDialog(
        context: context,
        builder: (c){
          return LoadingDialog(
            message: "Checking Credentials",
          );
        }
    );

    User? currentUser;
    await firebaseAuth.signInWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    ).then((auth){
      currentUser = auth.user!;
    }).catchError((error) {
      Navigator.pop(context);
      showDialog(
          context: context,
          builder: (c){
            return ErrorDialog(
              message: error.message.toString(),
            );
          }
      );
    });
    if(currentUser != null){
      readDataAndSetDataLocally(currentUser!);
    }
  }

  Future readDataAndSetDataLocally(User currentUser) async {
    await FirebaseFirestore.instance.collection("users").doc(currentUser.uid).get().then((snapshot) async {
      if(snapshot.exists){
        if(snapshot.data()!["status"] == "approved"){
          await sharedPreferences!.setString("uid", currentUser.uid);
          await sharedPreferences!.setString("email", snapshot.data()!["email"]);
          await sharedPreferences!.setString("name", snapshot.data()!["name"]);
          await sharedPreferences!.setString("photoUrl", snapshot.data()!["photoUrl"]);

          List<String> userCartList = snapshot.data()!["userCart"].cast<String>();
          await sharedPreferences!.setStringList("userCart", userCartList);

          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(builder: (c)=> const HomeScreen()));
        }
        else {
          firebaseAuth.signOut();
          Navigator.pop(context);
          Fluttertoast.showToast(msg: "Admin has blocked your account. \n\nContact: admin@admin.com");
        }
      }
      else {
        firebaseAuth.signOut();

        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (c)=> const AuthScreen()));

        showDialog(
            context: context,
            builder: (c){
              return ErrorDialog(
                message: "No record found!",
              );
            }
        );
      }

    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Image.asset(
                "images/logo.png",
                height: 250,
              ),
            ),
          ),
          Form(
            key: _formKey,
            child: Column(
              children: [
                CustomTextField(
                  data: Icons.email,
                  controller: emailController,
                  hintText: "Email",
                  isObsecre: false,
                ),
                CustomTextField(
                  data: Icons.lock,
                  controller: passwordController,
                  hintText: "Password",
                  isObsecre: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 40,),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow,
                padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 10)
            ),
            onPressed: () {
              formValidation();
            },
            child: const Text(
              "Login",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,),
            ),
          ),
          const SizedBox(height: 10,),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10)
            ),
            onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (c) => const ForgotPasswordScreen()));
            },
            child: const Text(
              "Forgot Password ?",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,),
            ),
          ),
          const SizedBox(height: 30,),
        ],
      ),
    );
  }
}
