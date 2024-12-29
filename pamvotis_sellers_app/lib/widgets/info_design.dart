import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pamvotis_sellers_app/global/global.dart';
import 'package:pamvotis_sellers_app/mainScreens/items_screen.dart';
import 'package:pamvotis_sellers_app/model/menus.dart';

class InfoDesignWidget extends StatefulWidget {

  Menus? model;
  BuildContext? context;

  InfoDesignWidget({this.model, this.context});

  @override
  State<InfoDesignWidget> createState() => _InfoDesignWidgetState();
}

class _InfoDesignWidgetState extends State<InfoDesignWidget> {
  
  deleteMenu(String menuID){
    FirebaseFirestore.instance.collection("sellers")
        .doc(sharedPreferences!.getString("uid"))
        .collection("menus")
        .doc(menuID)
        .delete();

    Fluttertoast.showToast(msg: "Menu Deleted Successfully");
  }
  
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (c) => ItemsScreen(model: widget.model)));
      },
      splashColor: Colors.blue,
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Container(
          height: 380,
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              Divider(
                height: 4,
                thickness: 3,
                color: Colors.grey[300],
              ),
              Image.network(
                  widget.model!.thumbnailUrl!,
                  height: 270.0,
                  fit: BoxFit.cover,
              ),
              const SizedBox(height: 2.0,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.model!.menuTitle!,
                    style: const TextStyle(
                      color: Colors.blue,
                      fontSize: 20,
                      fontFamily: "Lexend",
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_sweep,
                      color: Colors.pinkAccent,
                    ),
                    onPressed: (){
                      // delete menu
                      deleteMenu(widget.model!.menuID!);
                    },
                  ),
                ],
              ),
              // Text(
              //   widget.model!.menuInfo!,
              //   style: const TextStyle(
              //     color: Colors.blue,
              //     fontSize: 20,
              //     fontFamily: "Train",
              //   ),
              //
              // ),
              Divider(
                height: 4,
                thickness: 3,
                  color: Colors.grey[300],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
