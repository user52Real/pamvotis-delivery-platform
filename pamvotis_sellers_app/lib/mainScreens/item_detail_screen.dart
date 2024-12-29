import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pamvotis_sellers_app/global/global.dart';
import 'package:pamvotis_sellers_app/mainScreens/home_screen.dart';
import 'package:pamvotis_sellers_app/widgets/simple_app_bar.dart';

import '../model/items.dart';

class ItemDetailScreen extends StatefulWidget {

  final Items? model;
  ItemDetailScreen({this.model});

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}


class _ItemDetailScreenState extends State<ItemDetailScreen> {

  TextEditingController counterTextEditingController = TextEditingController();

  deleteItem(String itemID){
    FirebaseFirestore.instance
        .collection("sellers")
        .doc(sharedPreferences!.getString("uid"))
        .collection("menus")
        .doc(widget.model!.menuID!)
        .collection("items")
        .doc(itemID)
        .delete().then((value) {
          FirebaseFirestore.instance
              .collection("items")
              .doc(itemID)
              .delete();
          Navigator.push(context, MaterialPageRoute(builder: (c) => const HomeScreen()));
          Fluttertoast.showToast(msg: "Item Deleted Successfully");
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SimpleAppBar(title: sharedPreferences!.getString("name"),),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Image.network(widget.model!.thumbnailUrl.toString())),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              widget.model!.title.toString(),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              widget.model!.longDescription.toString(),
              textAlign: TextAlign.justify,
              style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "€ " + widget.model!.price.toString(),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
            ),
          ),
          const SizedBox(height: 10,),
          Center(
            child: InkWell(
              onTap: (){
                // Delete item
                deleteItem(widget.model!.itemID!);
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
                width: MediaQuery.of(context).size.width - 180,
                height: 50,
                child: const Center(
                  child: Text(
                    "Delete Item",
                    style: TextStyle(color: Colors.white, fontSize: 15),
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
