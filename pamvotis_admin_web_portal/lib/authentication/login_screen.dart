import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pamvotis_admin_web_portal/main_screen/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  String adminEmail = "";
  String adminPassword = "";

  allowAdminToLogin() async {

    SnackBar snackBar = const SnackBar(
      content: Text(
        "Checking Credentials, Please Wait: ",
        style: TextStyle(
          fontSize: 36,
          color: Colors.black,
        ),
      ),
      backgroundColor: Colors.yellow,
      duration: Duration(seconds: 2),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);

    User? currentAdmin;
    await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: adminEmail,
        password: adminPassword,
    ).then((fAuth){
      //success
      currentAdmin =  fAuth.user;
    }).catchError((onError){
      //in case of error
      //display header message
      final snackBar = SnackBar(
        content: Text(
          "Error Occured: " + onError.toString(),
          style: const TextStyle(
            fontSize: 36,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.yellow,
        duration: const Duration(seconds: 5),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    });

    if(currentAdmin != null){
      // check if that admin record exists in the admins collection in firestore database
      await FirebaseFirestore.instance
          .collection("admins")
          .doc(currentAdmin!.uid)
          .get().then((snap){
            if(snap.exists){
              Navigator.push(context, MaterialPageRoute(builder: (c) => const HomeScreen()));
            }
            else{
              SnackBar snackBar = const SnackBar(
                content: Text(
                  "No record found. Please, Contact Administrator. ",
                  style: TextStyle(
                    fontSize: 36,
                    color: Colors.black,
                  ),
                ),
                backgroundColor: Colors.yellow,
                duration: Duration(seconds: 6),
              );
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            }
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * .5,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //image
                  Image.asset(
                    "images/logo.png"
                  ),

                  const SizedBox(height: 40,),

                  //email text field
                  TextField(
                    onChanged: (value){
                      adminEmail = value;
                    },
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                    decoration: const InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.blueAccent,
                          width: 2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.yellow,
                          width: 2,
                        ),
                      ),
                      hintText: "Email",
                      hintStyle: TextStyle(
                        color: Colors.white,
                      ),
                      icon: Icon(
                        Icons.email,
                        color: Colors.blue,
                        size: 40,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20,),

                  //password text field
                  TextField(
                    onChanged: (value){
                      adminPassword = value;
                    },
                    obscureText: true,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                    decoration: const InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.blueAccent,
                          width: 2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.yellow,
                          width: 2,
                        ),
                      ),
                      hintText: "Password",
                      hintStyle: TextStyle(
                        color: Colors.white,
                      ),
                      icon: Icon(
                        Icons.password,
                        color: Colors.blue,
                        size: 40,
                      ),
                    ),
                  ),

                  const SizedBox(height: 50,),

                  // Button login
                  ElevatedButton(
                    onPressed: (){
                      allowAdminToLogin();
                    },
                    style: ButtonStyle(
                      padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 100, vertical: 20)),
                      backgroundColor: WidgetStateProperty.all<Color>(Colors.blue),
                      foregroundColor: WidgetStateProperty.all<Color>(Colors.yellow),
                    ),
                    child: const Text(
                      "Login",
                      style: TextStyle(
                        color: Colors.white,
                        letterSpacing: 2,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
