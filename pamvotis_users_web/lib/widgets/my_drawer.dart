import 'package:flutter/material.dart';
import '/authentication/auth_screen.dart';
import '/global/global.dart';
import '/mainScreens/address_screen.dart';
import '/mainScreens/history_screen.dart';
import '/mainScreens/home_screen.dart';
import '/mainScreens/my_orders_screen.dart';
import '/mainScreens/search_screen.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({Key? key}) : super(key: key);

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  String userName = "Guest User";
  String userEmail = "";
  String userPhotoUrl = "";

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    try {
      if (firebaseAuth.currentUser != null && sharedPreferences != null) {
        setState(() {
          userName = sharedPreferences!.getString("name") ?? "Guest User";
          userEmail = sharedPreferences!.getString("email") ?? "";
          userPhotoUrl = sharedPreferences!.getString("photoUrl") ?? "";
        });
      }
    } catch (error) {
      debugPrint("Error loading user data: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return NavigationDrawer(
      elevation: 16,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      onDestinationSelected: (int index) {
        // Close the drawer before navigation
        Navigator.pop(context);
        // Handle the navigation
        _handleNavigation(context, index);
      },
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 28, 16, 16),
          child: Column(
            children: [
              Material(
                borderRadius: const BorderRadius.all(Radius.circular(80)),
                elevation: 8,
                child: Container(
                  height: 160,
                  width: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(
                        userPhotoUrl.isNotEmpty
                            ? userPhotoUrl
                            : "https://placeholder.com/user.png",
                      ),
                      onError: (_, __) => const Icon(Icons.person),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                userName,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontFamily: "Lexend",
                ),
                textAlign: TextAlign.center,
              ),
              if (userEmail.isNotEmpty)
                Text(
                  userEmail,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
        const Divider(height: 1, thickness: 1),
        const NavigationDrawerDestination(
          icon: Icon(Icons.home),
          label: Text('Home'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.reorder),
          label: Text('My Orders'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.access_time),
          label: Text('History'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.search),
          label: Text('Search'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.add_location),
          label: Text('Add New Address'),
        ),
        const Divider(height: 1, thickness: 1),
        const NavigationDrawerDestination(
          icon: Icon(Icons.exit_to_app),
          label: Text('Sign Out'),
        ),
      ],
    );
  }

  void _handleNavigation(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (c) => const HomeScreen())
        );
        break;
      case 1:
        Navigator.push(
            context,
            MaterialPageRoute(builder: (c) => MyOrdersScreen())
        );
        break;
      case 2:
        Navigator.push(
            context,
            MaterialPageRoute(builder: (c) => HistoryScreen())
        );
        break;
      case 3:
        Navigator.push(
            context,
            MaterialPageRoute(builder: (c) => const SearchScreen())
        );
        break;
      case 4:
        Navigator.push(
            context,
            MaterialPageRoute(builder: (c) => AddressScreen())
        );
        break;
      case 5:
        _handleSignOut(context);
        break;
    }
  }

  Future<void> _handleSignOut(BuildContext context) async {
    try {
      // Clear shared preferences
      await sharedPreferences?.clear();

      // Sign out from Firebase
      await firebaseAuth.signOut();

      if (!mounted) return;

      // Navigate to auth screen
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (c) => const AuthScreen()),
            (route) => false,
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing out: $error')),
      );
    }
  }
}