import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/payment_service.dart';
import '../widgets/loading_dialog.dart';
import '../widgets/error_dialog.dart';
import '/assistantMethods/address_changer.dart';
import '/global/global.dart';
import '/mainScreens/save_address_screen.dart';
import '/models/address.dart';
import '/widgets/address_design.dart';
import '/widgets/progress_bar.dart';
import 'package:provider/provider.dart';

class AddressScreen extends StatefulWidget {
  final double? totalAmount;
  final String? sellerUID;
  final String? paymentMethod;

  AddressScreen({
    this.totalAmount,
    this.sellerUID,
    this.paymentMethod = "cash_on_delivery",
  });

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  PaymentMethod _selectedPaymentMethod = PaymentMethod.cash;

  Widget _buildPaymentMethodSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Select Payment Method",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: "Lexend",
            ),
          ),
          const SizedBox(height: 8),
          RadioListTile<PaymentMethod>(
            title: const Text('Cash on Delivery'),
            value: PaymentMethod.cash,
            groupValue: _selectedPaymentMethod,
            onChanged: (PaymentMethod? value) {
              setState(() {
                _selectedPaymentMethod = value!;
              });
            },
          ),
          RadioListTile<PaymentMethod>(
            title: const Text('Pay with Card'),
            value: PaymentMethod.stripe,
            groupValue: _selectedPaymentMethod,
            onChanged: (PaymentMethod? value) {
              setState(() {
                _selectedPaymentMethod = value!;
              });
            },
          ),
        ],
      ),
    );
  }

  Future<void> _processPayment() async {
    if (_selectedPaymentMethod == PaymentMethod.stripe) {
      try {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (c) => LoadingDialog(message: "Processing Payment"),
        );

        await PaymentService.makeStripePayment(
          totalAmount: widget.totalAmount!,
          context: context,
          onSuccess: () async {
            Navigator.pop(context); // Dismiss loading dialog
            _placeOrder("paid");
          },
        );
      } catch (e) {
        Navigator.pop(context); // Dismiss loading dialog
        showDialog(
          context: context,
          builder: (c) => ErrorDialog(message: e.toString()),
        );
      }
    } else {
      _placeOrder("cash_on_delivery");
    }
  }

  void _placeOrder(String paymentStatus) {
    String orderId = DateTime.now().millisecondsSinceEpoch.toString();

    writeOrderDetailsForUser({
      "addressID": Address.selectedAddress.toString(),
      "totalAmount": widget.totalAmount,
      "orderBy": sharedPreferences!.getString("uid"),
      "productIDs": sharedPreferences!.getStringList("userCart"),
      "paymentStatus": paymentStatus,
      "orderTime": orderId,
      "isSuccess": true,
      "sellerUID": widget.sellerUID,
      "riderUID": "",
      "status": "normal",
      "orderId": orderId,
    });

    writeOrderDetailsForSeller({
      "addressID": Address.selectedAddress.toString(),
      "totalAmount": widget.totalAmount,
      "orderBy": sharedPreferences!.getString("uid"),
      "productIDs": sharedPreferences!.getStringList("userCart"),
      "paymentStatus": paymentStatus,
      "orderTime": orderId,
      "isSuccess": true,
      "sellerUID": widget.sellerUID,
      "riderUID": "",
      "status": "normal",
      "orderId": orderId,
    });
  }

  void writeOrderDetailsForUser(Map<String, dynamic> data) async {
    // Get the payment status based on selected payment method
    String paymentStatus = _selectedPaymentMethod == PaymentMethod.cash
        ? "cash_on_delivery"
        : "paid";

    await FirebaseFirestore.instance
        .collection("users")
        .doc(sharedPreferences!.getString("uid"))
        .collection("orders")
        .doc(data["orderId"])
        .set({
      ...data,
      "paymentStatus": paymentStatus, // Use paymentStatus instead of paymentMethod
    });
  }

  Future<void> writeOrderDetailsForSeller(Map<String, dynamic> data) async {
    // Get the payment status based on selected payment method
    String paymentStatus = _selectedPaymentMethod == PaymentMethod.cash
        ? "cash_on_delivery"
        : "paid";

    await FirebaseFirestore.instance
        .collection("orders")
        .doc(data["orderId"])
        .set({
      ...data,
      "paymentStatus": paymentStatus, // Use paymentStatus instead of paymentMethod
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
        appBar: AppBar(
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
            "Pamvotis",
            style: TextStyle(fontSize: 32, fontFamily: "Lexend"),
          ),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton.extended(
          label: const Text(
            "Add New Address",
            style: TextStyle(
              fontFamily: "Lexend",
              color: Colors.black87,
            ),
          ),
          backgroundColor: Colors.yellow,
          icon: const Icon(Icons.add_location, color: Colors.blue),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (c) => SaveAddressScreen()),
            );
          },
        ),
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
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    "Select Address",
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      fontFamily: "Lexend",
                    ),
                  ),
                ),
                Expanded(
                  child: Consumer<AddressChanger>(
                    builder: (context, address, c) {
                      return StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection("users")
                            .doc(sharedPreferences!.getString("uid"))
                            .collection("userAddress")
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Center(child: circularProgress());
                          }
                          if (snapshot.data!.docs.isEmpty) {
                            return const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.location_off,
                                    size: 70,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    "No addresses found",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 20,
                                      fontFamily: "Lexend",
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          return ListView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: AddressDesign(
                                  currentIndex: address.count,
                                  value: index,
                                  addressId: snapshot.data!.docs[index].id,
                                  totalAmount: widget.totalAmount,
                                  sellerUID: widget.sellerUID,
                                  paymentMethod: widget.paymentMethod,
                                  model: Address.fromJson(
                                    snapshot.data!.docs[index].data()!
                                    as Map<String, dynamic>,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
                _buildPaymentMethodSelector(),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 50,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _processPayment,
                    child: Text(
                      _selectedPaymentMethod == PaymentMethod.cash
                          ? "Place Order (Cash on Delivery)"
                          : "Pay with Card",
                      style: const TextStyle(
                        fontSize: 16,
                        fontFamily: "Lexend",
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum PaymentMethod { cash, stripe }