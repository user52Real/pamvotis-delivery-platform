import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:image_picker/image_picker.dart';
import '../global/global.dart';
import '../mainScreens/home_screen.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/error_dialog.dart';
import '../widgets/loading_dialog.dart';
import 'package:firebase_storage/firebase_storage.dart' as f_storage;
import 'package:shared_preferences/shared_preferences.dart';


class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController locationController = TextEditingController();


  XFile? imageXFile;
  final ImagePicker _picker = ImagePicker();

  Position? position;
  List<Placemark>? placeMarks;

  String sellerImageUrl = "";
  String completeAddress = "";

  final places = GoogleMapsPlaces(apiKey: "AIzaSyCN6SwLrCWnMB0Y0TKRRR97MArZl6qG_zY");
  List<Prediction> _placesList = [];

  Future<void> _getImage() async {
    imageXFile = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      imageXFile;
    });
  }

  getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled');
    }

    // Check location permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
    }

    // Define location settings
    LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    // Get current position
    Position newPosition = await Geolocator.getCurrentPosition(
      locationSettings: locationSettings,
    );
    position = newPosition;

    // Get placemark from coordinates
    List<Placemark> placeMarksList = await placemarkFromCoordinates(
      position!.latitude,
      position!.longitude,
    );

    if (placeMarksList.isNotEmpty) {
      Placemark pMark = placeMarksList[0];
      completeAddress = '${pMark.subThoroughfare ?? ''} ${pMark.thoroughfare ?? ''}, '
          '${pMark.subLocality ?? ''} ${pMark.locality ?? ''}, '
          '${pMark.subAdministrativeArea ?? ''}, ${pMark.administrativeArea ?? ''} '
          '${pMark.postalCode ?? ''}, ${pMark.country ?? ''}';
    } else {
      completeAddress = 'Address not found';
    }
    locationController.text = completeAddress;

  }

  Future<void> _getAddressSuggestions(String input) async {
    if (input.isNotEmpty) {
      PlacesAutocompleteResponse response = await places.autocomplete(
        input,
        types: ['address'],
        components: [Component(Component.country, "gr")],
      );

      if (response.isOkay) {
        setState(() {
          _placesList = response.predictions;
        });
      }
    }
  }

  Future<void> formValidation() async{
    if(imageXFile == null){
      showDialog(
        context: context,
        builder: (c){
          return ErrorDialog(
            message: "Please select an image ",
          );
        }
      );
    }
    else {
      if(passwordController.text == confirmPasswordController.text){

        if(confirmPasswordController.text.isNotEmpty && emailController.text.isNotEmpty && nameController.text.isNotEmpty && phoneController.text.isNotEmpty && locationController.text.isNotEmpty){
          //start uploading the image
          showDialog(
            context: context,
            builder: (c) {
              return LoadingDialog(
                message: "Registering Account",
              );
            }
          );
          String fileName = DateTime.now().millisecondsSinceEpoch.toString();
          f_storage.Reference reference = f_storage.FirebaseStorage.instance.ref().child("sellers").child(fileName);
          f_storage.UploadTask uploadTask = reference.putFile(File(imageXFile!.path));
          f_storage.TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
          await taskSnapshot.ref.getDownloadURL().then((url) {
            sellerImageUrl = url;

            //save information to firestore
            authenticateSellerAndSignUp();
          });
        }
        else {
          showDialog(
              context: context,
              builder: (c){
                return ErrorDialog(
                  message: "Please fill the required info for the Registration.",
                );
              }
          );
        }
      }
      else {
        showDialog(
            context: context,
            builder: (c){
              return ErrorDialog(
                message: "Password do not match.",
              );
            }
        );
      }
    }
  }

  void authenticateSellerAndSignUp() async {
    User? currentUser;

    await firebaseAuth.createUserWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    ).then((auth) {
      currentUser = auth.user;
    }).catchError((error){
      Navigator.pop(context);
      showDialog(
          context: context,
          builder: (c){
            return ErrorDialog(
              message: error.message.toString(),
            );
          }
      );
    });
    if(currentUser != null){
      saveDataToFirestore(currentUser!).then((value) {
        Navigator.pop(context);
        //send user to home page
        Route newRoute = MaterialPageRoute(builder: (c) => const HomeScreen());
        Navigator.pushReplacement(context, newRoute);
      });
    }
  }

  Future saveDataToFirestore(User currentUser) async {
    FirebaseFirestore.instance.collection("sellers").doc(currentUser.uid).set({
      "sellerUID": currentUser.uid,
      "sellerEmail": currentUser.email,
      "sellerName": nameController.text.trim(),
      "sellerAvatarUrl": sellerImageUrl,
      "phone": phoneController.text.trim(),
      "address": locationController.text.trim(),
      "status": "approved",
      "earnings": 0.0,
      "lat": position!.latitude,
      "lng": position!.longitude,
    });

    // save data locally
    sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences!.setString("uid", currentUser.uid);
    await sharedPreferences!.setString("email", currentUser.email.toString());
    await sharedPreferences!.setString("name", nameController.text.trim());
    await sharedPreferences!.setString("photoUrl", sellerImageUrl);

  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            const SizedBox(height: 10,),
            InkWell(
              onTap: () {
                _getImage();
              },
              child: CircleAvatar(
                radius: MediaQuery.of(context).size.width * 0.20,
                backgroundColor: Colors.white,
                backgroundImage: imageXFile==null ? null : FileImage(File(imageXFile!.path)),
                child: imageXFile == null
                    ?
                Icon(
                  Icons.add_photo_alternate,
                  size: MediaQuery.of(context).size.width * 0.20,
                  color: Colors.grey,
                ) : null,
              ),
            ),
            const SizedBox(height: 10,),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  CustomTextField(
                    data: Icons.person,
                    controller: nameController,
                    hintText: "Name",
                    isObsecre: false,
                  ),
                  CustomTextField(
                    data: Icons.email,
                    controller: emailController,
                    hintText: "Email",
                    isObsecre: false,
                  ),
                  CustomTextField(
                    data: Icons.lock,
                    controller: passwordController,
                    hintText: "Password",
                    isObsecre: true,
                  ),
                  CustomTextField(
                    data: Icons.lock,
                    controller: confirmPasswordController,
                    hintText: "Confirm Password",
                    isObsecre: true,
                  ),
                  CustomTextField(
                    data: Icons.phone,
                    controller: phoneController,
                    hintText: "Phone",
                    isObsecre: false,
                  ),
                  Autocomplete<Prediction>(
                    optionsBuilder: (TextEditingValue textEditingValue) async {
                      if (textEditingValue.text.isEmpty) {
                        return const Iterable<Prediction>.empty();
                      }
                      await _getAddressSuggestions(textEditingValue.text);
                      return _placesList;
                    },
                    displayStringForOption: (Prediction option) => option.description!,
                    fieldViewBuilder: (BuildContext context, TextEditingController fieldTextEditingController,
                        FocusNode fieldFocusNode, VoidCallback onFieldSubmitted) {
                      return CustomTextField(
                        data: Icons.my_location,
                        controller: fieldTextEditingController,
                        hintText: "Cafe/Restaurant Address",
                        isObsecre: false,
                        focusNode: fieldFocusNode,
                      );
                    },
                    onSelected: (Prediction selection) async {
                      PlacesDetailsResponse detail = await places.getDetailsByPlaceId(selection.placeId!);
                      final lat = detail.result.geometry!.location.lat;
                      final lng = detail.result.geometry!.location.lng;

                      setState(() {
                        locationController.text = selection.description!;
                        position = Position(
                          latitude: lat,
                          longitude: lng,
                          timestamp: DateTime.now(),
                          accuracy: 0,
                          altitude: 0,
                          heading: 0,
                          speed: 0,
                          speedAccuracy: 0, altitudeAccuracy: 0.0,
                          headingAccuracy: 0.0,
                        );
                      });
                    },
                  ),
                  // CustomTextField(
                  //   data: Icons.my_location,
                  //   controller: locationController,
                  //   hintText: "Cafe/Restaurant Address",
                  //   isObsecre: false,
                  //   enabled: true,
                  // ),
                  Container(
                    width: 400,
                    height: 40,
                    alignment: Alignment.center,
                    child: ElevatedButton.icon(
                      label: const Text(
                        "Get my Current Location",
                        style: TextStyle(color: Colors.white),
                      ),
                      icon: const Icon(
                        Icons.location_on,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        getCurrentLocation();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30,),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow,
                padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 10)
              ),
              onPressed: () {
                formValidation();
              },
              child: const Text(
                "Sign Up",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,),
              ),
            ),
            const SizedBox(height: 30,),
          ],
        ),
      ),
    );
  }
}
