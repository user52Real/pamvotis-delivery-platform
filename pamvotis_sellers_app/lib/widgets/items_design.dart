import 'package:flutter/material.dart';
import 'package:pamvotis_sellers_app/mainScreens/item_detail_screen.dart';
import 'package:pamvotis_sellers_app/model/items.dart';

class ItemsDesignWidget extends StatefulWidget {

  Items? model;
  BuildContext? context;

  ItemsDesignWidget({this.model, this.context});

  @override
  State<ItemsDesignWidget> createState() => _ItemsDesignWidgetState();
}

class _ItemsDesignWidgetState extends State<ItemsDesignWidget> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (c) => ItemDetailScreen(model: widget.model)));
      },
      splashColor: Colors.blue,
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Container(
          height: 350,
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              Divider(
                height: 4,
                thickness: 3,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 1.0,),
              Text(
                widget.model!.title!,
                style: const TextStyle(
                  color: Colors.blue,
                  fontSize: 18,
                  fontFamily: "Train",
                ),
              ),
              const SizedBox(height: 2.0,),
              Image.network(
                widget.model!.thumbnailUrl!,
                height: 270.0,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 2.0,),
              Text(
                widget.model!.shortInfo!,
                style: const TextStyle(
                  color: Colors.blue,
                  fontSize: 20,
                  fontFamily: "Train",
                ),
              ),
              const SizedBox(height: 1.0,),
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
