import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pamvotis_sellers_app/global/global.dart';
import 'package:pamvotis_sellers_app/model/menus.dart';
import 'package:pamvotis_sellers_app/uploadScreens/menus_upload_screen.dart';
import 'package:pamvotis_sellers_app/widgets/info_design.dart';
import 'package:pamvotis_sellers_app/widgets/my_drawer.dart';
import 'package:pamvotis_sellers_app/widgets/progress_bar.dart';
import 'package:pamvotis_sellers_app/widgets/text_widget_header.dart';

import '../splashScreen/splash_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  restrictBlockedSellers() async {
    await FirebaseFirestore.instance
        .collection("sellers")
        .doc(firebaseAuth.currentUser!.uid)
        .get().then((snapshot){
      if(snapshot.data()!["status"] != "approved"){
        Fluttertoast.showToast(msg: "You have been blocked by the Administrator");

        firebaseAuth.signOut();
        Navigator.push(context, MaterialPageRoute(builder: (c) => const MySplashScreen()));
      }
    });
  }

  @override
  void initState() {
    super.initState();

    restrictBlockedSellers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MyDrawer(),
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
          sharedPreferences!.getString("name")!.toUpperCase(),
          style: const TextStyle(fontSize: 30, fontFamily: "Lexend", color: Colors.white),
        ),
        centerTitle: true,
        automaticallyImplyLeading: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.post_add, color: Colors.white,),
            onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (c) => const MenusUploadScreen()));
            },
          )
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(pinned: true ,delegate: TextWidgetHeader(title: "Οι Καταλογοι μου")),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("sellers")
                .doc(sharedPreferences!.getString("uid"))
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
                        return InfoDesignWidget(
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
