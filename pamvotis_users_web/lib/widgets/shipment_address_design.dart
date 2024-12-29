import 'package:flutter/material.dart';
import '/mainScreens/home_screen.dart';
import '/models/address.dart';

class ShipmentAddressDesign extends StatelessWidget {
  final Address? model;
  final String? orderStatus;
  final String? orderId;
  final String? sellerId;
  final String? orderByUser;

  const ShipmentAddressDesign({
    Key? key,
    this.model,
    this.orderStatus,
    this.orderId,
    this.sellerId,
    this.orderByUser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          _buildAddressDetails(),
          _buildFullAddress(),
          _buildActionButton(context),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(15),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.location_on,
            color: Colors.blue.shade700,
            size: 24,
          ),
          const SizedBox(width: 10),
          const Text(
            "Shipping Details",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: "Lexend",
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressDetails() {
    return Container(
      padding: const EdgeInsets.all(15),
      child: Column(
        children: [
          _buildDetailRow("Name", model!.name!),
          const SizedBox(height: 10),
          _buildDetailRow("Phone", model!.phoneNumber!),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
              fontFamily: "Lexend",
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 16,
              fontFamily: "Lexend",
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFullAddress() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(
          top: BorderSide(
            color: Colors.grey.shade200,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Full Address",
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
              fontFamily: "Lexend",
            ),
          ),
          const SizedBox(height: 8),
          Text(
            model!.fullAddress!,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 16,
              fontFamily: "Lexend",
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.grey.shade200,
          ),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: orderStatus == "ended"
                ? Colors.blue
                : Colors.green,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (c) => const HomeScreen(),
              ),
            );
          },
          child: Text(
            orderStatus == "ended" ? "Go Back" : "Order Packing - Done",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontFamily: "Lexend",
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}