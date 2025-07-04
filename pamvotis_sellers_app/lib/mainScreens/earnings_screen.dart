import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pamvotis_sellers_app/global/global.dart';
import 'package:pamvotis_sellers_app/mainScreens/home_screen.dart';

class EarningsScreen extends StatefulWidget {


  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}



class _EarningsScreenState extends State<EarningsScreen> {
  double sellerTotalEarnings = 0;

  retrieveSellerEarnings() async {
    await FirebaseFirestore.instance
        .collection("sellers")
        .doc(sharedPreferences!.getString("uid"))
        .get().then((snap){
          setState(() {
            sellerTotalEarnings = double.parse(snap.data()!["earnings"].toString());
          });
        });
  }

  @override
  void initState() {
    super.initState();

    retrieveSellerEarnings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                 "€ " + sellerTotalEarnings.toString(),
                  style: const TextStyle(
                    fontSize: 80.0,
                    color: Colors.white,
                  ),
                ),
                const Text(
                  "Total Earnings ",
                  style: TextStyle(
                    fontSize: 20.0,
                    color: Colors.blueGrey,
                    letterSpacing: 3,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 20,
                  width: 200,
                  child: Divider(
                    color: Colors.white,
                    thickness: 2,
                  ),
                ),

                const SizedBox(height: 40.0,),
                GestureDetector(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (c) => const HomeScreen()));
                  },
                  child: const Card(
                    color: Colors.white54,
                    margin: EdgeInsets.symmetric(vertical: 40, horizontal: 140),
                    child: ListTile(
                      leading: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                      title: Text(
                        "Back",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
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
