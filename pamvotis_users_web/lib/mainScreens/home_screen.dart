import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import '../assistantMethods/cart_item_counter.dart';
import '/assistantMethods/assistant_methods.dart';
import '/global/global.dart';
import '/models/sellers.dart';
import '/splashScreen/splash_screen.dart';
import '/widgets/sellers_design.dart';
import '/widgets/my_drawer.dart';
import '/widgets/progress_bar.dart';
import '/mainScreens/menus_screen.dart';
import 'cart_screen.dart'; // Add this import

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int _currentImageIndex = 0;
  late Stream<List<Sellers>> sellersStream;
  late AnimationController _animationController;
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    restrictBlockedUsers();
    sellersStream = fetchSellers();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Stream<List<Sellers>> fetchSellers() async* {
    while (true) {
      final QuerySnapshot sellersSnapshot = await FirebaseFirestore.instance
          .collection("sellers")
          .get();
      List<Sellers> sellers = sellersSnapshot.docs
          .map((doc) => Sellers.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
      yield sellers;
      await Future.delayed(const Duration(seconds: 5));
    }
  }

  Future<void> restrictBlockedUsers() async {
    try {
      final currentUser = firebaseAuth.currentUser;
      if (currentUser == null) {
        await _handleBlockedUser();
        return;
      }

      final snapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUser.uid)
          .get();

      if (!mounted) return;

      if (!snapshot.exists || snapshot.data() == null) {
        await _handleBlockedUser();
        return;
      }

      final userData = snapshot.data()!;
      if (userData["status"] != "approved") {
        await _handleBlockedUser();
      } else {
        clearCartNow(context);
      }
    } catch (e) {
      debugPrint("Error checking user status: $e");
      if (!mounted) return;
      await _handleBlockedUser();
    }
  }

  Future<void> _handleBlockedUser() async {
    try {
      Fluttertoast.showToast(
        msg: "You have been blocked by the Administrator",
        webPosition: "center",
        timeInSecForIosWeb: 4,
      );
      await firebaseAuth.signOut();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (c) => const MySplashScreen()),
      );
    } catch (e) {
      debugPrint("Error handling blocked user: $e");
    }
  }

  void _navigateToMenuScreen(Sellers seller) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MenusScreen(model: seller),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      drawer: MediaQuery.of(context).size.width < 800 ? const MyDrawer() : null,
      body: Row(
        children: [
          if (MediaQuery.of(context).size.width >= 800)
            const SizedBox(width: 250, child: MyDrawer()),
          Expanded(child: _buildBody()),
        ],
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
        icon: const Icon(Icons.menu),
        onPressed: () {
          Scaffold.of(context).openDrawer();
        },
      ),
      title: const Text(
        "Pamvotis",
        style: TextStyle(
          fontSize: 32,
          fontFamily: "Lexend",
        ),
      ),
      centerTitle: true,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: _buildCartIcon(),
        ),
      ],
    );
  }

  Widget _buildCartIcon() {
    return Stack(
      clipBehavior: Clip.none, // Allow badge to overflow
      children: [
        IconButton(
          icon: const Icon(
            Icons.shopping_cart,
            color: Colors.white,
            size: 28,
          ),
          onPressed: () {
            // Check if cart is empty
            if (sharedPreferences!.getStringList("userCart")!.length == 1) {
              Fluttertoast.showToast(msg: "Cart is empty");
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (c) => CartScreen()),
              );
            }
          },
        ),
        Positioned(
          bottom: -8, // Position below the icon
          right: 0,
          left: 0,
          child: Consumer<CartItemCounter>(
            builder: (context, counter, _) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.white,
                    width: 1,
                  ),
                ),
                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: Text(
                  counter.count.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeroSection(),
          _buildCategories(),
          _buildPopularSellers(),
          _buildAllSellers(),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.4,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue.shade700, Colors.purple.shade700],
        ),
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "What would you like to order?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width < 600 ? 24 : 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 20),
              _buildSearchBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          // Implement search functionality
          setState(() {
            // Filter sellers based on search
          });
        },
        decoration: InputDecoration(
          hintText: "Search restaurants...",
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildCategories() {
    final categories = [
      {'icon': Icons.restaurant, 'name': 'Restaurants'},
      {'icon': Icons.local_pizza, 'name': 'Fast Food'},
      {'icon': Icons.local_cafe, 'name': 'Cafe'},
      {'icon': Icons.bakery_dining, 'name': 'Bakery'},
    ];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Categories",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: MediaQuery.of(context).size.width > 800 ? 4 : 2,
              childAspectRatio: 1.5,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              return _buildCategoryCard(
                categories[index]['icon'] as IconData,
                categories[index]['name'] as String,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(IconData icon, String name) {
    return InkWell( // Changed from MouseRegion to InkWell
      onTap: () {
        // Implement category filter
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: Colors.blue),
            const SizedBox(height: 8),
            Text(
              name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularSellers() {
    return StreamBuilder<List<Sellers>>(
      stream: sellersStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_hasError) {
          return const Center(
            child: Text('Something went wrong. Please try again.'),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Popular Restaurants",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () => _navigateToMenuScreen(snapshot.data![index]),
                      child: _buildPopularSellerCard(snapshot.data![index]),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPopularSellerCard(Sellers seller) {
    return Container(
      width: 300,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              seller.sellerAvatarUrl!,
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  seller.sellerName!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "⭐ 4.5 • 20-30 min",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllSellers() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection("sellers").snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "All Restaurants",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: _getGridCrossAxisCount(MediaQuery.of(context).size.width),
                  childAspectRatio: 0.8,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                ),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  Sellers seller = Sellers.fromJson(
                    snapshot.data!.docs[index].data() as Map<String, dynamic>,
                  );
                  return InkWell(
                    onTap: () => _navigateToMenuScreen(seller),
                    child: _buildSellerCard(seller),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSellerCard(Sellers seller) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (c) => MenusScreen(model: seller),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                seller.sellerAvatarUrl!,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 150,
                    color: Colors.grey[100],
                    child: const Center(
                      child: Icon(Icons.error_outline, color: Colors.grey),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    seller.sellerName!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "⭐ 4.5 • 20-30 min",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Free delivery",
                    style: TextStyle(
                      color: Colors.green[600],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _getGridCrossAxisCount(double width) {
    if (width > 1200) return 4;
    if (width > 800) return 3;
    if (width > 600) return 2;
    return 1;
  }

}