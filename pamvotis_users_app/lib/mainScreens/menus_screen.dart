import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:pamvotis_users_app/assistantMethods/assistant_methods.dart';
import 'package:pamvotis_users_app/models/menus.dart';
import 'package:pamvotis_users_app/models/sellers.dart';
import 'package:pamvotis_users_app/splashScreen/splash_screen.dart';
import 'package:pamvotis_users_app/widgets/menus_design.dart';
import 'package:pamvotis_users_app/widgets/progress_bar.dart';
import 'package:pamvotis_users_app/widgets/text_widget_header.dart';

class MenusScreen extends StatefulWidget {

  final Sellers? model;
  MenusScreen({this.model});

  @override
  State<MenusScreen> createState() => _MenusScreenState();
}

class _MenusScreenState extends State<MenusScreen> {
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            clearCartNow(context);
            Navigator.push(context, MaterialPageRoute(builder: (c) => const MySplashScreen()));
          },
        ),
        title: const Text(
          "Pamvotis",
          style: TextStyle(fontSize: 36, fontFamily: "Lexend", color: Colors.white),
        ),
        centerTitle: true,
        automaticallyImplyLeading: true,
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverPersistentHeader(
              pinned: true,
              delegate: TextWidgetHeader(
                  title: widget.model!.sellerName.toString() + " Menus",
              ),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("sellers")
                .doc(widget.model!.sellerUID)
                .collection("menus")
                .orderBy("publishedDate", descending: true)
                .snapshots(),
            builder: (context, snapshot){
              return !snapshot.hasData
                  ? SliverToBoxAdapter(
                child: Center(child: circularProgress(),),
              )
                  : SliverStaggeredGrid.countBuilder(
                    crossAxisCount: 1,
                    staggeredTileBuilder: (c) => const StaggeredTile.fit(1),
                    itemBuilder: (context, index){
                      Menus model = Menus.fromJson(
                        snapshot.data!.docs[index].data()! as Map<String, dynamic>
                      );
                      return MenusDesignWidget(
                        model: model,
                        context: context,
                      );
                    },
                    itemCount: snapshot.data!.docs.length,
                  );
            },
          ),
        ],
      ),
    );
  }
}
