import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '/assistantMethods/assistant_methods.dart';
import '/global/global.dart';
import '/widgets/order_card.dart';
import '/widgets/progress_bar.dart';

class HistoryScreen extends StatefulWidget {
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Colors.blue.shade400,
            Colors.blue.shade600,
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: _buildAppBar(),
        body: Center(
          child: Container(
            margin: const EdgeInsets.all(20),
            constraints: const BoxConstraints(maxWidth: 1200),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: _buildOrdersList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blue.shade400,
              Colors.blue.shade600,
            ],
            begin: const FractionalOffset(0.0, 0.0),
            end: const FractionalOffset(1.0, 0.0),
          ),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        "Order History",
        style: TextStyle(
          fontSize: 32,
          fontFamily: "Lexend",
        ),
      ),
      centerTitle: true,
      elevation: 0,
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
      ),
      child: const Row(
        children: [
          Icon(Icons.history, size: 30, color: Colors.blue),
          SizedBox(width: 10),
          Text(
            "Past Orders",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: "Lexend",
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("users")
          .doc(sharedPreferences!.getString("uid"))
          .collection("orders")
          .where("status", isEqualTo: "ended")
          .orderBy("orderTime", descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: circularProgress());
        }

        if (snapshot.data!.docs.isEmpty) {
          return _buildEmptyHistory();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(15),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance
                    .collection("items")
                    .where(
                  "itemID",
                  whereIn: separateOrderItemIDs(
                    (snapshot.data!.docs[index].data()!
                    as Map<String, dynamic>)["productIDs"],
                  ),
                )
                    .where(
                  "orderBy",
                  whereIn: (snapshot.data!.docs[index].data()!
                  as Map<String, dynamic>)["uid"],
                )
                    .orderBy("publishedDate", descending: true)
                    .get(),
                builder: (context, snap) {
                  if (!snap.hasData) {
                    return Center(child: circularProgress());
                  }

                  return OrderCard(
                    itemCount: snap.data!.docs.length,
                    data: snap.data!.docs,
                    orderID: snapshot.data!.docs[index].id,
                    separateQuantitiesList: separateOrderItemQuantities(
                      (snapshot.data!.docs[index].data()!
                      as Map<String, dynamic>)["productIDs"],
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyHistory() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_outlined,
            size: 100,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 20),
          Text(
            "No order history yet",
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 24,
              fontFamily: "Lexend",
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Your completed orders will appear here",
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 16,
              fontFamily: "Lexend",
            ),
          ),
        ],
      ),
    );
  }
}