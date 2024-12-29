import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import '/global/global.dart';
import '/models/address.dart';

class SaveAddressScreen extends StatefulWidget {
  const SaveAddressScreen({super.key});

  @override
  State<SaveAddressScreen> createState() => _SaveAddressScreenState();
}

class _SaveAddressScreenState extends State<SaveAddressScreen> {
  final _name = TextEditingController();
  final _phoneNumber = TextEditingController();
  final _flatNumber = TextEditingController();
  final _city = TextEditingController();
  final _state = TextEditingController();
  final _completeAddress = TextEditingController();
  final _locationController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  List<Placemark>? placemarks;
  Position? position;

  Future<void> getUserLocationAddress() async {
    try {
      // Request location permission
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied');
      }

      // Check if location service is enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

      // Configure location settings
      const LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
      );

      // Get current position
      Position newPosition = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );

      position = newPosition;

      // Get address from coordinates
      placemarks = await placemarkFromCoordinates(
        position!.latitude,
        position!.longitude,
      );

      Placemark pMark = placemarks![0];

      String fullAddress = '${pMark.subThoroughfare} ${pMark.thoroughfare}, '
          '${pMark.subLocality} ${pMark.locality}, '
          '${pMark.subAdministrativeArea}, ${pMark.administrativeArea} '
          '${pMark.postalCode}, ${pMark.country}';

      _locationController.text = fullAddress;
      _flatNumber.text =
      '${pMark.subThoroughfare} ${pMark.thoroughfare}, ${pMark.subLocality} ${pMark.locality}';
      _city.text =
      '${pMark.subAdministrativeArea}, ${pMark.administrativeArea} ${pMark.postalCode}';
      _state.text = '${pMark.country}';
      _completeAddress.text = fullAddress;
    } catch (e) {
      Fluttertoast.showToast(msg: "Error getting location: ${e.toString()}");
    }
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
        floatingActionButton: _buildSaveButton(),
        body: Center(
          child: Container(
            margin: const EdgeInsets.all(20),
            constraints: const BoxConstraints(maxWidth: 800),
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 20),
                    _buildLocationSection(),
                    const SizedBox(height: 30),
                    _buildAddressForm(),
                  ],
                ),
              ),
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
        "Add New Address",
        style: TextStyle(fontSize: 32, fontFamily: "Lexend"),
      ),
      centerTitle: true,
      elevation: 0,
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(Icons.location_on, color: Colors.blue.shade700),
          const SizedBox(width: 10),
          const Text(
            "Delivery Address",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: "Lexend",
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          controller: _locationController,
          hint: "Your current location",
          prefixIcon: Icons.location_on,
          readOnly: true,
        ),
        const SizedBox(height: 15),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: getUserLocationAddress,
            icon: const Icon(Icons.my_location),
            label: const Text(
              "Get Current Location",
              style: TextStyle(
                fontFamily: "Lexend",
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddressForm() {
    return Column(
      children: [
        _buildTextField(
          controller: _name,
          hint: "Full Name",
          prefixIcon: Icons.person,
        ),
        const SizedBox(height: 15),
        _buildTextField(
          controller: _phoneNumber,
          hint: "Phone Number",
          prefixIcon: Icons.phone,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 15),
        _buildTextField(
          controller: _city,
          hint: "City",
          prefixIcon: Icons.location_city,
        ),
        const SizedBox(height: 15),
        _buildTextField(
          controller: _state,
          hint: "State / Country",
          prefixIcon: Icons.map,
        ),
        const SizedBox(height: 15),
        _buildTextField(
          controller: _flatNumber,
          hint: "Address Line",
          prefixIcon: Icons.home,
        ),
        const SizedBox(height: 15),
        _buildTextField(
          controller: _completeAddress,
          hint: "Complete Address",
          prefixIcon: Icons.location_on,
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData prefixIcon,
    bool readOnly = false,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: const TextStyle(
          fontFamily: "Lexend",
          fontSize: 16,
        ),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(prefixIcon, color: Colors.blue),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $hint';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildSaveButton() {
    return FloatingActionButton.extended(
      backgroundColor: Colors.blue,
      onPressed: () async {
        if (formKey.currentState!.validate()) {
          try {
            if (position == null) {
              throw Exception("Please get your location first");
            }

            final model = Address(
              name: _name.text.trim(),
              state: _state.text.trim(),
              fullAddress: _completeAddress.text.trim(),
              phoneNumber: _phoneNumber.text.trim(),
              flatNumber: _flatNumber.text.trim(),
              city: _city.text.trim(),
              lat: position!.latitude,
              lng: position!.longitude,
            ).toJson();

            await FirebaseFirestore.instance
                .collection("users")
                .doc(sharedPreferences!.getString("uid"))
                .collection("userAddress")
                .doc(DateTime.now().millisecondsSinceEpoch.toString())
                .set(model);

            Fluttertoast.showToast(msg: "Address saved successfully!");
            formKey.currentState!.reset();
          } catch (e) {
            Fluttertoast.showToast(msg: e.toString());
          }
        }
      },
      icon: const Icon(Icons.save),
      label: const Text(
        "Save Address",
        style: TextStyle(
          fontFamily: "Lexend",
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}