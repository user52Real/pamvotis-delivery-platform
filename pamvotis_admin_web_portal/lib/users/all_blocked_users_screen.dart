import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pamvotis_admin_web_portal/main_screen/home_screen.dart';
import 'package:pamvotis_admin_web_portal/widgets/simple_app_bar.dart';

class AllBlockedUsersScreen extends StatefulWidget {
  const AllBlockedUsersScreen({super.key});

  @override
  State<AllBlockedUsersScreen> createState() => _AllBlockedUsersScreenState();
}

class _AllBlockedUsersScreenState extends State<AllBlockedUsersScreen> {

  QuerySnapshot? allUsers;

  displayDialogBoxForActivatingAccount(userDocumentID){
    return showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            title: const Text(
              "Activate Blocked User",
              style: TextStyle(
                fontSize: 25,
                letterSpacing: 2,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: const Text(
              "Do you want to unblock this account?",
              style: TextStyle(
                fontSize: 16,
                letterSpacing: 2,
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: (){
                  Navigator.pop(context);
                },
                child: const Text("No"),
              ),
              ElevatedButton(
                onPressed: (){
                  Map<String, dynamic> userDataMap = {
                    //blocked
                    "status": "approved",
                  };
                  FirebaseFirestore.instance
                      .collection("users")
                      .doc(userDocumentID)
                      .update(userDataMap)
                      .then((value){

                    Navigator.push(context, MaterialPageRoute(builder: (c) => const HomeScreen()));

                    SnackBar snackBar = const SnackBar(
                      content: Text(
                        "Unblocked Successfully.",
                        style: TextStyle(
                          fontSize: 36,
                          color: Colors.black,
                        ),
                      ),
                      backgroundColor: Colors.yellow,
                      duration: Duration(seconds: 2),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  });
                },
                child: const Text("Yes"),
              ),
            ],
          );
        }
    );
  }

  @override
  void initState() {
    super.initState();

    FirebaseFirestore.instance
        .collection("users")
        .where("status", isEqualTo: "not approved")
        .get()
        .then((approvedUsers){
      setState(() {
        allUsers = approvedUsers;
      });
    });
  }

  @override
  Widget build(BuildContext context) {

    Widget displayBlockedUserDesign(){
      if(allUsers != null){
        return ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: allUsers!.docs.length,
          itemBuilder: (context, i){
            return Card(
              elevation: 10,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: ListTile(
                      leading: Container(
                        width: 65,
                        height: 65,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: NetworkImage(allUsers!.docs[i].get("photoUrl")),
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                      title: Text(
                        allUsers!.docs[i].get("name"),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.email, color: Colors.black,),
                          const SizedBox(width: 20,),
                          Text(
                            allUsers!.docs[i].get("email"),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow,
                      ),
                      icon: const Icon(
                        Icons.person_pin_sharp,
                        color: Colors.white,
                      ),
                      label: Text(
                        "Activate this Account".toUpperCase(),
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                          letterSpacing: 3,
                        ),
                      ),
                      onPressed: (){
                        displayDialogBoxForActivatingAccount(allUsers!.docs[i].id);
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }
      else{
        return const Center(
          child: Text(
            "No record found.",
            style: TextStyle(
              fontSize: 30,
            ),
          ),
        );
      }
    }

    return Scaffold(
      appBar: SimpleAppBar(title: "All Blocked Users",),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * .5,
          child: displayBlockedUserDesign(),
        ),
      ),
    );
  }
}
