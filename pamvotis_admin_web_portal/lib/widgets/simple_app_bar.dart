import 'package:flutter/material.dart';
import 'package:pamvotis_admin_web_portal/main_screen/home_screen.dart';

class SimpleAppBar extends StatelessWidget implements PreferredSizeWidget{

  String? title;
  final PreferredSizeWidget? bottom;

  SimpleAppBar({this.bottom, this.title});

  @override
  Size get preferredSize => bottom == null ? Size(56, AppBar().preferredSize.height) : Size(56, 80 + AppBar().preferredSize.height);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      iconTheme: const IconThemeData(
        color: Colors.white,
      ),
      flexibleSpace: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.blue,
                Colors.yellow,
              ],
              begin: FractionalOffset(0.0, 0.0),
              end: FractionalOffset(1.0, 0.0),
              stops: [0.0, 1.0],
              tileMode: TileMode.clamp,
            )
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white,),
        onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (c) => const HomeScreen()));
        },
      ),
      title: Text(
        title!,
        style: const TextStyle(fontSize: 20, letterSpacing: 3),
      ),
      centerTitle: true,
      backgroundColor: Colors.blue,
    );
  }
}
