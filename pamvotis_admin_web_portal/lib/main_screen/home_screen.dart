import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pamvotis_admin_web_portal/authentication/login_screen.dart';
import 'package:pamvotis_admin_web_portal/riders/all_blocked_riders_screen.dart';
import 'package:pamvotis_admin_web_portal/riders/all_verified_riders_screen.dart';
import 'package:pamvotis_admin_web_portal/sellers/all_blocked_sellers_screen.dart';
import 'package:pamvotis_admin_web_portal/sellers/all_verified_sellers.screen.dart';
import 'package:pamvotis_admin_web_portal/users/all_blocked_users_screen.dart';
import 'package:pamvotis_admin_web_portal/users/all_verified_users_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  String timeText = "";
  String dateText = "";

  String formatCurrentLiveTime(DateTime time){
    return DateFormat("hh:mm:ss a").format(time);
  }

  String formatCurrentDate(DateTime date){
    return DateFormat("dd MMMM, yyyy").format(date);
  }


  getCurrentLiveTime(){
    final DateTime timeNow = DateTime.now();
    final String liveTime = formatCurrentLiveTime(timeNow);
    final String liveDate = formatCurrentDate(timeNow);

    if(this.mounted){
      setState(() {
        timeText =  liveTime;
        dateText = liveDate;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    //Time
    timeText = formatCurrentLiveTime(DateTime.now());

    //Date
    dateText = formatCurrentDate(DateTime.now());

    Timer.periodic(const Duration(seconds: 1), (timer) {
      getCurrentLiveTime();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.yellow,
                Colors.blue,
              ],
              begin: FractionalOffset(0, 0),
              end: FractionalOffset(1, 0),
              stops: [0, 1],
              tileMode: TileMode.clamp,
            ),
          ),
        ),
        title: const Text(
          "Admin Web Portal",
          style: TextStyle(
            fontSize: 20,
            letterSpacing: 3,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [

            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                timeText + "\n" + dateText,
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  letterSpacing: 3,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            //User activate and block account buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //activate
                ElevatedButton.icon(
                  icon: const Icon(Icons.person_add, color: Colors.white,),
                  label: Text(
                    "All Verified Users".toUpperCase() + "\n"  + "Accounts".toUpperCase(),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.blue,
                      letterSpacing: 3,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(40),
                    backgroundColor: Colors.yellow,
                  ),
                  onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (c) => const AllVerifiedUsersScreen()));
                  },
                ),

                const SizedBox(width: 20,),

                //block
                ElevatedButton.icon(
                  icon: const Icon(Icons.block_flipped, color: Colors.white,),
                  label: Text(
                    "All Blocked Users".toUpperCase() + "\n"  + "Accounts".toUpperCase(),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      letterSpacing: 3,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(40),
                    backgroundColor: Colors.blue,
                  ),
                  onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (c) => const AllBlockedUsersScreen()));
                  },
                ),
              ],
            ),

            //Sellers activate and block account buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //activate
                ElevatedButton.icon(
                  icon: const Icon(Icons.person_add, color: Colors.white,),
                  label: Text(
                    "All Verified Sellers".toUpperCase() + "\n"  + "Accounts".toUpperCase(),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      letterSpacing: 3,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(40),
                    backgroundColor: Colors.blue,
                  ),
                  onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (c) => const AllVerifiedSellersScreen()));
                  },
                ),

                const SizedBox(width: 20,),

                //block
                ElevatedButton.icon(
                  icon: const Icon(Icons.block_flipped, color: Colors.white,),
                  label: Text(
                    "All Blocked Sellers".toUpperCase() + "\n"  + "Accounts".toUpperCase(),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.lightBlueAccent,
                      letterSpacing: 3,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(40),
                    backgroundColor: Colors.yellow,
                  ),
                  onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (c) => const AllBlockedSellersScreen()));
                  },
                ),
              ],
            ),

            // Riders Activate and block account buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //activate
                ElevatedButton.icon(
                  icon: const Icon(Icons.person_add, color: Colors.white,),
                  label: Text(
                    "All Verified Riders".toUpperCase() + "\n"  + "Accounts".toUpperCase(),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      letterSpacing: 3,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(40),
                    backgroundColor: Colors.yellow,
                  ),
                  onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (c) => const AllVerifiedRidersScreen()));
                  },
                ),

                const SizedBox(width: 20,),

                //block
                ElevatedButton.icon(
                  icon: const Icon(Icons.block_flipped, color: Colors.white,),
                  label: Text(
                    "All Blocked Riders".toUpperCase() + "\n"  + "Accounts".toUpperCase(),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      letterSpacing: 3,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(40),
                    backgroundColor: Colors.blue,
                  ),
                  onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (c) => const AllBlockedRidersScreen()));
                  },
                ),
              ],
            ),

            // Logout Button for Admin
            ElevatedButton.icon(
              icon: const Icon(Icons.logout, color: Colors.white,),
              label: Text(
                "Logout".toUpperCase(),
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  letterSpacing: 3,
                ),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(40),
                backgroundColor: Colors.blueGrey,
              ),
              onPressed: (){
                FirebaseAuth.instance.signOut();
                Navigator.push(context, MaterialPageRoute(builder: (c) => const LoginScreen()));
              },
            ),
          ],
        ),
      ),
    );
  }
}
