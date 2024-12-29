import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '/models/sellers.dart';
import '/widgets/sellers_design.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  Future<QuerySnapshot>? restaurantsDocumentsList;
  String sellerNameText = "";
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void initSearchingRestaurant(String textEntered) {
    setState(() {
      restaurantsDocumentsList = FirebaseFirestore.instance
          .collection("sellers")
          .where("sellerName", isGreaterThanOrEqualTo: textEntered)
          .get();
    });
  }

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
                _buildSearchHeader(),
                Expanded(child: _buildSearchResults()),
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
      title: const Text(
        "Search",
        style: TextStyle(
          fontSize: 32,
          fontFamily: "Lexend",
        ),
      ),
      centerTitle: true,
      elevation: 0,
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (textEntered) {
          setState(() {
            sellerNameText = textEntered;
          });
          initSearchingRestaurant(textEntered);
        },
        style: const TextStyle(
          fontSize: 16,
          fontFamily: "Lexend",
        ),
        decoration: InputDecoration(
          hintText: "Search for Restaurant/Cafe",
          hintStyle: TextStyle(
            color: Colors.grey.shade600,
            fontFamily: "Lexend",
          ),
          prefixIcon: const Icon(Icons.search, color: Colors.blue),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear, color: Colors.blue),
            onPressed: () {
              _searchController.clear();
              setState(() {
                sellerNameText = "";
                restaurantsDocumentsList = null;
              });
            },
          )
              : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.blue.shade400),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return FutureBuilder<QuerySnapshot>(
      future: restaurantsDocumentsList,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              "Error: ${snapshot.error}",
              style: const TextStyle(
                color: Colors.red,
                fontFamily: "Lexend",
              ),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(15),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            Sellers model = Sellers.fromJson(
              snapshot.data!.docs[index].data()! as Map<String, dynamic>,
            );
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: SellersDesignWidget(
                model: model,
                context: context,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 100,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 20),
          Text(
            sellerNameText.isEmpty
                ? "Start searching for restaurants"
                : "No restaurants found",
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 20,
              fontFamily: "Lexend",
            ),
          ),
        ],
      ),
    );
  }
}