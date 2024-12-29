import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../assistant_methods/get_current_location.dart';
import '../authentication/auth_screen.dart';
import '../global/global.dart';
import '../mainScreens/earnings_screen.dart';
import '../mainScreens/new_orders_screen.dart';
import '../mainScreens/history_screen.dart';
import '../mainScreens/not_yet_delivered_screen.dart';
import '../mainScreens/order_in_progress_screen.dart';

import '../splashScreen/splash_screen.dart';



class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  Card makeDashboardItem(String title, IconData iconData, int index){
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(8),
      child: Container(
        decoration: index == 0 || index == 3 || index == 4
            ? const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.blue,
                Colors.blue,
              ],
              begin: FractionalOffset(0.0, 0.0),
              end: FractionalOffset(1.0, 0.0),
              stops: [0.0, 1.0],
              tileMode: TileMode.clamp,
            )
        ) : const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.blueAccent,
                Colors.blueAccent,
              ],
              begin: FractionalOffset(0.0, 0.0),
              end: FractionalOffset(1.0, 0.0),
              stops: [0.0, 1.0],
              tileMode: TileMode.clamp,
            )
        ),
        child: InkWell(
          onTap: (){
            if(index == 0) {
              //New Available Orders
              Navigator.push(context, MaterialPageRoute(builder: (c) => NewOrdersScreen()));
            }
            if(index == 1) {
              //Order in Progress
              Navigator.push(context, MaterialPageRoute(builder: (c) => OrderInProgress()));
            }
            if(index == 2) {
              //Not yet delivered
              Navigator.push(context, MaterialPageRoute(builder: (c) => NotYetDeliveredScreen()));
            }
            if(index == 3) {
              //History
              Navigator.push(context, MaterialPageRoute(builder: (c) => HistoryScreen()));
            }
            if(index == 4) {
              //Total earning
              Navigator.push(context, MaterialPageRoute(builder: (c) => EarningsScreen()));
            }
            if(index == 5) {
              //Logout
              firebaseAuth.signOut().then((value) {
                Navigator.push(context, MaterialPageRoute(builder: (c) => const AuthScreen()));
              });
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            verticalDirection: VerticalDirection.down,
            children: [
              const SizedBox(height: 50,),
              Center(
                child: Icon(
                  iconData,
                  size: 40,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20,),
              Center(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  restrictBlockedRiders() async {
    await FirebaseFirestore.instance
        .collection("riders")
        .doc(firebaseAuth.currentUser!.uid)
        .get().then((snapshot){
      if(snapshot.data()!["status"] != "approved"){
        Fluttertoast.showToast(msg: "You have been blocked by the Administrator");

        firebaseAuth.signOut();
        Navigator.push(context, MaterialPageRoute(builder: (c) => const MySplashScreen()));
      }
      else{
        UserLocation? uLocation = UserLocation();
        uLocation.getCurrentLocation();
        getPerOrderDeliveryAmount();
        getRiderPreviousEarnings();
      }
    });
  }

  @override
  void initState() {
    super.initState();

    restrictBlockedRiders();
  }

  getRiderPreviousEarnings(){
    FirebaseFirestore.instance
        .collection("riders")
        .doc(sharedPreferences!.getString("uid"))
        .get()
        .then((snap){
          previousRiderEarnings =  snap.data()!["earnings"].toString();
        });
  }
  
  getPerOrderDeliveryAmount(){
    FirebaseFirestore.instance
        .collection("perDelivery")
        .doc("alani4837")
        .get().then((snap) {
          perOrderDeliveryAmount = snap.data()!["amount"].toString();
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blue,
                  Colors.blue,
                ],
                begin: FractionalOffset(0.0, 0.0),
                end: FractionalOffset(1.0, 0.0),
                stops: [0.0, 1.0],
                tileMode: TileMode.clamp,
              )
          ),
        ),
        title: Text(
          "Welcome " +
          sharedPreferences!.getString("name")!,
          style: const TextStyle(
            fontSize: 24.0,
            color: Colors.white,
            fontFamily: "Lexend",
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 50.0, horizontal: 1.0),
        child: GridView.count(
          crossAxisCount: 2,
          padding: const EdgeInsets.all(2),
          children: [
            makeDashboardItem("New Available Orders", Icons.assignment, 0),
            makeDashboardItem("Order in Progress", Icons.airport_shuttle, 1),
            makeDashboardItem("Not Yet Delivered", Icons.location_history, 2),
            makeDashboardItem("History", Icons.history, 3),
            makeDashboardItem("Total Earnings", Icons.monetization_on, 4),
            makeDashboardItem("Logout", Icons.logout, 5),
          ],
        ),
      ),
    );
  }
}
