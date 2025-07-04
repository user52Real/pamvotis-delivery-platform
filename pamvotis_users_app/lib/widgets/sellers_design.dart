import 'package:flutter/material.dart';
import 'package:pamvotis_users_app/mainScreens/menus_screen.dart';
import 'package:pamvotis_users_app/models/sellers.dart';

class SellersDesignWidget extends StatefulWidget {

  Sellers? model;
  BuildContext? context;

  SellersDesignWidget({this.model, this.context});

  @override
  State<SellersDesignWidget> createState() => _SellersDesignWidgetState();
}

class _SellersDesignWidgetState extends State<SellersDesignWidget> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (c) => MenusScreen(model: widget.model)));
      },
      splashColor: Colors.blue,
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Container(
          height: 320,
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              Divider(
                height: 4,
                thickness: 3,
                color: Colors.grey[300],
              ),
              Image.network(
                  widget.model!.sellerAvatarUrl!,
                  height: 270.0,
                  fit: BoxFit.cover,
              ),
              const SizedBox(height: 2.0,),
              Text(
                widget.model!.sellerName!,
                style: const TextStyle(
                  color: Colors.blue,
                  fontSize: 20,
                  fontFamily: "Lexend",
                ),
              ),Divider(
                height: 4,
                thickness: 3,
                  color: Colors.grey[300],
              )
            ],
          ),
        ),
      ),
    );
  }
}
