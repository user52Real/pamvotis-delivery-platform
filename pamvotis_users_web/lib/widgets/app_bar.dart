import 'package:flutter/material.dart';
import '/assistantMethods/cart_item_counter.dart';
import '/mainScreens/cart_screen.dart';
import 'package:provider/provider.dart';

class MyAppBar extends StatefulWidget implements PreferredSizeWidget{

  final PreferredSizeWidget? bottom;
  final String? sellerUID;

  MyAppBar({this.bottom, this.sellerUID});

  @override
  State<MyAppBar> createState() => _MyAppBarState();

  @override
  Size get preferredSize => bottom == null ? Size(56, AppBar().preferredSize.height) : Size(56, 80 + AppBar().preferredSize.height);
}

class _MyAppBarState extends State<MyAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
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
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: (){
          Navigator.pop(context);
        },
      ),
      title: const Text(
        "Pamvotis",
        style: TextStyle(fontSize: 45, fontFamily: "Lexend"),
      ),
      centerTitle: true,
      automaticallyImplyLeading: true,
      actions: [
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.shopping_cart, color: Colors.yellow,),
              onPressed: (){
                // send user to cart screen
                Navigator.push(context, MaterialPageRoute(builder: (c) => CartScreen(sellerUID: widget.sellerUID)));
              },
            ),
             Positioned(
              child: Stack(
                children: [
                  const Icon(
                    Icons.brightness_1,
                    size: 20.0,
                    color: Colors.yellow,
                  ),
                  Positioned(
                    top: 3,
                    right: 4,
                    child: Center(
                      child: Consumer<CartItemCounter>(
                        builder: (context, counter, c) {
                          return Text(
                            counter.count.toString(),
                            style: const TextStyle(color: Colors.blue, fontSize: 12),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
