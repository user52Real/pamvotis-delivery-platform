import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pamvotis_users_app/assistantMethods/assistant_methods.dart';
import 'package:pamvotis_users_app/assistantMethods/cart_item_counter.dart';
import 'package:pamvotis_users_app/assistantMethods/total_amount.dart';
import 'package:pamvotis_users_app/mainScreens/address_screen.dart';
import 'package:pamvotis_users_app/models/items.dart';
import 'package:pamvotis_users_app/splashScreen/splash_screen.dart';
import 'package:pamvotis_users_app/widgets/app_bar.dart';
import 'package:pamvotis_users_app/widgets/cart_item_design.dart';
import 'package:pamvotis_users_app/widgets/progress_bar.dart';
import 'package:pamvotis_users_app/widgets/text_widget_header.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatefulWidget {

  final String? sellerUID;

  CartScreen({this.sellerUID});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {

  List<int>? separateItemQuantityList;
  num totalAmount = 0;

  @override
  void initState() {
    super.initState();

    totalAmount = 0;
    Provider.of<TotalAmount>(context, listen: false).displayTotalAmount(0);

    separateItemQuantityList = separateItemQuantities();
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
        leading: IconButton(
          icon: const Icon(Icons.clear_all),
          onPressed: (){
            clearCartNow(context);
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
                icon: const Icon(Icons.shopping_cart, color: Colors.blue,),
                onPressed: (){
                  print("clicked");
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
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const SizedBox(width: 4,),
          Align(
            alignment: Alignment.bottomLeft,
            child: FloatingActionButton.extended(
              heroTag: "btn1",
              label: const Text("Clear Cart", style: TextStyle(fontSize: 16)),
              backgroundColor: Colors.blue,
              icon: const Icon(Icons.clear_all),
              onPressed: (){
                clearCartNow(context);
                Navigator.push(context, MaterialPageRoute(builder: (c) => const MySplashScreen()));

                Fluttertoast.showToast(msg: "Cart has been cleared");
              },
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: FloatingActionButton.extended(
              heroTag: "btn2",
              label: const Text("Check Out", style: TextStyle(fontSize: 16),),
              backgroundColor: Colors.blue,
              icon: const Icon(Icons.navigate_next),
              onPressed: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (c) => AddressScreen(
                        totalAmount: totalAmount.toDouble(),
                        sellerUID: widget.sellerUID,
                      )
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          //overall total price
          SliverPersistentHeader(
              pinned: true ,
              delegate: TextWidgetHeader(title: "My Cart List")
          ),
          SliverToBoxAdapter(
            child: Consumer2<TotalAmount, CartItemCounter>(
              builder: (context, amountProvider, cartProvider, c){
                return Padding(
                  padding: const EdgeInsets.all(2),
                  child: Center(
                    child: cartProvider.count == 0
                        ? Container()
                        : Text(
                          "Total Price:  ${amountProvider.tAmount.toString()}",
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                  ),
                );
              }
            ),
          ),

          //display cart items with quantity numbers
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("items")
                .where("itemID", whereIn: separateItemIDs())
                .orderBy("publishedDate", descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              return !snapshot.hasData
                  ? SliverToBoxAdapter(child: Center(child: circularProgress(),),)
                  : snapshot.data!.docs.isEmpty
                  ? //startBuildingCart()
                    Container()
                  : SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        Items model = Items.fromJson(
                          snapshot.data!.docs[index].data()! as Map<String, dynamic>,
                        );

                        if(index == 0){
                          totalAmount = 0;
                          totalAmount = totalAmount + (model.price! * separateItemQuantityList![index]);
                        }
                        else {
                          totalAmount = totalAmount + (model.price! * separateItemQuantityList![index]);
                        }

                        if(snapshot.data!.docs.length - 1 == index){
                          WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
                            Provider.of<TotalAmount>(context, listen: false).displayTotalAmount(totalAmount.toDouble());
                          });
                        }

                        return CartItemDesign(
                          model: model,
                          context: context,
                          quanNumber: separateItemQuantityList![index],
                        );
                      },
                          childCount: snapshot.hasData ? snapshot.data!.docs.length : 0,
                      ),
                    );
            },
          ),
        ],
      ),
    );
  }
}
