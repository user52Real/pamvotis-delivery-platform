
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../splashScreen/splash_screen.dart';

import '../assistant_methods/get_current_location.dart';
import '../global/global.dart';
import '../maps/map_utils.dart';

class OrderDeliveringScreen extends StatefulWidget {

  String? purchaserId;
  String? purchaserAddress;
  double? purchaserLat;
  double? purchaserLng;
  String? sellerId;
  String? getOrderId;

  OrderDeliveringScreen({
    this.purchaserId,
    this.purchaserAddress,
    this.purchaserLat,
    this.purchaserLng,
    this.sellerId,
    this.getOrderId,
  });

  @override
  State<OrderDeliveringScreen> createState() => _OrderDeliveringScreenState();
}

class _OrderDeliveringScreenState extends State<OrderDeliveringScreen> {

  String orderTotalAmount = "";

  confirmOrderHasBeenDelivered(getOrderId, sellerId, purchaserId, purchaserAddress, purchaserLat, purchaserLng){
    String riderNewTotalEarningAmount = ((double.parse(previousRiderEarnings)) + (double.parse(perOrderDeliveryAmount))).toString();

    FirebaseFirestore.instance
        .collection("orders")
        .doc(getOrderId).update({
      "status": "ended",
      "address": completeAddress,
      "lat": position!.latitude,
      "lng": position!.longitude,
      "earnings": perOrderDeliveryAmount, //pay per order delivery
    }).then((value){
        FirebaseFirestore.instance
            .collection("riders")
            .doc(sharedPreferences!.getString("uid"))
            .update({
              "earnings": riderNewTotalEarningAmount, //total earnings of riders
            });
      }).then((value){
          FirebaseFirestore.instance
              .collection("sellers")
              .doc(widget.sellerId)
              .update({
                "earnings": (double.parse(orderTotalAmount) + (double.parse(previousEarnings))).toString(), //total earnings of seller
              });
      }).then((value){
          FirebaseFirestore.instance
              .collection("users")
              .doc(purchaserId)
              .collection("orders")
              .doc(getOrderId)
              .update({
                "status": "ended",
                "riderUID": sharedPreferences!.getString("uid"),
              });
      });
    Navigator.push(context, MaterialPageRoute(builder: (c) => const MySplashScreen()));
  }

  getOrderTotalAmount(){
    FirebaseFirestore.instance
        .collection("orders")
        .doc(widget.getOrderId)
        .get()
        .then((snap){
          orderTotalAmount = snap.data()!["totalAmount"].toString();
          widget.sellerId = snap.data()!["sellerUID"];
        }).then((value){
          getSellerData();
        });
  }

  getSellerData(){
    FirebaseFirestore.instance
        .collection("sellers")
        .doc(widget.sellerId)
        .get()
        .then((snap){
          previousEarnings = snap.data()!["earnings"].toString();
        });
  }

  @override
  void initState() {
    super.initState();

    //rider location update
    UserLocation uLocation = UserLocation();
    uLocation.getCurrentLocation();

    getOrderTotalAmount();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            "images/confirm2.png",
            width: 350,
          ),

          const SizedBox(height: 5.0,),

          GestureDetector(
            onTap: (){
              // Show location form rider current location towards seller location
              MapUtils.launchMapFromSourceToDestination(
                  position!.latitude,
                  position!.longitude,
                  widget.purchaserLat,
                  widget.purchaserLng,
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "images/restaurant.png",
                  width: 50,
                ),
                const SizedBox(width: 7,),
                const Column(
                  children: [
                    SizedBox(height: 10,),
                    Text(
                      "Show Delivery Drop-off Location",
                      style: TextStyle(
                        fontFamily: "Lexend",
                        fontSize: 18,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 15.0,),

          Padding(
            padding: const EdgeInsets.all(40.0),
            child: Center(
              child: InkWell(
                onTap: (){

                  //Rider location update
                  UserLocation uLocation = UserLocation();
                  uLocation.getCurrentLocation();
                  // confirmed - Rider has picked order from seller
                  confirmOrderHasBeenDelivered(
                      widget.getOrderId,
                      widget.sellerId,
                      widget.purchaserId,
                      widget.purchaserAddress,
                      widget.purchaserLat,
                      widget.purchaserLng
                  );
                },
                child: Container(
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
                  width: MediaQuery.of(context).size.width - 120,
                  height: 50,
                  child: const Center(
                    child: Text(
                      "Order has been Delivered - Confirm",
                      style: TextStyle(color: Colors.white, fontSize: 15.0),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
